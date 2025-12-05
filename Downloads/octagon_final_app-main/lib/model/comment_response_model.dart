// To parse this JSON data, do
//
//     final postResponseModel = postResponseModelFromJson(jsonString);

import 'dart:convert';

import 'comment_data_model.dart';

CommentResponseModel postResponseModelFromJson(String str) => CommentResponseModel.fromJson(json.decode(str));

// String postResponseModelToJson(PostResponseModel data) => json.encode(data.toJson());

class CommentResponseModel {
  CommentResponseModel({
    this.success,
  });

  CommentCommentDataModel? success;

  factory CommentResponseModel.fromJson(Map<String, dynamic> json) => CommentResponseModel(
    success: CommentCommentDataModel.fromJson((json["success"]),
  )
  );

}
