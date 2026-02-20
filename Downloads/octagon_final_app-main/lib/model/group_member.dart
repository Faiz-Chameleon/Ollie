class GroupMember {
  final int id;
  final int groupId;
  final int userId;
  final String name;
  final String email;
  final String photo;
  final bool isDeleted;
  final int isInvited;
  final String? requestStatus;

  GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.name,
    required this.email,
    required this.photo,
    required this.isDeleted,
    required this.isInvited,
    required this.requestStatus,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return GroupMember(
      id: json['id'],
      groupId: json['group_id'],
      userId: json['user_id'],
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      photo: user['photo'] ?? '',
      isDeleted: json['is_deleted'] == "1" || json['is_deleted'] == 1,
      isInvited: json['is_invited'] ?? 0,
      requestStatus: json['status'],
    );
  }
}
