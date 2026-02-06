import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:octagon/main.dart';
import 'package:octagon/screen/mainFeed/bloc/post_bloc.dart';
import 'package:octagon/screen/mainFeed/bloc/post_event.dart';
import 'package:octagon/screen/mainFeed/bloc/post_state.dart';
import 'package:octagon/screen/mainFeed/home/postController.dart';
import 'package:octagon/screen/profile/follow_following.dart';
import 'package:octagon/screen/profile/other_user_profile_controller.dart';
import 'package:octagon/screen/profile/profile_posts.dart';
import 'package:octagon/screen/common/full_screen_post.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/image_picker_inapp.dart';

import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/toast_utils.dart';
import 'package:octagon/widgets/follow_button_widget.dart';
import '../../model/post_response_model.dart';
import '../../model/user_profile_response.dart';

import '../../networking/response.dart';
import '../../utils/analiytics.dart';
import '../../utils/octagon_common.dart';
import '../../utils/string.dart';

// class OtherUserProfileScreen extends StatefulWidget {
//   int? userId;

//   OtherUserProfileScreen({Key? key, this.userId}) : super(key: key);

//   @override
//   _OtherUserProfileScreenState createState() => _OtherUserProfileScreenState();
// }

// class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
//   bool isMorePageAvailable = false;
//   int currentPageNo = 1;

//   UserProfileResponseModel? profileData;
//   List<PostResponseModelData> postDataList = [];
//   List<PostResponseModelData> storiesDataList = [];

//    PostBloc postBloc = PostBloc();

//   bool isBlocked = true;
//   bool isReport = false;
//   List<String> reportOptions = ["Nudity or sexual activity", "Hate speech or symbols", "Scam or fraud", "Violence or dangerous organizations", "Sale of illegal or regulated goods", "Bullying or harassment", "Pretending to be someone else", "Intellectual property violation", "Suicide or self-injury", "Spam", "The problem isn't listed here"];

//   final CustomPopupMenuController _controller = CustomPopupMenuController();

//   @override
//   void initState() {

//     postBloc = PostBloc();

//     refreshData();

//     publishAmplitudeEvent(eventType: 'Other User Profile $kScreenView');
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: appBgColor,
//         appBar: AppBar(
//           backgroundColor: appBgColor,
//           elevation: 0.0,
//           leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: const Icon(
//               Icons.arrow_back,
//               color: Colors.white,
//             ),
//           ),
//           actions: [
//             CustomPopupMenu(
//               child: Container(
//                 child: const Icon(Icons.menu, color: Colors.white),
//                 padding: const EdgeInsets.all(20),
//               ),
//               menuBuilder: () => ClipRRect(
//                 borderRadius: BorderRadius.circular(5),
//                 child: Container(
//                   color: const Color(0xFF4C4C4C),
//                   child: IntrinsicWidth(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         GestureDetector(
//                           behavior: HitTestBehavior.translucent,
//                           onTap: () {
//                             _controller.hideMenu();
//                             isReport = false;
//                             //postBloc.blockUnblockUser(userId: "${profileData?.success?.user?.id??""}", isBlock: isBlocked);
//                             postBloc.add(BlockUnBlockEvent(
//                                 userId: "${profileData?.success?.user?.id??""}", isBlock: isBlocked
//                             ));
//                           },
//                           child: Container(
//                             height: 40,
//                             padding: const EdgeInsets.symmetric(horizontal: 20),
//                             child: Row(
//                               children: <Widget>[
//                                 const Icon(
//                                   Icons.block,
//                                   size: 15,
//                                   color: Colors.white,
//                                 ),
//                                 Expanded(
//                                   child: Container(
//                                     margin: const EdgeInsets.only(left: 10),
//                                     padding:
//                                     const EdgeInsets.symmetric(vertical: 10),
//                                     child: Text(
//                                       isBlocked? "Block":"Unblock",
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         GestureDetector(
//                           behavior: HitTestBehavior.translucent,
//                           onTap: () {
//                             _controller.hideMenu();
//                             buildReportDialog();
//                           },
//                           child: Container(
//                             height: 40,
//                             padding: const EdgeInsets.symmetric(horizontal: 20),
//                             child: Row(
//                               children: <Widget>[
//                                 const Icon(
//                                   Icons.report,
//                                   size: 15,
//                                   color: Colors.white,
//                                 ),
//                                 Expanded(
//                                   child: Container(
//                                     margin: const EdgeInsets.only(left: 10),
//                                     padding:
//                                     const EdgeInsets.symmetric(vertical: 10),
//                                     child: const Text("Report",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               pressType: PressType.singleClick,
//               verticalMargin: -10,
//               controller: _controller,
//             ),
//           ],
//           title: Text((isDataAvailable()?
//           "${profileData?.success?.user?.name}'s profile":"").capitalize!,
//             style: whiteColor20BoldTextStyle,
//           ),
//           centerTitle: false,
//         ),
//         body: BlocConsumer(
//           bloc: postBloc,
//           listener: (context,state){
//             if(state is PostLoadingBeginState){
//               onLoading(context);
//             }
//             if(state is PostErrorState){
//               stopLoader(context);
//             }
//             if(state is GetPostState){
//               stopLoader(context);
//               postDataList = [];
//               storiesDataList = [];
//               for (var element in state.postResponseModel.success!) {
//                 if (element.type == "1") {
//                   postDataList.add(element);
//                 } else if (element.type == "2") {
//                   storiesDataList.add(element);
//                 }
//               }
//               isMorePageAvailable = state.postResponseModel.more ?? false;
//             }
//             if(state is OtherUserProfileState){
//               stopLoader(context);
//               profileData = state.userProfileResponseModel;
//             }
//             if(state is BlockUnBlockUserState){
//               stopLoader(context);
//               showToast(message: "You just ${isReport ? 'reported' : 'blocked'} this user");
//               setState(() {
//                 isBlocked = !isBlocked;
//               });
//               Navigator.pop(context);
//             }
//           },
//           builder: (context,_) {
//             return isDataAvailable()?RefreshIndicator(
//               child: NestedScrollView(
//                 headerSliverBuilder:
//                     (BuildContext context, bool innerBoxIsScrolled) {
//                   return [
//                     SliverToBoxAdapter(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           SizedBox(
//                             height: 250,
//                             width: MediaQuery.of(context).size.width,
//                             child: Stack(
//                               children: [
//                                 Image.asset(
//                                   "assets/splash/splash.png",
//                                   height: 100,
//                                   fit: BoxFit.cover,
//                                   width: double.infinity,
//                                 ),

//                                 ///Middle Profile info container
//                                 Container(
//                                   height: 150,
//                                   width: double.infinity,
//                                   // decoration: BoxDecoration(
//                                   //     color: whiteColor,
//                                   //     borderRadius: const BorderRadius.only(
//                                   //         bottomRight: Radius.circular(50),
//                                   //         bottomLeft: Radius.circular(50))),
//                                   margin: const EdgeInsets.only(top: 100),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.max,
//                                     children: [
//                                       Container(
//                                         height: 150,
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 10),
//                                         // decoration: BoxDecoration(
//                                         //     color: whiteColor.withOpacity(0.5),
//                                         //     borderRadius: const BorderRadius.only(
//                                         //         bottomLeft: Radius.circular(50))),
//                                         child: buildProfileView(
//                                             userPic: profileData
//                                                     ?.success?.user?.photo ??
//                                                 "https://uifaces.co/our-content/donated/3799Ffxy.jpeg",
//                                             teamLogo:
//                                                 "https://uifaces.co/our-content/donated/3799Ffxy.jpeg"),
//                                       ),
//                                       Expanded(
//                                           child: Container(
//                                         height: 150,
//                                             decoration: BoxDecoration(
//                                                 color: whiteColor,
//                                                 borderRadius: const BorderRadius.only(
//                                                     bottomRight: Radius.circular(50),
//                                                     bottomLeft: Radius.circular(50))),
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 5, vertical: 10),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.spaceBetween,
//                                               children: [
//                                                 SizedBox(
//                                                   child: Row(
//                                                     children: [
//                                                       // const Icon(
//                                                       //   Icons.flaky,
//                                                       //   size: 30,
//                                                       //   color: Colors.grey,
//                                                       // ),
//                                                       Text(
//                                                         "${profileData?.success?.user?.name}".capitalize!,
//                                                         style:
//                                                             blackColor20BoldTextStyle,
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 const SizedBox(
//                                                   width: 10,
//                                                 ),
//                                               ],
//                                             ),
//                                             if (profileData?.success?.user?.bio !=
//                                                 null)
//                                               Text(
//                                                 "${profileData?.success?.user?.bio}",
//                                                 maxLines: 4,
//                                                 textAlign: TextAlign.start,
//                                                 overflow: TextOverflow.clip,
//                                                 style: blackColor16BoldTextStyle,
//                                               ),
//                                           ],
//                                         ),
//                                       ))
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),

//                           ///Post info
//                           Container(
//                             padding: const EdgeInsets.symmetric(vertical: 15),
//                             //height: 50,
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 ///post
//                                 buildPost(),

//                                 ///Followers
//                                 buildFollowers(),

//                                 ///Following
//                                 buildFollowing(),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ];
//                 },
//                 body: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Container(
//                     //   height: 50,
//                     //   decoration: BoxDecoration(
//                     //     color: whiteColor,
//                     //     borderRadius: const BorderRadius.only(
//                     //         bottomRight: Radius.circular(25),
//                     //         bottomLeft: Radius.circular(25)),
//                     //   ),
//                     //   child: TabBar(
//                     //     unselectedLabelColor: greyColor,
//                     //     labelColor: purpleColor,
//                     //     indicatorColor: Colors.transparent,
//                     //     tabs: const [
//                     //       Tab(
//                     //         icon: Icon(
//                     //           Icons.apps_rounded,
//                     //         ),
//                     //       ),
//                     //       Tab(
//                     //         icon: Icon(
//                     //           Icons.person_pin_rounded,
//                     //         ),
//                     //       )
//                     //     ],
//                     //     controller: _tabController,
//                     //     indicatorSize: TabBarIndicatorSize.tab,
//                     //   ),
//                     // ),
//                     Flexible(
//                       fit: FlexFit.loose,
//                       child: ProfilePosts(postDataList: postDataList, isOtherUser: true),
//                     ),
//                   ],
//                 ),
//               ),
//               onRefresh: () => _onRefreshHandler(context),
//             ): Center(
//               child: Text(
//               "No Data Available",
//                 style: whiteColor20BoldTextStyle,
//               ),
//             );
//           }
//         ),
//       ),
//     );
//   }

//   buildFollowers() {
//     return GestureDetector(
//       onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => FollowFollowing(
//                     initIndex: 0,
//                     followingUsers: profileData?.success?.followingUsers,
//                     followersUsers: profileData?.success?.followersUsers,
//                     refreshPage: () {
//                       refreshData();
//                     },
//                     isOtherUser: true
//                   ))),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 15),
//         decoration: BoxDecoration(
//             color: Colors.transparent,
//             border: Border(right: BorderSide(color: greyColor))),
//         child: RichText(
//           textAlign: TextAlign.center,
//           text: TextSpan(
//               text: "Followers\n",
//               style: whiteColor16TextStyle,
//               children: [
//                 TextSpan(
//                     text: "${profileData?.success?.followers ?? 0}",
//                     style: whiteColor16BoldTextStyle)
//               ]),
//         ),
//       ),
//     );
//   }

//   buildFollowing() {
//     return GestureDetector(
//       onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => FollowFollowing(
//                     initIndex: 1,
//                     followersUsers: profileData?.success?.followersUsers,
//                     followingUsers: profileData?.success?.followingUsers,
//                     refreshPage: () {
//                       refreshData();
//                     },
//                   isOtherUser: true
//               ))),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         decoration: BoxDecoration(
//             color: Colors.transparent,
//             border: Border(right: BorderSide(color: greyColor))),
//         child: RichText(
//           textAlign: TextAlign.center,
//           text: TextSpan(
//               text: "Following\n",
//               style: whiteColor16TextStyle,
//               children: [
//                 TextSpan(
//                     text: "${profileData?.success?.following ?? 0}",
//                     style: whiteColor16BoldTextStyle)
//               ]),
//         ),
//       ),
//     );
//   }

//   buildReportDialog(){
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.grey,
//       isDismissible: true,
//       shape: const RoundedRectangleBorder(
//           borderRadius:
//           BorderRadius.vertical(top: Radius.circular(16))),
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.4,
//         minChildSize: 0.2,
//         maxChildSize: 0.75,
//         expand: false,
//         builder: (_, controller) => Column(
//           children: [
//             Icon(
//               Icons.remove,
//               color: Colors.grey[600],
//             ),
//             const Text("Report", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
//             const SizedBox(height: 20,),
//             Row(
//               children: const [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 8.0),
//                   child: Text("Select a problem to report", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, ), textAlign: TextAlign.start),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 8.0),
//               child: const Text("You can report this user to Octagon if you think it goes against our Community Guidelines. We won't notify the account that you submitted this report.", style: TextStyle(fontSize: 16, color: Colors.white),),
//             ),
//             const SizedBox(height: 20,),
//             Expanded(
//               child: ListView.builder(
//                 controller: controller,
//                 itemCount: reportOptions.length,
//                 itemBuilder: (_, index) {
//                   return GestureDetector(
//                     onTap: (){
//                       isReport = true;
//                       postBloc.add(BlockUnBlockEvent(userId: "${profileData?.success?.user?.id??""}", isBlock: isBlocked));
//                       Navigator.pop(context);
//                     },
//                     child: Card(
//                       color: Colors.grey,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8),
//                         child: Text(reportOptions[index], style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   buildPost() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       decoration:
//           BoxDecoration(border: Border(right: BorderSide(color: greyColor))),
//       child: RichText(
//         textAlign: TextAlign.center,
//         text: TextSpan(text: "Post\n", style: whiteColor16TextStyle, children: [
//           TextSpan(
//               text: "${profileData?.success?.postCount ?? 0}",
//               style: whiteColor16BoldTextStyle)
//         ]),
//       ),
//     );
//   }

//   Future<void> _onRefreshHandler(BuildContext context) async {
//     postBloc.add(GetUserProfileEvent());
//     // homeFeedDataBloc.getHomeFeed(pageNo: currentPageNo, isProfile: true);
//   }

//   buildProfileView({required String userPic, required String teamLogo}) {
//     return GestureDetector(
//       onTap: () {},
//       child: Stack(
//         children: [
//           Container(
//             width: 90,
//             height: 130,
//             decoration: BoxDecoration(
//                 color: greyColor,
//                 borderRadius: BorderRadius.all(Radius.circular(20)),
//                 image: DecorationImage(
//                     image: NetworkImage(userPic!), fit: BoxFit.cover)),
//           ),
//           //Expanded(child: Container()),

//           Positioned(
//             top: 90,
//             left: 12,
//             child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: OctagonShape(
//                   child: (profileData!=null &&
//                       profileData!.success!=null &&
//                       profileData?.success?.sportInfo != null &&
//                       profileData!.success!.sportInfo!.isNotEmpty &&
//                       profileData!.success!.sportInfo!.first.team!.isNotEmpty
//                       && profileData!.success!.sportInfo!.first.team?.first !=null &&
//                       profileData!.success!.sportInfo!.first.team!.first.strTeam!.isNotEmpty ??false)?
//                   CachedNetworkImage(
//                     imageUrl: profileData!.success!.sportInfo!.first.team?.first.strTeamLogo??"",
//                     fit: BoxFit.cover,
//                     alignment: Alignment.center,
//                     width: 100,
//                     height: 100,
//                     placeholder: (context, url) => const SizedBox(height: 20),
//                     errorWidget: (context, url, error) => const Icon(Icons.error),
//                   ):null,
//                 )
//             ),
//           ),
//           /* Visibility(
//            visible: isVisible!,
//            child: Padding(
//              padding: const EdgeInsets.all(3.5),
//              child: Facebook_Fav(),
//            ),
//          )*/
//         ],
//       ),
//     );
//   }

//   void refreshData() {
//     postBloc.add(GetPostEvent(pageNo: currentPageNo,isProfile: true,userId: widget.userId!));
//     //profileBloc.getOtherUserDetails(userId: widget.userId);
//     postBloc.add(GetOtherProfileEvent(userId: widget.userId.toString(), ));
//   }

//   bool isDataAvailable(){
//     return profileData!=null;
//   }
// }

class OtherUserProfileScreen extends StatelessWidget {
  final int userId;

  OtherUserProfileScreen({Key? key, required this.userId}) : super(key: key);

  final List<String> reportOptions = [
    "Nudity or sexual activity",
    "Hate speech",
    "Scam",
    "Violence",
    "Illegal goods",
    "Harassment",
    "Impersonation",
    "IP Violation",
    "Self-injury",
    "Spam",
    "Other"
  ];

  @override
  Widget build(BuildContext context) {
    // Use Get.put with a unique tag to avoid conflicts

    final controller = Get.put(OtherUserProfileController(userId), tag: 'other_user_$userId');

    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: appBgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
              "${controller.profileData.value?.success?.user?.name ?? "Loading..."}'s profile",
              style: whiteColor20BoldTextStyle,
            )),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == 'Block') {
                controller.blockUnblockUser(controller.isBlocked.value);
              } else if (value == 'Report') {
                _showReportDialog(context, controller);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Block', child: Text(controller.isBlocked.value ? 'Unblock' : 'Block')),
              PopupMenuItem(value: 'Report', child: Text('Report')),
            ],
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading profile...", style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        }

        final profile = controller.profileData.value?.success;

        if (profile == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("No profile found", style: TextStyle(color: Colors.white)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    controller.fetchUserProfile();
                    controller.fetchPosts();
                  },
                  child: Text("Retry"),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchUserProfile();
            await controller.fetchPosts();
          },
          child: ListView(
            children: [_buildHeader(profile, controller), _buildStats(controller), _buildPosts(controller)],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(user, OtherUserProfileController controller) {
    return Column(
      children: [
        SizedBox(height: 20),
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(user.user.photo ?? ""),
        ),
        const SizedBox(height: 10),
        Text(user.user.name ?? "", style: whiteColor20BoldTextStyle),
        if (user.user.bio != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(user.user.bio!, style: greyColor16TextStyle, textAlign: TextAlign.center),
          ),
        SizedBox(
          height: 10,
        ),

        // ignore: unrelated_type_equality_checks
        userId != storage.read("current_uid")
            ? GestureDetector(
                onTap: () {
                  controller.followUserFromProfile(
                    user.user.id.toString(),
                    !user.follow_status,
                  );
                },
                child: Container(
                  width: 150,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: purpleColor,
                  ),
                  child: Center(
                    child: Text(user.follow_status == false ? "Follow" : "Following", style: whiteColor14BoldTextStyle, textAlign: TextAlign.center),
                  ),
                ),
              )
            : SizedBox.shrink(),

        SizedBox(
          height: 10,
        )
      ],
    );
  }

  Widget _buildStats(OtherUserProfileController controller) {
    final profile = controller.profileData.value?.success;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("Posts", profile?.postCount ?? 0),
        GestureDetector(
            onTap: () => Get.toNamed('/follow-following', arguments: {
                  'followers': profile?.followersUsers ?? [],
                  'following': profile?.followingUsers ?? [],
                  'initIndex': 0,
                  'isOtherUser': true
                }),
            child: _buildStatItem("Followers", profile?.followers ?? 0)),
        GestureDetector(
            onTap: () => Get.toNamed('/follow-following', arguments: {
                  'followers': profile?.followersUsers ?? [],
                  'following': profile?.followingUsers ?? [],
                  'initIndex': 1,
                  'isOtherUser': true
                }),
            child: _buildStatItem("Following", profile?.following ?? 0)),
      ],
    );
  }

  Widget _buildStatItem(String title, int count) {
    return Column(
      children: [
        Text(title, style: whiteColor14TextStyle),
        Text(count.toString(), style: whiteColor16BoldTextStyle),
      ],
    );
  }

  Widget _buildPosts(OtherUserProfileController controller) {
    return Obx(() {
      // Filter posts to only show those with images or videos (exclude text-only posts)
      final mediaPosts = controller.postList.where((post) {
        final hasImages = post.images != null && post.images!.isNotEmpty;
        final hasVideos = post.videos != null && post.videos!.isNotEmpty;
        return hasImages || hasVideos;
      }).toList();

      if (mediaPosts.isEmpty) {
        return const Center(
            child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("No media posts yet.", style: TextStyle(color: Colors.white)),
        ));
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        itemCount: mediaPosts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
        itemBuilder: (context, index) {
          final post = mediaPosts[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenPost(
                    postData: post,
                    updateData: () {},
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Stack(
                children: [
                  // Show image if available, otherwise show video thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: post.images != null && post.images!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: post.images!.first.filePath ?? "",
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (ctx, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (ctx, url, err) => const Icon(Icons.error),
                          )
                        : post.videos != null && post.videos!.isNotEmpty
                            ? buildVideoView(post)
                            : Container(
                                color: Colors.grey[800],
                                child: const Icon(Icons.error, color: Colors.white),
                              ),
                  ),
                  // Show video indicator if it's a video post
                  if (post.videos != null && post.videos!.isNotEmpty && (post.images == null || post.images!.isEmpty))
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showReportDialog(BuildContext context, OtherUserProfileController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: reportOptions
              .map((opt) => ListTile(
                    title: Text(opt, style: TextStyle(color: Colors.white)),
                    onTap: () {
                      controller.isReported.value = true;
                      controller.blockUnblockUser(true);
                      Get.back();
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  buildVideoView(PostResponseModelData e) {
    return FutureBuilder(
        future: getImagePath(e.videos?.first.filePath ?? ""),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.file(
              File("${snapshot.data!}"),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
          } else {
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            );
          }
        });
  }
}
