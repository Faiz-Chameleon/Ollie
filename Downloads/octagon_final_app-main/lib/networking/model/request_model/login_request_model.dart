
// To parse this JSON data, do
//
//     final loginRequestModel = loginRequestModelFromJson(jsonString);

import 'dart:convert';

LoginRequestModel loginRequestModelFromJson(String str) => LoginRequestModel.fromJson(json.decode(str));

String loginRequestModelToJson(LoginRequestModel data) => json.encode(data.toJson());

class LoginRequestModel {
  LoginRequestModel({
    this.email,
    this.password,
    this.fcm_token
  });

  String? email;
  String? password;
  String? fcm_token;

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) => LoginRequestModel(
    email: json["email"],
    password: json["password"],
    fcm_token: json["fcm_token"]
  );

  Map<String, String> toJson() => {
    "email": email??"",
    "password": password??"",
    "fcm_token": fcm_token??""
  };
}
