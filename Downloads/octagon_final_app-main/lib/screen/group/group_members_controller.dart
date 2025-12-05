import 'package:get/get.dart';
import '../../model/group_member.dart';
import '../../networking/network.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupMembersController extends GetxController {
  final String groupId;
  GroupMembersController(this.groupId);

  var members = <GroupMember>[].obs;
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
    } catch (e) {
      errorMessage.value = 'Failed to load members: $e';
      members.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeMember(int userId) async {
    try {
      isLoading.value = true;
      await NetworkAPICall()
          .removeMember(userId: userId, groupId: int.parse(groupId));
      members.removeWhere((m) => m.userId == userId);
      Get.snackbar('Success', 'Member removed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove member: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
