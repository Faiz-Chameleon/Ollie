import 'package:get/get.dart';
import 'package:octagon/networking/network.dart';

class BlockedUser {
  final String userId;
  final String name;
  final String email;
  final String photo;

  BlockedUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.photo,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map ? json['user'] as Map<String, dynamic> : <String, dynamic>{};
    final rawId = user['id'] ?? json['user_id'] ?? json['id'] ?? '';
    return BlockedUser(
      userId: rawId.toString(),
      name: user['name']?.toString() ?? json['name']?.toString() ?? '',
      email: user['email']?.toString() ?? json['email']?.toString() ?? '',
      photo: user['photo']?.toString() ?? json['photo']?.toString() ?? '',
    );
  }
}

class BlockedUsersController extends GetxController {
  final String threadId;
  BlockedUsersController(this.threadId);

  var users = <BlockedUser>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBlockedUsers();
  }

  Future<void> fetchBlockedUsers() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await NetworkAPICall().getGroupBlockedUsers(threadId: threadId);
      final list = _extractBlockedList(response);
      users.value = list.map((e) => BlockedUser.fromJson(e)).toList();
    } catch (e) {
      errorMessage.value = 'Failed to load blocked users: $e';
      users.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      isLoading.value = true;
      await NetworkAPICall().unblockGroupUser(userId: int.parse(userId), threadId: threadId);
      users.removeWhere((u) => u.userId == userId);
      Get.snackbar('Success', 'User unblocked successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to unblock user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> _extractBlockedList(Map<String, dynamic> payload) {
    List<Map<String, dynamic>> fromList(dynamic value) {
      if (value is! List) {
        return <Map<String, dynamic>>[];
      }
      return value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }

    final direct = fromList(payload['block_users']);
    if (direct.isNotEmpty) {
      return direct;
    }
    final success = payload['success'];
    final nestedSuccess = success is Map ? fromList(success['block_users']) : <Map<String, dynamic>>[];
    if (nestedSuccess.isNotEmpty) {
      return nestedSuccess;
    }
    final data = payload['data'];
    final nestedData = data is Map ? fromList(data['block_users']) : <Map<String, dynamic>>[];
    if (nestedData.isNotEmpty) {
      return nestedData;
    }
    // Original fallbacks (keep if needed for other endpoints)
    final successList = fromList(success);
    if (successList.isNotEmpty) {
      return successList;
    }
    final dataList = fromList(data);
    if (dataList.isNotEmpty) {
      return dataList;
    }
    final successDataList = success is Map ? fromList(success['data']) : <Map<String, dynamic>>[];
    if (successDataList.isNotEmpty) {
      return successDataList;
    }
    return <Map<String, dynamic>>[];
  }
}
