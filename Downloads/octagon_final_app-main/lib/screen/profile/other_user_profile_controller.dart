import 'package:get/get.dart';
import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/model/user_profile_response.dart';
import 'package:octagon/networking/model/resource.dart';
import 'package:octagon/networking/model/user_response_model.dart';
import 'package:octagon/networking/response.dart';

import 'package:octagon/screen/mainFeed/bloc/post_repo.dart';

class OtherUserProfileController extends GetxController {
  final PostRepository _repo = PostRepository();

  Rxn<UserProfileResponseModel> profileData = Rxn();
  RxList<PostResponseModelData> postList = <PostResponseModelData>[].obs;
  RxList<PostResponseModelData> storyList = <PostResponseModelData>[].obs;
  RxBool isLoading = false.obs;
  RxBool isBlocked = false.obs;
  RxBool isReported = false.obs;

  final int userId;
  int currentPage = 1;
  bool isMoreAvailable = false;

  OtherUserProfileController(this.userId);

  @override
  void onInit() {
    super.onInit();
    print('OtherUserProfileController initialized with userId: $userId');
    fetchUserProfile();
    fetchPosts();
  }

  Future<void> fetchUserProfile() async {
    try {
      print('Fetching user profile for userId: $userId');
      isLoading.value = true;
      final Resource res = await _repo.getOtherProfile(userId.toString());
      print('Profile API response: ${res.data}');
      profileData.value = res.data;
      isLoading.value = false;
      print('Profile data loaded: ${profileData.value?.success?.user?.name}');
    } catch (e) {
      print('Error fetching user profile: $e');
      isLoading.value = false;
    }
  }

  Future<void> fetchPosts() async {
    try {
      print('Fetching posts for userId: $userId');
      isLoading.value = true;
      final Resource<PostResponseModel> res = await _repo.getPosts(pageNo: currentPage, isProfile: true, userId: userId.toString());

      if (res.data != null) {
        print('Posts API response received successfully');
        print('Posts count: ${res.data!.success?.length ?? 0}');

        final List<PostResponseModelData> success = res.data!.success ?? [];
        postList.assignAll(success.where((e) => e.type == "1").toList());
        storyList.assignAll(success.where((e) => e.type == "2").toList());
        isMoreAvailable = res.data!.more ?? false;

        print('Posts loaded: ${postList.length} posts, ${storyList.length} stories');
      } else {
        print('Posts API response is null');
        postList.clear();
        storyList.clear();
        isMoreAvailable = false;
      }

      isLoading.value = false;
    } catch (e) {
      print('Error fetching posts: $e');
      print('Error stack trace: ${StackTrace.current}');
      isLoading.value = false;
      postList.clear();
      storyList.clear();
      isMoreAvailable = false;
    }
  }

  Future<void> blockUnblockUser(bool shouldBlock) async {
    try {
      await _repo.blockUnblockUser(userId: userId.toString(), isBlock: shouldBlock);
      isBlocked.value = !isBlocked.value;
    } catch (e) {
      print('Error blocking/unblocking user: $e');
    }
  }

  Future<void> followUserFromProfile(
    String userId,
    bool isFollow,
  ) async {
    await _repo.followUser(
      followId: userId,
      follow: isFollow ? "1" : "0",
    );
    profileData.value?.success?.follow_status = isFollow;
    profileData.value?.success?.followers =
        isFollow ? (profileData.value?.success?.followers ?? 0) + 1 : (profileData.value?.success?.followers ?? 1) - 1;
    profileData.refresh();
  }

  @override
  void onClose() {
    print('OtherUserProfileController disposed for userId: $userId');
    super.onClose();
  }
}
