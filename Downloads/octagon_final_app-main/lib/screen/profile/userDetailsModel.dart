class UserDetailsModel {
  Success? success;

  UserDetailsModel({this.success});

  UserDetailsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] != null ? Success.fromJson(json['success']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (success != null) {
      data['success'] = success!.toJson();
    }
    return data;
  }
}

class Success {
  int? following;
  List<FollowingUsers>? followingUsers;
  int? followers;
  List<FollowingUsers>? followersUsers;
  User? user;
  List<SportInfo>? sportInfo;
  int? postCount;
  int? favoritePostCount;
  int? savePostCount;
  int? likePostCount;

  Success(
      {this.following,
      this.followingUsers,
      this.followers,
      this.followersUsers,
      this.user,
      this.sportInfo,
      this.postCount,
      this.favoritePostCount,
      this.savePostCount,
      this.likePostCount});

  Success.fromJson(Map<String, dynamic> json) {
    following = json['following'];
    if (json['followingUsers'] != null) {
      followingUsers = <FollowingUsers>[];
      json['followingUsers'].forEach((v) {
        followingUsers!.add(FollowingUsers.fromJson(v));
      });
    }
    followers = json['followers'];
    if (json['followersUsers'] != null) {
      followersUsers = <FollowingUsers>[];
      json['followersUsers'].forEach((v) {
        followersUsers!.add(FollowingUsers.fromJson(v));
      });
    }
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['sport_info'] != null) {
      sportInfo = <SportInfo>[];
      json['sport_info'].forEach((v) {
        sportInfo!.add(SportInfo.fromJson(v));
      });
    }
    postCount = json['post_count'];
    favoritePostCount = json['favorite_post_count'];
    savePostCount = json['save_post_count'];
    likePostCount = json['like_post_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['following'] = following;
    if (followingUsers != null) {
      data['followingUsers'] = followingUsers!.map((v) => v.toJson()).toList();
    }
    data['followers'] = followers;
    if (followersUsers != null) {
      data['followersUsers'] = followingUsers!.map((v) => v.toJson()).toList();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (sportInfo != null) {
      data['sport_info'] = sportInfo!.map((v) => v.toJson()).toList();
    }
    data['post_count'] = postCount;
    data['favorite_post_count'] = favoritePostCount;
    data['save_post_count'] = savePostCount;
    data['like_post_count'] = likePostCount;
    return data;
  }
}

class FollowingUsers {
  int? id;
  String? name;
  String? email;
  var socialId;
  String? gender;
  String? userType;
  String? profileAccess;
  String? mobile;
  var photo;
  var background;
  String? dob;
  String? bio;
  String? country;
  var emailVerifiedAt;
  String? password;
  String? fcmToken;
  var rememberToken;
  String? createdAt;
  String? updatedAt;
  String? isDeleted;

  FollowingUsers(
      {this.id,
      this.name,
      this.email,
      this.socialId,
      this.gender,
      this.userType,
      this.profileAccess,
      this.mobile,
      this.photo,
      this.background,
      this.dob,
      this.bio,
      this.country,
      this.emailVerifiedAt,
      this.password,
      this.fcmToken,
      this.rememberToken,
      this.createdAt,
      this.updatedAt,
      this.isDeleted});

  FollowingUsers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    socialId = json['social_id'];
    gender = json['gender'];
    userType = json['user_type'];
    profileAccess = json['profile_access'];
    mobile = json['mobile'];
    photo = json['photo'];
    background = json['background'];
    dob = json['dob'];
    bio = json['bio'];
    country = json['country'];
    emailVerifiedAt = json['email_verified_at'];
    password = json['password'];
    fcmToken = json['fcm_token'];
    rememberToken = json['remember_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isDeleted = json['is_deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['social_id'] = this.socialId;
    data['gender'] = this.gender;
    data['user_type'] = this.userType;
    data['profile_access'] = this.profileAccess;
    data['mobile'] = this.mobile;
    data['photo'] = this.photo;
    data['background'] = this.background;
    data['dob'] = this.dob;
    data['bio'] = this.bio;
    data['country'] = this.country;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['password'] = this.password;
    data['fcm_token'] = this.fcmToken;
    data['remember_token'] = this.rememberToken;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_deleted'] = this.isDeleted;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  var socialId;
  String? gender;
  String? userType;
  String? profileAccess;
  String? mobile;
  var photo;
  var background;
  var dob;
  var bio;
  String? country;
  var emailVerifiedAt;
  String? password;
  String? fcmToken;
  var rememberToken;
  String? createdAt;
  String? updatedAt;
  String? isDeleted;

  User(
      {this.id,
      this.name,
      this.email,
      this.socialId,
      this.gender,
      this.userType,
      this.profileAccess,
      this.mobile,
      this.photo,
      this.background,
      this.dob,
      this.bio,
      this.country,
      this.emailVerifiedAt,
      this.password,
      this.fcmToken,
      this.rememberToken,
      this.createdAt,
      this.updatedAt,
      this.isDeleted});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    socialId = json['social_id'];
    gender = json['gender'];
    userType = json['user_type'];
    profileAccess = json['profile_access'];
    mobile = json['mobile'];
    photo = json['photo'];
    background = json['background'];
    dob = json['dob'];
    bio = json['bio'];
    country = json['country'];
    emailVerifiedAt = json['email_verified_at'];
    password = json['password'];
    fcmToken = json['fcm_token'];
    rememberToken = json['remember_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isDeleted = json['is_deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['social_id'] = this.socialId;
    data['gender'] = this.gender;
    data['user_type'] = this.userType;
    data['profile_access'] = this.profileAccess;
    data['mobile'] = this.mobile;
    data['photo'] = this.photo;
    data['background'] = this.background;
    data['dob'] = this.dob;
    data['bio'] = this.bio;
    data['country'] = this.country;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['password'] = this.password;
    data['fcm_token'] = this.fcmToken;
    data['remember_token'] = this.rememberToken;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_deleted'] = this.isDeleted;
    return data;
  }
}

class SportInfo {
  int? id;
  int? idSport;
  String? strSport;
  String? strFormat;
  String? strSportThumb;
  String? strSportIconGreen;
  String? strSportDescription;
  String? createdAt;
  String? isDeleted;
  List<Team>? team;

  SportInfo(
      {this.id,
      this.idSport,
      this.strSport,
      this.strFormat,
      this.strSportThumb,
      this.strSportIconGreen,
      this.strSportDescription,
      this.createdAt,
      this.isDeleted,
      this.team});

  SportInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idSport = json['idSport'];
    strSport = json['strSport'];
    strFormat = json['strFormat'];
    strSportThumb = json['strSportThumb'];
    strSportIconGreen = json['strSportIconGreen'];
    strSportDescription = json['strSportDescription'];
    createdAt = json['created_at'];
    isDeleted = json['is_deleted'];
    if (json['team'] != null) {
      team = <Team>[];
      json['team'].forEach((v) {
        team!.add(new Team.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idSport'] = this.idSport;
    data['strSport'] = this.strSport;
    data['strFormat'] = this.strFormat;
    data['strSportThumb'] = this.strSportThumb;
    data['strSportIconGreen'] = this.strSportIconGreen;
    data['strSportDescription'] = this.strSportDescription;
    data['created_at'] = this.createdAt;
    data['is_deleted'] = this.isDeleted;
    if (this.team != null) {
      data['team'] = this.team!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Team {
  int? id;
  int? idTeam;
  var idSoccerXML;
  var idAPIfootball;
  var intLoved;
  String? strTeam;
  var strTeamShort;
  var strAlternate;
  var intFormedYear;
  int? idSport;
  String? strSport;
  String? strLeague;
  var idLeague;
  var strLeague2;
  var idLeague2;
  var strLeague3;
  var idLeague3;
  var strLeague4;
  var idLeague4;
  var strLeague5;
  var idLeague5;
  var strLeague6;
  var idLeague6;
  var strLeague7;
  var idLeague7;
  var strDivision;
  var strManager;
  var strStadium;
  var strKeywords;
  var strRSS;
  var strStadiumThumb;
  var strStadiumDescription;
  var strStadiumLocation;
  var intStadiumCapacity;
  var strWebsite;
  var strFacebook;
  var strTwitter;
  var strInstagram;
  var strDescriptionEN;
  var strDescriptionDE;
  var strDescriptionFR;
  var strDescriptionCN;
  var strDescriptionIT;
  var strDescriptionJP;
  var strDescriptionRU;
  var strDescriptionES;
  var strDescriptionPT;
  var strDescriptionSE;
  var strDescriptionNL;
  var strDescriptionHU;
  var strDescriptionNO;
  var strDescriptionIL;
  var strDescriptionPL;
  var strKitColour1;
  var strKitColour2;
  var strKitColour3;
  var strGender;
  var idCountry;
  var strCountry;
  var strTeamBadge;
  var strTeamJersey;
  String? strTeamLogo;
  var strTeamFanart1;
  var strTeamFanart2;
  var strTeamFanart3;
  var strTeamFanart4;
  var strTeamBanner;
  var strYoutube;
  var strLocked;
  String? status;
  String? createdAt;

  Team(
      {this.id,
      this.idTeam,
      this.idSoccerXML,
      this.idAPIfootball,
      this.intLoved,
      this.strTeam,
      this.strTeamShort,
      this.strAlternate,
      this.intFormedYear,
      this.idSport,
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
      this.strRSS,
      this.strStadiumThumb,
      this.strStadiumDescription,
      this.strStadiumLocation,
      this.intStadiumCapacity,
      this.strWebsite,
      this.strFacebook,
      this.strTwitter,
      this.strInstagram,
      this.strDescriptionEN,
      this.strDescriptionDE,
      this.strDescriptionFR,
      this.strDescriptionCN,
      this.strDescriptionIT,
      this.strDescriptionJP,
      this.strDescriptionRU,
      this.strDescriptionES,
      this.strDescriptionPT,
      this.strDescriptionSE,
      this.strDescriptionNL,
      this.strDescriptionHU,
      this.strDescriptionNO,
      this.strDescriptionIL,
      this.strDescriptionPL,
      this.strKitColour1,
      this.strKitColour2,
      this.strKitColour3,
      this.strGender,
      this.idCountry,
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
      this.createdAt});

  Team.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idTeam = json['idTeam'];
    idSoccerXML = json['idSoccerXML'];
    idAPIfootball = json['idAPIfootball'];
    intLoved = json['intLoved'];
    strTeam = json['strTeam'];
    strTeamShort = json['strTeamShort'];
    strAlternate = json['strAlternate'];
    intFormedYear = json['intFormedYear'];
    idSport = json['idSport'];
    strSport = json['strSport'];
    strLeague = json['strLeague'];
    idLeague = json['idLeague'];
    strLeague2 = json['strLeague2'];
    idLeague2 = json['idLeague2'];
    strLeague3 = json['strLeague3'];
    idLeague3 = json['idLeague3'];
    strLeague4 = json['strLeague4'];
    idLeague4 = json['idLeague4'];
    strLeague5 = json['strLeague5'];
    idLeague5 = json['idLeague5'];
    strLeague6 = json['strLeague6'];
    idLeague6 = json['idLeague6'];
    strLeague7 = json['strLeague7'];
    idLeague7 = json['idLeague7'];
    strDivision = json['strDivision'];
    strManager = json['strManager'];
    strStadium = json['strStadium'];
    strKeywords = json['strKeywords'];
    strRSS = json['strRSS'];
    strStadiumThumb = json['strStadiumThumb'];
    strStadiumDescription = json['strStadiumDescription'];
    strStadiumLocation = json['strStadiumLocation'];
    intStadiumCapacity = json['intStadiumCapacity'];
    strWebsite = json['strWebsite'];
    strFacebook = json['strFacebook'];
    strTwitter = json['strTwitter'];
    strInstagram = json['strInstagram'];
    strDescriptionEN = json['strDescriptionEN'];
    strDescriptionDE = json['strDescriptionDE'];
    strDescriptionFR = json['strDescriptionFR'];
    strDescriptionCN = json['strDescriptionCN'];
    strDescriptionIT = json['strDescriptionIT'];
    strDescriptionJP = json['strDescriptionJP'];
    strDescriptionRU = json['strDescriptionRU'];
    strDescriptionES = json['strDescriptionES'];
    strDescriptionPT = json['strDescriptionPT'];
    strDescriptionSE = json['strDescriptionSE'];
    strDescriptionNL = json['strDescriptionNL'];
    strDescriptionHU = json['strDescriptionHU'];
    strDescriptionNO = json['strDescriptionNO'];
    strDescriptionIL = json['strDescriptionIL'];
    strDescriptionPL = json['strDescriptionPL'];
    strKitColour1 = json['strKitColour1'];
    strKitColour2 = json['strKitColour2'];
    strKitColour3 = json['strKitColour3'];
    strGender = json['strGender'];
    idCountry = json['idCountry'];
    strCountry = json['strCountry'];
    strTeamBadge = json['strTeamBadge'];
    strTeamJersey = json['strTeamJersey'];
    strTeamLogo = json['strTeamLogo'];
    strTeamFanart1 = json['strTeamFanart1'];
    strTeamFanart2 = json['strTeamFanart2'];
    strTeamFanart3 = json['strTeamFanart3'];
    strTeamFanart4 = json['strTeamFanart4'];
    strTeamBanner = json['strTeamBanner'];
    strYoutube = json['strYoutube'];
    strLocked = json['strLocked'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idTeam'] = this.idTeam;
    data['idSoccerXML'] = this.idSoccerXML;
    data['idAPIfootball'] = this.idAPIfootball;
    data['intLoved'] = this.intLoved;
    data['strTeam'] = this.strTeam;
    data['strTeamShort'] = this.strTeamShort;
    data['strAlternate'] = this.strAlternate;
    data['intFormedYear'] = this.intFormedYear;
    data['idSport'] = this.idSport;
    data['strSport'] = this.strSport;
    data['strLeague'] = this.strLeague;
    data['idLeague'] = this.idLeague;
    data['strLeague2'] = this.strLeague2;
    data['idLeague2'] = this.idLeague2;
    data['strLeague3'] = this.strLeague3;
    data['idLeague3'] = this.idLeague3;
    data['strLeague4'] = this.strLeague4;
    data['idLeague4'] = this.idLeague4;
    data['strLeague5'] = this.strLeague5;
    data['idLeague5'] = this.idLeague5;
    data['strLeague6'] = this.strLeague6;
    data['idLeague6'] = this.idLeague6;
    data['strLeague7'] = this.strLeague7;
    data['idLeague7'] = this.idLeague7;
    data['strDivision'] = this.strDivision;
    data['strManager'] = this.strManager;
    data['strStadium'] = this.strStadium;
    data['strKeywords'] = this.strKeywords;
    data['strRSS'] = this.strRSS;
    data['strStadiumThumb'] = this.strStadiumThumb;
    data['strStadiumDescription'] = this.strStadiumDescription;
    data['strStadiumLocation'] = this.strStadiumLocation;
    data['intStadiumCapacity'] = this.intStadiumCapacity;
    data['strWebsite'] = this.strWebsite;
    data['strFacebook'] = this.strFacebook;
    data['strTwitter'] = this.strTwitter;
    data['strInstagram'] = this.strInstagram;
    data['strDescriptionEN'] = this.strDescriptionEN;
    data['strDescriptionDE'] = this.strDescriptionDE;
    data['strDescriptionFR'] = this.strDescriptionFR;
    data['strDescriptionCN'] = this.strDescriptionCN;
    data['strDescriptionIT'] = this.strDescriptionIT;
    data['strDescriptionJP'] = this.strDescriptionJP;
    data['strDescriptionRU'] = this.strDescriptionRU;
    data['strDescriptionES'] = this.strDescriptionES;
    data['strDescriptionPT'] = this.strDescriptionPT;
    data['strDescriptionSE'] = this.strDescriptionSE;
    data['strDescriptionNL'] = this.strDescriptionNL;
    data['strDescriptionHU'] = this.strDescriptionHU;
    data['strDescriptionNO'] = this.strDescriptionNO;
    data['strDescriptionIL'] = this.strDescriptionIL;
    data['strDescriptionPL'] = this.strDescriptionPL;
    data['strKitColour1'] = this.strKitColour1;
    data['strKitColour2'] = this.strKitColour2;
    data['strKitColour3'] = this.strKitColour3;
    data['strGender'] = this.strGender;
    data['idCountry'] = this.idCountry;
    data['strCountry'] = this.strCountry;
    data['strTeamBadge'] = this.strTeamBadge;
    data['strTeamJersey'] = this.strTeamJersey;
    data['strTeamLogo'] = this.strTeamLogo;
    data['strTeamFanart1'] = this.strTeamFanart1;
    data['strTeamFanart2'] = this.strTeamFanart2;
    data['strTeamFanart3'] = this.strTeamFanart3;
    data['strTeamFanart4'] = this.strTeamFanart4;
    data['strTeamBanner'] = this.strTeamBanner;
    data['strYoutube'] = this.strYoutube;
    data['strLocked'] = this.strLocked;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    return data;
  }
}
