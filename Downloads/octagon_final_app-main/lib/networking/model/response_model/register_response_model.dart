
// To parse this JSON data, do
//
//     final regiserResponseModel = regiserResponseModelFromJson(jsonString);

import 'dart:convert';

RegisterResponseModel regiserResponseModelFromJson(String str) => RegisterResponseModel.fromJson(json.decode(str));

String regiserResponseModelToJson(RegisterResponseModel data) => json.encode(data.toJson());

class RegisterResponseModel {
  RegisterResponseModel({
    this.success,
    this.error
  });

  Success? success;
  String? error;

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) => RegisterResponseModel(
    success: json["success"]!=null ? Success.fromJson(json["success"]) : null,
    error: json["error"]
  );

  Map<String, dynamic> toJson() => {
    "success": success!.toJson(),
  };
}

class Success {
  Success({
    this.token,
    this.name,
  });

  String? token;
  String? name;

  factory Success.fromJson(Map<String, dynamic> json) => Success(
    token: json["token"],
    name: json["name"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "name": name,
  };
}
