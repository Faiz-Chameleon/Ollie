import 'package:get/get.dart';
import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/model/favorite_model.dart';
import 'package:octagon/model/follow_model.dart';
import 'package:octagon/model/comment_response_model.dart';
import 'package:octagon/model/block_user.dart';
import 'package:octagon/model/live_score_data.dart';
import 'package:octagon/model/file_upload_response_model.dart';
import 'package:octagon/model/user_profile_response.dart';
import 'package:octagon/networking/model/request_model/create_post_request.dart';
import 'package:octagon/screen/common/create_post_controller.dart';
import 'package:octagon/screen/common/create_post_screen.dart';

import 'package:octagon/networking/model/resource.dart';
import 'package:octagon/screen/mainFeed/bloc/post_repo.dart';
import 'package:octagon/utils/constants.dart';

class PostController extends GetxController {
  final _repo = PostRepository();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var posts = <PostResponseModelData>[].obs;
  var savedPosts = <PostResponseModelData>[].obs;

  var userProfile = Rxn<UserProfileResponseModel>();
  var blockList = <dynamic>[].obs;
  var liveScoreData = Rxn<LiveScoreData>();

  /// --- POST RELATED OPERATIONS ---
  Future<void> fetchPosts({int pageNo = 1}) async {
    isLoading.value = true;
    final res = await _repo.getPosts(pageNo: pageNo);
    isLoading.value = false;
    if (res.data != null) {
      posts.addAll(res.data!.success ?? []);
    } else {
      errorMessage.value = res.error ?? 'Unknown error';
    }
  }

  Future<void> likePost(String contentId, bool isLiked, String type) async {
    await _repo.likePost(
      contentId: contentId,
      isLike: isLiked ? "1" : "0",
      type: type,
    );
  }

  // Future<void> followUser(String userId, bool isFollow) async {
  //   await _repo.followUser(followId: userId, follow: isFollow ? "1" : "0");
  // }
  Future<void> followUser(String userId, bool isFollow) async {
    await _repo.followUser(
      followId: userId,
      follow: isFollow ? "1" : "0",
    );
  }

  // Future<void> followUserFromProfile(String userId, bool isFollow, dynamic user) async {
  //   await _repo.followUser(
  //     followId: userId,
  //     follow: isFollow ? "1" : "0",
  //   );
  //   user.follow_status = isFollow;
  //   update();
  // }

  Future<void> savePost(String postId, bool isSaved) async {
    await _repo.savePost(postId: postId, save: isSaved ? "1" : "0");
  }

  Future<PostResponseModel?> getPostDetails(String postId, String type) async {
    final res = await _repo.getPostDetails(postId: postId, type: type);
    return res.data;
  }

  /// --- COMMENTS ---
  Future<void> addComment(String postId, String comment) async {
    await _repo.addComment(postId: postId, comment: comment);
  }

  Future<void> deleteComment(String commentId) async {
    await _repo.deleteComment(commentId);
  }

  /// --- POST MANAGEMENT ---
  Future<void> deletePost(String postId) async {
    await _repo.deletePost(postId);
    posts.removeWhere((p) => p.id.toString() == postId);
  }

  Future<void> createPost(var request) async {
    await _repo.createPost(request);
  }

  /// --- PROFILE ---
  Future<void> getUserProfile() async {
    final res = await _repo.getUserProfile();
    if (res.data != null) {
      userProfile.value = res.data;
    }
  }

  Future<void> getOtherProfile(String userId) async {
    final res = await _repo.getOtherProfile(userId);
    if (res.data != null) {
      userProfile.value = res.data;
    }
  }

  /// --- BLOCKING ---
  Future<void> blockUnblockUser(String userId, bool isBlock) async {
    await _repo.blockUnblockUser(userId: userId, isBlock: isBlock);
  }

  Future<void> getBlockedUsers(int pageNo) async {
    final res = await _repo.getBlockedUsers(pageNo);
    if (res.data != null) {
      // blockList.assignAll(res.data!.data ?? []);
    }
  }

  /// --- LIVE SCORES ---
  Future<void> fetchLiveScore(String sportType) async {
    final res = await _repo.getLiveScore(sportType);
    if (res.data != null) {
      liveScoreData.value = res.data;
    }
  }

  /// --- FILE UPLOAD ---
  Future<FileUploadResponseModel?> uploadMedia(int type, List<PostFile> files) async {
    final res = await _repo.uploadFile(type, files);
    return res.data;
  }

  /// --- REPORT ---
  Future<void> reportPost({
    required String contentId,
    required String title,
    required String type,
  }) async {
    await _repo.reportPost(contentId: contentId, title: title, type: type);
  }

  /// --- SAVED POSTS ---
  Future<void> fetchSavedPosts({int pageNo = 1}) async {
    final res = await _repo.getSavedPosts(pageNo);
    if (res.data != null) {
      savedPosts.assignAll(res.data!.success ?? []);
    }
  }
}
