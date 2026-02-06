// To parse this JSON data, do
//
//     final postResponseModel = postResponseModelFromJson(jsonString);

import 'dart:convert';
import 'package:octagon/networking/model/response_model/SportInfoModel.dart';

import 'user_data_model.dart';

PostResponseModel postResponseModelFromJson(String str) => PostResponseModel.fromJson(json.decode(str));

String postResponseModelToJson(PostResponseModel data) => json.encode(data.toJson());

class PostResponseModel {
  PostResponseModel({this.success, this.successForCreatePost, this.size, this.more, this.page, this.total, this.totalPage, this.error});

  List<PostResponseModelData>? success;
  PostResponseModelData? successForCreatePost;
  int? total;
  String? size;
  int? totalPage;
  String? page;
  bool? more;
  String? error;

  factory PostResponseModel.fromJson(Map<String, dynamic> json) => PostResponseModel(
        success: json["success"] != null ? List<PostResponseModelData>.from(json["success"].map((x) => PostResponseModelData.fromJson(x))) : [],
        size: "${json["size"]}",
        more: json["more"],
        page: "${json["page"]}",
        total: json["total"] ?? 0,
        totalPage: json["total_page"] ?? 0,
        error: json["error"] == null ? null : json["error"],
      );

  factory PostResponseModel.fromJsonForCreatePost(Map<String, dynamic> json) => PostResponseModel(
        successForCreatePost: PostResponseModelData.fromJson(json["success"]),
      );

  Map<String, dynamic> toJson() => {
        "success": List<PostResponseModelData>.from(success!.map((x) => x.toJson())),
      };
}

class PostResponseModelData {
  PostResponseModelData({
    this.id,
    this.userId,
    this.title,
    this.post,
    this.type,
    this.location,
    this.shareUrl,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
    this.userName,
    this.photo,
    this.likes = 0,
    this.userLikes,
    this.isSaveByMe = false,
    this.isLikedByMe = false,
    this.isUserFollowedByMe = false,
    this.comments,
    this.videos,
    this.thumbUrl,
    this.images,
    this.sportInfo,
    this.user_group_img,
    this.groupType,
    this.originalUser,
    this.is_repost,
    this.userGroupType,
  });

  int? is_repost;
  String? groupType;
  int? id;
  int? userId;
  String? post;
  String? title;
  String? type;

  ///1-Post, 2-Story, 3-Reels
  String? location;
  String? shareUrl;
  String? comment;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? isDeleted;
  String? userName;
  String? user_group_img;
  String? photo;
  int likes;
  List<UserLikes>? userLikes;
  List<SuccessComment>? comments;
  List<ImageData>? videos;
  String? thumbUrl;
  List<ImageData>? images;

  bool isLikedByMe;
  bool isUserFollowedByMe;
  bool isSaveByMe;
  List<SportInfo>? sportInfo;
  OriginalUser? originalUser;
  String? userGroupType;

  factory PostResponseModelData.fromJson(Map<String, dynamic> json) => PostResponseModelData(
        id: json["id"],
        user_group_img: json["user_group_img"],
        userId: json["user_id"],
        post: json["post"],
        title: json["title"],
        type: json["type"],
        location: json["location"],
        shareUrl: json["share_url"],
        comment: json["comment"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]).toLocal(),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]).toLocal(),
        isDeleted: json["is_deleted"],
        userName: json["user_name"],
        photo: json["photo"],
        likes: json["likes"],
        isLikedByMe: json["like_by_me"] != 0,
        isUserFollowedByMe: json["is_user_follow"] != 0,
        groupType: json["user_type_label"] ?? "",

        ///koi mane follow kartu hoi to.
        isSaveByMe: json["save_by_me"] != 0,
        sportInfo: json["sport_info"] == null ? null : List<SportInfo>.from(json["sport_info"].map((x) => SportInfo.fromJson(x))),
        userLikes: json["user_likes"] != null ? List<UserLikes>.from(json["user_likes"].map((x) => UserLikes.fromJson(x))) : null,
        comments: json["comments"] == null ? null : List<SuccessComment>.from(json["comments"].map((x) => SuccessComment.fromJson(x))),
        videos: json["videos"] == null ? null : List<ImageData>.from(json["videos"].map((x) => ImageData.fromJson(x))),
        thumbUrl: json["thumb_url"] == null ? null : json["thumb_url"] ?? "",
        images: json["images"] == null ? null : List<ImageData>.from(json["images"].map((x) => ImageData.fromJson(x))),
        originalUser: json["original_user"] != null ? OriginalUser.fromJson(json["original_user"]) : null,
        is_repost: json["is_repost"],
        userGroupType: json["user_type_label"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "user_group_img": user_group_img,
        "post": post,
        "type": type,
        "title": title,
        "location": location == null ? null : location,
        "share_url": shareUrl,
        "comment": comment,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "is_deleted": isDeleted,
        "user_name": userName,
        "photo": photo,
        "likes": likes,
        "is_user_follow": isUserFollowedByMe,
        "like_by_me": isLikedByMe,
        "save_by_me": isSaveByMe,
        "sport_info": List<dynamic>.from(sportInfo!.map((x) => x.toJson())),
        "comments": List<SuccessComment>.from(comments!.map((x) => x.toJson())),
        "videos": List<ImageData>.from(videos!.map((x) => x.toJson())),
        "thumb_url": thumbUrl,
        "images": List<ImageData>.from(images!.map((x) => x.toJson())),
        "groupType": groupType,
        "original_user": originalUser?.toJson(),
        "is_repost": is_repost,
        "userGroupType": userGroupType,
      };
}

class OriginalUser {
  OriginalUser({
    this.id,
    this.name,
    this.photo,
    this.userType,
  });

  int? id;
  String? name;
  String? photo;
  String? userType;

  factory OriginalUser.fromJson(Map<String, dynamic> json) => OriginalUser(
        id: json["id"],
        name: json["name"],
        photo: json["photo"],
        userType: json["user_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "photo": photo,
        "user_type": userType,
      };
}

class SuccessComment {
  SuccessComment(
      {this.id, this.userId, this.postId, this.comment, this.parentCommentId, this.createdAt, this.users, this.comments, this.isShowMore = false});

  int? id;
  int? userId;
  int? postId;
  String? comment;
  int? parentCommentId;
  DateTime? createdAt;
  Users? users;
  List<SuccessComment>? comments;
  bool isShowMore = false;

  factory SuccessComment.fromJson(Map<String, dynamic> json) => SuccessComment(
      id: json["id"],
      userId: json["user_id"],
      postId: json["post_id"],
      comment: json["comment"],
      parentCommentId: json["parent_comment_id"],
      createdAt: DateTime.parse(json["created_at"]),
      users: Users.fromJson(json["users"]),
      comments: json["comments"] == null ? null : List<SuccessComment>.from(json["comments"].map((x) => SuccessComment.fromJson(x))),
      isShowMore: false);

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "post_id": postId,
        "comment": comment,
        "parent_comment_id": parentCommentId,
        "created_at": createdAt!.toIso8601String(),
        "users": users!.toJson(),
        "comments": comments == null ? null : List<SuccessComment>.from(comments!.map((x) => x.toJson())),
      };
}

class UserLikes {
  UserLikes({
    this.id,
    this.userId,
    this.contentId,
    this.type,
    this.createdAt,
  });

  int? id;
  int? userId;
  int? contentId;
  int? type;
  DateTime? createdAt;

  factory UserLikes.fromJson(Map<String, dynamic> json) => UserLikes(
      id: json["id"], userId: json["user_id"], contentId: json["content_id"], type: json["comment"], createdAt: DateTime.parse(json["created_at"]));

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "content_id": contentId,
        "type": type,
        "created_at": createdAt!.toIso8601String(),
      };
}

// class CommentComment {
//   CommentComment({
//     this.id,
//     this.userId,
//     this.postId,
//     this.comment,
//     this.parentCommentId,
//     this.createdAt,
//     this.users,
//   });
//
//   int? id;
//   int? userId;
//   int? postId;
//   String? comment;
//   int? parentCommentId;
//   DateTime? createdAt;
//   Users? users;
//
//   factory CommentComment.fromJson(Map<String, dynamic> json) => CommentComment(
//     id: json["id"],
//     userId: json["user_id"],
//     postId: json["post_id"],
//     comment: json["comment"],
//     parentCommentId: json["parent_comment_id"],
//     createdAt: DateTime.parse(json["created_at"]),
//     users: Users.fromJson(json["users"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "user_id": userId,
//     "post_id": postId,
//     "comment": comment,
//     "parent_comment_id": parentCommentId,
//     "created_at": createdAt?.toIso8601String(),
//     "users": users?.toJson(),
//   };
// }

class ImageData {
  ImageData({
    this.id,
    this.userId,
    this.postId,
    this.filePath,
    this.type,
    this.shareUrl,
    this.createdAt,
  });

  int? id;
  int? userId;
  int? postId;
  String? filePath;
  String? type;
  String? shareUrl;
  DateTime? createdAt;

  factory ImageData.fromJson(Map<String, dynamic> json) => ImageData(
        id: json["id"],
        userId: json["user_id"],
        postId: json["post_id"],
        filePath: json["file_path"],
        type: json["type"],
        shareUrl: json["share_url"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "post_id": postId,
        "file_path": filePath,
        "type": type,
        "share_url": shareUrl,
        "created_at": createdAt!.toIso8601String(),
      };
}
