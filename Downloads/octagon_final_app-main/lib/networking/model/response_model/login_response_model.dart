// To parse this JSON data, do
//
//     final loginResponseModel = loginResponseModelFromJson(jsonString);

import 'dart:convert';

import 'SportInfoModel.dart';

LoginResponseModel loginResponseModelFromJson(String str) => LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) => json.encode(data.toJson());

class LoginResponseModel {
  LoginResponseModel({
    this.success,
    this.error
  });

  LoginResponseDatauccess? success;
  String? error;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
    success: json["success"]!=null ? LoginResponseDatauccess.fromJson(json["success"]) : null,
    error: json["error"]
  );

  Map<String, dynamic> toJson() => {
    "success": success!.toJson(),
  };
}

class LoginResponseDatauccess {
  LoginResponseDatauccess({
    this.token,
    this.userId,
    this.sportInfo,
    this.email,
    this.mobile,
    this.gender,
    this.photo,
    this.background,
    this.dob,
    this.bio,
    this.country,
    this.fcmToken,
    this.name
  });

  String? token;
  int? userId;
  List<SportInfo>? sportInfo;
  String? email;
  String? name;
  String? mobile;
  String? gender;
  String? photo;
  String? background;
  String? dob;
  String? bio;
  String? country;
  String? fcmToken;

  factory LoginResponseDatauccess.fromJson(Map<String, dynamic> json) => LoginResponseDatauccess(
    token: json["token"],
    name: json["name"],
    userId: json["userId"] ?? json["id"],
    sportInfo:json["sport_info"]==null?[]: List<SportInfo>.from(json["sport_info"].map((x) => SportInfo.fromJson(x))),
    email: json["email"] == null ? null : json["email"],
    mobile: json["mobile"] == null ? null : json["mobile"],
    gender: json["gender"] == null ? null : json["gender"],
    photo: json["photo"] == null ? null : json["photo"],
    background: json["background"] == null ? null : json["background"],
    dob: json["dob"] == null ? null : json["dob"],
    bio: json["bio"] == null ? null : json["bio"],
    country: json["country"] == null ? null : json["country"],
    fcmToken: json["fcm_token"] == null ? null : json["fcm_token"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "userId": userId,
    "name": name,
    "sport_info": List<dynamic>.from(sportInfo!.map((x) => x.toJson())),
    "email": email,
    "mobile": mobile,
    "gender": gender,
    "photo": photo,
    "background": background,
    "dob": dob,
    "bio": bio,
    "country": country,
    "fcm_token": fcmToken,
  };
}


