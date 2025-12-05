import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:octagon/screen/mainFeed/home/postController.dart';
import 'package:octagon/utils/octagon_common.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/toast_utils.dart';
import 'package:octagon/widgets/follow_button_widget.dart';
import '../../networking/model/user_response_model.dart';
import '../../networking/response.dart';
import '../model/block_user.dart';
import '../screen/mainFeed/bloc/post_bloc.dart';
import '../screen/mainFeed/bloc/post_event.dart';
import '../screen/mainFeed/bloc/post_state.dart';
import '../utils/analiytics.dart';
import '../utils/string.dart';

// class BlockUserListScreen extends StatefulWidget {
//   final int? initIndex;
//   // List<UserModel>? followersUsers;
//   Function? refreshPage;
//   bool isOtherUser = false;

//   BlockUserListScreen({Key? key, this.initIndex, this.refreshPage, this.isOtherUser = false}) : super(key: key);

//   @override
//   _BlockUserListScreenState createState() => _BlockUserListScreenState();
// }

// class _BlockUserListScreenState extends State<BlockUserListScreen>
//     with SingleTickerProviderStateMixin {

//   List<BlockUserData> blockUserData = [];

//   @override
//   void initState() {

//     /*postBloc.followUserDataStream.listen((event) {
//       switch (event.status) {
//         case Status.LOADING:
//           break;
//         case Status.COMPLETED:
//           widget.refreshPage!.call();
//           break;
//         case Status.ERROR:
//           print(Status.ERROR);
//           break;
//         case null:
//           // TODO: Handle this case.
//       }
//     });

//     postBloc.blockUnblockUserDataStream.listen((event) {
//       switch (event.status) {
//         case Status.LOADING:
//           break;
//         case Status.COMPLETED:
//           setState(() {
//             refreshPage();
//           });
//           break;
//         case Status.ERROR:
//           print(Status.ERROR);
//           break;
//         case null:
//           // TODO: Handle this case.
//       }
//     });

//     postBloc.getBlockedUserListStream.listen((event) {
//       switch (event.status) {
//         case Status.LOADING:
//           break;
//         case Status.COMPLETED:
//           setState(() {
//             blockUserModel = event.data;
//             // isBlocked = !isBlocked;
//           });
//           break;
//         case Status.ERROR:
//           print(Status.ERROR);
//           break;
//         case null:
//           // TODO: Handle this case.
//       }
//     });*/

//     refreshPage();

//     publishAmplitudeEvent(eventType: 'Block User $kScreenView');
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: appBgColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text("Blocked Users", style: whiteColor20BoldTextStyle),
//         centerTitle: true,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(
//             Icons.arrow_back,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body:  BlocConsumer(
//           bloc: postBloc,
//           listener: (context, state) {
//             if(state is PostLoadingBeginState){
//               // onLoading(context);
//             }
//             if(state is PostLoadingEndState){
//               // stopLoader(context);
//             }

//             if (state is BlockedUserState) {
//               // if (isRefreshHome) {
//               //   blockUserData.clear();
//               //   // storiesDataList.clear();
//               // }

//               if (state.blockUserModel != null) {
//                 for (var element in state.blockUserModel.blockUserData) {
//                   // if(element.type == "1"){
//                   if (blockUserData
//                       .indexWhere((data) => data.id == element.id) ==
//                       -1) {
//                     blockUserData.add(element);
//                   } else {
//                     print("${element.name} user drop from listing!");
//                   }
//                   // }else if(element.type == "2"){
//                   // storiesDataList.add(element);
//                   // }
//                 }
//                 // isMorePageAvailable = state.postResponseModel.more ?? false;
//               }

//               // isRefreshHome = false;
//             }
//           },
//           builder: (context, _) {
//             return buildFollowers(blockUserData, (BlockUserData onRemove) {
//               ///call remove follower api
//               postBloc.add(BlockUnBlockEvent(
//                   userId: "${onRemove.id??""}", isBlock: false
//               ));

//               setState(() {
//                 blockUserData.removeWhere((element) => element.id == onRemove.id);
//               });
//             });
//           }),
//     );
//   }

//   buildFollowers(List<BlockUserData>? usersData, Function onRemove) {
//     if(usersData==null || usersData.isEmpty){
//       return buildNoDataWidget();
//     }

//     return ListView.builder(
//       // physics: NeverScrollableScrollPhysics(),
//         itemCount: usersData.length ?? 0,
//         itemBuilder: (context, index) {
//           return ListTile(
//             onTap: (){
//               showToast(message: "You can not see this profile, if you want then you have to unblock it first!");
//               // Navigator.push(
//               //     context,
//               //     MaterialPageRoute(
//               //         builder: (context) =>
//               //             OtherUserProfileScreen(
//               //                 userId: usersData[index].id)));
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
//               usersData[index].name??"",
//               style: whiteColor16BoldTextStyle,
//             ),
//             subtitle: Text(
//               usersData[index].name??"",
//               style: greyColor16TextStyle,
//             ),
//             trailing: !widget.isOtherUser ? Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // if(followerData?.indexWhere((element) => element.id == usersData[index].id) == -1)
//                 //   FollowButton(
//                 //       text: "Follow",
//                 //       onClick: (){
//                 //         onUnFollow.call(usersData[index]);
//                 //       }
//                 //   ),
//                 FollowButton(
//                     text: "UnBlock",
//                     backgroundColor: darkGreyColor,
//                     textStyle: greyColor14TextStyle,
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
//               /*Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           OtherUserProfileScreen(
//                               userId: usersData[index].id)));*/
//             },
//             contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//             leading: OctagonShape(
//               width: 50,
//               height: 50,
//               child: usersData[index].photo == null ? null :
//               CachedNetworkImage(
//                 imageUrl: /*usersData[index].photo??*/"https://randomuser.me/api/portraits/women/0.jpg",
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => const SizedBox(height: 10,),
//                 errorWidget: (context, url, error) => const Icon(Icons.error),
//               ),
//             ),
//             title: Text(
//               usersData[index].name??"",
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

//   void refreshPage() {
//     postBloc.add(GetBlockUserEvent());
//     // postBloc.getBlockUserList();
//   }
// }

class BlockUserListScreen extends StatefulWidget {
  final Function? refreshPage;
  final bool isOtherUser;

  const BlockUserListScreen({Key? key, this.refreshPage, this.isOtherUser = false}) : super(key: key);

  @override
  State<BlockUserListScreen> createState() => _BlockUserListScreenState();
}

class _BlockUserListScreenState extends State<BlockUserListScreen> {
  final PostController _postController = Get.find<PostController>();
  final RxList<BlockUserData> blockUserData = <BlockUserData>[].obs;

  @override
  void initState() {
    super.initState();
    fetchBlockedUsers();
  }

  Future<void> fetchBlockedUsers() async {
    await _postController.getBlockedUsers(1);
    // TODO: Replace below with actual data assignment when you populate `blockList` in controller
    // Example:
    // blockUserData.assignAll(_postController.blockList.cast<BlockUserData>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Blocked Users", style: whiteColor20BoldTextStyle),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Obx(() {
        if (blockUserData.isEmpty) {
          return const Center(child: Text("No data found!", style: TextStyle(color: Colors.white)));
        }

        return ListView.builder(
          itemCount: blockUserData.length,
          itemBuilder: (context, index) {
            final user = blockUserData[index];

            return ListTile(
              onTap: () => showToast(message: "You can not see this profile, unblock to view it."),
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              leading: OctagonShape(
                width: 50,
                height: 50,
                child: CachedNetworkImage(
                  imageUrl: user.photo ?? "https://randomuser.me/api/portraits/women/0.jpg",
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox(height: 20, child: Center(child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              title: Text(user.name ?? "", style: whiteColor16BoldTextStyle),
              subtitle: Text(user.name ?? "", style: greyColor16TextStyle),
              trailing: !widget.isOtherUser
                  ? FollowButton(
                      text: "UnBlock",
                      backgroundColor: darkGreyColor,
                      textStyle: greyColor14TextStyle,
                      onClick: () async {
                        await _postController.blockUnblockUser("${user.id}", false);
                        blockUserData.removeAt(index);
                        widget.refreshPage?.call();
                      },
                    )
                  : null,
            );
          },
        );
      }),
    );
  }
}
