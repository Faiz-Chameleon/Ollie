
// To parse this JSON data, do
//
//     final resetPasswordRequestModel = resetPasswordRequestModelFromJson(jsonString);

import 'dart:convert';

ResetPasswordRequestModel resetPasswordRequestModelFromJson(String str) => ResetPasswordRequestModel.fromJson(json.decode(str));

String resetPasswordRequestModelToJson(ResetPasswordRequestModel data) => json.encode(data.toJson());

class ResetPasswordRequestModel {
  ResetPasswordRequestModel({
    this.email,
    this.password,
    this.cpassword,
  });

  String? email;
  String? password;
  String? cpassword;

  factory ResetPasswordRequestModel.fromJson(Map<String, dynamic> json) => ResetPasswordRequestModel(
    email: json["email"],
    password: json["password"],
    cpassword: json["cpassword"],
  );

  Map<String, String> toJson() => {
    "email": email!,
    "password": password!,
    "cpassword": cpassword!,
  };
}
