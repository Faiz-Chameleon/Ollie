import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'blocked_users_controller.dart';

class BlockedUsersScreen extends StatefulWidget {
  final String threadId;
  const BlockedUsersScreen({super.key, required this.threadId});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  late final BlockedUsersController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(BlockedUsersController(widget.threadId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blocked Users')),
      backgroundColor: const Color(0xFF18162A),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchBlockedUsers,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (controller.users.isEmpty) {
          return const Center(
            child: Text('No blocked users.', style: TextStyle(color: Colors.white)),
          );
        }
        return RefreshIndicator(
          color: Colors.deepPurple,
          backgroundColor: const Color(0xFF232042),
          onRefresh: controller.fetchBlockedUsers,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.users.length,
            itemBuilder: (context, index) {
              final user = controller.users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.photo.isNotEmpty ? NetworkImage(user.photo) : null,
                  child: user.photo.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                  backgroundColor: Colors.deepPurple,
                ),
                title: Text(user.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(user.email, style: const TextStyle(color: Colors.grey)),
                trailing: TextButton(
                  onPressed: () => controller.unblockUser(user.userId),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                  child: const Text('Unblock', style: TextStyle(color: Colors.black)),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
