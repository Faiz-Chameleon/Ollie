// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:resize/resize.dart';
// import '../../networking/network.dart';
// import '../../model/user_data_model.dart';

// class InviteMembersController extends GetxController {
//   final String groupId;
//   InviteMembersController(this.groupId);

//   var users = <Users>[].obs;
//   var loadingUserIds = <int>{}.obs;
//   var isLoading = false.obs;
//   var errorMessage = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchUsers();
//   }

//   Future<void> fetchUsers() async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//       final data = await NetworkAPICall().getUsersForGroupInvite(groupId);
//       users.value = data.where((u) => u['is_member'] == 0 || u['is_member'] == '0').map<Users>((u) => Users.fromJson(u)).toList();
//     } catch (e) {
//       errorMessage.value = 'Failed to load users: $e';
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> inviteUser(int userId, int index, BuildContext context) async {
//     loadingUserIds.add(userId);
//     try {
//       await NetworkAPICall().inviteUserToGroup(groupId: groupId, userId: userId);
//       users.removeAt(index);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('User invited successfully')),
//       );
//       if (users.isEmpty) {
//         Future.delayed(const Duration(milliseconds: 400), () {
//           Navigator.pop(context, true);
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to invite user: $e')),
//       );
//     } finally {
//       loadingUserIds.remove(userId);
//     }
//   }
// }

// class InviteMembersScreen extends StatelessWidget {
//   final String groupId;
//   const InviteMembersScreen({Key? key, required this.groupId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final InviteMembersController controller = Get.put(InviteMembersController(groupId));
//     return Scaffold(
//       appBar: AppBar(title: Text('Invite Members')),
//       backgroundColor: Color(0xFF18162A),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(child: CircularProgressIndicator());
//         } else if (controller.errorMessage.isNotEmpty) {
//           return Center(child: Text(controller.errorMessage.value, style: TextStyle(color: Colors.red)));
//         } else if (controller.users.isEmpty) {
//           return Center(child: Text('No users available to invite.', style: TextStyle(color: Colors.white)));
//         }
//         return ListView.builder(
//           itemCount: controller.users.length,
//           itemBuilder: (context, index) {
//             final user = controller.users[index];
//             final isLoading = controller.loadingUserIds.contains(user.id);
//             return Card(
//               color: const Color(0xFF232042),
//               margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   radius: 24,
//                   backgroundImage: (user.photo != null && user.photo!.isNotEmpty) ? NetworkImage(user.photo!) : null,
//                   backgroundColor: Colors.deepPurple[400],
//                   child: (user.photo == null || user.photo!.isEmpty) ? Icon(Icons.person, color: Colors.white, size: 28) : null,
//                 ),
//                 title: Text(user.name ?? '',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     )),
//                 subtitle: Text(user.email ?? '',
//                     style: TextStyle(
//                       color: Colors.deepPurple[100],
//                       fontSize: 12,
//                       overflow: TextOverflow.ellipsis,
//                     )),
//                 trailing: SizedBox(
//                   width: 95.w,
//                   height: 36,
//                   child: ElevatedButton(
//                     onPressed: isLoading ? null : () => controller.inviteUser(user.id!, index, context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: isLoading ? Colors.deepPurple[200] : Colors.deepPurple[700],
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: isLoading
//                         ? SizedBox(
//                             width: 18,
//                             height: 18,
//                             child: CircularProgressIndicator(
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                               strokeWidth: 2.2,
//                             ),
//                           )
//                         : Text('Invite', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resize/resize.dart';
import '../../networking/network.dart';
import '../../model/user_data_model.dart';

class InviteMembersController extends GetxController {
  final String groupId;
  InviteMembersController(this.groupId);

  var users = <Users>[].obs;
  var filteredUsers = <Users>[].obs;
  var loadingUserIds = <int>{}.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var searchQuery = ''.obs;
  var isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await NetworkAPICall().getUsersForGroupInvite(groupId);
      users.value = data.where((u) => u['is_member'] == 1).map<Users>((u) => Users.fromJson(u)).toList();
      filteredUsers.value = users; // Initialize filteredUsers with all users
    } catch (e) {
      errorMessage.value = 'Failed to load users: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void filterUsers(String query) {
    searchQuery.value = query;
    isSearching.value = query.isNotEmpty;

    if (query.isEmpty) {
      // Show all users when search query is empty
      filteredUsers.value = users;
    } else {
      // Filter users based on search query
      filteredUsers.value = users.where((user) {
        final name = user.name?.toLowerCase() ?? '';
        final email = user.email?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();

        return name.startsWith(searchLower) || email.startsWith(searchLower);
      }).toList();
    }
  }

  Future<void> inviteUser(int userId, int index, BuildContext context) async {
    loadingUserIds.add(userId);
    try {
      await NetworkAPICall().inviteUserToGroup(groupId: groupId, userId: userId, isInvite: 1, status: 'invited');

      // Remove user from both lists
      users.removeWhere((user) => user.id == userId);
      filteredUsers.removeWhere((user) => user.id == userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User invited successfully')),
      );

      if (users.isEmpty) {
        Future.delayed(const Duration(milliseconds: 400), () {
          Navigator.pop(context, true);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to invite user: $e')),
      );
    } finally {
      loadingUserIds.remove(userId);
    }
  }
}

class InviteMembersScreen extends StatelessWidget {
  final String groupId;
  const InviteMembersScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final InviteMembersController controller = Get.put(InviteMembersController(groupId));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: GestureDetector(
            onTap: () {
              Get.close(1);
            },
            child: Icon(Icons.arrow_back, color: Colors.white)),
        title: Text(
          'Invite Members',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF18162A),
      ),
      backgroundColor: Color(0xFF18162A),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: controller.filterUsers,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF232042),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),

          // User List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              } else if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Text(controller.errorMessage.value, style: TextStyle(color: Colors.red)),
                );
              } else if (controller.filteredUsers.isEmpty) {
                if (controller.isSearching.value) {
                  // Show message when search returns no results
                  return Center(
                    child: Text(
                      'No users found for "${controller.searchQuery.value}"',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  // Show message when there are no users available to invite
                  return Center(
                    child: Text('No users available to invite.', style: TextStyle(color: Colors.white)),
                  );
                }
              }

              return ListView.builder(
                itemCount: controller.filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.filteredUsers[index];
                  final isLoading = controller.loadingUserIds.contains(user.id);

                  return Card(
                    color: const Color(0xFF232042),
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: (user.photo != null && user.photo!.isNotEmpty) ? NetworkImage(user.photo!) : null,
                        backgroundColor: Colors.deepPurple[400],
                        child: (user.photo == null || user.photo!.isEmpty) ? Icon(Icons.person, color: Colors.white, size: 28) : null,
                      ),
                      title: Text(
                        user.name ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        user.email ?? '',
                        style: TextStyle(
                          color: Colors.deepPurple[100],
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: SizedBox(
                        width: 95.w,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => controller.inviteUser(user.id!, index, context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLoading ? Colors.deepPurple[200] : Colors.deepPurple[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : Text(
                                  'Invite',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:resize/resize.dart';
// import '../../networking/network.dart';
// import '../../model/user_data_model.dart';

// class InviteMembersController extends GetxController {
//   final String groupId;
//   InviteMembersController(this.groupId);

//   var users = <Users>[].obs;
//   final filteredUsers = <Users>[].obs;
//   var loadingUserIds = <int>{}.obs;
//   var isLoading = false.obs;
//   var errorMessage = ''.obs;

//   final query = ''.obs;
//   final searchCtrl = TextEditingController();
//   late Worker _debouncer;

//   @override
//   void onInit() {
//     super.onInit();
//     _debouncer = debounce(query, (_) => _applyFilter(), time: 300.milliseconds);
//     fetchUsers();
//   }

//   @override
//   void onClose() {
//     _debouncer.dispose();
//     searchCtrl.dispose();
//     super.onClose();
//   }

//   // update query from UI
//   void onSearchChanged(String text) {
//     query.value = text;
//   }

//   // clear search from UI
//   void clearSearch() {
//     searchCtrl.clear();
//     query.value = '';
//   }

//   void _applyFilter() {
//     final q = query.value.trim().toLowerCase();
//     if (q.isEmpty) {
//       filteredUsers.assignAll(users);
//       return;
//     }
//     filteredUsers.assignAll(
//       users.where((u) {
//         final name = (u.name ?? '').toLowerCase();
//         final email = (u.email ?? '').toLowerCase();
//         return name.contains(q) || email.contains(q);
//       }),
//     );
//   }

//   Future<void> fetchUsers() async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//       final data = await NetworkAPICall().getUsersForGroupInvite(groupId);
//       users.value = data.where((u) => u['is_member'] == 0 || u['is_member'] == '0').map<Users>((u) => Users.fromJson(u)).toList();
//     } catch (e) {
//       errorMessage.value = 'Failed to load users: $e';
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> inviteUser(int userId, int index, BuildContext context) async {
//     loadingUserIds.add(userId);
//     try {
//       await NetworkAPICall().inviteUserToGroup(groupId: groupId, userId: userId);
//       users.removeAt(index);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('User invited successfully')),
//       );
//       if (users.isEmpty) {
//         Future.delayed(const Duration(milliseconds: 400), () {
//           Navigator.pop(context, true);
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to invite user: $e')),
//       );
//     } finally {
//       loadingUserIds.remove(userId);
//     }
//   }
// }

// class InviteMembersScreen extends StatelessWidget {
//   final String groupId;
//   const InviteMembersScreen({Key? key, required this.groupId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final InviteMembersController controller = Get.put(InviteMembersController(groupId));
//     return Scaffold(
//       appBar: AppBar(title: Text('Invite Members')),
//       backgroundColor: Color(0xFF18162A),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(child: CircularProgressIndicator());
//         } else if (controller.errorMessage.isNotEmpty) {
//           return Center(child: Text(controller.errorMessage.value, style: TextStyle(color: Colors.red)));
//         } else if (controller.users.isEmpty) {
//           return Center(child: Text('No users available to invite.', style: TextStyle(color: Colors.white)));
//         }
//         return ListView.builder(
//           itemCount: controller.users.length,
//           itemBuilder: (context, index) {
//             final user = controller.users[index];
//             final isLoading = controller.loadingUserIds.contains(user.id);
//             return Card(
//               color: const Color(0xFF232042),
//               margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   radius: 24,
//                   backgroundImage: (user.photo != null && user.photo!.isNotEmpty) ? NetworkImage(user.photo!) : null,
//                   backgroundColor: Colors.deepPurple[400],
//                   child: (user.photo == null || user.photo!.isEmpty) ? Icon(Icons.person, color: Colors.white, size: 28) : null,
//                 ),
//                 title: Text(user.name ?? '',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     )),
//                 subtitle: Text(user.email ?? '',
//                     style: TextStyle(
//                       color: Colors.deepPurple[100],
//                       fontSize: 12,
//                       overflow: TextOverflow.ellipsis,
//                     )),
//                 trailing: SizedBox(
//                   width: 95.w,
//                   height: 36,
//                   child: ElevatedButton(
//                     onPressed: isLoading ? null : () => controller.inviteUser(user.id!, index, context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: isLoading ? Colors.deepPurple[200] : Colors.deepPurple[700],
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: isLoading
//                         ? SizedBox(
//                             width: 18,
//                             height: 18,
//                             child: CircularProgressIndicator(
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                               strokeWidth: 2.2,
//                             ),
//                           )
//                         : Text('Invite', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }
