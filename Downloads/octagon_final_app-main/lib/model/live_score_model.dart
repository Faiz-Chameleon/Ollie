// To parse this JSON data, do
//
//     final getChatRoomResponseModel = getChatRoomResponseModelFromJson(jsonString);

import 'dart:convert';


LiveScoreResponseModel getChatRoomResponseModelFromJson(String str) => LiveScoreResponseModel.fromJson(json.decode(str));

String getChatRoomResponseModelToJson(LiveScoreResponseModel data) => json.encode(data.toJson());

class LiveScoreResponseModel {
  int? statusCode;
  String? message;
  List<Matche>? matches;

  LiveScoreResponseModel({
    this.statusCode,
    this.message,
    this.matches
  });

  factory LiveScoreResponseModel.fromJson(Map<String, dynamic> json) => LiveScoreResponseModel(
    statusCode: json["status"],
    message: json["message"],
    matches: json["matches"] == null ? [] : List<Matche>.from(json["matches"]!.map((x) => Matche.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": statusCode,
    "message": message,
    "matches": matches
  };
}

class Matche {
  int? id;
  String? matchVs;
  List<MatchTeam>? matchTeams;
  DateTime? startDate;
  DateTime? endDate;

  Matche({
    this.id,
    this.startDate,
    this.endDate,
    this.matchTeams,
    this.matchVs
  });

  factory Matche.fromJson(Map<String, dynamic> json) => Matche(
    id: json["id"],
    matchVs: "${json["match_vs"]}",
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]).toLocal(),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]).toLocal(),
    matchTeams: json["match_teams"] == null ? [] : List<MatchTeam>.from(json["match_teams"]!.map((x) => MatchTeam.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "match_vs": matchVs,
    "start_date": startDate?.toIso8601String(),
    "end_date": endDate?.toIso8601String(),
  };
}

class MatchTeam {
  int? id;
  String? matchId;
  String? teamName;
  List<MatchScore>? matchScore;

  MatchTeam({
    this.id,
    this.matchId,
    this.teamName,
    this.matchScore
  });

  factory MatchTeam.fromJson(Map<String, dynamic> json) => MatchTeam(
    id: json["id"],
    matchId: "${json["match_id"]}",
    teamName: json["team_name"],
    matchScore: json["match_score"] == null ? [] : List<MatchScore>.from(json["match_score"]!.map((x) => MatchScore.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "match_id": matchId,
    "team_name": teamName,
    "match_score": matchScore,
  };
}

class MatchScore {
  int? id;
  String? matchTeamId;
  String? score;
  int? matchOver;
  int? wicket;
  String? innings;

  MatchScore({
    this.id,
    this.matchTeamId,
    this.score,
    this.innings,
    this.matchOver,
    this.wicket
  });

  factory MatchScore.fromJson(Map<String, dynamic> json) => MatchScore(
    id: json["id"],
    matchTeamId: "${json["match_team_id"]}",
    score: "${json["score"]}",
    matchOver: json["match_over"],
    wicket: json["wicket"],
    innings: json["innings"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "match_team_id": matchTeamId,
    "score": score,
    "match_over": matchOver,
    "wicket": wicket,
    "innings": innings
  };
}