// To parse this JSON data, do
//
//     final otpVerifyRequestModel = otpVerifyRequestModelFromJson(jsonString);

import 'dart:convert';

import '../../main.dart';

OtpVerifyRequestModel otpVerifyRequestModelFromJson(String str) => OtpVerifyRequestModel.fromJson(json.decode(str));

String otpVerifyRequestModelToJson(OtpVerifyRequestModel data) => json.encode(data.toJson());

class OtpVerifyRequestModel {
  OtpVerifyRequestModel({
    this.email,
    this.otp,
    this.fcm_token
  });

  String? email;
  String? otp;
  String? fcm_token;

  factory OtpVerifyRequestModel.fromJson(Map<String, dynamic> json) => OtpVerifyRequestModel(
    email: json["email"],
    otp: json["otp"],
    fcm_token: storage.read("fcm_token")
  );

  Map<String, String> toJson() => {
    "email": email??"",
    "otp": otp??"",
    "fcm_token": storage.read("fcm_token")
  };
}
