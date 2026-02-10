import 'package:get/get.dart';
import 'package:octagon/networking/network.dart';

class GroupJoinRequest {
  final String requestId;
  final String userId;
  final String name;
  final String email;
  final String photo;

  GroupJoinRequest({
    required this.requestId,
    required this.userId,
    required this.name,
    required this.email,
    required this.photo,
  });

  factory GroupJoinRequest.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map ? json['user'] as Map<String, dynamic> : <String, dynamic>{};
    final rawRequestId = json['request_id'] ?? json['id'] ?? json['req_id'] ?? '';
    final rawId = user['id'] ?? json['user_id'] ?? json['id'] ?? '';
    return GroupJoinRequest(
      requestId: rawRequestId.toString(),
      userId: rawId.toString(),
      name: user['name']?.toString() ?? json['name']?.toString() ?? '',
      email: user['email']?.toString() ?? json['email']?.toString() ?? '',
      photo: user['photo']?.toString() ?? json['photo']?.toString() ?? '',
    );
  }
}

class GroupRequestsController extends GetxController {
  final String groupId;
  GroupRequestsController(this.groupId);

  var requests = <GroupJoinRequest>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await NetworkAPICall().getGroupJoinRequests(groupId: groupId);
      final list = _extractRequestList(response);
      requests.value = list.map((e) => GroupJoinRequest.fromJson(e)).toList();
    } catch (e) {
      errorMessage.value = 'Failed to load requests: $e';
      requests.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptRequest(GroupJoinRequest request) async {
    try {
      isLoading.value = true;
      final requestId = int.tryParse(request.requestId);
      if (requestId == null) {
        Get.snackbar('Error', 'Invalid request id');
        return;
      }
      await NetworkAPICall().acceptGroupJoinRequest(requestId: requestId);
      requests.removeWhere((r) => r.requestId == request.requestId);
      Get.snackbar('Success', 'Request accepted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept request: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectRequest(GroupJoinRequest request) async {
    try {
      isLoading.value = true;
      final requestId = int.tryParse(request.requestId);
      if (requestId == null) {
        Get.snackbar('Error', 'Invalid request id');
        return;
      }
      await NetworkAPICall().rejectGroupJoinRequest(requestId: requestId);
      requests.removeWhere((r) => r.requestId == request.requestId);
      Get.snackbar('Success', 'Request rejected');
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject request: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> _extractRequestList(Map<String, dynamic> payload) {
    List<Map<String, dynamic>> fromList(dynamic value) {
      if (value is! List) {
        return <Map<String, dynamic>>[];
      }
      return value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }

    final direct = fromList(payload['requests']);
    if (direct.isNotEmpty) {
      return direct;
    }
    final success = payload['success'];
    final successRequests = success is Map ? fromList(success['requests']) : <Map<String, dynamic>>[];
    if (successRequests.isNotEmpty) {
      return successRequests;
    }
    final data = payload['data'];
    final dataRequests = data is Map ? fromList(data['requests']) : <Map<String, dynamic>>[];
    if (dataRequests.isNotEmpty) {
      return dataRequests;
    }
    final successList = fromList(success);
    if (successList.isNotEmpty) {
      return successList;
    }
    final dataList = fromList(data);
    if (dataList.isNotEmpty) {
      return dataList;
    }
    final nestedSuccessData = success is Map ? fromList(success['data']) : <Map<String, dynamic>>[];
    if (nestedSuccessData.isNotEmpty) {
      return nestedSuccessData;
    }
    return <Map<String, dynamic>>[];
  }
}
