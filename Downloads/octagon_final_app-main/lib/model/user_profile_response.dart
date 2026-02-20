// To parse this JSON data, do
//
//     final userProfileResponseModel = userProfileResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:octagon/networking/model/response_model/SportInfoModel.dart';
import 'package:octagon/networking/model/user_response_model.dart';

UserProfileResponseModel userProfileResponseModelFromJson(String str) => UserProfileResponseModel.fromJson(json.decode(str));

String userProfileResponseModelToJson(UserProfileResponseModel data) => json.encode(data.toJson());

class UserProfileResponseModel {
  UserProfileResponseModel({
    this.success,
  });

  Success? success;

  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) => UserProfileResponseModel(
        success: Success.fromJson(json["success"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success!.toJson(),
      };
}

class Success {
  Success({
    this.following,
    this.followingUsers,
    this.followers,
    this.followersUsers,
    this.user,
    this.postCount,
    // ignore: non_constant_identifier_names
    this.follow_status,
    // this.post,
    this.favoritePostCount,
    // this.favoritePost,
    this.savePostCount,
    // this.savePost,
    this.likePostCount,
    this.sportInfo,

    // this.likePost,
  });

  int? following;
  List<UserModel>? followingUsers;
  int? followers;
  List<UserModel>? followersUsers;
  UserModel? user;
  int? postCount;
  int? favoritePostCount;
  bool? follow_status;
  // List<PostResponseModelData>? post;
  // List<PostResponseModelData>? favoritePost;
  int? savePostCount;
  // List<PostResponseModelData>? savePost;
  int? likePostCount;
  List<SportInfo>? sportInfo;
  // List<PostResponseModelData>? likePost;

  factory Success.fromJson(Map<String, dynamic> json) => Success(
        following: json["following"],
        followingUsers: List<UserModel>.from(json["followingUsers"].map((x) => UserModel.fromJson(x))),
        followers: json["followers"],
        followersUsers: List<UserModel>.from(json["followersUsers"].map((x) => UserModel.fromJson(x))),
        user: UserModel.fromJson(json["user"]),
        postCount: json["post_count"],
        favoritePostCount: json["favorite_post_count"],
        follow_status: json["follow_status"],
        // post: List<PostResponseModelData>.from(json["post"].map((x) => PostResponseModelData.fromJson(x))),
        // favoritePost: List<PostResponseModelData>.from(json["favorite_post"].map((x) => PostResponseModelData.fromJson(x))),
        savePostCount: json["save_post_count"],
        // savePost: List<PostResponseModelData>.from(json["save_post"].map((x) => PostResponseModelData.fromJson(x))),
        likePostCount: json["like_post_count"],
        sportInfo: json["sport_info"] == null ? null : List<SportInfo>.from(json["sport_info"].map((x) => SportInfo.fromJson(x))),
        // likePost: List<PostResponseModelData>.from(json["like_post"].map((x) => PostResponseModelData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "following": following,
        "followingUsers": List<dynamic>.from(followingUsers!.map((x) => x.toJson())),
        "followers": followers,
        "followersUsers": List<dynamic>.from(followersUsers!.map((x) => x.toJson())),
        "user": user!.toJson(),
        "follow_status": follow_status,
        "post_count": postCount,
        "favorite_post_count": favoritePostCount,
        // "post": List<PostResponseModelData>.from(post!.map((x) => x.toJson())),
        "save_post_count": savePostCount,
        // "save_post": List<PostResponseModelData>.from(savePost!.map((x) => x.toJson())),
        "like_post_count": likePostCount,
        "sport_info": List<dynamic>.from(sportInfo!.map((x) => x.toJson())),
        // "like_post": List<PostResponseModelData>.from(likePost!.map((x) => x.toJson())),
      };
}
