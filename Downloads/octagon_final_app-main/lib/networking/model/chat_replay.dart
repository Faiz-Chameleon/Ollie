import 'dart:convert';



class ChatReplayMessage {
  String? firebaseToken;
  String? docId;
  String? content;
  String? userName;
  String? senderUid;
  String? userImage;
  String? userDefaultTeam;
  List<String> messageDepth = [];
  String? image;
  String? video;
  bool? isRead;
  DateTime? updatedAt;
  int? createdAt;
  int? likeCount;
  List<String>? likeUsers;
  List<ChatReplayMessage>? replay = [];
  bool isMoreVisible = false;

  ChatReplayMessage(
      {this.firebaseToken, this.senderUid, this.image = "", this.isMoreVisible = false, this.video = "", this.isRead = false,
        this.content,
        this.likeUsers,
        this.docId,
        // required this.messageDepth,
        this.userDefaultTeam,
        this.replay,
        this.userImage,
        this.likeCount,
        this.updatedAt, this.createdAt, this.userName = ""}) ;

  factory ChatReplayMessage.fromJson(Map<String, dynamic> json) {
    return ChatReplayMessage(
      senderUid: json["senderUid"] ?? null,
      firebaseToken: json["firebaseToken"] ?? null,
      docId: json["docId"],
      image: json["image"],
      userName: json["userName"] ?? "",
      userDefaultTeam: json["userDefaultTeam"] ?? "",
      userImage: json["userImage"] ?? "",
      isRead: json["isRead"],
      video: json["video"],
      content: json["content"],
      likeCount: json["likeCount"],
      likeUsers: json["likeUsers"]!=null ?
      List<String>.from(json["likeUsers"].map((x) => x)):null,
      // messageDepth: json["messageDepth"],
      replay: json["replay"]==null || json["replay"].toString().length < 4? [] :
      List<ChatReplayMessage>.from(json["replay"].map((x) => ChatReplayMessage.fromJson(x))),
      isMoreVisible: false,
      createdAt: json["createdAt"],
      // updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "image" : image,
    "content" : content,
    "userName": userName,
    "docId": docId,
    "firebaseToken": firebaseToken,
    // "updatedAt" : updatedAt,
    "createdAt": createdAt,
    "isRead" : isRead,
    "senderUid" : senderUid,
    "video" : video,
    "userImage" : userImage,
    "likeCount": likeCount,
    "likeUsers":  likeUsers!=null ? likeUsers!.map((x) => x).toList() : [],
    "userDefaultTeam": userDefaultTeam,
    "messageDepth": messageDepth,
    "isMoreVisible": isMoreVisible,
    "replay" : replay!=null ? replay!.map((x) => x.toJson()).toList() : [],
  };

}
