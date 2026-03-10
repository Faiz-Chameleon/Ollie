import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/group_member.dart';
import '../../networking/network.dart';

class GroupMembersController extends GetxController {
  final String groupId;
  GroupMembersController(this.groupId);

  var members = <GroupMember>[].obs;
  var pendingRequestsCount = 0.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await NetworkAPICall().getGroupMembers(groupId);
      if (response['success'] == null) {
        errorMessage.value = 'No data received from server.';
        members.clear();
        return;
      }
      final List data = response['success'];
      members.value = data.map((e) => GroupMember.fromJson(e)).toList();

      // Fetch join requests count so UI can show "New member request".
      final requestsResponse = await NetworkAPICall().getGroupJoinRequests(groupId: groupId);
      pendingRequestsCount.value = _extractRequestList(requestsResponse).length;
    } catch (e) {
      errorMessage.value = 'Failed to load members: $e';
      members.clear();
      pendingRequestsCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeMember(int userId) async {
    try {
      isLoading.value = true;
      await NetworkAPICall().removeMember(userId: userId, groupId: int.parse(groupId));
      members.removeWhere((m) => m.userId == userId);
      Get.snackbar(
        'Success',
        'Member removed successfully',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove member: $e',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> blockMember({required int userId, required String threadId}) async {
    try {
      isLoading.value = true;
      await NetworkAPICall().blockGroupUser(userId: userId, threadId: threadId);
      members.removeWhere((m) => m.userId == userId);
      Get.snackbar(
        'Success',
        'Member blocked successfully',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to block member: $e',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> _extractRequestList(Map<String, dynamic> payload) {
    List<Map<String, dynamic>> fromList(dynamic value) {
      if (value is! List) return <Map<String, dynamic>>[];
      return value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }

    final direct = fromList(payload['requests']);
    if (direct.isNotEmpty) return direct;

    final success = payload['success'];
    final successRequests = success is Map ? fromList(success['requests']) : <Map<String, dynamic>>[];
    if (successRequests.isNotEmpty) return successRequests;

    final data = payload['data'];
    final dataRequests = data is Map ? fromList(data['requests']) : <Map<String, dynamic>>[];
    if (dataRequests.isNotEmpty) return dataRequests;

    final successList = fromList(success);
    if (successList.isNotEmpty) return successList;

    final dataList = fromList(data);
    if (dataList.isNotEmpty) return dataList;

    final nestedSuccessData = success is Map ? fromList(success['data']) : <Map<String, dynamic>>[];
    if (nestedSuccessData.isNotEmpty) return nestedSuccessData;

    return <Map<String, dynamic>>[];
  }
}
