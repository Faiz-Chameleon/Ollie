import 'user_data_model.dart';

class EditProfileResponseModel {
  final int following;
  final List<Users> followingUsers;
  final int followers;
  final List<Users> followersUsers;
  final Users user;
  final List<dynamic> sportInfo;
  final int postCount;
  final int favoritePostCount;
  final int savePostCount;
  final int likePostCount;

  EditProfileResponseModel({
    required this.following,
    required this.followingUsers,
    required this.followers,
    required this.followersUsers,
    required this.user,
    required this.sportInfo,
    required this.postCount,
    required this.favoritePostCount,
    required this.savePostCount,
    required this.likePostCount,
  });

  factory EditProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return EditProfileResponseModel(
      following: json['following'] ?? 0,
      followingUsers: (json['followingUsers'] as List<dynamic>?)?.map((e) => Users.fromJson(e)).toList() ?? [],
      followers: json['followers'] ?? 0,
      followersUsers: (json['followersUsers'] as List<dynamic>?)?.map((e) => Users.fromJson(e)).toList() ?? [],
      user: Users.fromJson(json['user'] ?? {}),
      sportInfo: json['sport_info'] ?? [],
      postCount: json['post_count'] ?? 0,
      favoritePostCount: json['favorite_post_count'] ?? 0,
      savePostCount: json['save_post_count'] ?? 0,
      likePostCount: json['like_post_count'] ?? 0,
    );
  }
}
