// To parse this JSON data, do
//
//     final favotieResponseModel = favotieResponseModelFromJson(jsonString);

import 'dart:convert';

FavoriteResponseModel favoriteResponseModelFromJson(String str) => FavoriteResponseModel.fromJson(json.decode(str));

String favoriteResponseModelToJson(FavoriteResponseModel data) => json.encode(data.toJson());

class FavoriteResponseModel {
  FavoriteResponseModel({
    required this.success,
  });

  Success success;

  factory FavoriteResponseModel.fromJson(Map<String, dynamic> json) => FavoriteResponseModel(
    success: Success.fromJson(json["success"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success.toJson(),
  };
}

class Success {
  Success({
    required this.favorite,
  });

  int favorite;

  factory Success.fromJson(Map<String, dynamic> json) => Success(
    favorite: json["favorite"]?? json["likes"] ?? json["reports"] ?? json["save_post"],
  );

  Map<String, dynamic> toJson() => {
    "favorite": favorite,
  };
}
