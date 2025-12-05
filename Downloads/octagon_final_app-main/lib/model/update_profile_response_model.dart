import 'dart:convert';

import 'package:octagon/model/user_data_model.dart';


UpdateProfileResponseModel userProfileResponseModelFromJson(String str) => UpdateProfileResponseModel.fromJson(json.decode(str));

String userProfileResponseModelToJson(UpdateProfileResponseModel data) => json.encode(data.toJson());

class UpdateProfileResponseModel {
  UpdateProfileResponseModel({
    this.success,
  });

  Users? success;

  factory UpdateProfileResponseModel.fromJson(Map<String, dynamic> json) => UpdateProfileResponseModel(
    success: Users.fromJson(json["success"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success!.toJson(),
  };
}