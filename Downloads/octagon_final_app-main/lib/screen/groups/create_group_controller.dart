import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:octagon/main.dart';
import 'package:octagon/networking/network.dart';
import 'package:octagon/screen/login/auth_controller.dart';
import 'package:octagon/screen/tabs_screen.dart';
import 'package:octagon/screen/setting/your_groups_screen.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/widgets/showCustomLoadingDialog.dart';
import 'package:octagon/services/group_thread_service.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateGroupController extends GetxController {
  // final ImagePicker _picker = ImagePicker();

  Rx<File?> selectedImage = Rx<File?>(null);
  RxBool isCompressing = false.obs;
  RxBool isPrivate = false.obs;

  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController updateTextController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController infoController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final GroupThreadService _threadService = GroupThreadService();

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
  // Future<void> _requestGalleryPermission() async {
  //   var status = await Permission.photos.status;

  //   if (status.isGranted) {
  //     pickImageFromGallery();
  //   } else if (status.isPermanentlyDenied ||
  //       status.isDenied ||
  //       status.isLimited) {
  //     // Show dialog guiding user to open settings
  //     Get.defaultDialog(
  //       title: "Permission Required",
  //       middleText:
  //           "Please enable photo access from Settings to upload an image.",
  //       confirm: ElevatedButton(
  //         onPressed: () => openAppSettings(),
  //         child: const Text("Open Settings"),
  //       ),
  //       cancel: TextButton(
  //         onPressed: () => Get.back(),
  //         child: const Text("Cancel"),
  //       ),
  //     );
  //   } else {
  //     var result = await Permission.photos.request();
  //     if (result.isGranted) {
  //       pickImageFromGallery();
  //     } else {
  //       Get.snackbar("Permission Denied",
  //           "Photo access is required to upload an image.");
  //     }
  //   }
  // }

  // static final ImagePicker _picker = ImagePicker();

  // static Future<File?> pickImageFromGallery() async {
  //   if (Platform.isIOS) {
  //     final status = await Permission.photos.request();
  //     if (!status.isGranted) {
  //       Get.snackbar("Permission Denied", "Photo access is required.");
  //       return null;
  //     }
  //   }

  //   try {
  //     final XFile? image = await _picker.pickImage(
  //       source: ImageSource.gallery,
  //       imageQuality: 70, // Optional: Compress image
  //     );

  //     if (image != null) {
  //       return File(image.path);
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     print("Gallery error: $e");
  //     Get.snackbar("Error", "Failed to pick image.");
  //     return null;
  //   }
  // }

  // Future<void> pickImage() async {
  //   try {
  //     final XFile? pickedFile = await _picker.pickImage(
  //       source: ImageSource.gallery,
  //       imageQuality: 50,
  //     );

  //     if (pickedFile != null) {
  //       // Add delay to prevent UI freeze
  //       await Future.delayed(const Duration(milliseconds: 100));
  //       await compressImage(File(pickedFile.path));
  //     }
  //   } catch (e) {
  //     print('Error picking image: $e');
  //     Get.snackbar('Error', 'Failed to pick image');
  //   }
  // }

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

  final authController = Get.put(AuthController());
  Future<void> createGroup(BuildContext context, {String? fromWhere, String? teamName}) async {
    try {
      // Show loading UI
      showCustomLoadingDialog(context: context);

      // Prepare fields
      final fields = {
        'title': teamName,
        'options': updateTextController.text.trim().isEmpty ? '""' : updateTextController.text.trim(),
        'dates': dateController.text,
        'description': infoController.text.trim().isEmpty ? '""' : infoController.text.trim(),
        'is_public': isPrivate.value ? 1 : 0,
        'user_id': storage.read("current_uid"),
      };
      log("punni: \\${fields["user_id"]}");

      // Prepare file (if selected)
      http.MultipartFile? imageFile;
      if (selectedImage.value != null) {
        imageFile = await http.MultipartFile.fromPath('photo', selectedImage.value!.path);
      }

      // Combine fields and file into body map
      final body = {
        ...fields,
        if (imageFile != null) 'photo': imageFile, // key must start with 'photo'
      };

      // Call API
      final response = await NetworkAPICall().multiPartPostRequest(
        "user-groups-create",
        body,
        true,
        "POST",
      );
      final String? newGroupId = GroupThreadService.extractGroupId(response);
      String? threadWarning;
      if (newGroupId != null && newGroupId.isNotEmpty) {
        try {
          await _threadService.createThreadForGroup(newGroupId);
        } catch (e) {
          log('Auto thread creation failed: $e');
          threadWarning = 'thread_failed';
        }
      } else {
        log('Unable to determine group id from create response');
        threadWarning = 'missing_group_id';
      }

      // Close loading UI
      Get.back();
      Get.snackbar("Success", "Group created successfully", backgroundColor: appBgColor, colorText: whiteColor);
      if (threadWarning != null) {
        Get.snackbar(
          "Chat Thread",
          "Group created but chat isn't ready yet. Open the group settings later to add the chat thread.",
          backgroundColor: appBgColor,
          colorText: whiteColor,
        );
      }
      if (fromWhere == 'setting') {
        Get.offAll(() => YourGroupsScreen());
      } else {
        Get.off(() => TabScreen());
      }
    } catch (e) {
      // Handle error
      Navigator.pop(context);
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
