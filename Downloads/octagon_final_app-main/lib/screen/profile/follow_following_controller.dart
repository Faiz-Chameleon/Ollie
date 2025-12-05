import 'package:get/get.dart';
import 'package:octagon/networking/model/user_response_model.dart';
import 'package:octagon/networking/response.dart';
import 'package:octagon/screen/mainFeed/bloc/post_repo.dart';

class FollowFollowingController extends GetxController {
  final _postRepo = PostRepository();

  RxList<UserModel> followers = <UserModel>[].obs;
  RxList<UserModel> following = <UserModel>[].obs;
  RxInt currentTab = 0.obs;

  RxBool isLoading = false.obs;

  void setData({
    required List<UserModel> followersList,
    required List<UserModel> followingList,
  }) {
    followers.assignAll(followersList);
    following.assignAll(followingList);
  }

  void switchTab(int index) {
    currentTab.value = index;
  }

  Future<void> followUser(UserModel user) async {
    isLoading.value = true;
    await _postRepo.followUser(followId: "1", follow: user.id.toString());
    following.add(user);
    isLoading.value = false;
  }

  Future<void> unfollowUser(UserModel user) async {
    isLoading.value = true;
    await _postRepo.followUser(followId: "0", follow: user.id.toString());
    following.removeWhere((element) => element.id == user.id);
    isLoading.value = false;
  }

  Future<void> removeFollower(UserModel user) async {
    isLoading.value = true;
    await _postRepo.followUser(followId: user.id.toString(), follow: '0');
    followers.removeWhere((element) => element.id == user.id);
    isLoading.value = false;
  }
}
