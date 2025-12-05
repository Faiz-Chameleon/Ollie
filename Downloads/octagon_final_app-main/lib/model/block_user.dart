// To parse this JSON data, do
//
//     final blockUser = blockUserFromJson(jsonString);

import 'dart:convert';

BlockUserModel blockUserFromJson(String str) => BlockUserModel.fromJson(json.decode(str));

String blockUserToJson(BlockUserModel data) => json.encode(data.toJson());

class BlockUserModel {
  BlockUserModel({
    required this.blockUserData,
  });

  List<BlockUserData> blockUserData;

  factory BlockUserModel.fromJson(Map<String, dynamic> json) => BlockUserModel(
    blockUserData: List<BlockUserData>.from(json["success"].map((x) => BlockUserData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": List<dynamic>.from(blockUserData.map((x) => x.toJson())),
  };
}

class BlockUserData {
  BlockUserData({
    required this.id,
    required this.name,
    required this.photo,
  });

  int id;
  String name;
  String photo;

  factory BlockUserData.fromJson(Map<String, dynamic> json) => BlockUserData(
    id: json["id"],
    name: json["name"]??"",
    photo: json["photo"]??"",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "photo": photo,
  };
}
