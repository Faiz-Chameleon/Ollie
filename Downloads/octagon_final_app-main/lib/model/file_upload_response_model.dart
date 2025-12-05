// To parse this JSON data, do
//
//     final fileUploadResponseModel = fileUploadResponseModelFromJson(jsonString);

import 'dart:convert';

FileUploadResponseModel fileUploadResponseModelFromJson(String str) => FileUploadResponseModel.fromJson(json.decode(str));

String fileUploadResponseModelToJson(FileUploadResponseModel data) => json.encode(data.toJson());

class FileUploadResponseModel {
  FileUploadResponseModel({
    this.success,
  });

  SucessData? success;

  factory FileUploadResponseModel.fromJson(Map<String, dynamic> json) => FileUploadResponseModel(
    success: SucessData.fromJson(json["success"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success!.toJson(),
  };
}

// class FileModel {
//   FileModel({
//     this.previous,
//     this.latest,
//   });
//
//   List<Latest>? previous;
//   List<Latest>? latest;
//
//   factory FileModel.fromJson(Map<String, dynamic> json) => FileModel(
//     previous: List<Latest>.from(json["previous"].map((x) => Latest.fromJson(x))),
//     latest: List<Latest>.from(json["latest"].map((x) => Latest.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "previous": List<dynamic>.from(previous!.map((x) => x.toJson())),
//     "latest": List<dynamic>.from(latest!.map((x) => x.toJson())),
//   };
// }

class SucessData {
  SucessData({
    this.id,
    this.userId,
    this.filePath,
    this.thumbUrl,
    this.type,
    this.createdAt,
  });

  int? id;
  int? userId;
  String? filePath;
  String? thumbUrl;
  String? type;
  DateTime? createdAt;

  factory SucessData.fromJson(Map<String, dynamic> json) => SucessData(
    id: json["id"],
    userId: json["user_id"],
    filePath: json["file_path"],
    thumbUrl: json["thumb_url"],
    type: json["type"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "file_path": filePath,
    "thumb_url": thumbUrl,
    "type": type,
    "created_at": createdAt!.toIso8601String(),
  };
}
