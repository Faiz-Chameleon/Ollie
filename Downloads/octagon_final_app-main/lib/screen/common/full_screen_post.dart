import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/screen/common/FullScreenPostController.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:video_player/video_player.dart';

import '../../main.dart';
import '../../utils/analiytics.dart';
import '../../utils/constants.dart';
import '../../utils/string.dart';
import '../mainFeed/bloc/post_bloc.dart';
import '../mainFeed/bloc/post_event.dart';
import '../mainFeed/bloc/post_state.dart';
import 'content_screen.dart';

// class FullScreenPost extends StatefulWidget {
//   String? postId;

//   PostResponseModelData? postData;
//   Function? updateData;
//   Duration? videoDuration;
//   bool isFromChat = false;
//   VideoPlayerController? videoPlayerController;

//   FullScreenPost({this.postData, this.postId, this.videoDuration, this.updateData, this.isFromChat = false, this.videoPlayerController});

//   @override
//   State<FullScreenPost> createState() => _FullScreenPostState();
// }

// class _FullScreenPostState extends State<FullScreenPost> {

// var userId;

// PostBloc postBloc = PostBloc();

// @override
// void initState() {
//   super.initState();
//   postBloc = PostBloc();

//   userId = storage.read("current_uid");

//   if(widget.postId!=null){
//     getPostDetails();
//   }

//   publishAmplitudeEvent(eventType: 'Full Post $kScreenView');
// }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: appBgColor,
//     body: BlocConsumer(
//         bloc: postBloc,
//         listener: (context,state){
//           if(state is PostLoadingBeginState){
//             onLoading(context);
//           }
//           if(state is PostErrorState){
//             stopLoader(context);
//           }
//           if(state is GetPostDetailsState){
//             stopLoader(context);
//             setState(() {
//               widget.postData = state.postResponseModel.successForCreatePost!;
//             });

// if(postData!=null && postData!.comments!=null){
//   for(int index = 0; index < postData!.comments!.length; index++){
//     usersList.add(postData!.comments![index].users!);
//     int id = postData!.comments![index].id!;
//     if(postData!.comments![index].comments!=null){
//       List<SuccessComment> comments = [];
//       for (var value in postData!.comments![index].comments!) {
//
//         // value.parentCommentId = 0;
//         // value.id = id;
//         // if(comments.indexWhere((element) => element.id == value.id) == -1){
//         //   comments.add(value);
//         // }
//         usersList.add(value.users!);
//         if(value.comments!=null){
//           for (var data in value.comments!) {
//
//             data.parentCommentId = 0;
//             data.id = id;
//             if(comments.indexWhere((element) => element.id == data.id) == -1){
//               comments.add(data);
//             }
//             usersList.add(data.users!);
//
//             if(data.comments!=null){
//               for (var dataA in data.comments!) {
//
//                 dataA.parentCommentId = 0;
//                 dataA.id = id;
//                 if(comments.indexWhere((element) => element.id == dataA.id) == -1){
//                   comments.add(dataA);
//                 }
//                 usersList.add(dataA.users!);
//               }
//             }
//           }
//         }
//       }
//       postData!.comments![index].comments!.addAll(comments);
//     }
//   }
// }

///remove comments > comments > comments.
// if(postData!=null && postData!.comments!=null){
//   for(int index = 0; index < postData!.comments!.length; index++){
//     if(postData!.comments![index].comments!=null){
//       for(int indexx = 0; indexx < postData!.comments![index].comments!.length; indexx++){
//         if(postData!.comments![index].comments!=null && postData!.comments![index].comments![indexx].comments!=null){
//           for(int indexxx = 0; indexxx < postData!.comments![index].comments![indexx].comments!.length; indexxx++){
//             postData!.comments![index].comments![indexx].comments!.clear();
//           }
//         }
//       }
//     }
//   }
// }
// }
// if(state is AddCommentState){
//   stopLoader(context);
//   getPostDetails();
// }
// if(state is DeleteCommentState){
//   stopLoader(context);
//   getPostDetails();
// }
// },
// builder: (context,_) {
// return Container(
//   child: Stack(
//     children: [
//       widget.postData!=null?
//       //We need swiper for every content
//       Swiper(
//         itemBuilder: (BuildContext context, int index) {
//           return ContentScreen(
//             postData: widget.postData,
//             videoDuration: widget.videoDuration,
//             userId: userId,
//             isFromChat: widget.isFromChat,
//             videoPlayerController: widget.videoPlayerController,
//             updateData: (){
//               widget.updateData!.call();
//             },
//           );
//         },
//         itemCount: 1,
//         loop: false,
//         scrollDirection: Axis.vertical,
//       ) : Container(),
// Padding(
//   padding: const EdgeInsets.all(0.0),
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: const [
//       Text(
//         'Flutter Shorts',
//         style: TextStyle(
//           fontSize: 22,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       Icon(Icons.camera_alt),
//     ],
//   ),
// ),
//             ],
//           ),
//         );
//       }
//     ),
//   );
// }

//   void getPostDetails() {
//     //postBloc.getPostDetails(postId: widget.postData!.id!, postType: int.tryParse(widget.postData!.type!)??0);
//     postBloc.add(GetPostDetailsEvent(
//         postId: widget.postId.toString(),
//         type: widget.postData?.type ?? "1"
//     ));
//   }
// }

class FullScreenPost extends StatelessWidget {
  final String? postId;
  final PostResponseModelData? postData;
  final Function? updateData;
  final Duration? videoDuration;
  final bool isFromChat;
  final VideoPlayerController? videoPlayerController;

  FullScreenPost({
    this.postId,
    this.postData,
    this.updateData,
    this.videoDuration,
    this.isFromChat = false,
    this.videoPlayerController,
  });

  final FullScreenPostController controller = Get.put(FullScreenPostController());

  @override
  Widget build(BuildContext context) {
    final userId = storage.read("current_uid");

    if (postId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchPostDetails(postId!, postData?.type ?? "1");
      });
    } else {
      controller.postData.value = postData;
    }

    return Scaffold(
      backgroundColor: appBgColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.postData.value == null) {
          return const Center(child: Text("Post not found", style: TextStyle(color: Colors.white)));
        }

        return Stack(
          children: [
            Swiper(
              itemCount: 1,
              loop: false,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) => ContentScreen(
                postData: controller.postData.value,
                userId: userId,
                videoDuration: videoDuration,
                videoPlayerController: videoPlayerController,
                isFromChat: isFromChat,
                updateData: () => updateData?.call(),
              ),
            ),
          ],
        );
      }),
    );
  }
}
