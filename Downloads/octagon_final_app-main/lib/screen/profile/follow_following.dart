import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:octagon/screen/mainFeed/bloc/post_bloc.dart';
import 'package:octagon/screen/mainFeed/bloc/post_event.dart';
import 'package:octagon/screen/mainFeed/bloc/post_state.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/octagon_common.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/widgets/follow_button_widget.dart';

import '../../networking/model/user_response_model.dart';
import '../../networking/response.dart';
import '../../utils/analiytics.dart';
import '../../utils/string.dart';
import 'other_user_profile.dart';

// class FollowFollowing extends StatefulWidget {
//   final int? initIndex;
//   List<UserModel>? followersUsers;
//   List<UserModel>? followingUsers;
//   Function? refreshPage;
//   bool isOtherUser = false;

//   FollowFollowing({Key? key, this.initIndex, this.followersUsers, this.refreshPage,
//   this.followingUsers, this.isOtherUser = false}) : super(key: key);

//   @override
//   _FollowFollowingState createState() => _FollowFollowingState();
// }

// class _FollowFollowingState extends State<FollowFollowing>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//    PostBloc postBloc = PostBloc();

//   @override
//   void initState() {
//     _tabController = TabController(
//         length: 2, vsync: this, initialIndex: widget.initIndex ?? 0);

//     postBloc = PostBloc();

//     _tabController.addListener(() {
//       setState(() {

//       });
//     });

//     publishAmplitudeEvent(eventType: 'Follow Following $kScreenView');
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: appBgColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: InkWell(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: const Icon(
//             Icons.arrow_back_ios,
//             color: Colors.white,
//           ),
//         ),
//         title: TabBar(
//           dividerColor: Colors.transparent,
//           automaticIndicatorColorAdjustment: false,
//           controller: _tabController,
//           onTap: (int value){
//             setState(() {
//               _tabController.index = value;
//             });
//           },
//           indicatorColor: Colors.white,
//           overlayColor: MaterialStateProperty.all(Colors.transparent),
//           tabs: [
//             Tab(
//               child: FollowButton(
//                 text: "Followers",
//                 backgroundColor:
//                     _tabController.index == 0 ? purpleColor : darkGreyColor,
//                 textStyle: _tabController.index == 0
//                     ? whiteColor16BoldTextStyle
//                     : greyColor16TextStyle,
//               ),
//             ),
//             Tab(
//               child: FollowButton(
//                 text: "Following",
//                 backgroundColor:
//                     _tabController.index == 0 ? darkGreyColor : purpleColor,
//                 textStyle: _tabController.index == 0
//                     ? greyColor16TextStyle
//                     : whiteColor16BoldTextStyle,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: BlocConsumer(
//         bloc: postBloc,
//         listener: (context,state){
//           if(state is PostLoadingBeginState){
//             onLoading(context);
//           }
//           if(state is PostErrorState){
//             stopLoader(context);
//           }
//           if(state is FollowUserState){
//             stopLoader(context);
//             widget.refreshPage!.call();
//           }
//           if(state is RemoveFollowUserState){
//             stopLoader(context);
//             widget.refreshPage!.call();
//           }

//         },
//         builder: (context,_) {
//           return TabBarView(
//             controller: _tabController,
//             children: [
//               ///Followers
//               buildFollowers(widget.followersUsers, widget.followingUsers, (UserModel onFollow) {
//                 ///call follow api
//                 postBloc.add(FollowUserEvent(
//                   follow: "1",
//                   followId: onFollow.id.toString()
//                 ));
//                 setState(() {
//                   widget.followingUsers!.add(onFollow);
//                 });
//               },(UserModel onRemove) {
//                 ///call remove follower api
//                 //postBloc.removeFollowerUser(userId: onRemove.id!);
//                 postBloc.add(RemoveFollowUserEvent(followingId: onRemove.id.toString()));

//                 setState(() {
//                   widget.followersUsers!.removeWhere((element) => element.id == onRemove.id);
//                 });
//               }),

//               ///Following
//               buildFollowing(widget.followingUsers, (UserModel onUnfollow) {
//                 ///call unfollow api
//                 postBloc.add(FollowUserEvent(
//                     follow: "0",
//                     followId: onUnfollow.id.toString()
//                 ));
//                 setState(() {
//                   widget.followingUsers!.removeWhere((element) => element.id == onUnfollow.id);
//                 });
//               })
//             ],
//           );
//         }
//       ),
//     );
//   }

//   buildFollowers(List<UserModel>? usersData, List<UserModel>? followerData, Function onUnFollow,
//       Function onRemove) {
//     if(usersData==null || usersData.isEmpty){
//       return buildNoDataWidget();
//     }

//     return ListView.builder(
//       // physics: NeverScrollableScrollPhysics(),
//         itemCount: usersData.length ?? 0,
//         itemBuilder: (context, index) {
//           return ListTile(
//             onTap: (){
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           OtherUserProfileScreen(
//                               userId: usersData[index].id)));
//             },
//             contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//             leading: OctagonShape(
//               width: 50,
//               height: 50,
//               child: usersData[index].photo == null ? null :
//               CachedNetworkImage(
//                 imageUrl: usersData[index].photo??"https://randomuser.me/api/portraits/women/0.jpg",
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => const SizedBox(height: 20, child: Center(child: CircularProgressIndicator())),
//                 errorWidget: (context, url, error) => const Icon(Icons.error),
//               ),
//             ),
//             title: Text(
//               (usersData[index].name??"").capitalize!,
//               style: whiteColor16BoldTextStyle,
//             ),
//             subtitle: Text(
//               usersData[index].bio??"",
//               style: greyColor16TextStyle,
//             ),
//             trailing: !widget.isOtherUser ? Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if(followerData?.indexWhere((element) => element.id == usersData[index].id) == -1)
//                 FollowButton(
//                   text: "Follow",
//                     onClick: (){
//                       onUnFollow.call(usersData[index]);
//                     }
//                 ),
//                 FollowButton(
//                   text: "Remove",
//                   backgroundColor: darkGreyColor,
//                   textStyle: greyColor14TextStyle,
//                     onClick: (){
//                       onRemove.call(usersData[index]);
//                     }
//                 )
//               ],
//             ): null,
//           );
//         });
//   }

//   buildFollowing(List<UserModel>? usersData, Function onUnFollow) {
//     if(usersData==null || usersData.isEmpty){
//       return buildNoDataWidget();
//     }
//     return ListView.builder(
//         itemCount: usersData.length ?? 0,
//         shrinkWrap: true,
//         itemBuilder: (context, index) {
//           return ListTile(
//             onTap: (){
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           OtherUserProfileScreen(
//                               userId: usersData[index].id)));
//             },
//             contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//             leading: OctagonShape(
//               width: 50,
//               height: 50,
//               child: usersData[index].photo == null ? null :
//               CachedNetworkImage(
//                 imageUrl: usersData[index].photo??"https://randomuser.me/api/portraits/women/0.jpg",
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => const SizedBox(height: 10,),
//                 errorWidget: (context, url, error) => const Icon(Icons.error),
//               ),
//             ),
//             title: Text(
//               (usersData[index].name??"").capitalize!,
//               style: whiteColor16BoldTextStyle,
//             ),
//             subtitle: Text(
//               usersData[index].bio??"",
//               style: greyColor16TextStyle,
//             ),
//             trailing:!widget.isOtherUser ? SizedBox(
//               width: 100,
//               child: FollowButton(
//                 text: "Unfollow",
//                 backgroundColor: darkGreyColor,
//                 textStyle: greyColor14TextStyle,
//                 onClick: (){
//                   onUnFollow.call(usersData[index]);
//                 },
//               ),
//             ): null,
//           );
//         });
//   }

//   buildNoDataWidget() {
//     return const Center(
//       child: Text("No data found!", style: TextStyle(color: Colors.white)),
//     );
//   }
// }
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octagon/networking/model/user_response_model.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/octagon_common.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/widgets/follow_button_widget.dart';
import 'package:octagon/utils/string.dart';

import 'other_user_profile.dart';
import 'follow_following_controller.dart';

class FollowFollowingScreen extends StatelessWidget {
  final List<UserModel>? followersUsers;
  final List<UserModel>? followingUsers;
  final int initialIndex;
  final bool isOtherUser;

  FollowFollowingScreen({
    Key? key,
    required this.followersUsers,
    required this.followingUsers,
    this.initialIndex = 0,
    this.isOtherUser = false,
  }) : super(key: key);

  final controller = Get.put(FollowFollowingController());

  @override
  Widget build(BuildContext context) {
    controller.setData(
      followersList: followersUsers ?? [],
      followingList: followingUsers ?? [],
    );
    controller.currentTab.value = initialIndex;

    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab("Followers", 0),
                const SizedBox(width: 10),
                _buildTab("Following", 1),
              ],
            )),
        centerTitle: true,
      ),
      body: Obx(() {
        return controller.currentTab.value == 0
            ? _buildList(
                controller.followers,
                showRemove: !isOtherUser,
                isFollowingTab: false,
              )
            : _buildList(
                controller.following,
                showRemove: !isOtherUser,
                isFollowingTab: true,
              );
      }),
    );
  }

  Widget _buildTab(String label, int index) {
    bool isActive = controller.currentTab.value == index;
    return GestureDetector(
      onTap: () => controller.switchTab(index),
      child: FollowButton(
        text: label,
        backgroundColor: isActive ? purpleColor : darkGreyColor,
        textStyle: isActive ? whiteColor16BoldTextStyle : greyColor16TextStyle,
      ),
    );
  }

  Widget _buildList(
    List<UserModel> users, {
    bool showRemove = false,
    bool isFollowingTab = false,
  }) {
    if (users.isEmpty) {
      return const Center(child: Text("No data found!", style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          onTap: () => Get.to(() => OtherUserProfileScreen(userId: user.id!)),
          contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          leading: OctagonShape(
            width: 50,
            height: 50,
            child: user.photo == null
                ? null
                : CachedNetworkImage(
                    imageUrl: user.photo!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const SizedBox(height: 20, child: CircularProgressIndicator()),
                    errorWidget: (_, __, ___) => const Icon(Icons.error),
                  ),
          ),
          title: Text(user.name?.capitalize ?? "", style: whiteColor16BoldTextStyle),
          subtitle: Text(user.bio ?? "", style: greyColor16TextStyle),
          trailing: showRemove
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isFollowingTab && !controller.following.any((e) => e.id == user.id))
                      FollowButton(
                        text: "Follow",
                        onClick: () => controller.followUser(user),
                      ),
                    const SizedBox(width: 8),
                    FollowButton(
                      text: isFollowingTab ? "Unfollow" : "Remove",
                      backgroundColor: darkGreyColor,
                      textStyle: greyColor14TextStyle,
                      onClick: () => isFollowingTab ? controller.unfollowUser(user) : controller.removeFollower(user),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
