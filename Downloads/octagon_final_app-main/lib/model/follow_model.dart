// To parse this JSON data, do
//
//     final followResponseModel = followResponseModelFromJson(jsonString);

import 'dart:convert';

FollowResponseModel followResponseModelFromJson(String str) => FollowResponseModel.fromJson(json.decode(str));

String followResponseModelToJson(FollowResponseModel data) => json.encode(data.toJson());

class FollowResponseModel {
  FollowResponseModel({
    required this.success,
  });

  Success success;

  factory FollowResponseModel.fromJson(Map<String, dynamic> json) => FollowResponseModel(
    success: Success.fromJson(json["success"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success.toJson(),
  };
}

class Success {
  Success({
    required this.following,
    required this.followers,
  });

  int following;
  int followers;

  factory Success.fromJson(Map<String, dynamic> json) => Success(
    following: json["following"],
    followers: json["followers"],
  );

  Map<String, dynamic> toJson() => {
    "following": following,
    "followers": followers,
  };
}
