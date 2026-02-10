import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:octagon/screen/chat/new_groupchat_screen.dart';
import 'package:octagon/screen/edit_profile/edit_profile_controller.dart';

import 'package:octagon/screen/profile/ProfileController.dart';
import 'package:octagon/screen/profile/octagon_container.dart';
import 'package:octagon/screen/profile/other_user_profile.dart';
import 'package:octagon/screen/profile/profile_posts.dart';
import 'package:octagon/screen/setting/setting_screen.dart';

import 'package:octagon/utils/theme/theme_constants.dart';

import 'package:resize/resize.dart';
import 'package:shape_maker/shape_maker.dart';

import '../../main.dart';

import '../../utils/chat_room.dart';

import '../../widgets/default_user_image.dart';

import 'follow_following.dart';
import 'package:stroke_text/stroke_text.dart';

class ProfileScreen extends StatefulWidget {
  int? userId;
  ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final controller = Get.put(ProfileController());
  late TabController _tabController;
  bool _hasLoaded = false;

  @override
  void initState() {
    widget.userId ??= storage.read("current_uid");
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.profileData.value == null && !controller.isLoading.value) {
        controller.refreshAll(force: true);
      }
    });

    // Get existing controller or create new one
    // try {
    //   controller = Get.find<ProfileController>();
    //   // If controller exists but has no data, refresh it
    //   if (controller.profileData.value == null) {
    //     controller.refreshAll();
    //   }
    // } catch (e) {
    //   controller = Get.put(ProfileController());
    // }

    // Force refresh posts after a short delay to ensure they load
    // if (!_hasLoaded) {
    //   // Force refresh posts after a short delay to ensure they load
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Future.delayed(Duration(milliseconds: 500), () {
    //       // controller.refreshAll();
    //       _hasLoaded = true; // ← MARK AS LOADED
    //     });
    // });
    // }

    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Refresh data when screen dependencies change (navigation)
  //   // WidgetsBinding.instance.addPostFrameCallback((_) {
  //   //   controller.refreshAll();
  //   // });
  // }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     // Refresh data when app comes back to foreground
  //     // controller.refreshAll();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: appBgColor,
        elevation: 0,
        title: StrokeText(
          text: "Octagon",
          textAlign: TextAlign.center,
          textStyle: whiteColor20BoldTextStyle.copyWith(fontSize: 40, color: Colors.black, fontWeight: FontWeight.w700),
          strokeColor: Colors.yellow,
          strokeWidth: 3.5,
        ),
        // Text("", style: whiteColor20BoldTextStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              controller.refreshAll(force: true);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && !controller.isDataLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }
        try {
          // Add error handling
          if (controller.profileData.value == null && !controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Failed to load profile",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.refreshAll(force: true),
                    child: Text("Retry"),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.refreshAll(force: true),
            child: Column(
              children: [
                // Profile Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Profile Picture or Group Image
                          controller.profileData.value?.success?.user?.userType == "2" && controller.groups.isNotEmpty
                              ? Stack(
                                  clipBehavior: Clip.none,
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
                                        'http://3.134.119.154/${controller.groups[0]["photo"]}', // Replace with your image URL
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
                                )
                              : controller.profileData.value?.success?.user?.userType == "0"
                                  ? Container(
                                      width: 75,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: greyColor,
                                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                                        image: DecorationImage(
                                          image: NetworkImage(controller.profileData.value?.success?.user?.photo ?? ""),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: !isProfilePicAvailable(controller.profileData.value?.success?.user?.photo) ? defaultThumb() : null,
                                    )
                                  : SizedBox.shrink(),

                          // Positioned Group Image (if user is not in group, hide)
                          if (controller.profileData.value?.success?.user?.userType != "2")
                            Positioned(
                              bottom: -18,
                              left: 12,
                              child: ClipPath(
                                clipper: OctagonClipper(),
                                child: CustomPaint(
                                  painter: OctagonBorderPainter(
                                    strokeWidth: 20.0,
                                    borderColor: Color(0xff211D39),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(7.0),
                                    child: ClipPath(
                                        clipper: OctagonClipper(),
                                        child:
                                            //  controller.groupProfileUrl.contains("http")
                                            //     ?
                                            Image.network(
                                          controller.groupProfileUrl.contains("http")
                                              ? "${controller.groupProfileUrl.toString()}"
                                              : 'http://3.134.119.154/${controller.groupProfileUrl}', // Replace with your image URL
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.fill,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                              width: 40,
                                              height: 40,
                                              color: Color(0xff211D39),
                                              child: Image.asset(
                                                'assets/ic/Group 4.png',
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.contain,
                                              )
                                              // Icon(Icons.error, color: Colors.red),
                                              ),
                                        )
                                        // : Image.asset(
                                        //     'assets/ic/Group 4.png',
                                        //     width: 40,
                                        //     height: 40,
                                        //     fit: BoxFit.contain,
                                        //   ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(width: 10),

                      // Profile or Group Information
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25),
                            ),
                          ),
                          child: Obx(() {
                            try {
                              final user = controller.profileData.value?.success?.user;

                              // If user is a group user (userType == "2")
                              if (user?.userType == "2" && controller.groups.isNotEmpty) {
                                final group = controller.groups[0];
                                return IntrinsicHeight(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 30,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          spacing: 0.0,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 5),
                                              child: Text(group["title"] ?? "No name", style: blackColor16BoldTextStyle),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(
                                                Icons.settings,
                                                color: Colors.black,
                                                size: 20,
                                              ),
                                              onPressed: () => Get.to(() => SettingScreen(profileData: controller.profileData.value)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      if (group["description"] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, bottom: 7, right: 7),
                                          child: Container(
                                            height: 30.h,
                                            child: Text(
                                              group["description"] != '""' ? group["description"] : "",
                                              style: blueColor12BoldTextStyle,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              } else {
                                // If user is not in a group
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: Text(controller.userName.value, style: blackColor20BoldTextStyle),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.settings, color: Colors.black),
                                          onPressed: () => Get.to(() => SettingScreen(profileData: controller.profileData.value)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                        height: 30.h,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 15, bottom: 2),
                                          child: Text(
                                            controller.bio.value,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: blackColor,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )),
                                  ],
                                );
                              }
                            } catch (e) {
                              return Text("Error loading profile", style: blackColor20BoldTextStyle);
                            }
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.vh),

                // Group Members Section (only for team profiles)
                Obx(() {
                  try {
                    final user = controller.profileData.value?.success?.user;
                    if (user?.userType == "2" && controller.groupMembers.isNotEmpty && controller.groupMembers.value != null) {
                      return Container(
                        height: 90.h,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Group Members",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.groupMembers.length,
                                itemBuilder: (context, index) {
                                  try {
                                    final member = controller.groupMembers[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 60.w,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5.r),
                                              color: purpleColor,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      print('Navigating to user profile with userId: ${controller.groupMembers[index]["id"]}');
                                                      Get.to(() => OtherUserProfileScreen(userId: controller.groupMembers[index]["id"]));
                                                    },
                                                    child: ShapeMaker(
                                                      height: 50,
                                                      width: 50,
                                                      bgColor: Colors.yellow,
                                                      widget: Container(
                                                        margin: const EdgeInsets.all(6),
                                                        child: ShapeMaker(
                                                          bgColor: Colors.black,
                                                          widget: Container(
                                                            margin: const EdgeInsets.all(8),
                                                            child: ShapeMaker(
                                                              bgColor: appBgColor,
                                                              widget: CachedNetworkImage(
                                                                imageUrl: "${member["photo"]}",
                                                                fit: BoxFit.cover,
                                                                placeholder: (context, url) => const SizedBox(height: 10),
                                                                errorWidget: (context, url, error) => const Icon(Icons.error, size: 20),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Container(
                                                  //   width: 30,
                                                  //   height: 30,
                                                  //   decoration: BoxDecoration(
                                                  //     shape: BoxShape.circle,
                                                  //     image: DecorationImage(
                                                  //         image: NetworkImage(
                                                  //           "${member["photo"]}",
                                                  //         ),
                                                  //         fit: BoxFit.fill),
                                                  //   ),
                                                  // ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Container(
                                                    constraints: BoxConstraints(maxWidth: 80),
                                                    child: Text(
                                                      member["name"] ?? "",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // CircleAvatar(
                                          //   radius: 15,
                                          //   backgroundImage: (member["photo"] !=
                                          //               null &&
                                          //           member["photo"].isNotEmpty)
                                          //       ? NetworkImage(
                                          //           "http://3.134.119.154/${member["photo"]}")
                                          //       : null,
                                          //   backgroundColor: Colors.deepPurple,
                                          //   child: (member["photo"] == null ||
                                          //           member["photo"].isEmpty)
                                          //       ? Icon(Icons.person,
                                          //           color: Colors.white,
                                          //           size: 20)
                                          //       : null,
                                          // ),
                                          SizedBox(height: 2),
                                        ],
                                      ),
                                    );
                                  } catch (e) {
                                    return SizedBox.shrink();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    print("Error in group members section: $e");
                  }
                  return SizedBox.shrink();
                }),

                // Stats
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat("Posts", controller.postCount.value),
                      _buildStat(
                        "Followers",
                        controller.followers.value,
                        onTap: () {
                          final followers = controller.profileData.value?.success?.followersUsers ?? [];
                          final following = controller.profileData.value?.success?.followingUsers ?? [];
                          Get.to(() => FollowFollowingScreen(
                                followersUsers: followers,
                                followingUsers: following,
                                initialIndex: 0,
                              ));
                        },
                      ),
                      _buildStat(
                        "Following",
                        controller.following.value,
                        onTap: () {
                          final followers = controller.profileData.value?.success?.followersUsers ?? [];
                          final following = controller.profileData.value?.success?.followingUsers ?? [];
                          Get.to(() => FollowFollowingScreen(
                                followersUsers: followers,
                                followingUsers: following,
                                initialIndex: 1,
                              ));
                        },
                      ),
                      _buildStat("Favourites", controller.saveCount.value),
                    ],
                  ),
                ),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    labelColor: purpleColor,
                    unselectedLabelColor: Colors.black,
                    tabs: const [
                      Tab(icon: Icon(Icons.apps_rounded)),
                      Tab(icon: Icon(Icons.bookmark_border)),
                    ],
                  ),
                ),

                // TabBar View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Obx(() {
                        print("Posts count: ${controller.posts.length}");
                        return ProfilePosts(
                          postDataList: controller.posts,
                          onButtonPress: (post) => controller.deletePost(post.id.toString()),
                        );
                      }),
                      Obx(() {
                        print("Favorites count: ${controller.favorites.length}");
                        return ProfilePosts(
                          postDataList: controller.favorites,
                          isSavedPost: true,
                          onButtonPress: (post) => controller.toggleSavePost(post.id.toString()),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        } catch (e) {
          print("Error in profile screen: $e");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Something went wrong",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.refreshAll(force: true),
                  child: Text("Retry"),
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  Widget _buildStat(String title, int value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(title, style: whiteColor14TextStyle),
          const SizedBox(height: 4),
          Text('$value', style: whiteColor16BoldTextStyle),
        ],
      ),
    );
  }
}
