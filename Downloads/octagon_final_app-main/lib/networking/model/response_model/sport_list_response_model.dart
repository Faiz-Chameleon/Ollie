
// To parse this JSON data, do
//
//     final sportListResponseModel = sportListResponseModelFromJson(jsonString);

import 'dart:convert';

SportListResponseModel sportListResponseModelFromJson(String str) => SportListResponseModel.fromJson(json.decode(str));

String sportListResponseModelToJson(SportListResponseModel data) => json.encode(data.toJson());

class SportListResponseModel {
  SportListResponseModel({
    this.data,
  });

  List<SportListResponseModelData>? data;

  factory SportListResponseModel.fromJson(Map<String, dynamic> json) => SportListResponseModel(
    data: List<SportListResponseModelData>.from(json["success"].map((x) => SportListResponseModelData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class SportListResponseModelData {
  SportListResponseModelData({
    this.id,
    this.idSport,
    this.strSport,
    this.strFormat,
    this.strSportThumb,
    this.strSportIconGreen,
    this.strSportDescription,
    this.createdAt,
    this.isSelected
  });

  int? id;
  int? idSport;
  String? strSport;
  String? strFormat;
  String? strSportThumb;
  String? strSportIconGreen;
  String? strSportDescription;
  DateTime? createdAt;
  bool? isSelected = false;

  factory SportListResponseModelData.fromJson(Map<String, dynamic> json) => SportListResponseModelData(
    id: json["id"],
    idSport: json["idSport"],
    strSport: json["strSport"],
    strFormat: json["strFormat"],
    strSportThumb: json["strSportThumb"],
    strSportIconGreen: json["strSportIconGreen"],
    strSportDescription: json["strSportDescription"],
    createdAt: DateTime.parse(json["created_at"]),
      isSelected: false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "idSport": idSport,
    "strSport": strSport,
    "strFormat": strFormat,
    "strSportThumb": strSportThumb,
    "strSportIconGreen": strSportIconGreen,
    "strSportDescription": strSportDescription,
    "created_at": createdAt!.toIso8601String(),
  };
}


