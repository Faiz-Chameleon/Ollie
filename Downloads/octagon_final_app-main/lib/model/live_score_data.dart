// To parse this JSON data, do
//
//     final liveScoreData = liveScoreDataFromJson(jsonString);

import 'dart:convert';

LiveScoreData liveScoreDataFromJson(String str) => LiveScoreData.fromJson(json.decode(str));

String liveScoreDataToJson(LiveScoreData data) => json.encode(data.toJson());

class LiveScoreData {
  LiveScoreData({
    this.stages,
  });

  List<Stage>? stages;

  factory LiveScoreData.fromJson(Map<String, dynamic> json) => LiveScoreData(
    stages: List<Stage>.from(json["Stages"].map((x) => Stage.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Stages": List<dynamic>.from(stages!.map((x) => x.toJson())),
  };
}

class Event {
  Event({
    this.eid,
    this.pids,
    this.sids,
    this.tr1,
    this.tr2,
    this.tr1Or,
    this.tr2Or,
    this.t1,
    this.t2,
    this.eps,
    this.esid,
    this.epr,
    this.ecov,
    this.ern,
    this.ernInf,
    this.et,
    this.esd,
    this.luUt,
    this.eds,
    this.eact,
    this.eo,
    this.incsX,
    this.comX,
    this.luX,
    this.statX,
    this.subsX,
    this.sdFowX,
    this.sdInnX,
    this.luC,
    this.ehid,
    this.spid,
    this.stg,
    this.pid,
    this.trh1,
    this.trh2,
  });

  String? eid;
  Map<String, String>? pids;
  Map<String, String>? sids;
  String? tr1;
  String? tr2;
  String? tr1Or;
  String? tr2Or;
  List<T1>? t1;
  List<T1>? t2;
  String? eps;
  int? esid;
  int? epr;
  int? ecov;
  int? ern;
  String? ernInf;
  int? et;
  int? esd;
  int? luUt;
  int? eds;
  int? eact;
  int? eo;
  int? incsX;
  int? comX;
  int? luX;
  int? statX;
  int? subsX;
  int? sdFowX;
  int? sdInnX;
  int? luC;
  int? ehid;
  int? spid;
  Stage? stg;
  int? pid;
  String? trh1;
  String? trh2;

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    eid: json["Eid"],
    pids: Map.from(json["Pids"]).map((k, v) => MapEntry<String, String>(k, v)),
    sids: Map.from(json["Sids"]).map((k, v) => MapEntry<String, String>(k, v)),
    tr1: json["Tr1"],
    tr2: json["Tr2"],
    tr1Or: json["Tr1OR"],
    tr2Or: json["Tr2OR"],
    t1: List<T1>.from(json["T1"].map((x) => T1.fromJson(x))),
    t2: List<T1>.from(json["T2"].map((x) => T1.fromJson(x))),
    eps: json["Eps"],
    esid: json["Esid"],
    epr: json["Epr"],
    ecov: json["Ecov"],
    ern: json["Ern"],
    ernInf: json["ErnInf"],
    et: json["Et"],
    esd: json["Esd"],
    luUt: json["LuUT"] == null ? null : json["LuUT"],
    eds: json["Eds"],
    eact: json["Eact"],
    eo: json["EO"],
    incsX: json["IncsX"],
    comX: json["ComX"],
    luX: json["LuX"],
    statX: json["StatX"],
    subsX: json["SubsX"],
    sdFowX: json["SDFowX"],
    sdInnX: json["SDInnX"],
    luC: json["LuC"],
    ehid: json["Ehid"],
    spid: json["Spid"],
    stg: Stage.fromJson(json["Stg"]),
    pid: json["Pid"],
    trh1: json["Trh1"] == null ? null : json["Trh1"],
    trh2: json["Trh2"] == null ? null : json["Trh2"],
  );

  Map<String, dynamic> toJson() => {
    "Eid": eid,
    "Pids": pids == null ? null : Map.from(pids!).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "Sids": sids == null ? null : Map.from(sids!).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "Tr1": tr1,
    "Tr2": tr2,
    "Tr1OR": tr1Or,
    "Tr2OR": tr2Or,
    "T1": t1 == null ? null : List<dynamic>.from(t1!.map((x) => x.toJson())),
    "T2": t2 == null ? null : List<dynamic>.from(t2!.map((x) => x.toJson())),
    "Eps": eps,
    "Esid": esid,
    "Epr": epr,
    "Ecov": ecov,
    "Ern": ern,
    "ErnInf": ernInf,
    "Et": et,
    "Esd": esd,
    "LuUT": luUt == null ? null : luUt,
    "Eds": eds,
    "Eact": eact,
    "EO": eo,
    "IncsX": incsX,
    "ComX": comX,
    "LuX": luX,
    "StatX": statX,
    "SubsX": subsX,
    "SDFowX": sdFowX,
    "SDInnX": sdInnX,
    "LuC": luC,
    "Ehid": ehid,
    "Spid": spid,
    "Stg": stg!.toJson(),
    "Pid": pid,
    "Trh1": trh1 == null ? null : trh1,
    "Trh2": trh2 == null ? null : trh2,
  };
}

class Stage {
  Stage({
    this.sid,
    this.snm,
    this.scd,
    this.cid,
    this.cnm,
    this.csnm,
    this.ccd,
    this.compId,
    this.compN,
    this.compD,
    this.scu,
    this.ccdiso,
    this.chi,
    this.shi,
    this.sdn,
    this.events,
    this.sds,
  });

  String? sid;
  String? snm;
  String? scd;
  String? cid;
  String? cnm;
  String? csnm;
  String? ccd;
  String? compId;
  String? compN;
  String? compD;
  int? scu;
  String? ccdiso;
  int? chi;
  int? shi;
  String? sdn;
  List<Event>? events;
  String? sds;

  factory Stage.fromJson(Map<String, dynamic> json) => Stage(
    sid: json["Sid"],
    snm: json["Snm"],
    scd: json["Scd"],
    cid: json["Cid"],
    cnm: json["Cnm"],
    csnm: json["Csnm"],
    ccd: json["Ccd"],
    compId: json["CompId"] == null ? null : json["CompId"],
    compN: json["CompN"] == null ? null : json["CompN"],
    compD: json["CompD"] == null ? null : json["CompD"],
    scu: json["Scu"],
    ccdiso: json["Ccdiso"],
    chi: json["Chi"],
    shi: json["Shi"],
    sdn: json["Sdn"],
    events: json["Events"] == null ? null : List<Event>.from(json["Events"].map((x) => Event.fromJson(x))),
    sds: json["Sds"] == null ? null : json["Sds"],
  );

  Map<String, dynamic> toJson() => {
    "Sid": sid,
    "Snm": snm,
    "Scd": scd,
    "Cid": cid,
    "Cnm": cnm,
    "Csnm": csnm,
    "Ccd": ccd,
    "CompId": compId == null ? null : compId,
    "CompN": compN == null ? null : compN,
    "CompD": compD == null ? null : compD,
    "Scu": scu,
    "Ccdiso": ccdiso,
    "Chi": chi,
    "Shi": shi,
    "Sdn": sdn,
    "Events": events == null ? null : List<dynamic>.from(events!.map((x) => x.toJson())),
    "Sds": sds == null ? null : sds,
  };
}

class T1 {
  T1({
    this.nm,
    this.id,
    this.img,
    this.newsTag,
    this.abr,
    this.tbd,
    this.gd,
    this.pids,
    this.coNm,
    this.coId,
    this.hasVideo,
  });

  String? nm;
  String? id;
  String? img;
  String? newsTag;
  String? abr;
  int? tbd;
  int? gd;
  Map<String, List<String>>? pids;
  String? coNm;
  String? coId;
  bool? hasVideo;

  factory T1.fromJson(Map<String, dynamic> json) => T1(
    nm: json["Nm"],
    id: json["ID"],
    img: json["Img"],
    newsTag: json["NewsTag"] == null ? null : json["NewsTag"],
    abr: json["Abr"],
    tbd: json["tbd"],
    gd: json["Gd"],
    pids: Map.from(json["Pids"]).map((k, v) => MapEntry<String, List<String>>(k, List<String>.from(v.map((x) => x)))),
    coNm: json["CoNm"],
    coId: json["CoId"],
    hasVideo: json["HasVideo"],
  );

  Map<String, dynamic> toJson() => {
    "Nm": nm,
    "ID": id,
    "Img": img,
    "NewsTag": newsTag == null ? null : newsTag,
    "Abr": abr,
    "tbd": tbd,
    "Gd": gd,
    "Pids": pids == null ? null : Map.from(pids!).map((k, v) => MapEntry<String, dynamic>(k, List<dynamic>.from(v.map((x) => x)))),
    "CoNm": coNm,
    "CoId": coId,
    "HasVideo": hasVideo,
  };
}
