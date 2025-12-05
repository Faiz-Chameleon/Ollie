
// To parse this JSON data, do
//
//     final otpVerifyResponseModel = otpVerifyResponseModelFromJson(jsonString);

import 'dart:convert';

OtpVerifyResponseModel otpVerifyResponseModelFromJson(String str) => OtpVerifyResponseModel.fromJson(json.decode(str));

String otpVerifyResponseModelToJson(OtpVerifyResponseModel data) => json.encode(data.toJson());

class OtpVerifyResponseModel {
  OtpVerifyResponseModel({
    this.success,
  });

  String? success;

  factory OtpVerifyResponseModel.fromJson(Map<String, dynamic> json) => OtpVerifyResponseModel(
    success: json["success"],
  );

  Map<String, String> toJson() => {
    "success": success!,
  };
}