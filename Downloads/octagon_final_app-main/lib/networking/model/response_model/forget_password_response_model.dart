
// To parse this JSON data, do
//
//     final forgetPasswordResponseModel = forgetPasswordResponseModelFromJson(jsonString);

import 'dart:convert';

ForgetPasswordResponseModel forgetPasswordResponseModelFromJson(String str) => ForgetPasswordResponseModel.fromJson(json.decode(str));

String forgetPasswordResponseModelToJson(ForgetPasswordResponseModel data) => json.encode(data.toJson());

class ForgetPasswordResponseModel {
  ForgetPasswordResponseModel({
    this.success,
  });

  Success? success;

  factory ForgetPasswordResponseModel.fromJson(Map<String, dynamic> json) => ForgetPasswordResponseModel(
    success: Success.fromJson(json["success"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success!.toJson(),
  };
}

class Success {
  Success({
    this.userId,
    this.mobile,
    this.otp,
    this.createdAt,
  });

  int? userId;
  String? mobile;
  int? otp;
  DateTime? createdAt;

  factory Success.fromJson(Map<String, dynamic> json) => Success(
    userId: json["user_id"],
    mobile: json["mobile"],
    otp: json["otp"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "mobile": mobile,
    "otp": otp,
    "created_at": createdAt!.toIso8601String(),
  };
}
