// To parse this JSON data, do
//
//     final teamListResponse = teamListResponseFromJson(jsonString);

import 'dart:convert';

TeamListResponse teamListResponseFromJson(String str) => TeamListResponse.fromJson(json.decode(str));

String teamListResponseToJson(TeamListResponse data) => json.encode(data.toJson());

class TeamListResponse {
  TeamListResponse({
    this.success,
  });

  List<TeamData>? success;

  factory TeamListResponse.fromJson(Map<String, dynamic> json) => TeamListResponse(
    success: List<TeamData>.from(json["success"].map((x) => TeamData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": List<dynamic>.from(success!.map((x) => x.toJson())),
  };
}

class TeamData {
  TeamData({
    this.id,
    this.idTeam,
    this.sportId,
    this.idSoccerXml,
    this.idApIfootball,
    this.intLoved,
    this.strTeam,
    this.strTeamShort,
    this.intFormedYear,
    // this.strSport,
    this.strLeague,
    // this.idLeague,
    // this.strLeague2,
    // this.idLeague2,
    // this.strLeague3,
    // this.idLeague3,
    // this.strLeague4,
    // this.idLeague4,
    // this.strLeague5,
    // this.idLeague5,
    // this.strLeague6,
    // this.idLeague6,
    // this.strLeague7,
    // this.idLeague7,
    // this.strDivision,
    // this.strManager,
    this.strStadium,
    this.strKeywords,
    this.strRss,
    this.strStadiumThumb,
    this.strStadiumDescription,
    this.strStadiumLocation,
    this.intStadiumCapacity,
    this.strWebsite,
    this.strFacebook,
    this.strTwitter,
    this.strInstagram,
    // this.strDescriptionEn,
    // this.strDescriptionDe,
    // this.strDescriptionFr,
    // this.strDescriptionCn,
    // this.strDescriptionIt,
    // this.strDescriptionJp,
    // this.strDescriptionRu,
    // this.strDescriptionEs,
    // this.strDescriptionPt,
    // this.strDescriptionSe,
    // this.strDescriptionNl,
    // this.strDescriptionHu,
    // this.strDescriptionNo,
    // this.strDescriptionIl,
    // this.strDescriptionPl,
    // this.strKitColour1,
    // this.strKitColour2,
    // this.strKitColour3,
    this.strGender,
    this.strCountry,
    this.strTeamBadge,
    this.strTeamJersey,
    this.strTeamLogo,
    // this.strTeamFanart1,
    // this.strTeamFanart2,
    // this.strTeamFanart3,
    // this.strTeamFanart4,
    // this.strTeamBanner,
    this.strYoutube,
    // this.strLocked,
    this.status,
    this.createdAt,
    this.isSelected = false
  });

  int? id;
  int? idTeam;
  int? sportId;
  dynamic? idSoccerXml;
  String? idApIfootball;
  String? intLoved;
  String? strTeam;
  dynamic? strTeamShort;
  int? intFormedYear;
  // StrSport? strSport;
  String? strLeague;
  // int? idLeague;
  // StrLeague? strLeague2;
  // int? idLeague2;
  // StrLeague? strLeague3;
  // int? idLeague3;
  // StrLeague? strLeague4;
  // int? idLeague4;
  // StrLeague? strLeague5;
  // int? idLeague5;
  // String? strLeague6;
  // dynamic? idLeague6;
  // String? strLeague7;
  // dynamic? idLeague7;
  // dynamic? strDivision;
  // String? strManager;
  String? strStadium;
  String? strKeywords;
  String? strRss;
  String? strStadiumThumb;
  String? strStadiumDescription;
  String? strStadiumLocation;
  int? intStadiumCapacity;
  String? strWebsite;
  String? strFacebook;
  String? strTwitter;
  String? strInstagram;
  // String? strDescriptionEn;
  // dynamic? strDescriptionDe;
  // dynamic? strDescriptionFr;
  // dynamic? strDescriptionCn;
  // dynamic? strDescriptionIt;
  // dynamic? strDescriptionJp;
  // dynamic? strDescriptionRu;
  // dynamic? strDescriptionEs;
  // dynamic? strDescriptionPt;
  // dynamic? strDescriptionSe;
  // dynamic? strDescriptionNl;
  // dynamic? strDescriptionHu;
  // dynamic? strDescriptionNo;
  // dynamic? strDescriptionIl;
  // dynamic? strDescriptionPl;
  // String? strKitColour1;
  // String? strKitColour2;
  // String? strKitColour3;
  String? strGender;
  String? strCountry;
  String? strTeamBadge;
  String? strTeamJersey;
  String? strTeamLogo;
  // String? strTeamFanart1;
  // String? strTeamFanart2;
  // String? strTeamFanart3;
  // String? strTeamFanart4;
  // String? strTeamBanner;
  String? strYoutube;
  String? status;
  DateTime? createdAt;
  bool isSelected;

  factory TeamData.fromJson(Map<dynamic, dynamic> json) => TeamData(
    id: json["id"],
    idTeam: json["idTeam"],
    sportId: json["sportId"],
    idSoccerXml: json["idSoccerXML"],
    idApIfootball: json["idAPIfootball"],
    intLoved: json["intLoved"] == null ? null : json["intLoved"],
    strTeam: json["strTeam"],
    strTeamShort: json["strTeamShort"],
    intFormedYear: json["intFormedYear"],
    // strSport: strSportValues.map[json["strSport"]],
    strLeague: json["strLeague"],
    // idLeague: json["idLeague"],
    // strLeague2: json["strLeague2"] == null ? null : strLeagueValues.map[json["strLeague2"]],
    // idLeague2: json["idLeague2"] == null ? null : json["idLeague2"],
    // strLeague3: json["strLeague3"] == null ? null : strLeagueValues.map[json["strLeague3"]],
    // idLeague3: json["idLeague3"] == null ? null : json["idLeague3"],
    // strLeague4: json["strLeague4"] == null ? null : strLeagueValues.map[json["strLeague4"]],
    // idLeague4: json["idLeague4"] == null ? null : json["idLeague4"],
    // strLeague5: json["strLeague5"] == null ? null : strLeagueValues.map[json["strLeague5"]],
    // idLeague5: json["idLeague5"] == null ? null : json["idLeague5"],
    // strLeague6: json["strLeague6"] == null ? null : json["strLeague6"],
    // idLeague6: json["idLeague6"],
    // strLeague7: json["strLeague7"] == null ? null : json["strLeague7"],
    // idLeague7: json["idLeague7"],
    // strDivision: json["strDivision"],
    // strManager: json["strManager"],
    strStadium: json["strStadium"],
    strKeywords: json["strKeywords"],
    strRss: json["strRSS"],
    strStadiumThumb: json["strStadiumThumb"] == null ? null : json["strStadiumThumb"],
    strStadiumDescription: json["strStadiumDescription"] == null ? null : json["strStadiumDescription"],
    strStadiumLocation: json["strStadiumLocation"],
    intStadiumCapacity: json["intStadiumCapacity"],
    strWebsite: json["strWebsite"],
    strFacebook: json["strFacebook"],
    strTwitter: json["strTwitter"],
    strInstagram: json["strInstagram"],
    // strDescriptionEn: json["strDescriptionEN"] == null ? null : json["strDescriptionEN"],
    // strDescriptionDe: json["strDescriptionDE"],
    // strDescriptionFr: json["strDescriptionFR"],
    // strDescriptionCn: json["strDescriptionCN"],
    // strDescriptionIt: json["strDescriptionIT"],
    // strDescriptionJp: json["strDescriptionJP"],
    // strDescriptionRu: json["strDescriptionRU"],
    // strDescriptionEs: json["strDescriptionES"],
    // strDescriptionPt: json["strDescriptionPT"],
    // strDescriptionSe: json["strDescriptionSE"],
    // strDescriptionNl: json["strDescriptionNL"],
    // strDescriptionHu: json["strDescriptionHU"],
    // strDescriptionNo: json["strDescriptionNO"],
    // strDescriptionIl: json["strDescriptionIL"],
    // strDescriptionPl: json["strDescriptionPL"],
    // strKitColour1: json["strKitColour1"] == null ? null : json["strKitColour1"],
    // strKitColour2: json["strKitColour2"] == null ? null : json["strKitColour2"],
    // strKitColour3: json["strKitColour3"] == null ? null : json["strKitColour3"],
    strGender: json["strGender"],
    strCountry: json["strCountry"],
    strTeamBadge: json["strTeamBadge"] == null ? null : json["strTeamBadge"],
    strTeamJersey: json["strTeamJersey"] == null ? null : json["strTeamJersey"],
    strTeamLogo: json["strTeamLogo"] == null ? null : json["strTeamLogo"],
    // strTeamFanart1: json["strTeamFanart1"] == null ? null : json["strTeamFanart1"],
    // strTeamFanart2: json["strTeamFanart2"] == null ? null : json["strTeamFanart2"],
    // strTeamFanart3: json["strTeamFanart3"] == null ? null : json["strTeamFanart3"],
    // strTeamFanart4: json["strTeamFanart4"] == null ? null : json["strTeamFanart4"],
    // strTeamBanner: json["strTeamBanner"] == null ? null : json["strTeamBanner"],
    strYoutube: json["strYoutube"],
    // strLocked: strLockedValues.map[json["strLocked"]],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
      isSelected: false
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "idTeam": idTeam,
    "sportId": sportId,
    "idSoccerXML": idSoccerXml,
    "idAPIfootball": idApIfootball,
    "intLoved": intLoved == null ? null : intLoved,
    "strTeam": strTeam,
    "strTeamShort": strTeamShort,
    "intFormedYear": intFormedYear,
    // "strSport": strSportValues.reverse[strSport],
    "strLeague": strLeague,
    // "idLeague": idLeague,
    // "strLeague2": strLeague2 == null ? null : strLeagueValues.reverse[strLeague2],
    // "idLeague2": idLeague2 == null ? null : idLeague2,
    // "strLeague3": strLeague3 == null ? null : strLeagueValues.reverse[strLeague3],
    // "idLeague3": idLeague3 == null ? null : idLeague3,
    // "strLeague4": strLeague4 == null ? null : strLeagueValues.reverse[strLeague4],
    // "idLeague4": idLeague4 == null ? null : idLeague4,
    // "strLeague5": strLeague5 == null ? null : strLeagueValues.reverse[strLeague5],
    // "idLeague5": idLeague5 == null ? null : idLeague5,
    // "strLeague6": strLeague6 == null ? null : strLeague6,
    // "idLeague6": idLeague6,
    // "strLeague7": strLeague7 == null ? null : strLeague7,
    // "idLeague7": idLeague7,
    // "strDivision": strDivision,
    // "strManager": strManager,
    "strStadium": strStadium,
    "strKeywords": strKeywords,
    "strRSS": strRss,
    "strStadiumThumb": strStadiumThumb == null ? null : strStadiumThumb,
    "strStadiumDescription": strStadiumDescription == null ? null : strStadiumDescription,
    "strStadiumLocation": strStadiumLocation,
    "intStadiumCapacity": intStadiumCapacity,
    "strWebsite": strWebsite,
    "strFacebook": strFacebook,
    "strTwitter": strTwitter,
    "strInstagram": strInstagram,
    // "strDescriptionEN": strDescriptionEn == null ? null : strDescriptionEn,
    // "strDescriptionDE": strDescriptionDe,
    // "strDescriptionFR": strDescriptionFr,
    // "strDescriptionCN": strDescriptionCn,
    // "strDescriptionIT": strDescriptionIt,
    // "strDescriptionJP": strDescriptionJp,
    // "strDescriptionRU": strDescriptionRu,
    // "strDescriptionES": strDescriptionEs,
    // "strDescriptionPT": strDescriptionPt,
    // "strDescriptionSE": strDescriptionSe,
    // "strDescriptionNL": strDescriptionNl,
    // "strDescriptionHU": strDescriptionHu,
    // "strDescriptionNO": strDescriptionNo,
    // "strDescriptionIL": strDescriptionIl,
    // "strDescriptionPL": strDescriptionPl,
    // "strKitColour1": strKitColour1 == null ? null : strKitColour1,
    // "strKitColour2": strKitColour2 == null ? null : strKitColour2,
    // "strKitColour3": strKitColour3 == null ? null : strKitColour3,
    "strGender": strGender,
    "strCountry": strCountry,
    "strTeamBadge": strTeamBadge == null ? null : strTeamBadge,
    "strTeamJersey": strTeamJersey == null ? null : strTeamJersey,
    "strTeamLogo": strTeamLogo == null ? null : strTeamLogo,
    // "strTeamFanart1": strTeamFanart1 == null ? null : strTeamFanart1,
    // "strTeamFanart2": strTeamFanart2 == null ? null : strTeamFanart2,
    // "strTeamFanart3": strTeamFanart3 == null ? null : strTeamFanart3,
    // "strTeamFanart4": strTeamFanart4 == null ? null : strTeamFanart4,
    // "strTeamBanner": strTeamBanner == null ? null : strTeamBanner,
    "strYoutube": strYoutube,
    // "strLocked": strLockedValues.reverse[strLocked],
    "status": status,
    "created_at": createdAt!.toIso8601String(),
  };
}
