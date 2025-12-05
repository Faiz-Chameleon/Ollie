// To parse this JSON data, do
//
//     final saveSportListResponseModel = saveSportListResponseModelFromJson(jsonString);

import 'dart:convert';


import 'package:octagon/networking/model/response_model/team_response_model.dart';

import 'SportInfoModel.dart';

SaveSportListResponseModel saveSportListResponseModelFromJson(String str) => SaveSportListResponseModel.fromJson(json.decode(str));

String saveSportListResponseModelToJson(SaveSportListResponseModel data) => json.encode(data.toJson());

class SaveSportListResponseModel {
  SaveSportListResponseModel({
    this.success,
  });

  Success? success;

  factory SaveSportListResponseModel.fromJson(Map<String, dynamic> json) => SaveSportListResponseModel(
    success: Success.fromJson(json["success"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success!.toJson(),
  };
}

class Success {
  Success({
    this.sport,
    this.sportInfo,
    this.team,
  });

  List<Sport>? sport;
  List<SportInfo>? sportInfo;
  List<TeamResponseModel>? team;

  factory Success.fromJson(Map<String, dynamic> json) => Success(
    sport: json["sport"] == null ? null : List<Sport>.from(json["sport"].map((x) => Sport.fromJson(x))),
    sportInfo: json["sport_info"] == null ? null : List<SportInfo>.from(json["sport_info"].map((x) => SportInfo.fromJson(x))),
    team: json["team"] == null ? null : List<TeamResponseModel>.from(json["team"].map((x) => TeamResponseModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "sport": List<dynamic>.from(sport!.map((x) => x.toJson())),
    "sport_info": List<dynamic>.from(sportInfo!.map((x) => x.toJson())),
    "team": List<dynamic>.from(team!.map((x) => x.toJson())),
  };
}

class Sport {
  Sport({
    this.id,
    this.userId,
    this.sportId,
    this.sportApiId,
    this.createdAt,
    this.isDeleted,
  });

  int? id;
  int? userId;
  int? sportId;
  int? sportApiId;
  DateTime? createdAt;
  String? isDeleted;

  factory Sport.fromJson(Map<String, dynamic> json) => Sport(
    id: json["id"],
    userId: json["user_id"],
    sportId: json["sport_id"],
    sportApiId: json["sport_api_id"],
    createdAt: DateTime.parse(json["created_at"]),
    isDeleted: json["is_deleted"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "sport_id": sportId,
    "sport_api_id": sportApiId,
    "created_at": createdAt!.toIso8601String(),
    "is_deleted": isDeleted,
  };
}
