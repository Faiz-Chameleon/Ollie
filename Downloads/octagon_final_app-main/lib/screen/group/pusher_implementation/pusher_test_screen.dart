import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octagon/networking/network.dart';
import 'package:octagon/screen/group/pusher_implementation/pusher_service.dart';
import 'package:octagon/services/group_thread_service.dart';
import 'package:uuid/uuid.dart';

class PusherTestScreen extends StatefulWidget {
  const PusherTestScreen({Key? key}) : super(key: key);

  @override
  State<PusherTestScreen> createState() => _PusherTestScreenState();
}

class _PusherTestScreenState extends State<PusherTestScreen> {
  final TextEditingController _groupIdC = TextEditingController();
  final TextEditingController _groupNameC = TextEditingController();
  final TextEditingController _messageC = TextEditingController();
  final NetworkAPICall _api = NetworkAPICall();
  final PusherService _pusherService = Get.find<PusherService>();

  String? _threadId = "a06f82f1-021c-452a-8699-9911d398f88b";
  List<dynamic> _messages = [];
  bool _loading = false;
  StreamSubscription<dynamic>? _pusherSub;

  void _setLoading(bool v) => setState(() => _loading = v);

  Future<void> _createOrOpenThread() async {
    final gid = _groupIdC.text.trim();
    if (gid.isEmpty) return;
    _setLoading(true);
    try {
      final res = await _api.postApiCall('groups-create-chat-thread', {'group_id': gid});
      log('create thread res: $res');
      String? tid = GroupThreadService.extractThreadId(res);

      if (tid != null) {
        setState(() => _threadId = tid);
        Get.snackbar('Thread', 'Thread id: $tid');
      } else {
        Get.snackbar('Thread', 'Could not determine thread id from response');
      }
    } catch (e) {
      log('create thread error: $e');
      Get.snackbar('Error', e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _createGroupViaMessenger() async {
    final name = _groupNameC.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Validation', 'Please enter a group name');
      return;
    }

    _setLoading(true);
    try {
      // Use multipart helper so we can support avatar uploads later
      final body = {'subject': name};
      final res = await _api.multiPartPostRequest('api/messenger/groups', body, true, 'POST');
      log('create group (messenger/groups) res: $res');

      // The API returns the newly created thread object at top-level. Extract id.
      String? id;
      if (res is Map && res['id'] != null) id = res['id'].toString();
      if (id == null) {
        // Try to find nested id in resources.latest_message.meta.thread_id
        try {
          if (res is Map && res['resources'] != null && res['resources']['latest_message'] != null) {
            id = res['resources']['latest_message']['meta']?['thread_id']?.toString();
          }
        } catch (_) {}
      }

      if (id != null) {
        setState(() => _threadId = id);
        Get.snackbar('Created', 'Thread id: $id');
      } else {
        Get.snackbar('Error', 'Could not determine thread id from response');
      }
    } catch (e) {
      log('create group error: $e');
      Get.snackbar('Error', e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchMessages() async {
    if (_threadId == null) {
      Get.snackbar('Error', 'No thread id');
      return;
    }
    _setLoading(true);
    try {
      final res = await _api.getApiCall('messenger/threads/$_threadId/messages?per_page=50');
      log('messages res: $res');
      List<dynamic> msgs = [];
      if (res is Map && res['data'] is List) msgs = res['data'];
      if (res is List) msgs = res;
      setState(() => _messages = msgs);
    } catch (e) {
      log('fetch messages error: $e');
      Get.snackbar('Error', e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _subscribeThread() async {
    if (_threadId == null) {
      Get.snackbar('Error', 'No thread id');
      return;
    }
    try {
      try {
        await _pusherService.initializePusher();
      } catch (_) {}

      await _pusherService.subscribeToMessengerThread(_threadId!);

      _pusherSub?.cancel();
      _pusherSub = _pusherService.messageStream.listen((payload) {
        try {
          setState(() {
            _messages.insert(0, payload);
          });
        } catch (e) {
          log('pusher test stream parse error: $e');
        }
      });

      Get.snackbar('Subscribed', 'Subscribed to thread $_threadId');
    } catch (e) {
      log('subscribe error: $e');
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _sendMessage() async {
    if (_threadId == null) {
      Get.snackbar('Error', 'No thread id');
      return;
    }
    final text = _messageC.text.trim();
    if (text.isEmpty) return;
    _setLoading(true);
    try {
      final temp = Uuid().v4();
      final res = await _api.postApiCall('messenger/threads/$_threadId/messages', {'message': text, 'temporary_id': temp});
      log('send res: $res');
      _messageC.clear();
      // Optionally append to list optimistically
      setState(() {
        _messages.insert(0, res);
      });
    } catch (e) {
      log('send message error: $e');
      Get.snackbar('Error', e.toString());
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _pusherSub?.cancel();
    _groupIdC.dispose();
    _messageC.dispose();
    _groupNameC.dispose();
    super.dispose();
  }

  // Widget _buildConnectionIndicator() {
  //   return StreamBuilder<bool>(
  //     stream: _pusherService.connectedStream,
  //     initialData: _pusherService.isConnected,
  //     builder: (context, snap) {
  //       final connected = snap.data ?? false;
  //       return Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(Icons.circle, size: 12, color: connected ? Colors.green : Colors.red),
  //           const SizedBox(width: 8),
  //           Text(connected ? 'Connected' : 'Disconnected'),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusher Test'),
        // actions: [Padding(padding: const EdgeInsets.all(8.0), child: _buildConnectionIndicator())],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _groupIdC,
              decoration: const InputDecoration(labelText: 'Group ID', hintText: 'Enter group id'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _groupNameC,
              decoration: const InputDecoration(labelText: 'Group Name', hintText: 'Enter group name to create'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _createOrOpenThread,
                  child: const Text('Create/Open Thread'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _createGroupViaMessenger,
                  child: const Text('Create Group (messenger/groups)'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _fetchMessages,
                  child: const Text('Fetch Messages'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _subscribeThread,
                  child: const Text('Subscribe'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_threadId != null) Text('Thread: $_threadId'),
            const SizedBox(height: 12),
            TextField(
              controller: _messageC,
              decoration: const InputDecoration(labelText: 'Message', hintText: 'Type message to send'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loading ? null : _sendMessage, child: const Text('Send Message')),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? const Center(child: Text('No messages'))
                      : ListView.separated(
                          reverse: true,
                          itemCount: _messages.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final m = _messages[index];
                            String body = '';
                            try {
                              if (m is Map && m['message'] != null)
                                body = m['message'].toString();
                              else
                                body = m.toString();
                            } catch (e) {
                              body = m.toString();
                            }
                            return ListTile(
                              title: Text(body),
                              subtitle: Text(m is Map && m['sender'] != null ? m['sender'].toString() : ''),
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}
