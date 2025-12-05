import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/model/team_list_response.dart';
import 'package:octagon/networking/model/resource.dart';

import 'package:octagon/screen/setting/group_controller.dart';
import 'package:octagon/screen/chat/group_chat_screen.dart';

import 'package:octagon/screen/mainFeed/bloc/post_repo.dart';

import 'package:octagon/screen/chat_network/bloc/chat_bloc.dart';
import 'package:octagon/screen/tabs_screen.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  final ScrollController _scrollController = ScrollController();

  void scrollToTop() {
    // Scroll to the top (index 0)
    _scrollController.animateTo(
      0, // Scroll position at index 0
      duration: Duration(milliseconds: 500), // Duration for smooth scroll
      curve: Curves.easeInOut, // Animation curve for smooth scroll
    );
  }

  final PostRepository _postRepository = PostRepository();
  final ChatBloc chatBloc = ChatBloc();
  final GroupController groupController = Get.put(GroupController());

  var postDataList = <PostResponseModelData>[].obs;
  var poster = Rxn<PostResponseModel>();
  var team = <TeamData>[].obs;
  var groups = <PublicGroupModel>[].obs;
  var isStoryVisible = true.obs;
  var isLoading = false.obs;
  var isMorePageAvailable = false;
  var currentPageNo = 1;
  var isRefreshHome = false;

  ScrollController scrollController = ScrollController();
  ScrollController teamsScrollController = ScrollController();
  updateData(PostResponseModel data) {
    poster.value = data;
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   scrollController.addListener(() {
  //     if (scrollController.hasClients) {
  //       _pagination();
  //       _updateStoryVisibility();
  //     }
  //   });

  //   // getUserTeams();
  //   getHomePageData();

  //   Future.delayed(Duration.zero, () {
  //     getAllGroups();
  //   });

  //   chatBloc.roomDataStream.listen((event) {
  //     if (event.status == Status.COMPLETED) {
  //       final result = event.data as List<TeamData>;
  //       final filtered =
  //           result.where((e) => !team.any((t) => t.id == e.id)).toList();
  //       team.addAll(filtered);
  //     }
  //   });

  //   currentPage.stream.listen((event) {
  //     if (event == 0) {
  //       scrollToTopSafely();
  //     }
  //   });
  // }

  void _updateStoryVisibility() {
    if (!scrollController.hasClients) return;
    isStoryVisible.value = scrollController.position.pixels == 0;
  }

  void scrollToTopSafely() {
    final tempMute = isMute;
    isMute = true;

    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    if (teamsScrollController.hasClients) {
      teamsScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    isMute = tempMute;
  }

  void navigateToGroupChat(PublicGroupModel group) async {
    if (group.isPublic != "1") {
      // Fetch group members
      final storage = GetStorage();
      final token = storage.read("token");
      if (token == null) {
        print("No token found in storage");
        return;
      }

      var headers = {'Authorization': 'Bearer $token'};
      var request = http.MultipartRequest('POST', Uri.parse('http://3.134.119.154/api/user-groups-list'));
      request.fields.addAll({'group_id': group.id.toString()});
      request.headers.addAll(headers);

      try {
        final response = await request.send();
        if (response.statusCode == 200) {
          String responseBody = await response.stream.bytesToString();
          var data = json.decode(responseBody);
          List<String> members = [];
          if (data['success'] != null && data['success'] is List) {
            members = (data['success'] as List).map((e) => e['user_id'].toString()).toList();
          }

          Get.to(() => GroupChatScreen(
                groupId: group.id.toString(),
                groupName: group.title,
                groupPhoto: group.photo,
                members: members,
              ));
        } else {
          print(response.reasonPhrase);
          Get.snackbar("Error", "Failed to fetch group members", backgroundColor: Colors.red, colorText: Colors.white);
        }
      } catch (e) {
        print("Error fetching group members: $e");
        Get.snackbar("Error", "Failed to fetch group members", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      Get.snackbar("Private Group", "This is a private group. You need to be a member to join the chat.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> getHomePageData() async {
    if (isLoading.value) return;

    isLoading.value = true;
    final Resource<PostResponseModel> res = await _postRepository.getPosts(pageNo: currentPageNo);
    if (res.data != null) {
      await updateData(res.data!);
    }
    isLoading.value = false;

    // if (res.data != null) {
    //   if (isRefreshHome) postDataList.clear();
    //   for (var post in res.data!.success ?? []) {
    //     if (!postDataList.any((e) => e.post == post.post)) {
    //       postDataList.add(post);
    //     }
    //   }
    //   isMorePageAvailable = res.data!.more ?? false;
    //   isRefreshHome = false;
    // }
  }

  // void _pagination() {
  //   if (!scrollController.hasClients) return;

  //   final position = scrollController.position;
  //   if (position.pixels >= position.maxScrollExtent - 200 && isMorePageAvailable && !isLoading.value) {
  //     isRefreshHome = false;
  //     currentPageNo += 1;
  //     getHomePageData();
  //   }
  // }

  Future<void> refreshPage() async {
    isRefreshHome = true;
    currentPageNo = 1;
    postDataList.clear();
    await Future.wait([
      // getHomePageData(),
      getAllGroups()
    ]);
    update();
  }

  // void getUserTeams() {
  //   final data = storage.read(sportInfo);
  //   final List<TeamData> sportsListing = [];

  //   if (data != null) {
  //     for (var element in data) {
  //       final value = SportInfo.fromJson(element);
  //       sportsListing.add(TeamData(sportId: value.idSport));
  //     }
  //   }

  //   if (sportsListing.isNotEmpty) {
  //     team.assignAll(sportsListing);
  //     chatBloc.getChatRooms(sportsListing.first);
  //   }
  // }

  Future<void> getAllGroups() async {
    try {
      final allGroups = await groupController.fetchAllGroups();
      groups.assignAll(allGroups);
    } catch (e) {
      print("Error fetching groups: $e");
    }
  }

  Future<String?> ensureThreadIdForGroup(PublicGroupModel group) async {
    if (group.thread_id.isNotEmpty) return group.thread_id;
    final storage = GetStorage();
    final currentUserId = storage.read("current_uid");
    if (currentUserId == null) {
      print('No logged in user id found; cannot resolve thread id');
      return null;
    }
    if (group.userId.toString() != currentUserId.toString()) {
      // Only the creator can trigger thread creation
      print('Only group creators can create chat threads');
      return null;
    }
    try {
      final threadId = await groupController.fetchOrCreateThreadId(group.id.toString());
      if (threadId != null && threadId.isNotEmpty) {
        final idx = groups.indexWhere((g) => g.id == group.id);
        if (idx != -1) {
          groups[idx] = groups[idx].copyWith(thread_id: threadId);
        }
      }
      return threadId;
    } catch (e) {
      print('Failed to ensure thread id: $e');
      return null;
    }
  }
}
