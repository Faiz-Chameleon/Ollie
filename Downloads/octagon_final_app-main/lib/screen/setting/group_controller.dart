import 'package:get/get.dart';
import 'package:octagon/screen/groups/create_group_screen.dart';
import 'package:octagon/screen/setting/update_group_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:octagon/networking/network.dart';
import 'package:octagon/services/group_thread_service.dart';

class GroupController extends GetxController {
  final NetworkAPICall _networkApi = NetworkAPICall();
  var groups = <GroupModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Don't call fetchGroups here to avoid build-time issues
  }

  Future<void> fetchGroups() async {
    isLoading.value = true;
    final storage = GetStorage();
    final userId = storage.read("current_uid");
    final token = storage.read("token");
    if (userId == null) {
      print("No user id found in storage");
      isLoading.value = false;
      return;
    }
    if (token == null) {
      print("No token found in storage");
      isLoading.value = false;
      return;
    }
    var headers = {'Authorization': 'Bearer $token'};
    var request = http.MultipartRequest('POST', Uri.parse('http://3.134.119.154/api/user-groups-get'));
    request.fields.addAll({'user_id': userId.toString()});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      var data = json.decode(responseBody);
      List<GroupModel> loadedGroups = [];
      if (data['success'] != null && data['success'] is List) {
        for (var group in data['success']) {
          loadedGroups.add(GroupModel.fromJson(group));
        }
      }
      groups.value = loadedGroups;
    } else {
      print(response.reasonPhrase);
    }
    isLoading.value = false;
  }

  Future<bool> joinGroupIfNeeded(int groupId) async {
    final storage = GetStorage();
    final token = storage.read("token");
    final dynamic storedUserId = storage.read("current_uid") ?? storage.read("user_id") ?? storage.read("id");
    final int? currentUserId = storedUserId != null ? int.tryParse(storedUserId.toString()) : null;

    if (token == null) {
      Get.snackbar('Error', 'Authentication token missing. Please log in again.');
      return false;
    }
    if (currentUserId == null) {
      Get.snackbar('Error', 'Unable to determine the current user.');
      return false;
    }

    try {
      final bool? alreadyMember = await _isUserAlreadyMember(groupId, currentUserId);
      if (alreadyMember == null) {
        Get.snackbar('Error', 'Unable to verify group membership. Please try again.');
        return false;
      }
      if (alreadyMember) {
        return true;
      }

      final request = http.MultipartRequest('POST', Uri.parse('http://3.134.119.154/api/groups-member-personal-create'));
      request.headers.addAll({'Authorization': 'Bearer $token'});
      request.fields['group_id'] = groupId.toString();

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to join group ($groupId): ${response.statusCode} - ${response.reasonPhrase} - $responseBody');
        Get.snackbar('Error', 'Failed to join group. Please try again.');
        return false;
      }
    } catch (e) {
      print('joinGroupIfNeeded error: $e');
      Get.snackbar('Error', 'Failed to join group. Please try again.');
      return false;
    }
  }

  // Fetch all groups for main feed (public groups)
  Future<List<PublicGroupModel>> fetchAllGroups() async {
    final storage = GetStorage();
    final token = storage.read("token");
    if (token == null) {
      print("No token found in storage");
      return [];
    }

    var headers = {'Authorization': 'Bearer $token'};
    var request = http.MultipartRequest('POST', Uri.parse('http://3.134.119.154/api/user-show-group'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      var data = json.decode(responseBody);
      List<PublicGroupModel> allGroups = [];
      if (data['success'] != null && data['success'] is List) {
        for (var group in data['success']) {
          allGroups.add(PublicGroupModel.fromJson(group));
        }
      }
      return allGroups;
    } else {
      print(response.reasonPhrase);
      return [];
    }
  }

  Future<String?> fetchOrCreateThreadId(String groupId) async {
    final storage = GetStorage();
    final token = storage.read("token");
    if (token == null) {
      print("No token found in storage");
      return null;
    }

    final uri = Uri.parse('http://3.134.119.154/api/groups-create-chat-thread');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    request.fields['group_id'] = groupId;

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final decoded = json.decode(body);
        final threadId = GroupThreadService.extractThreadId(decoded);
        if (threadId != null && threadId.isNotEmpty) return threadId;
      } catch (e) {
        print('Failed to parse thread response: $e');
      }
    } else {
      print('Failed to create/fetch thread: ${response.statusCode} - $body');
    }
    return null;
  }

  Future<bool?> _isUserAlreadyMember(int groupId, int userId) async {
    try {
      final response = await _networkApi.getGroupMembers(groupId.toString());
      final members = response['success'];
      if (members is! List) return false;
      for (final member in members) {
        if (member is! Map<String, dynamic>) continue;
        final memberUserId = _tryParseInt(member['user_id']);
        if (memberUserId != null && memberUserId == userId) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Membership check failed: $e');
      return null;
    }
  }

  int? _tryParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  void createNewGroup() {
    // Show bottom sheet or form to create a new group
    // Get.snackbar("Info", "Create Group action triggered.");
    Get.to(() => CreateGroupScreen(fromWhere: 'setting'));
  }

  void onGroupTap(GroupModel group) {
    // Navigate to group detail
    Get.snackbar("Tapped", "Group: ${group.title}");
    Get.to(() => UpdateGroupScreen(groupId: group.id.toString()));
  }

  void onGroupTapForUpdate(GroupModel group) {
    // Navigate to update group screen
    Get.to(() => UpdateGroupScreen(groupId: group.id.toString()));
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
}

class PublicGroupModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String? photo;
  final String isPublic;
  final String createdAt;
  final String? updatedAt;
  final String thread_id;

  PublicGroupModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.photo,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    required this.thread_id,
  });

  factory PublicGroupModel.fromJson(Map<String, dynamic> json) {
    return PublicGroupModel(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      photo: json['photo'],
      isPublic: json['is_public'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
      thread_id: json['thread_id'] == null || json['thread_id'].toString().toLowerCase() == 'null' ? '' : json['thread_id'].toString(),
    );
  }

  PublicGroupModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? photo,
    String? isPublic,
    String? createdAt,
    String? updatedAt,
    String? thread_id,
  }) {
    return PublicGroupModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thread_id: thread_id ?? this.thread_id,
    );
  }
}
