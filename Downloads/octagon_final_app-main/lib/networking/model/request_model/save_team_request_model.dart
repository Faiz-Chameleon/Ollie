

// To parse this JSON data, do
//
//     final sportListResponseModel = sportListResponseModelFromJson(jsonString);

import 'dart:convert';

SaveTeamListRequestModel sportListResponseModelFromJson(String str) => SaveTeamListRequestModel.fromJson(json.decode(str));

String sportListResponseModelToJson(SaveTeamListRequestModel data) => json.encode(data.toJson());

class SaveTeamListRequestModel {
  SaveTeamListRequestModel({
    this.sports,
  });

  List<SaveTeam>? sports;

  factory SaveTeamListRequestModel.fromJson(Map<String, dynamic> json) => SaveTeamListRequestModel(
    sports: List<SaveTeam>.from(json["teams"].map((x) => SaveTeam.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "teams": List<dynamic>.from(sports!.map((x) => x.toJson())),
  };
}

class SaveTeam {
  SaveTeam({
    this.id,
    this.idTeam,
    this.sport_id,
    this.sport_api_id
  });

  int? id;
  int? idTeam;
  int? sport_id;
  int? sport_api_id;


  factory SaveTeam.fromJson(Map<String, dynamic> json) => SaveTeam(
    id: json["id"],
    idTeam: json["idTeam"],
      sport_id: json["sport_id"],
      sport_api_id: json["sport_api_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "idTeam": idTeam,
    "sport_id" : sport_id,
    "sport_api_id": sport_api_id
  };
}
