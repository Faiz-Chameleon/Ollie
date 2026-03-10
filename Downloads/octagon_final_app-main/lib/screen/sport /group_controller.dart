// import 'dart:convert';
// import 'dart:io';

// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:octagon/main.dart';
// import 'package:path/path.dart';

// import '../../utils/constants.dart';

// class NewGroupController extends GetxController {
//   var isLoading = false.obs;
//   var isLoadingOnJoin = false.obs;

//   var groupData = [].obs;
//   RxInt selectedGroupId = 0.obs;
//   void updateSelectedGroupId(int id) {
//     selectedGroupId.value = id;
//   }

//   Future<void> fetchGroupData() async {
//     isLoading.value = true;

//     var headers = {
//       'Authorization': 'Bearer ${getUserToken()}',
//     };

//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('http://3.134.119.154/api/user-show-group'),
//     );

//     request.headers.addAll(headers);

//     try {
//       http.StreamedResponse response = await request.send();

//       if (response.statusCode == 200) {
//         String responseBody = await response.stream.bytesToString();
//         var jsonData = jsonDecode(responseBody);
//         groupData.value = jsonData['success'] as List<dynamic>;
//         print(jsonData);
//       } else {
//         print('Error: ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('Exception: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // newAPI groups-member-personal-create
//   // old api groups-member-create
//   Future<void> joinGroup() async {
//     isLoadingOnJoin.value = true;

//     var headers = {
//       'Authorization': 'Bearer ${getUserToken()}',
//     };

//     var request = http.MultipartRequest('POST',
//         Uri.parse('http://3.134.119.154/api/groups-member-personal-create'));
//     request.fields.addAll({
//       'group_id': selectedGroupId.value.toString(),
//       // 'user_id': storage.read('current_uid').toString()
//     });

//     request.headers.addAll(headers);
//     try {
//       http.StreamedResponse response = await request.send();
//       String responseBody = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         print(responseBody);

//         update();
//       } else {
//         print(response.reasonPhrase);
//         Get.snackbar('Error', 'Failed to join group');
//       }
//     } catch (e) {
//       print('Exception: $e');
//       Get.snackbar('Error', 'Failed to join group');
//     } finally {
//       isLoadingOnJoin.value = false;

//       update();
//     }
//   }

//   Future<void> createGroup({
//     required String title,
//     required String options,
//     required String dates,
//     required String description,
//     required String userId,
//     required String isPublic,
//     File? photoFile,
//   }) async {
//     isLoading.value = true;

//     var headers = {
//       'Authorization': 'Bearer ${getUserToken()}',
//     };

//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('http://3.134.119.154/api/user-groups-create'),
//     );

//     request.fields.addAll({
//       'title': title,
//       'options': options,
//       'dates': dates,
//       'description': description,
//       'user_id': userId,
//       'is_public': isPublic,
//     });

//     if (photoFile != null) {
//       request.files.add(await http.MultipartFile.fromPath(
//         'photo',
//         photoFile.path,
//         filename: basename(photoFile.path),
//       ));
//     }

//     request.headers.addAll(headers);

//     try {
//       http.StreamedResponse response = await request.send();

//       if (response.statusCode == 200) {
//         final responseBody = await response.stream.bytesToString();
//         print("✅ Group Created: $responseBody");
//         await fetchGroupData(); // Refresh group list
//       } else {
//         print("❌ Failed to create group: ${response.reasonPhrase}");
//       }
//     } catch (e) {
//       print("❌ Exception in group creation: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:octagon/main.dart';
import 'package:octagon/networking/network.dart';
import 'package:path/path.dart';

import '../../utils/constants.dart';

class NewGroupController extends GetxController {
  final NetworkAPICall _networkApi = NetworkAPICall();
  var isLoading = false.obs;
  var isLoadingOnJoin = false.obs;

  var groupData = [].obs;
  RxInt selectedGroupId = 0.obs;
  RxInt defaultGroupId = 0.obs;
  void updateSelectedGroupId(int id) {
    selectedGroupId.value = id;
  }

  var searchQuery = ''.obs;
  var isSearching = false.obs;
  var filteredgroups = <dynamic>[].obs;

  void filterUsers(String query) {
    searchQuery.value = query;
    isSearching.value = query.isNotEmpty;

    if (query.isEmpty) {
      // Show all users when search query is empty
      filteredgroups.value = _moveOctagonToFirst(List<dynamic>.from(groupData));
    } else {
      // Filter users based on search query
      final filtered = groupData.where((user) {
        final title = user['title'].toString().toLowerCase();

        final searchLower = query.toLowerCase();

        return title.startsWith(searchLower);
      }).toList();
      filteredgroups.value = _moveOctagonToFirst(filtered);
    }
  }

  Future<void> fetchGroupData() async {
    isLoading.value = true;

    var headers = {
      'Authorization': 'Bearer ${getUserToken()}',
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://3.134.119.154/api/user-show-group'),
    );

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseBody);
        final groups = List<dynamic>.from(jsonData['success'] as List<dynamic>);
        groupData.value = _moveOctagonToFirst(groups);
        _autoSelectDefaultTaggedGroup();
        if (searchQuery.value.isEmpty) {
          filteredgroups.value = groupData;
        } else {
          filterUsers(searchQuery.value);
        }
        print(jsonData);
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // newAPI groups-member-personal-create
  // old api groups-member-create
  Future<void> joinGroup() async {
    isLoadingOnJoin.value = true;

    try {
      final dynamic storedUserId = storage.read('current_uid') ?? storage.read('user_id') ?? storage.read('id');
      final int? currentUserId = storedUserId != null ? int.tryParse(storedUserId.toString()) : null;

      if (currentUserId == null) {
        Get.snackbar(
          'Error',
          'Unable to determine the current user',
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
        return;
      }

      final bool? alreadyMember = await _isUserAlreadyMember(currentUserId);
      if (alreadyMember == null) {
        Get.snackbar(
          'Error',
          'Unable to verify group membership. Please try again.',
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
        return;
      }
      if (alreadyMember) {
        Get.snackbar(
          'Groups',
          'You have already joined this group',
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
        return;
      }

      var headers = {
        'Authorization': 'Bearer ${getUserToken()}',
      };

      var request = http.MultipartRequest('POST', Uri.parse('http://3.134.119.154/api/groups-member-personal-create'));
      request.fields.addAll({
        'group_id': selectedGroupId.value.toString(),
        // 'user_id': storage.read('current_uid').toString()
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print(responseBody);

        update();
      } else {
        print(response.reasonPhrase);
        Get.snackbar(
          'Error',
          'Failed to join group',
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
      }
    } catch (e) {
      print('Exception: $e');
      Get.snackbar(
        'Error',
        'Failed to join group',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    } finally {
      isLoadingOnJoin.value = false;

      update();
    }
  }

  Future<bool> sendJoinRequest(int groupId) async {
    isLoadingOnJoin.value = true;
    final token = storage.read("token");
    if (token == null) {
      isLoadingOnJoin.value = false;
      Get.snackbar(
        'Error',
        'Authentication token missing. Please log in again.',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return false;
    }

    final uri = Uri.parse(Uri.encodeFull('${baseUrl}send-request'));
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({'Authorization': 'Bearer $token'});
    request.fields['group_id'] = groupId.toString();

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 201) {
        return true;
      }
      if (response.statusCode == 409) {
        String message = 'You have already sent a request to this group.';
        try {
          final decoded = jsonDecode(responseBody);
          if (decoded is Map && decoded['error'] != null) {
            message = decoded['error'].toString();
          }
        } catch (_) {}
        Get.snackbar(
          'Request already sent',
          message,
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
        return false;
      }
      print('sendJoinRequest failed ($groupId): ${response.statusCode} - ${response.reasonPhrase} - $responseBody');
      Get.snackbar(
        'Error',
        'Failed to send request. Please try again.',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return false;
    } catch (e) {
      print('sendJoinRequest error: $e');
      Get.snackbar(
        'Error',
        'Failed to send request. Please try again.',
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return false;
    } finally {
      isLoadingOnJoin.value = false;
    }
  }

  Future<bool?> _isUserAlreadyMember(int userId) async {
    if (selectedGroupId.value == 0) {
      return false;
    }
    try {
      final response = await _networkApi.getGroupMembers(selectedGroupId.value.toString());
      final members = response['success'];
      if (members is! List) {
        return false;
      }
      return members.any((member) {
        if (member is! Map<String, dynamic>) {
          return false;
        }
        final memberUserId = _tryParseInt(member['user_id']);
        return memberUserId != null && memberUserId == userId;
      });
    } catch (e) {
      print('Membership check failed: $e');
      return null;
    }
  }

  int? _tryParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  List<dynamic> _moveOctagonToFirst(List<dynamic> groups) {
    if (groups.isEmpty) return groups;
    final index = groups.indexWhere((group) {
      if (group is! Map) return false;
      final title = group['title']?.toString().trim().toLowerCase();
      return title == 'octagon';
    });
    if (index <= 0) return groups;
    final octagonGroup = groups.removeAt(index);
    groups.insert(0, octagonGroup);
    return groups;
  }

  void _autoSelectDefaultTaggedGroup() {
    if (groupData.isEmpty) return;

    dynamic defaultGroup = groupData.cast<dynamic>().firstWhereOrNull((group) => _isDefaultTaggedGroup(group));
    defaultGroup ??= groupData.cast<dynamic>().firstWhereOrNull((group) {
      if (group is! Map) return false;
      final title = group['title']?.toString().trim().toLowerCase();
      return title == 'octagon';
    });
    defaultGroup ??= groupData.first;
    if (defaultGroup is! Map) return;

    final id = _tryParseInt(defaultGroup['id']);
    if (id == null) return;

    defaultGroupId.value = id;
    if (selectedGroupId.value == 0) {
      selectedGroupId.value = id;
    }
    storage.write('userDefaultGroup', defaultGroup['logo'] ?? defaultGroup['photo']);
    storage.write('userDefaultGroupName', defaultGroup['title']);
  }

  bool _isDefaultTaggedGroup(dynamic group) {
    if (group is! Map) return false;

    bool checkValue(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is num) return value == 1;
      final normalized = value.toString().trim().toLowerCase();
      return normalized == 'default' || normalized == '1' || normalized == 'true' || normalized == 'yes';
    }

    final dynamic tagValue = group['tag'] ?? group['group_tag'] ?? group['label'] ?? group['badge'];
    if (checkValue(tagValue)) return true;

    final dynamic defaultValue = group['default'] ?? group['is_default'] ?? group['isDefault'];
    return checkValue(defaultValue);
  }

  bool isDefaultTaggedGroup(dynamic group) => _isDefaultTaggedGroup(group);

  Future<void> createGroup({
    required String title,
    required String options,
    required String dates,
    required String description,
    required String userId,
    required String isPublic,
    File? photoFile,
  }) async {
    isLoading.value = true;

    var headers = {
      'Authorization': 'Bearer ${getUserToken()}',
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://3.134.119.154/api/user-groups-create'),
    );

    request.fields.addAll({
      'title': title,
      'options': options,
      'dates': dates,
      'description': description,
      'user_id': userId,
      'is_public': isPublic,
    });

    if (photoFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        photoFile.path,
        filename: basename(photoFile.path),
      ));
    }

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print("✅ Group Created: $responseBody");
        await fetchGroupData(); // Refresh group list
      } else {
        print("❌ Failed to create group: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("❌ Exception in group creation: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
