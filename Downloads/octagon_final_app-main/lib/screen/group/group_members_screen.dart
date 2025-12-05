import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'group_members_controller.dart';
import 'invite_members_screen.dart';

class GroupMembersScreen extends StatefulWidget {
  final String groupId;
  GroupMembersScreen({required this.groupId});

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
      appBar: AppBar(title: Text('Members')),
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
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (member.photo.isNotEmpty) ? NetworkImage(member.photo) : null,
                        child: (member.photo.isEmpty) ? Icon(Icons.person, color: Colors.white) : null,
                        backgroundColor: Colors.deepPurple,
                      ),
                      title: Text(
                        member.name,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        member.email,
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: TextButton(
                        onPressed: () => controller.removeMember(member.userId),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white, // white background
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // optional: adjust padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // optional: rounded corners
                            side: BorderSide(color: Colors.black), // optional: red border
                          ),
                        ),
                        child: Text('UnInvite', style: TextStyle(color: Colors.black)),
                      ),
                    );
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
