// To parse this JSON data, do
//
//     final forgetPasswordRequestModel = forgetPasswordRequestModelFromJson(jsonString);

import 'dart:convert';

ForgetPasswordRequestModel forgetPasswordRequestModelFromJson(String str) => ForgetPasswordRequestModel.fromJson(json.decode(str));

String forgetPasswordRequestModelToJson(ForgetPasswordRequestModel data) => json.encode(data.toJson());

class ForgetPasswordRequestModel {
  ForgetPasswordRequestModel({
    this.email,
  });

  String? email;

  factory ForgetPasswordRequestModel.fromJson(Map<String, dynamic> json) => ForgetPasswordRequestModel(
    email: json["email"],
  );

  Map<String, String> toJson() => {
    "email": email!,
  };
}
