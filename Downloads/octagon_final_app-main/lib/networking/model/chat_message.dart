import 'dart:convert';
import 'chat_replay.dart';

class ChatMessageData {
  String? firebaseToken;
  String? docId;
  String? content;
  String? senderUid;
  String? senderName;
  String? senderTeam;
  String? senderImage;
  String? image;
  String? video;
  bool? isRead;
  int? likeCount;
  List<String>? likeUsers;
  DateTime? updatedAt;
  DateTime? createdOn;
  List<ChatReplayMessage>? replay = [];

  String timeAgo = "";

  String? currentUserUid;

  ChatMessageData(
      {this.firebaseToken,
      this.docId,
      this.senderUid,
      this.senderName,
      this.image = "",
      this.timeAgo = "",
      this.video = "",
      this.isRead = false,
      this.createdOn,
      this.content,
      this.senderImage,
      this.senderTeam,
      this.likeCount,
      this.likeUsers,
      this.updatedAt,
      this.replay});

  factory ChatMessageData.fromJson(Map<String, dynamic> json) {
    return ChatMessageData(
      firebaseToken: json["firebaseToken"] ?? "",
      docId: json["docId"] ?? "",
      senderUid: json["senderUid"] != null ? json["senderUid"] : null,
      senderName: json["senderName"] != null ? json["senderName"] : null,
      image: json["image"],
      timeAgo: json["timeAgo"],
      isRead: json["isRead"],
      video: json["video"],
      senderImage: json["senderImage"],
      senderTeam: json["senderTeam"],
      createdOn: json["createdOn"] != null
          ? json["createdOn"].toDate()
          : DateTime.now(),
      content: json["content"],
      likeCount: json["likeCount"],
      likeUsers:
          json["likeUsers"] == null || json["likeUsers"].toString().length < 4
              ? []
              : List<String>.from(jsonDecode(json["likeUsers"]).map((x) => x)),
      // updatedAt: DateTime.parse(json["updatedAt"]),
      replay: json["replay"] == null || json["replay"].toString().length < 4
          ? []
          : List<ChatReplayMessage>.from(jsonDecode(json["replay"])
              .map((x) => ChatReplayMessage.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "firebaseToken": firebaseToken,
        "docId": docId,
        "image": image,
        "createdOn": createdOn,
        "content": content,
        "updatedAt": updatedAt,
        "isRead": isRead,
        "senderUid": senderUid,
        "senderName": senderName,
        "timeAgo": timeAgo,
        "video": video,
        "senderTeam": senderTeam,
        "senderImage": senderImage,
        "likeCount": likeCount,
        "likeUsers": likeUsers != null ? likeUsers!.map((x) => x).toList() : [],
        "replay": replay != null ? replay!.map((x) => x.toJson()).toList() : [],
      };
}
