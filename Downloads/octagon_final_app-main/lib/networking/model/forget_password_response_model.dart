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
    success: Success.fromJson(json["success"][0]),
  );

  Map<String, dynamic> toJson() => {
    "success": success!.toJson(),
  };
}

class Success {
  Success({
    this.userId,
    this.mobile,
    this.email,
    this.name,
  });

  int? userId;
  String? mobile;
  String? email;
  // int? otp;
  String? name;

  factory Success.fromJson(Map<String, dynamic> json) => Success(
    userId: json["id"],
    mobile: json["mobile"],
    email: json["email"],
    // otp: json["otp"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": userId,
    "mobile": mobile,
    "email": email,
    // "otp": otp,
    "name": name!,
  };
}
