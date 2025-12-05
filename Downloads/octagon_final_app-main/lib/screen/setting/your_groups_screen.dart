import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octagon/main.dart';
import 'package:octagon/screen/chat/group_chat_screen.dart';
import 'package:octagon/screen/setting/group_controller.dart';
import 'package:octagon/utils/colors.dart';

import '../chat/new_groupchat_screen.dart';

class YourGroupsScreen extends StatefulWidget {
  @override
  State<YourGroupsScreen> createState() => _YourGroupsScreenState();
}

class _YourGroupsScreenState extends State<YourGroupsScreen> {
  late final GroupController controller;

  @override
  void initState() {
    super.initState();
    try {
      controller = Get.find<GroupController>();
    } catch (e) {
      controller = Get.put(GroupController());
    }
    // Delay the fetch to avoid build-time issues
    Future.delayed(Duration.zero, () {
      controller.fetchGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131F),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text("Your Groups", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          Widget content;
          if (controller.isLoading.value) {
            content = const Center(child: CircularProgressIndicator());
          } else if (controller.groups.isEmpty) {
            content = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.group_off, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No groups available",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          } else {
            content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 24),
                const Text("Groups", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                // Group List
                ...controller.groups.map((group) => GestureDetector(
                      onTap: () {
                        // Navigate to group chat
                        Get.to(() => NewGroupChatScreen(
                              groupId: group.id.toString(),
                              isPublic: group.isPublic == 0 ? false : true,
                              userId: storage.read("current_uid").toString(),
                              userName: storage.read("user_name").toString(),
                              groupName: group.title,
                              groupImage: group.photo.toString(),
                              userImage: storage.read('image_url'),
                              thread_id: group.threadId.toString(),
                            ));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2244),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            if (group.photo != null && group.photo!.isNotEmpty)
                              Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage("${"http://3.134.119.154/"}${group.photo!}"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey,
                                ),
                                child: const Icon(
                                  Icons.group,
                                  color: Colors.white,
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(group.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  if (group.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        group.description != '""' ? group.description : "",
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    )),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Create New Group Button
              // GestureDetector(
              //   onTap: () => controller.createNewGroup(),
              //   child: Container(
              //     padding:
              //         const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              //     decoration: BoxDecoration(
              //       color: const Color(0xFF2D2244),
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: Row(
              //       children: const [
              //         Icon(Icons.add, color: Colors.white),
              //         SizedBox(width: 10),
              //         Text("Create New Group",
              //             style: TextStyle(color: Colors.white)),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 8),
              Expanded(child: content),
            ],
          );
        }),
      ),
    );
  }
}
