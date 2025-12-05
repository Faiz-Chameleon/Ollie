import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:octagon/model/team_list_response.dart';
import 'package:octagon/networking/model/chat_message.dart';
import 'package:octagon/networking/model/chat_room.dart';

class ChatRepository {
  final DB_REF_CHATS = "chat_rooms";

  FirebaseFirestore fireStore;

  ChatRepository(this.fireStore);

  ///add message
  Future<DocumentReference> sendMessage({required ChatMessageData message, required TeamData sportInfo}) async {

    DocumentReference ref =  fireStore.collection('$DB_REF_CHATS/${sportInfo.id}/messages').doc();

    message.docId = ref.id;

    fireStore.collection(DB_REF_CHATS).doc("${sportInfo.id}").
    set(sportInfo.toJson()).then((value) {

    }).onError((error, stackTrace) {
      print(error);
    });

    await ref.set(message.toJson());
    return ref;
  }

  ///update message for replay
  Future<DocumentReference> sendReplayMessage({required ChatMessageData message, required String groupId}) async {

    DocumentReference ref = fireStore.collection('$DB_REF_CHATS/$groupId/messages').doc(message.docId);

    await ref.update({"replay": jsonEncode(message.replay!), "likeCount": message.likeCount, "likeUsers": jsonEncode(message.likeUsers!)}).then((value) {
      print("success");
    }).catchError((onError){
      print("$onError");
    });
    return ref;
  }

  ///get chat messages specific to chat group.
  Stream<QuerySnapshot> getChatMessages(ChatRoom chatRoom, {String? lastPage = ""}) {
    Query<Map<String, dynamic>> queryRef = fireStore.collection('$DB_REF_CHATS/${chatRoom.id}/messages');

    if(lastPage!=null && lastPage.isNotEmpty){
      queryRef = queryRef.orderBy("createdOn", descending: true)
          .limit(50)
          .startAfter([lastPage]);
    }else{
      queryRef = queryRef.orderBy("createdOn", descending: true)
          .limit(50);
    }
    queryRef.snapshots().listen((event) {
      print(event);
    });
    return queryRef.snapshots();
  }

  ///to get chat rooms belongs to current user.
  Future<List<TeamData>> getChatRoom(TeamData sportInfo) async {
    List<TeamData> sportInfoData = [];
    var value = await FirebaseFirestore.instance
        .collection(DB_REF_CHATS)
        .where('sportId', isEqualTo: sportInfo.sportId)
        .get();

    for (var element in value.docs) {

      var dataa = element.data() as Map;

      if(sportInfoData.length < 9){
        sportInfoData.add(TeamData.fromJson(dataa));
      }
    }

    return sportInfoData;
  }

  Future<List<TeamData>> getPopularChatRooms(TeamData sportInfo) async {
    List<TeamData> sportInfoData = [];

    final chatRoomsRef = FirebaseFirestore.instance.collection('chat_rooms');

    // Get all chat rooms
    QuerySnapshot chatRoomsSnapshot = await chatRoomsRef.get();

    // List to hold the chat room and message count
    List<Map<String, dynamic>> popularChatRooms = [];

    // Loop through each chat room
    for (var chatRoom in chatRoomsSnapshot.docs) {
      if (chatRoom['sportId'] == sportInfo.sportId) {
        // Get the messages subcollection for each chat room
        final messagesRef = chatRoomsRef
            .doc(chatRoom.id)
            .collection('messages')
            .orderBy('createdOn', descending: true); // Optionally order by createdOn

        // Fetch messages and count them
        QuerySnapshot messagesSnapshot = await messagesRef.get();
        int messageCount = messagesSnapshot.docs.length;

        // Add chat room and message count to list
        popularChatRooms.add({
          'chatRoomId': chatRoom.id,
          'chatRoomData': chatRoom.data(),
          'messageCount': messageCount,
          'latestMessage': messagesSnapshot.docs.isNotEmpty
              ? messagesSnapshot.docs.first['createdOn'] // Latest message timestamp
              : null
        });
      }
    }

    // Sort chat rooms by message count in descending order
    popularChatRooms.sort((a, b) => b['messageCount'].compareTo(a['messageCount']));

    for(var data in popularChatRooms){
      sportInfoData.add(TeamData.fromJson(data["chatRoomData"]));
    }

    return sportInfoData;
  }


  ///remove message
  Future<void> removeMessage(ChatMessageData message) async {
    var snapshot = await fireStore.collection(DB_REF_CHATS).doc(""/*message.id*/).delete();
    return snapshot;
  }

}