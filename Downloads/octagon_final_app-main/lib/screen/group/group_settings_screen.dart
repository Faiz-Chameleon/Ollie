import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octagon/screen/setting/update_group_controller.dart';
import 'package:octagon/screen/setting/update_group_screen.dart';

import 'group_members_screen.dart';
import 'invite_members_screen.dart';

class GroupSettingsScreen extends StatefulWidget {
  final String groupId;
  const GroupSettingsScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  final UpdateGroupController controller = Get.put(UpdateGroupController());
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    try {
      await controller.fetchGroupDetails(widget.groupId);
      if (controller.groupData.value == null) {
        errorMessage = 'No group data found.';
      } else {
        errorMessage = null;
      }
    } catch (e) {
      errorMessage = 'Failed to load group details: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF18162A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF18162A),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: fetchDetails,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        final group = controller.groupData.value;
        if (group == null) {
          return const Center(child: Text('No group data found', style: TextStyle(color: Colors.white)));
        }
        // For member count, if not present in model, show 0 or add logic to fetch members if needed
        int memberCount = group.options.isNotEmpty ? int.tryParse(group.options) ?? 0 : 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Group Logo
              CircleAvatar(
                radius: 40,
                backgroundImage: group.photo != null && group.photo!.isNotEmpty
                    ? NetworkImage("${"http://3.134.119.154/"}${group.photo!}")
                    : const AssetImage('assets/fc_barcelona.png') as ImageProvider,
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 16),
              // Group Name
              Text(
                group.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              // Subtitle
              Text(
                'Group - ${controller.groupMembers.value} members',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              // Description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF232042),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  group.description.isNotEmpty && group.description != '""' ? group.description : 'No description',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              // Edit Group Info
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text('Edit Group Info', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                tileColor: const Color(0xFF232042),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onTap: () async {
                  // Delay navigation to next frame to avoid setState/Obx build error
                  await Future.delayed(Duration.zero);
                  Get.to(() => UpdateGroupScreen(groupId: widget.groupId));
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                minLeadingWidth: 0,
              ),
              const SizedBox(height: 16),
              // Settings Section
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF232042),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.update, color: Colors.white),
                      title: const Text('Updates', style: TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onTap: () {},
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      minLeadingWidth: 0,
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    ListTile(
                      leading: const Icon(Icons.group, color: Colors.white),
                      title: const Text('Members', style: TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onTap: () {
                        Get.to(() => GroupMembersScreen(
                              groupId: widget.groupId,
                            ));
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      minLeadingWidth: 0,
                    ),

                    // if (group.isPublic == "1" || group.isPublic == 1) ...[
                    //   ListTile(
                    //     leading: const Icon(Icons.group, color: Colors.white),
                    //     title: const Text('Members', style: TextStyle(color: Colors.white)),
                    //     trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    //     onTap: () {
                    //       Get.to(() => GroupMembersScreen(
                    //             groupId: widget.groupId,
                    //           ));
                    //     },
                    //     contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    //     minLeadingWidth: 0,
                    //   ),
                    // ],
                    ListTile(
                      leading: const Icon(Icons.person_add, color: Colors.white),
                      title: const Text('Invite Members', style: TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onTap: () {
                        Get.to(() => InviteMembersScreen(
                              groupId: widget.groupId,
                            ));
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      minLeadingWidth: 0,
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    ListTile(
                      leading: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                      title: Text(
                        group.threadId.isNotEmpty ? 'Chat Thread Enabled' : 'Enable Chat Thread',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        group.threadId.isNotEmpty ? 'Thread ID: ${group.threadId}' : 'Add chat for all current and future members',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: controller.isCreatingThread.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : group.threadId.isNotEmpty
                              ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                              : const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onTap: group.threadId.isNotEmpty || controller.isCreatingThread.value ? null : controller.ensureChatThread,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      minLeadingWidth: 0,
                      enabled: group.threadId.isEmpty && !controller.isCreatingThread.value,
                    ),
                    // Show Invite Members only for private groups
                    // if (group.isPublic == "1" || group.isPublic == 1) ...[
                    //   const Divider(color: Colors.white12, height: 1),
                    //   ListTile(
                    //     leading: const Icon(Icons.person_add, color: Colors.white),
                    //     title: const Text('Invite Members', style: TextStyle(color: Colors.white)),
                    //     trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    //     onTap: () {
                    //       Get.to(() => InviteMembersScreen(
                    //             groupId: widget.groupId,
                    //           ));
                    //     },
                    //     contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    //     minLeadingWidth: 0,
                    //   ),
                    // ],

                    // const Divider(color: Colors.white12, height: 1),
                    // SwitchListTile(
                    //   secondary:
                    //       const Icon(Icons.notifications, color: Colors.white),
                    //   title: const Text('Notifications',
                    //       style: TextStyle(color: Colors.white)),
                    //   value: false,
                    //   onChanged: (val) {},
                    //   activeColor: const Color(0xFF7B61FF),
                    //   tileColor: const Color(0xFF232042),
                    //   contentPadding:
                    //       const EdgeInsets.symmetric(horizontal: 16),
                    // ),
                    // const Divider(color: Colors.white12, height: 1),
                    // SwitchListTile(
                    //   secondary: const Icon(Icons.lock, color: Colors.white),
                    //   title: const Text('Make Group Private',
                    //       style: TextStyle(color: Colors.white)),
                    //   value: group.isPublic == "1",
                    //   onChanged: (val) {},
                    //   activeColor: const Color(0xFF7B61FF),
                    //   tileColor: const Color(0xFF232042),
                    //   contentPadding:
                    //       const EdgeInsets.symmetric(horizontal: 16),
                    // ),
                  ],
                ),
              ),
              const Spacer(),
              // Delete Group Button
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: const Color(0xFF7B61FF),
              //       shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(16)),
              //       padding: const EdgeInsets.symmetric(vertical: 16),
              //     ),
              //     onPressed: () {},
              //     child: const Text('Delete Group',
              //         style: TextStyle(
              //             color: Colors.white, fontWeight: FontWeight.bold)),
              //   ),
              // ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}
