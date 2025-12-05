
import 'dart:convert';

CreatePostResponseModel loginResponseModelFromJson(String str) => CreatePostResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(CreatePostResponseModel data) => json.encode(data.toJson());

class CreatePostResponseModel {
  CreatePostResponseModel({
    this.success,
  });

  Success? success;

  factory CreatePostResponseModel.fromJson(Map<String, dynamic> json) => CreatePostResponseModel(
    success: Success.fromJson(json["success"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success!.toJson(),
  };
}

class Success {
  Success({
    this.userId,
    this.title,
    this.location,
    this.type,
    this.post,
    this.comment,
    this.created_at,
    this.share_url
  });

  int? userId;
  String? title;
  String? post;
  String? type;
  String? location;
  String? comment;
  String? created_at;
  String? share_url;

  factory Success.fromJson(Map<String, dynamic> json) => Success(
      userId: json["user_id"],
      title: json["title"],
      post: json["post"],
      type: json["type"],
      location: json["location"],
      comment: json["comment"],
      created_at: json["created_at"],
      share_url: json["share_url"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "title": title,
    "post": post,
    "type": type,
    "location": location,
    "comment": comment,
    "created_at": created_at,
    "share_url": share_url,
  };
}
