// To parse this JSON data, do
//
//     final notificationResponse = notificationResponseFromJson(jsonString);

import 'dart:convert';

NotificationResponse notificationResponseFromJson(String str) => NotificationResponse.fromJson(json.decode(str));

String notificationResponseToJson(NotificationResponse data) => json.encode(data.toJson());

class NotificationResponse {
  NotificationResponse({
    this.success,
  });

  Success? success;

  factory NotificationResponse.fromJson(Map<String, dynamic> json) => NotificationResponse(
    success:json["success"]!=null? Success.fromJson(json["success"]):null,
  );

  Map<String, dynamic> toJson() => {
    "success": success!.toJson(),
  };
}

class Success {
  Success({
    this.count,
    this.notification,
  });

  int? count;
  List<NotificationData>? notification;

  factory Success.fromJson(Map<String, dynamic> json) => Success(
    count: json["count"],
    notification:
    json["notification"]==null ? [] :
    List<NotificationData>.from(json["notification"].map((x) => NotificationData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "notification": List<dynamic>.from(notification!.map((x) => x.toJson())),
  };
}

class NotificationData {
  NotificationData({
    this.id,
    this.user1,
    this.user2,
    this.typeId,
    this.notification,
    this.type,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.user,
    // this.post,
  });

  int? id;
  int? user1;
  int? user2;
  int? typeId;
  String? notification;
  int? type;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<User>? user;
  // List<Post>? post;

  factory NotificationData.fromJson(Map<String, dynamic> json) => NotificationData(
    id: json["id"],
    user1: json["user1"],
    user2: json["user2"],
    typeId: json["type_id"],
    notification: json["notification"],
    type: json["type"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    user: List<User>.from(json["user"].map((x) => User.fromJson(x))),
    // post: List<Post>.from(json["post"].map((x) => Post.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user1": user1,
    "user2": user2,
    "type_id": typeId,
    "notification": notification,
    "type": type,
    "status": status,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
    "user": List<dynamic>.from(user!.map((x) => x.toJson())),
    // "post": List<dynamic>.from(post!.map((x) => x.toJson())),
  };
}

class Post {
  Post({
    this.id,
    this.userId,
    this.title,
    this.post,
    this.type,
    this.location,
    this.shareUrl,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
  });

  int? id;
  int? userId;
  String? title;
  String? post;
  String? type;
  String? location;
  String? shareUrl;
  String? comment;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? isDeleted;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json["id"],
    userId: json["user_id"],
    title: json["title"],
    post: json["post"],
    type: json["type"],
    location: json["location"],
    shareUrl: json["share_url"],
    comment: json["comment"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    isDeleted: json["is_deleted"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "title": title,
    "post": post,
    "type": type,
    "location": location,
    "share_url": shareUrl,
    "comment": comment,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
    "is_deleted": isDeleted,
  };
}

class User {
  User({
    this.id,
    this.name,
    this.email,
    this.gender,
    this.userType,
    this.profileAccess,
    this.mobile,
    this.photo,
    // this.background,
    // this.dob,
    // this.bio,
    this.country,
    // this.emailVerifiedAt,
    // this.password,
    // this.fcmToken,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
  });

  int? id;
  String? name;
  String? email;
  String? gender;
  String? userType;
  String? profileAccess;
  String? mobile;
  String? photo;
  // dynamic background;
  // dynamic dob;
  // dynamic bio;
  String? country;
  // dynamic emailVerifiedAt;
  // String password;
  // dynamic fcmToken;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? isDeleted;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    gender: json["gender"],
    userType: json["user_type"],
    profileAccess: json["profile_access"],
    mobile: json["mobile"],
    photo: json["photo"],
    // background: json["background"],
    // dob: json["dob"],
    // bio: json["bio"],
    country: json["country"],
    // emailVerifiedAt: json["email_verified_at"],
    // password: json["password"],
    // fcmToken: json["fcm_token"],
    // createdAt: DateTime.parse(json["created_at"]),
    // updatedAt: DateTime.parse(json["updated_at"]),
    // isDeleted: json["is_deleted"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "gender": gender,
    "user_type": userType,
    "profile_access": profileAccess,
    "mobile": mobile,
    "photo": photo,
    // "background": background,
    // "dob": dob,
    // "bio": bio,
    "country": country,
    // "email_verified_at": emailVerifiedAt,
    // "password": password,
    // "fcm_token": fcmToken,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
    "is_deleted": isDeleted,
  };
}
