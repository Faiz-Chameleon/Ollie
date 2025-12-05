import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:octagon/model/team_list_response.dart';
import 'package:octagon/networking/model/chat_message.dart';
import 'package:http/http.dart' as http;
import 'package:octagon/networking/model/chat_room.dart';
import 'package:octagon/networking/response.dart';
import 'package:octagon/screen/chat_network/bloc/chat_repo.dart';

class ChatBloc {
  ChatRepository? _chatRepository;

  late StreamController<Response<List<ChatMessageData>>> chatMessageController;

  late StreamController<Response> roomController;

  StreamSink<Response<List<ChatMessageData>>> get dataSink =>
      chatMessageController.sink;

  Stream<Response<List<ChatMessageData>>> get dataStream =>
      chatMessageController.stream;

  StreamSink<Response> get roomDataSink => roomController.sink;

  Stream<Response> get roomDataStream => roomController.stream;

  ChatBloc() {
    chatMessageController = StreamController<Response<List<ChatMessageData>>>();
    _chatRepository = ChatRepository(FirebaseFirestore.instance);
    roomController = StreamController<Response>();
  }

  List<ChatMessageData> fetchedMessageItem =
      List<ChatMessageData>.empty(growable: true);

  sendMessage(ChatMessageData message, TeamData sportInfo) async {
    try {
      message.createdOn = DateTime.now();
      message.updatedAt = DateTime.now();

      DocumentReference responseData = await _chatRepository!
          .sendMessage(message: message, sportInfo: sportInfo);

      print('Message sent successfully: ${responseData.id}');
      // Don't send completion response - let the real-time listener handle it
    } catch (e) {
      print('Error sending message: $e');
      dataSink.add(Response.error(e.toString()));
    }
  }

  sendReplayMessage(ChatMessageData message, String groupId) async {
    try {
      message.createdOn = DateTime.now();
      message.updatedAt = DateTime.now();

      DocumentReference responseData = await _chatRepository!
          .sendReplayMessage(message: message, groupId: groupId);

      print('Reply sent successfully: ${responseData.id}');
      // Don't send completion response - let the real-time listener handle it
    } catch (e) {
      print('Error sending reply: $e');
      dataSink.add(Response.error(e.toString()));
    }
  }

  getChatMessages(ChatRoom chatRoom, String currentUser,
      {String? lastPage = ""}) {
    try {
      print('Starting getChatMessages for room: ${chatRoom.id}');
      dataSink.add(Response.loading('Loading messages...'));

      Query<Map<String, dynamic>> queryRef = FirebaseFirestore.instance
          .collection('chat_rooms/${chatRoom.id}/messages');

      print('Query path: chat_rooms/${chatRoom.id}/messages');

      if (lastPage != null && lastPage.isNotEmpty) {
        queryRef = queryRef
            .orderBy("createdOn", descending: true)
            .limit(50)
            .startAfter([lastPage]);
      } else {
        queryRef = queryRef.orderBy("createdOn", descending: true).limit(50);
      }

      queryRef.snapshots().listen((event) {
        print('Received snapshot with ${event.docs.length} documents');
        try {
          List<ChatMessageData> chatMessages = [];
          for (var value in event.docs.toList()) {
            try {
              print('Processing document: ${value.id}');
              print('Document data: ${value.data()}');
              ChatMessageData data = ChatMessageData.fromJson(value.data());
              data.currentUserUid = currentUser;
              chatMessages.add(data);
            } catch (parseError) {
              print('Error parsing message ${value.id}: $parseError');
              print('Message data: ${value.data()}');
              // Continue with other messages instead of failing completely
            }
          }
          print('Successfully parsed ${chatMessages.length} messages');
          dataSink.add(Response.completed(chatMessages));
        } catch (error) {
          print('Error processing messages: $error');
          dataSink.add(Response.error('Failed to process messages'));
        }
      }, onError: (error) {
        print('Error fetching messages: $error');
        dataSink.add(Response.error('Failed to load messages'));
      });
    } catch (e) {
      print('Exception in getChatMessages: $e');
      dataSink.add(Response.error('Failed to load messages'));
    }
  }

  getChatRooms(TeamData sportInfo) {
    roomDataSink.add(Response.loading('getting chat rooms..'));
    try {
      // _chatRepository!.getPopularChatRooms(sportInfo);

      _chatRepository!.getPopularChatRooms(sportInfo).then((value) {
        print(value);
        roomDataSink.add(Response.completed(value));
      });
    } catch (e) {
      roomDataSink.add(Response.error(e.toString()));
    }
  }

  sendNotifications(
      {required String subject,
      required String description,
      required String token}) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAAeyvqWOE:APA91bEikAqlSZ2TL-fMcsPEjoneQ0b6d3vAL309wk7PXtYl-xtm52z45ebaDXyMUvzh-JiTlOoK-a8gVcPyM8BllGj7dWL6F7GoUlhCQm_iyRq0TPrMZsPnqcqGuC6Ko7coZ4Q-tHWX'
    };
    var request =
        http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
    request.body = json.encode({
      "to": token,
      "notification": {
        "title": subject,
        "body": description,
        "subtitle": subject,
        "OrganizationId": "2",
        "content_available": true,
        "priority": "low",
      },
      "data": {
        "priority": "low",
        "content_available": true,
        "bodyText": description,
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // showMessage(msg: "Notifications has been sent to all users!");
      print(await response.stream.bytesToString());
    } else {
      // showMessage(msg: "Something went wrong! Please try again later!!");
      print(response.reasonPhrase);
    }
  }
}
