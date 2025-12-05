
import 'package:octagon/networking/model/user_response_model.dart';

import 'enum/chat_room_type.dart';

class ChatRoom {
  String? id;
  DateTime? createdOn;
  String? image;
  String? name;
  ChatRoomType? type;
  List<String>? occupantIds;
  Map<String, UserModel>? occupants;

  String? lastMessage = "";
  List<UserModel>? opponent;

  ChatRoom(
      {this.id,
        this.occupantIds,
        this.occupants,
        this.type,
        this.createdOn,
        this.image,
        this.name,this.lastMessage = "", this.opponent}) ;

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      ChatRoom(
        id: json["id"],
        createdOn: json["createdOn"],
        name: json["name"],
        lastMessage: json["lastMessage"],
        type: json["type"],
        image: json["image"],
        occupantIds: json["occupantIds"],
        occupants: json["occupants"],
        opponent: json["opponent"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "createdOn": createdOn,
    "name": name,
    "lastMessage": lastMessage,
    "type": type,
    "image": image,
    "occupantIds": occupantIds,
    "occupants": occupants,
    "opponent": opponent
  };

}