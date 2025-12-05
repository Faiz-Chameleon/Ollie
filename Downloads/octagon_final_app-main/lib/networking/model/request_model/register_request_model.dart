
// To parse this JSON data, do
//
//     final regiserRequestModel = regiserRequestModelFromJson(jsonString);

import 'dart:convert';

RegisterRequestModel regiserRequestModelFromJson(String str) => RegisterRequestModel.fromJson(json.decode(str));

String regiserRequestModelToJson(RegisterRequestModel data) => json.encode(data.toJson());

class RegisterRequestModel {
  RegisterRequestModel({
    this.name,
    this.email,
    this.mobile,
    this.gender = 1,
    this.password,
    this.cPassword,
    this.country
  });

  String? name;
  String? email;
  String? mobile;
  int gender = 1;
  String? password;
  String? cPassword;
  String? country;

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) => RegisterRequestModel(
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
    gender: json["gender"],
    password: json["password"],
    cPassword: json["c_password"],
      country: json["country"]
  );

  Map<String, String> toJson() => {
    "name": name!,
    "email": email!,
    "mobile": mobile!,
    "gender": gender.toString(),
    "password": password!,
    "c_password": cPassword!,
    "country": country!
  };
}
