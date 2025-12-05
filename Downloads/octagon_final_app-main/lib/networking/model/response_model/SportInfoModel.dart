
import 'package:octagon/networking/model/response_model/team_response_model.dart';

class SportInfo {
  SportInfo({
    this.id,
    this.idSport,
    this.strSport,
    this.strFormat,
    this.strSportThumb,
    this.strSportIconGreen,
    this.strSportDescription,
    this.createdAt,
    this.isDeleted,
    this.team,
  });

  int? id;
  int? idSport;
  String? strSport;
  String? strFormat;
  String? strSportThumb;
  String? strSportIconGreen;
  String? strSportDescription;
  DateTime? createdAt;
  String? isDeleted;
  List<TeamResponseModel>? team;

  factory SportInfo.fromJson(Map<String, dynamic> json) => SportInfo(
    id: json["id"],
    idSport: json["idSport"],
    strSport: json["strSport"],
    strFormat: json["strFormat"],
    strSportThumb: json["strSportThumb"],
    strSportIconGreen: json["strSportIconGreen"],
    strSportDescription: json["strSportDescription"],
    createdAt: DateTime.parse(json["created_at"]),
    isDeleted: json["is_deleted"],
    team:json["team"] == null ? null : List<TeamResponseModel>.from(json["team"].map((x) => TeamResponseModel.fromJson(x))),
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
    "is_deleted": isDeleted,
    "team": List<dynamic>.from(team!.map((x) => x.toJson())),
  };
}
