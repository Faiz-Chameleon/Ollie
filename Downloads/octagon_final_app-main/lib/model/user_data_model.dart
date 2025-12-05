class Users {
  Users({
    this.id,
    this.name,
    this.email,
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
  String? background;
  String? dob;
  String? bio;
  String? country;
  dynamic? emailVerifiedAt;
  String? password;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? isDeleted;

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        gender: json["gender"],
        userType: json["user_type"],
        profileAccess: json["profile_access"],
        mobile: json["mobile"],
        photo: json["photo"] == null ? null : json["photo"],
        background: json["background"] == null ? null : json["background"],
        dob: json["dob"] == null ? null : json["dob"],
        bio: json["bio"] == null ? null : json["bio"],
        country: json["country"],
        emailVerifiedAt: json["email_verified_at"],
        password: json["password"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        isDeleted: json["is_deleted"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "gender": gender,
        "user_type": userType,
        "profile_access": profileAccess,
        "mobile": mobile,
        "photo": photo == null ? null : photo,
        "background": background == null ? null : background,
        "dob": dob == null ? null : dob,
        "bio": bio == null ? null : bio,
        "country": country,
        "email_verified_at": emailVerifiedAt,
        "password": password,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "is_deleted": isDeleted,
      };
}
