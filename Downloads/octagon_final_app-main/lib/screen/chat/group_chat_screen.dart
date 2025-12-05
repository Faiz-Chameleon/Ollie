import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octagon/model/team_list_response.dart';
import 'package:octagon/networking/model/chat_message.dart';
import 'package:octagon/networking/model/chat_room.dart';
import 'package:octagon/networking/model/enum/chat_room_type.dart';
import 'package:octagon/networking/response.dart';
import 'package:octagon/screen/chat_network/bloc/chat_bloc.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/widgets/chat_message_widget.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String? groupPhoto;
  final List<String> members;

  const GroupChatScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
    this.groupPhoto,
    required this.members,
  }) : super(key: key);

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final ChatBloc chatBloc = ChatBloc();
  final TextEditingController messageController = TextEditingController();
  final storage = GetStorage();
  final ScrollController scrollController = ScrollController();
  List<ChatMessageData> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    // Create a ChatRoom object for the group
    final chatRoom = ChatRoom(
      id: widget.groupId,
      name: widget.groupName,
      image: widget.groupPhoto,
      type: ChatRoomType.GROUP,
      occupantIds: widget.members,
      createdOn: DateTime.now(),
    );

    // Listen to chat messages
    chatBloc.dataStream.listen((response) {
      try {
        // Add null check for response itself
        if (response == null) {
          print('Warning: Received null response');
          setState(() => isLoading = false);
          return;
        }

        // Add null check for status
        if (response.status == null) {
          print('Warning: Received response with null status');
          setState(() => isLoading = false);
          return;
        }

        switch (response.status!) {
          case Status.LOADING:
            setState(() => isLoading = true);
            break;
          case Status.COMPLETED:
            if (response.data != null) {
              setState(() {
                messages = response.data!;
                isLoading = false;
              });
              _scrollToBottom();
            } else {
              // Handle case where data is null
              setState(() => isLoading = false);
              print('Warning: Received completed response with null data');
            }
            break;
          case Status.ERROR:
            setState(() => isLoading = false);
            print('Chat error: ${response.message}');
            Get.snackbar(
              "Error",
              "Failed to load messages: ${response.message ?? 'Unknown error'}",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            break;
        }
      } catch (e) {
        print('Error in stream listener: $e');
        setState(() => isLoading = false);
        Get.snackbar(
          "Error",
          "An error occurred while processing messages",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }, onError: (error) {
      print('Stream error: $error');
      setState(() => isLoading = false);
      Get.snackbar(
        "Error",
        "Failed to connect to chat",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });

    // Get current user ID and convert to string
    final userId = storage.read("current_uid");
    if (userId == null) {
      Get.snackbar(
        "Error",
        "User ID not found",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Start listening to messages with string user ID
    final userIdString = userId.toString();
    chatBloc.getChatMessages(chatRoom, userIdString);
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final userId = storage.read("current_uid");
    final userIdString = userId != null ? userId.toString() : null;

    final message = ChatMessageData(
      content: messageController.text.trim(),
      senderUid: userIdString,
      senderName: storage.read("user_name"),
      senderImage: storage.read("image_url"),
      senderTeam: storage.read("userDefaultTeam"),
      firebaseToken: storage.read("fcm_token"),
      docId: const Uuid().v4(),
      createdOn: DateTime.now(),
    );

    messageController.clear();

    try {
      await chatBloc.sendMessage(
        message,
        TeamData(
          id: int.parse(widget.groupId),
          strTeam: widget.groupName,
          strTeamLogo: widget.groupPhoto,
        ),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send message + ${e}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: appBgColor,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[700],
              backgroundImage:
                  (widget.groupPhoto != null && widget.groupPhoto!.isNotEmpty)
                      ? NetworkImage(widget.groupPhoto!)
                      : null,
              child: (widget.groupPhoto == null || widget.groupPhoto!.isEmpty)
                  ? const Icon(Icons.group, color: Colors.white)
                  : null,
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(width: 10),
            Text(widget.groupName, style: whiteColor20BoldTextStyle),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    itemCount: messages.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe =
                          message.senderUid == storage.read("current_uid");

                      return ChatMessageWidget(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
