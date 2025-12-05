import 'package:get/get.dart';
import 'package:octagon/main.dart';
import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/model/team_list_response.dart';
import 'package:octagon/model/user_data_model.dart';
import 'package:octagon/model/user_profile_response.dart';
import 'package:octagon/networking/model/resource.dart';

import 'package:octagon/screen/mainFeed/bloc/post_repo.dart';
import 'package:octagon/networking/network.dart';

class ProfileController extends GetxController {
  Future<void> fetchAllData() async {
    await refreshAll(force: true);
  }

  final PostRepository _repo = PostRepository();
  final isDataLoaded = false.obs;
  var lastLoadTime = DateTime(0).obs;
  var isInitialized = false.obs;
  var dataStale = false.obs;

  final profileData = Rxn<UserProfileResponseModel>();
  final posts = <PostResponseModelData>[].obs;
  final favorites = <PostResponseModelData>[].obs;
  final sports = <TeamData>[].obs;

  final isLoading = false.obs;
  final saveCount = 0.obs;
  final followers = 0.obs;
  final following = 0.obs;
  final postCount = 0.obs;
  final userName = ''.obs;
  final bio = ''.obs;
  final profileUrl = ''.obs;
  final groupProfileUrl = ''.obs;

  int currentPageNo = 1;

  // Add observable for groups
  final groups = [].obs;

  // Add observable for group members
  final groupMembers = [].obs;

  Future<void> fetchProfile({bool force = false}) async {
    if (!shouldFetchData(force: force)) return;
    isLoading.value = true;

    final res = await _repo.getUserProfile();
    if (res.data != null) {
      profileData.value = res.data;
      final user = res.data?.success?.user;
      saveCount.value = res.data?.success?.savePostCount ?? 0;
      postCount.value = res.data?.success?.postCount ?? 0;
      followers.value = res.data?.success?.followers ?? 0;
      following.value = res.data?.success?.following ?? 0;
      userName.value = user?.name ?? '';
      bio.value = user?.bio ?? '';
      profileUrl.value = user?.photo ?? '';
      groupProfileUrl.value = user?.groupPhoto ?? "";
    }

    isLoading.value = false;
    lastLoadTime.value = DateTime.now();
    isInitialized.value = true;
    dataStale.value = false;
  }

  bool shouldFetchData({bool force = false}) {
    if (isLoading.value) return false; // Already loading

    // Always fetch if forced OR data is stale OR never initialized
    if (force || dataStale.value || !isInitialized.value) return true;

    // Fetch if data is older than 2 minutes
    return DateTime.now().difference(lastLoadTime.value).inMinutes > 2;
  }

  // Fetch groups for team profile
  Future<void> fetchGroups() async {
    try {
      isLoading.value = true;
      final result = await NetworkAPICall().multiPartPostRequest(
        "user-groups-get",
        {"user_id": storage.read("current_uid").toString()},
        true,
        "POST",
      );
      groups.value = result["success"] ?? [];
    } catch (e) {
      groups.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch group members for team profile
  Future<void> fetchGroupMembers() async {
    try {
      isLoading.value = true;
      if (groups.isNotEmpty) {
        final groupId = groups[0]["id"]?.toString() ?? "";
        if (groupId.isNotEmpty) {
          final result = await NetworkAPICall().multiPartPostRequest(
            "user-groups-list",
            {"group_id": groupId},
            true,
            "POST",
          );
          final allMembers = result["success"] ?? [];
          // Filter members where ismember == 1
          groupMembers.value = allMembers.where((member) => member["is_member"] == 1 || member["is_member"] == "1").toList();
        }
      }
    } catch (e) {
      groupMembers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  final String groupId = "";

  var errorMessage = ''.obs;
  var users = <Users>[].obs;
  final isLoadingOnProfile = false.obs;

  // Future<void> fetchGroupMembers() async {
  //   try {
  //     isLoadingOnProfile.value = true;
  //     errorMessage.value = '';
  //     final data = await NetworkAPICall().getUsersForGroupInvite(groupId);
  //     users.value = data
  //         .where((u) => u['is_member'] == 0 || u['is_member'] == '0')
  //         .map<Users>((u) => Users.fromJson(u))
  //         .toList();
  //   } catch (e) {
  //     errorMessage.value = 'Failed to load users: $e';
  //   } finally {
  //     isLoadingOnProfile.value = false;
  //   }
  // }

  Future<void> fetchPosts() async {
    try {
      isLoading.value = true;
      print("Fetching posts...");
      final Resource<PostResponseModel> res = await _repo.getPosts(
        pageNo: currentPageNo,
        isProfile: true,
      );
      print("Posts API response: ${res.data}");

      if (res.data == null || res.data!.success == null) {
        print("No posts found or invalid response format");
        posts.clear();
        return;
      }

      final filteredPosts = res.data!.success!.where((e) => e.type == "1").toList();
      print("Filtered posts count: ${filteredPosts.length}");

      posts.value = filteredPosts;
      // posts.refresh(); // Force refresh
    } catch (e) {
      print("Error fetching posts: $e");
      posts.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSavedPosts() async {
    final res = await _repo.getSavedPosts(currentPageNo);
    favorites.value = res.data?.success?.where((e) => e.type == "1").toList() ?? [];
  }

  Future<void> fetchUserTeams() async {
    final res = await _repo.getBlockedUsers(1); // Replace if wrong
    if (res.data is List<TeamData>) {
      sports.value = res.data as List<TeamData>;
    }
  }

  Future<void> deletePost(String postId) async {
    await _repo.deletePost(postId);
    await fetchPosts();
  }

  Future<void> refreshAll({bool force = false}) async {
    if (!shouldFetchData(force: true)) return;
    await Future.wait([
      fetchProfile(force: true),
      fetchPosts(),
      fetchSavedPosts(),
      fetchUserTeams(),
    ]);
    // Fetch groups if userType == 2 (team profile)
    if (profileData.value?.success?.user?.userType == "2") {
      await fetchGroups();
      await fetchGroupMembers();
    }
  }

  void toggleSavePost(String postId) {
    final index = favorites.indexWhere((p) => p.id.toString() == postId);
    if (index != -1) {
      favorites[index].isSaveByMe = !favorites[index].isSaveByMe;
      favorites.refresh();
    }
  }

  void markDataAsStale() {
    dataStale.value = true; // This will force refresh next time
  }

  void clearUserData() {
    lastLoadTime.value = DateTime(0);
    isInitialized.value = false;
    dataStale.value = false;
    profileData.value = null;
    posts.clear();
    favorites.clear();
    sports.clear();
    groups.clear();
    groupMembers.clear();
    saveCount.value = 0;
    followers.value = 0;
    following.value = 0;
    postCount.value = 0;
    userName.value = '';
    bio.value = '';
    profileUrl.value = '';
  }
}
