import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:octagon/screen/setting/your_groups_screen.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:octagon/services/group_thread_service.dart';

class UpdateGroupController extends GetxController {
  var isLoading = false.obs;
  var isUpdating = false.obs;
  var groupData = Rxn<GroupModel>();
  final GroupThreadService _threadService = GroupThreadService();

  // Text controllers
  final titleController = TextEditingController();
  final optionsController = TextEditingController();
  final dateController = TextEditingController();
  final descriptionController = TextEditingController();

  // Image related
  var selectedImage = Rx<File?>(null);
  var isCompressing = false.obs;
  var isPrivate = false.obs;
  var isCreatingThread = false.obs;

  // Group ID
  String? groupId;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    titleController.dispose();
    optionsController.dispose();
    dateController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  RxInt groupMembers = 0.obs;
  // Fetch group details by ID
  Future<void> fetchGroupDetails(String groupId) async {
    this.groupId = groupId;
    await Future.delayed(Duration.zero);
    isLoading.value = true;

    final storage = GetStorage();
    final token = storage.read("token");

    if (token == null) {
      print("No token found in storage");
      isLoading.value = false;
      return;
    }

    var headers = {'Authorization': 'Bearer $token'};

    var request = http.MultipartRequest('POST', Uri.parse('http://3.134.119.154/api/user-groups-get-by-id'));
    request.fields.addAll({'group_id': groupId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      var data = json.decode(responseBody);

      if (data['success'] != null && data['success'].isNotEmpty) {
        var groupJson = data['success']["0"];

        groupData.value = GroupModel.fromJson(groupJson);

        // Populate form fields
        titleController.text = groupData.value!.title;
        optionsController.text = groupData.value!.options == '""' ? "" : groupData.value!.options;
        dateController.text = groupData.value!.dates;
        descriptionController.text = groupData.value!.description == '""' ? "" : groupData.value!.description;
        isPrivate.value = groupData.value!.isPublic == "0" ? false : true;
        groupMembers.value = data["success"]["members_count"];

        print("Group details loaded successfully");
      } else {
        print("No group data found");
        Get.snackbar("Error", "No group data found");
      }
    } else {
      print(response.reasonPhrase);
      Get.snackbar("Error", "Failed to load group details");
    }

    isLoading.value = false;
  }

  // Show image picker options
  void showImagePickerOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Pick from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      print("Image picker error: $e");
      Get.snackbar("Error", "Failed to open gallery.");
    }
  }

  // Compress image
  Future<void> compressImage(File file) async {
    try {
      isCompressing.value = true;
      final dir = await getTemporaryDirectory();
      final targetPath = join(dir.absolute.path, "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg");

      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 75,
      );

      if (result != null) {
        selectedImage.value = File(result.path);
      }
    } catch (e) {
      print('Error compressing image: $e');
      Get.snackbar('Error', 'Failed to compress image');
    } finally {
      isCompressing.value = false;
    }
  }

  // Update group
  Future<void> updateGroup(BuildContext context) async {
    if (groupId == null) {
      Get.snackbar("Error", "Group ID not found");
      return;
    }

    if (titleController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter group title");
      return;
    }

    isUpdating.value = true;

    try {
      final storage = GetStorage();
      final token = storage.read("token");

      if (token == null) {
        Get.snackbar("Error", "No token found");
        isUpdating.value = false;
        return;
      }

      var headers = {'Authorization': 'Bearer $token'};

      var request = http.MultipartRequest('POST', Uri.parse('http://3.134.119.154/api/user-groups-update'));

      // Add fields
      request.fields.addAll({
        'title': titleController.text.trim(),
        'options': optionsController.text.trim().isEmpty ? '""' : optionsController.text.trim(),
        'dates': dateController.text.trim(),
        'description': descriptionController.text.trim().isEmpty ? '""' : descriptionController.text.trim(),
        'group_id': groupId!,
        'public_private': isPrivate.value ? '1' : '0',
      });

      // Add image if selected
      if (selectedImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', selectedImage.value!.path));
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var data = json.decode(responseBody);

        Get.back();
        Get.snackbar("Success", "Group updated successfully", backgroundColor: Colors.green, colorText: Colors.white);

        // Navigate back
      } else {
        print(response.reasonPhrase);
        Get.snackbar("Error", "Failed to update group");
      }
    } catch (e) {
      print("Error updating group: $e");
      Get.snackbar("Error", "Failed to update group: $e");
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> ensureChatThread() async {
    if (groupId == null || isCreatingThread.value) return;
    final currentGroup = groupData.value;
    if (currentGroup == null) return;
    if (currentGroup.threadId.isNotEmpty) {
      Get.snackbar("Chat Thread", "Chat is already enabled for this group");
      return;
    }

    isCreatingThread.value = true;
    try {
      final threadId = await _threadService.createThreadForGroup(groupId!);
      groupData.value = currentGroup.copyWith(threadId: threadId);
      groupData.refresh();
      Get.snackbar("Success", "Chat thread created for this group");
    } catch (e) {
      Get.snackbar("Error", "Failed to create chat thread");
    } finally {
      isCreatingThread.value = false;
    }
  }
}

class GroupModel {
  final int id;
  final int userId;
  final String title;
  final String options;
  final String dates;
  final String description;
  final String? photo;
  final String isPublic;
  final String createdAt;
  final String? updatedAt;
  final String isDeleted;
  final String threadId;

  GroupModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.options,
    required this.dates,
    required this.description,
    required this.photo,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.threadId,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      options: json['options'] ?? '',
      dates: json['dates'] ?? '',
      description: json['description'] ?? '',
      photo: json['photo'],
      isPublic: json['is_public'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
      isDeleted: json['is_deleted'] ?? '',
      threadId: json['thread_id'] == null || json['thread_id'].toString().toLowerCase() == 'null' ? '' : json['thread_id'].toString(),
    );
  }

  GroupModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? options,
    String? dates,
    String? description,
    String? photo,
    String? isPublic,
    String? createdAt,
    String? updatedAt,
    String? isDeleted,
    String? threadId,
  }) {
    return GroupModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      options: options ?? this.options,
      dates: dates ?? this.dates,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      threadId: threadId ?? this.threadId,
    );
  }
}
