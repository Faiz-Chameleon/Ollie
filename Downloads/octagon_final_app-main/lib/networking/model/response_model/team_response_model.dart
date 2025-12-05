class TeamResponseModel {
  TeamResponseModel({
    this.id,
    this.idTeam,
    this.idSoccerXml,
    this.idApIfootball,
    this.intLoved,
    this.strTeam,
    this.strTeamShort,
    this.strAlternate,
    this.intFormedYear,
    this.strSport,
    this.strLeague,
    this.idLeague,
    this.strLeague2,
    this.idLeague2,
    this.strLeague3,
    this.idLeague3,
    this.strLeague4,
    this.idLeague4,
    this.strLeague5,
    this.idLeague5,
    this.strLeague6,
    this.idLeague6,
    this.strLeague7,
    this.idLeague7,
    this.strDivision,
    this.strManager,
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
    this.strDescriptionEn,
    this.strDescriptionDe,
    this.strDescriptionFr,
    this.strDescriptionCn,
    this.strDescriptionIt,
    this.strDescriptionJp,
    this.strDescriptionRu,
    this.strDescriptionEs,
    this.strDescriptionPt,
    this.strDescriptionSe,
    this.strDescriptionNl,
    this.strDescriptionHu,
    this.strDescriptionNo,
    this.strDescriptionIl,
    this.strDescriptionPl,
    this.strKitColour1,
    this.strKitColour2,
    this.strKitColour3,
    this.strGender,
    this.strCountry,
    this.strTeamBadge,
    this.strTeamJersey,
    this.strTeamLogo,
    this.strTeamFanart1,
    this.strTeamFanart2,
    this.strTeamFanart3,
    this.strTeamFanart4,
    this.strTeamBanner,
    this.strYoutube,
    this.strLocked,
    this.status,
    this.createdAt,
  });

  int? id;
  int? idTeam;
  dynamic? idSoccerXml;
  String? idApIfootball;
  dynamic? intLoved;
  String? strTeam;
  dynamic? strTeamShort;
  String? strAlternate;
  int? intFormedYear;
  String? strSport;
  String? strLeague;
  int? idLeague;
  String? strLeague2;
  int? idLeague2;
  String? strLeague3;
  int? idLeague3;
  String? strLeague4;
  int? idLeague4;
  String? strLeague5;
  dynamic? idLeague5;
  String? strLeague6;
  dynamic? idLeague6;
  String? strLeague7;
  dynamic? idLeague7;
  dynamic? strDivision;
  String? strManager;
  String? strStadium;
  String? strKeywords;
  String? strRss;
  dynamic? strStadiumThumb;
  String? strStadiumDescription;
  String? strStadiumLocation;
  int? intStadiumCapacity;
  String? strWebsite;
  String? strFacebook;
  String? strTwitter;
  String? strInstagram;
  String? strDescriptionEn;
  dynamic? strDescriptionDe;
  dynamic? strDescriptionFr;
  dynamic? strDescriptionCn;
  String? strDescriptionIt;
  dynamic? strDescriptionJp;
  dynamic? strDescriptionRu;
  dynamic? strDescriptionEs;
  dynamic? strDescriptionPt;
  dynamic? strDescriptionSe;
  dynamic? strDescriptionNl;
  dynamic? strDescriptionHu;
  dynamic? strDescriptionNo;
  dynamic? strDescriptionIl;
  dynamic? strDescriptionPl;
  String? strKitColour1;
  String? strKitColour2;
  String? strKitColour3;
  String? strGender;
  String? strCountry;
  String? strTeamBadge;
  String? strTeamJersey;
  dynamic? strTeamLogo;
  dynamic? strTeamFanart1;
  dynamic? strTeamFanart2;
  dynamic? strTeamFanart3;
  dynamic? strTeamFanart4;
  dynamic? strTeamBanner;
  String? strYoutube;
  String? strLocked;
  String? status;
  DateTime? createdAt;

  factory TeamResponseModel.fromJson(Map<String, dynamic> json) => TeamResponseModel(
    id: json["id"],
    idTeam: json["idTeam"],
    idSoccerXml: json["idSoccerXML"],
    idApIfootball: json["idAPIfootball"],
    intLoved: json["intLoved"],
    strTeam: json["strTeam"],
    strTeamShort: json["strTeamShort"],
    strAlternate: json["strAlternate"],
    intFormedYear: json["intFormedYear"],
    strSport: json["strSport"],
    strLeague: json["strLeague"],
    idLeague: json["idLeague"],
    strLeague2: json["strLeague2"],
    idLeague2: json["idLeague2"] == null ? null : json["idLeague2"],
    strLeague3: json["strLeague3"],
    idLeague3: json["idLeague3"] == null ? null : json["idLeague3"],
    strLeague4: json["strLeague4"],
    idLeague4: json["idLeague4"] == null ? null : json["idLeague4"],
    strLeague5: json["strLeague5"],
    idLeague5: json["idLeague5"],
    strLeague6: json["strLeague6"],
    idLeague6: json["idLeague6"],
    strLeague7: json["strLeague7"],
    idLeague7: json["idLeague7"],
    strDivision: json["strDivision"],
    strManager: json["strManager"],
    strStadium: json["strStadium"],
    strKeywords: json["strKeywords"],
    strRss: json["strRSS"],
    strStadiumThumb: json["strStadiumThumb"],
    strStadiumDescription: json["strStadiumDescription"] == null ? null : json["strStadiumDescription"],
    strStadiumLocation: json["strStadiumLocation"],
    intStadiumCapacity: json["intStadiumCapacity"],
    strWebsite: json["strWebsite"],
    strFacebook: json["strFacebook"],
    strTwitter: json["strTwitter"],
    strInstagram: json["strInstagram"],
    strDescriptionEn: json["strDescriptionEN"] == null ? null : json["strDescriptionEN"],
    strDescriptionDe: json["strDescriptionDE"],
    strDescriptionFr: json["strDescriptionFR"],
    strDescriptionCn: json["strDescriptionCN"],
    strDescriptionIt: json["strDescriptionIT"] == null ? null : json["strDescriptionIT"],
    strDescriptionJp: json["strDescriptionJP"],
    strDescriptionRu: json["strDescriptionRU"],
    strDescriptionEs: json["strDescriptionES"],
    strDescriptionPt: json["strDescriptionPT"],
    strDescriptionSe: json["strDescriptionSE"],
    strDescriptionNl: json["strDescriptionNL"],
    strDescriptionHu: json["strDescriptionHU"],
    strDescriptionNo: json["strDescriptionNO"],
    strDescriptionIl: json["strDescriptionIL"],
    strDescriptionPl: json["strDescriptionPL"],
    strKitColour1: json["strKitColour1"] == null ? null : json["strKitColour1"],
    strKitColour2: json["strKitColour2"] == null ? null : json["strKitColour2"],
    strKitColour3: json["strKitColour3"] == null ? null : json["strKitColour3"],
    strGender: json["strGender"],
    strCountry: json["strCountry"],
    strTeamBadge: json["strTeamBadge"],
    strTeamJersey: json["strTeamJersey"] == null ? null : json["strTeamJersey"],
    strTeamLogo: json["strTeamLogo"],
    strTeamFanart1: json["strTeamFanart1"],
    strTeamFanart2: json["strTeamFanart2"],
    strTeamFanart3: json["strTeamFanart3"],
    strTeamFanart4: json["strTeamFanart4"],
    strTeamBanner: json["strTeamBanner"],
    strYoutube: json["strYoutube"],
    strLocked: json["strLocked"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "idTeam": idTeam,
    "idSoccerXML": idSoccerXml,
    "idAPIfootball": idApIfootball,
    "intLoved": intLoved,
    "strTeam": strTeam,
    "strTeamShort": strTeamShort,
    "strAlternate": strAlternate,
    "intFormedYear": intFormedYear,
    "strSport": strSport,
    "strLeague": strLeague,
    "idLeague": idLeague,
    "strLeague2": strLeague2,
    "idLeague2": idLeague2 == null ? null : idLeague2,
    "strLeague3": strLeague3,
    "idLeague3": idLeague3 == null ? null : idLeague3,
    "strLeague4": strLeague4,
    "idLeague4": idLeague4 == null ? null : idLeague4,
    "strLeague5": strLeague5,
    "idLeague5": idLeague5,
    "strLeague6": strLeague6,
    "idLeague6": idLeague6,
    "strLeague7": strLeague7,
    "idLeague7": idLeague7,
    "strDivision": strDivision,
    "strManager": strManager,
    "strStadium": strStadium,
    "strKeywords": strKeywords,
    "strRSS": strRss,
    "strStadiumThumb": strStadiumThumb,
    "strStadiumDescription": strStadiumDescription == null ? null : strStadiumDescription,
    "strStadiumLocation": strStadiumLocation,
    "intStadiumCapacity": intStadiumCapacity,
    "strWebsite": strWebsite,
    "strFacebook": strFacebook,
    "strTwitter": strTwitter,
    "strInstagram": strInstagram,
    "strDescriptionEN": strDescriptionEn == null ? null : strDescriptionEn,
    "strDescriptionDE": strDescriptionDe,
    "strDescriptionFR": strDescriptionFr,
    "strDescriptionCN": strDescriptionCn,
    "strDescriptionIT": strDescriptionIt == null ? null : strDescriptionIt,
    "strDescriptionJP": strDescriptionJp,
    "strDescriptionRU": strDescriptionRu,
    "strDescriptionES": strDescriptionEs,
    "strDescriptionPT": strDescriptionPt,
    "strDescriptionSE": strDescriptionSe,
    "strDescriptionNL": strDescriptionNl,
    "strDescriptionHU": strDescriptionHu,
    "strDescriptionNO": strDescriptionNo,
    "strDescriptionIL": strDescriptionIl,
    "strDescriptionPL": strDescriptionPl,
    "strKitColour1": strKitColour1 == null ? null : strKitColour1,
    "strKitColour2": strKitColour2 == null ? null : strKitColour2,
    "strKitColour3": strKitColour3 == null ? null : strKitColour3,
    "strGender": strGender,
    "strCountry": strCountry,
    "strTeamBadge": strTeamBadge,
    "strTeamJersey": strTeamJersey == null ? null : strTeamJersey,
    "strTeamLogo": strTeamLogo,
    "strTeamFanart1": strTeamFanart1,
    "strTeamFanart2": strTeamFanart2,
    "strTeamFanart3": strTeamFanart3,
    "strTeamFanart4": strTeamFanart4,
    "strTeamBanner": strTeamBanner,
    "strYoutube": strYoutube,
    "strLocked": strLocked,
    "status": status,
    "created_at": createdAt!.toIso8601String(),
  };
}
