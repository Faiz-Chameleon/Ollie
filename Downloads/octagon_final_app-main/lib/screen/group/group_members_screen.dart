import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'group_members_controller.dart';
import 'invite_members_screen.dart';
import 'blocked_users_screen.dart';
import 'group_requests_screen.dart';

class GroupMembersScreen extends StatefulWidget {
  final String groupId;
  final String threadId;
  GroupMembersScreen({required this.groupId, required this.threadId});

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  late final GroupMembersController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(GroupMembersController(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) {
              if (value == 'blocked') {
                if (widget.threadId.isEmpty) {
                  Get.snackbar('Error', 'Chat thread is not enabled for this group');
                  return;
                }
                Get.to(() => BlockedUsersScreen(threadId: widget.threadId));
                return;
              }
              if (value == 'requests') {
                Get.to(() => GroupRequestsScreen(groupId: widget.groupId));
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'blocked',
                child: Text('Blocked users'),
              ),
              PopupMenuItem(
                value: 'requests',
                child: Text('Request list'),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Color(0xFF18162A),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value, style: TextStyle(color: Colors.red)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchMembers,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (controller.members.isEmpty) {
          return Column(
            children: [
              Expanded(
                child: Center(child: Text('No members found.', style: TextStyle(color: Colors.white))),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InviteMembersScreen(groupId: widget.groupId),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Invite Members',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[800],
                  ),
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: Colors.deepPurple,
                backgroundColor: Color(0xFF232042),
                onRefresh: controller.fetchMembers,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: controller.members.length,
                  itemBuilder: (context, index) {
                    final member = controller.members[index];
                    return member.isInvited == 1 || member.requestStatus == "approved"
                        ? ListTile(
                            leading: CircleAvatar(
                              backgroundImage: (member.photo.isNotEmpty) ? NetworkImage(member.photo) : null,
                              child: (member.photo.isEmpty) ? Icon(Icons.person, color: Colors.white) : null,
                              backgroundColor: Colors.deepPurple,
                            ),
                            title: Text(
                              member.isInvited == 1 ? "${member.name} (Invited)" : member.name,
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              member.email,
                              style: TextStyle(color: Colors.grey),
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'uninvite') {
                                  await controller.removeMember(member.userId);
                                  return;
                                }
                                if (value == 'block') {
                                  if (widget.threadId.isEmpty) {
                                    Get.snackbar('Error', 'Chat thread is not enabled for this group');
                                    return;
                                  }
                                  await controller.blockMember(userId: member.userId, threadId: widget.threadId);
                                }
                              },
                              icon: Icon(Icons.more_vert, color: Colors.white),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'uninvite',
                                  child: Text('UnInvite'),
                                ),
                                PopupMenuItem(
                                  value: 'block',
                                  child: Text('Block'),
                                ),
                              ],
                            ),
                          )
                        : SizedBox.shrink();
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InviteMembersScreen(groupId: widget.groupId),
                    ),
                  );
                },
                icon: Icon(
                  Icons.person_add,
                  color: Colors.white,
                ),
                label: Text(
                  'Invite Members',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[800],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
