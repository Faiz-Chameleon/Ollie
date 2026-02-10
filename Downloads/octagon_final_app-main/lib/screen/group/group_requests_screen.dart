import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'group_requests_controller.dart';

class GroupRequestsScreen extends StatefulWidget {
  final String groupId;
  const GroupRequestsScreen({super.key, required this.groupId});

  @override
  State<GroupRequestsScreen> createState() => _GroupRequestsScreenState();
}

class _GroupRequestsScreenState extends State<GroupRequestsScreen> {
  late final GroupRequestsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(GroupRequestsController(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Requests')),
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
                  onPressed: controller.fetchRequests,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (controller.requests.isEmpty) {
          return const Center(
            child: Text('No requests.', style: TextStyle(color: Colors.white)),
          );
        }
        return RefreshIndicator(
          color: Colors.deepPurple,
          backgroundColor: const Color(0xFF232042),
          onRefresh: controller.fetchRequests,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.requests.length,
            itemBuilder: (context, index) {
              final request = controller.requests[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: request.photo.isNotEmpty ? NetworkImage(request.photo) : null,
                  child: request.photo.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                  backgroundColor: Colors.deepPurple,
                ),
                title: Text(request.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(request.email, style: const TextStyle(color: Colors.grey)),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => controller.acceptRequest(request),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                      child: const Text('Accept', style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () => controller.rejectRequest(request),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.white),
                        ),
                      ),
                      child: const Text('Reject', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
