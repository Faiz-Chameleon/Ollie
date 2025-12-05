import 'package:equatable/equatable.dart';
import 'package:octagon/networking/model/chat_room.dart';

abstract class ChatScreenEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetMessageEvent extends ChatScreenEvent {
  ChatRoom? chatRoom;
  String? currentUser;
  String lastPage;
  GetMessageEvent({this.chatRoom,this.currentUser, this.lastPage = "",});

  @override
  List<Object?> get props => [chatRoom, currentUser, lastPage,];
}
