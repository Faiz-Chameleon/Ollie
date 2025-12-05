
import 'user_data_model.dart';

class CommentCommentDataModel {
  CommentCommentDataModel({
    this.id,
    this.userId,
    this.postId,
    this.comment,
    this.parentCommentId,
    this.createdAt,
    this.users,
  });

  int? id;
  int? userId;
  var postId;
  String? comment;
  var parentCommentId;
  DateTime? createdAt;
  Users? users;

  factory CommentCommentDataModel.fromJson(Map<String, dynamic> json) => CommentCommentDataModel(
    id: json["id"],
    userId: json["user_id"],
    postId: json["post_id"],
    comment: json["comment"],
    parentCommentId: json["parent_comment_id"],
    createdAt: DateTime.parse(json["created_at"]),
    users: json["users"] == null ? null : Users.fromJson(json["users"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "post_id": postId,
    "comment": comment,
    "parent_comment_id": parentCommentId,
    "created_at": createdAt?.toIso8601String(),
    "users": users?.toJson(),
  };
}