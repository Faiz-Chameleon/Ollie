import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:octagon/screen/mainFeed/home/home_controller.dart';
import 'package:octagon/screen/mainFeed/home/postController.dart';

import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/widgets/post_container_widget.dart';

import 'package:resize/resize.dart';

import 'package:share_plus/share_plus.dart';

import '../../main.dart';
import '../../model/post_response_model.dart';

import '../chat/new_groupchat_screen.dart';

import '../common/create_post_screen.dart';

import 'home/new_homecontroller.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.find();
  final postController = Get.put(PostController());
  final newHomeController = Get.find<NewHomecontroller>();

  @override
  void initState() {
    super.initState();
    // controller.scrollController.jumpTo(0);
    // Integrate the API call here
    // newHomeController.pagingController = PagingController<int, PostResponseModelData>(firstPageKey: 1);

    // newHomeController.pagingController!.addPageRequestListener((pageKey) {
    //   newHomeController.fetchPage(pageKey);
    // });

    controller.getAllGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.camera_alt, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostScreen())).then((value) {
              if (value != null) {
                // Refresh both controllers to ensure new posts appear
                controller.refreshPage();
                newHomeController.refreshPosts();
              }
            });
          },
        ),
        backgroundColor: appBgColor,
        elevation: 0.0,
        title: Text(
          "Octagon",
          style: whiteColor20BoldTextStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              Share.share('My Favourite app for sports https://octagonapp.com/app-download');
            },
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
              child: const Icon(
                Icons.near_me_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          )
        ],
      ),
      body: Obx(() => RefreshIndicator(
            onRefresh: () async {
              await controller.refreshPage();
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: controller.groups.isNotEmpty ? 90.h : 90.h,
                  margin: EdgeInsets.only(bottom: 1.vh, top: 1.vh),
                  child: ListView.builder(
                    controller: controller.scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.groups.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemBuilder: (_, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () async {
                            final selectedGroup = controller.groups[index];
                            String threadId = selectedGroup.thread_id;
                            if (threadId.isEmpty) {
                              final resolvedThreadId = await controller.ensureThreadIdForGroup(selectedGroup);
                              if (resolvedThreadId == null || resolvedThreadId.isEmpty) {
                                Get.snackbar('Error', 'Unable to open chat for this group. Please try again later.');
                                return;
                              }
                              threadId = resolvedThreadId;
                            }
                            Get.to(() => NewGroupChatScreen(
                                  groupId: selectedGroup.id.toString(),
                                  // ignore: unrelated_type_equality_checks
                                  isPublic: selectedGroup.isPublic == "0" ? true : false,
                                  userId: storage.read("current_uid").toString(),
                                  userName: storage.read("user_name").toString(),
                                  groupName: selectedGroup.title,
                                  groupImage: selectedGroup.photo.toString(),
                                  userImage: storage.read('image_url'),
                                  thread_id: threadId,
                                ));
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              controller.groups[index].isPublic == "1"
                                  ? Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.center,
                                      children: [
                                        // Octagon background image
                                        Image.asset(
                                          'assets/ic/Group 4.png', // Your uploaded PNG asset
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),

                                        // Centered network image
                                        ClipPath(
                                          clipper: OctagonClipper(),
                                          child: Image.network(
                                            'http://3.134.119.154/${controller.groups[index].photo}', // Replace with your image URL
                                            width: 45,
                                            height: 45,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 45,
                                              height: 45,
                                              color: Colors.transparent,
                                              child: Icon(
                                                Icons.error,
                                                color: Colors.red,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/ic/Group 5.png',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.contain,
                                        ),

                                        // Centered network image
                                        ClipPath(
                                          clipper: OctagonClipper(),
                                          child: Image.network(
                                            'http://3.134.119.154/${controller.groups[index].photo}', // Replace with your image URL
                                            width: 45,
                                            height: 45,
                                            fit: BoxFit.fill,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 45,
                                              height: 45,
                                              color: Colors.transparent,
                                              child: Icon(
                                                Icons.error,
                                                color: Colors.red,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              // SizedBox(height: 1.2),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  constraints: BoxConstraints(maxWidth: 90),
                                  child: Text(
                                    controller.groups[index].title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: PagedListView<int, PostResponseModelData>(
                    pagingController: newHomeController.pagingController ?? PagingController<int, PostResponseModelData>(firstPageKey: 0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    builderDelegate: PagedChildBuilderDelegate<PostResponseModelData>(
                      itemBuilder: (context, post, index) {
                        // Create a reactive reference to the post data
                        final reactivePost = post.obs;

                        return Obx(() => PostWidgets(
                              name: reactivePost.value.userName,
                              post: reactivePost.value.post,
                              postData: reactivePost.value,
                              onLike: () {
                                postController.likePost(
                                  reactivePost.value.id.toString(),
                                  !reactivePost.value.isLikedByMe,
                                  reactivePost.value.type.toString(),
                                );
                                reactivePost.value.isLikedByMe = !reactivePost.value.isLikedByMe;
                                reactivePost.value.likes += reactivePost.value.isLikedByMe ? 1 : -1;
                                newHomeController.pagingController?.itemList?[index] = reactivePost.value;
                                // Trigger reactive update
                                reactivePost.refresh();
                              },
                              onFollow: () {
                                postController.followUser(
                                  reactivePost.value.userId.toString(),
                                  !reactivePost.value.isUserFollowedByMe,
                                );
                                reactivePost.value.isUserFollowedByMe = !reactivePost.value.isUserFollowedByMe;
                                newHomeController.pagingController?.itemList?[index] = reactivePost.value;
                                // Trigger reactive update
                                reactivePost.refresh();
                              },
                              onSavePost: () {
                                postController.savePost(
                                  reactivePost.value.id.toString(),
                                  !reactivePost.value.isSaveByMe,
                                );
                                reactivePost.value.isSaveByMe = !reactivePost.value.isSaveByMe;
                                newHomeController.pagingController?.itemList?[index] = reactivePost.value;
                                // Trigger reactive update
                                reactivePost.refresh();
                              },
                              updateData: () {
                                newHomeController.pagingController?.refresh();
                              },
                            ));
                      },
                      firstPageProgressIndicatorBuilder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      noItemsFoundIndicatorBuilder: (context) => const Center(
                        child: Text(
                          'No posts available',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      newPageProgressIndicatorBuilder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
