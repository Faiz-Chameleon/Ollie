
import 'package:octagon/networking/exception/exception.dart';
import 'package:octagon/networking/model/chat_message.dart';

class ChatInitialState extends ChatScreenState {}

class ChatLoadingBeginState extends ChatScreenState {}

class ChatLoadingEndState extends ChatScreenState {}

abstract class ChatScreenState {}

class GetChatMessageState extends ChatScreenState{
  List<ChatMessageData> chatMessages;
  GetChatMessageState(this.chatMessages);
}

class ChatErrorState extends ChatScreenState {
  AppException exception;

  ChatErrorState(this.exception);
}