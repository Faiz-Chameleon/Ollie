import 'dart:convert';

ResetPasswordResponseModel resetPasswordResponseModelFromJson(String str) => ResetPasswordResponseModel.fromJson(json.decode(str));

String resetPasswordResponseModelToJson(ResetPasswordResponseModel data) => json.encode(data.toJson());

class ResetPasswordResponseModel {
  ResetPasswordResponseModel({
    this.success,
  });

  String? success;

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) => ResetPasswordResponseModel(
    success: json["success"]??"Something went wrong",
  );

  Map<String, dynamic> toJson() => {
    "success": success!,
  };
}
