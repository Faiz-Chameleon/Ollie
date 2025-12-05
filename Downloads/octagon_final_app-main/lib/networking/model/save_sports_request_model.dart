

// To parse this JSON data, do
//
//     final sportListResponseModel = sportListResponseModelFromJson(jsonString);

import 'dart:convert';

SaveSportListRequestModel sportListResponseModelFromJson(String str) => SaveSportListRequestModel.fromJson(json.decode(str));

String sportListResponseModelToJson(SaveSportListRequestModel data) => json.encode(data.toJson());

class SaveSportListRequestModel {
  SaveSportListRequestModel({
    this.sports,
  });

  List<SaveSport>? sports;

  factory SaveSportListRequestModel.fromJson(Map<String, dynamic> json) => SaveSportListRequestModel(
    sports: List<SaveSport>.from(json["sports"].map((x) => SaveSport.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "sports": List<dynamic>.from(sports!.map((x) => x.toJson())),
  };
}

class SaveSport {
  SaveSport({
    this.sportId,
    this.sportApiId,
  });

  int? sportId;
  int? sportApiId;

  factory SaveSport.fromJson(Map<String, dynamic> json) => SaveSport(
    sportId: json["sport_id"],
    sportApiId: json["sport_api_id"],
  );

  Map<String, dynamic> toJson() => {
    "sport_id": sportId,
    "sport_api_id": sportApiId,
  };
}
