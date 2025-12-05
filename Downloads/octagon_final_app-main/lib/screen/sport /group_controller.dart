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

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:octagon/main.dart';
import 'package:path/path.dart';

import '../../utils/constants.dart';

class NewGroupController extends GetxController {
  var isLoading = false.obs;
  var isLoadingOnJoin = false.obs;

  var groupData = [].obs;
  RxInt selectedGroupId = 0.obs;
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
      filteredgroups.value = groupData;
    } else {
      // Filter users based on search query
      filteredgroups.value = groupData.where((user) {
        final title = user['title'].toString().toLowerCase();

        final searchLower = query.toLowerCase();

        return title.startsWith(searchLower);
      }).toList();
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
        groupData.value = jsonData['success'] as List<dynamic>;
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

    var headers = {
      'Authorization': 'Bearer ${getUserToken()}',
    };

    var request = http.MultipartRequest('POST', Uri.parse('http://3.134.119.154/api/groups-member-personal-create'));
    request.fields.addAll({
      'group_id': selectedGroupId.value.toString(),
      // 'user_id': storage.read('current_uid').toString()
    });

    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print(responseBody);

        update();
      } else {
        print(response.reasonPhrase);
        Get.snackbar('Error', 'Failed to join group');
      }
    } catch (e) {
      print('Exception: $e');
      Get.snackbar('Error', 'Failed to join group');
    } finally {
      isLoadingOnJoin.value = false;

      update();
    }
  }

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
