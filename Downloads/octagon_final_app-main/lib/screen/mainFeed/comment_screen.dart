import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/screen/mainFeed/bloc/post_bloc.dart';
import 'package:octagon/screen/mainFeed/bloc/post_event.dart';
import 'package:octagon/screen/mainFeed/bloc/post_state.dart';
import 'package:octagon/screen/mainFeed/comment/comment_controller.dart';
import 'package:octagon/screen/mainFeed/comment_box.dart';
import 'package:octagon/utils/chat_room.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
// import 'package:hexagon/hexagon.dart';

import '../../main.dart';
import '../../model/user_data_model.dart';

import '../../networking/response.dart';

import '../../utils/octagon_common.dart';
import '../../utils/polygon/polygon_border.dart';
import '../profile/other_user_profile.dart';

// class CommentScreen extends StatefulWidget {

//   final String? captionTxt;
//   final String? name;final String? profilePic;
//   PostResponseModelData? postData;

//   CommentScreen({Key? key,this.captionTxt,
//     this.name, this.profilePic, this.postData}) : super(key: key);

//   @override
//   _CommentScreenState createState() => _CommentScreenState();
// }

// class _CommentScreenState extends State<CommentScreen> {

//   bool isLiked = false;
//   late final _commentTextController = TextEditingController();

//   TextEditingController messageController  = TextEditingController();

//   PostBloc postBloc = PostBloc();
//   PostResponseModelData? postData;

//   List<Users> usersList = [];

//   var myId;

//   @override
//   void initState() {
//     super.initState();

//     myId = storage.read("current_uid");

//     postBloc = PostBloc();

// /*    postBloc.postDataStream.listen((event) {
//       switch (event.status) {
//         case Status.LOADING:
//           break;
//         case Status.COMPLETED:
//           setState(() {
//             postData = event.data!.successForCreatePost!;
//           });

//           if(postData!=null && postData!.comments!=null){
//             for(int index = 0; index < postData!.comments!.length; index++){
//               usersList.add(postData!.comments![index].users!);
//               int id = postData!.comments![index].id!;
//               if(postData!.comments![index].comments!=null){
//                 List<SuccessComment> comments = [];
//                 for (var value in postData!.comments![index].comments!) {

//                   // value.parentCommentId = 0;
//                   // value.id = id;
//                   // if(comments.indexWhere((element) => element.id == value.id) == -1){
//                   //   comments.add(value);
//                   // }
//                   usersList.add(value.users!);
//                   if(value.comments!=null){
//                     for (var data in value.comments!) {

//                       data.parentCommentId = 0;
//                       data.id = id;
//                       if(comments.indexWhere((element) => element.id == data.id) == -1){
//                         comments.add(data);
//                       }
//                       usersList.add(data.users!);

//                       if(data.comments!=null){
//                         for (var dataA in data.comments!) {

//                           dataA.parentCommentId = 0;
//                           dataA.id = id;
//                           if(comments.indexWhere((element) => element.id == dataA.id) == -1){
//                             comments.add(dataA);
//                           }
//                           usersList.add(dataA.users!);
//                         }
//                       }
//                     }
//                   }
//                 }
//                 postData!.comments![index].comments!.addAll(comments);
//               }
//             }
//           }

//           ///remove comments > comments > comments.
//           if(postData!=null && postData!.comments!=null){
//             for(int index = 0; index < postData!.comments!.length; index++){
//               if(postData!.comments![index].comments!=null){
//                 for(int indexx = 0; indexx < postData!.comments![index].comments!.length; indexx++){
//                   if(postData!.comments![index].comments!=null && postData!.comments![index].comments![indexx].comments!=null){
//                     for(int indexxx = 0; indexxx < postData!.comments![index].comments![indexx].comments!.length; indexxx++){
//                       postData!.comments![index].comments![indexx].comments!.clear();
//                     }
//                   }
//                 }
//               }
//             }
//           }

//           print(event.data);
//           break;
//         case Status.ERROR:
//           print(Status.ERROR);
//           break;
//         case null:
//           // TODO: Handle this case.
//       }
//     });
//     postBloc.addCommentDataStream.listen((event) {
//       switch (event.status) {
//         case Status.LOADING:
//           break;
//         case Status.COMPLETED:
//           getPostDetails();
//           print(event.data);
//           break;
//         case Status.ERROR:
//           print(Status.ERROR);
//           break;
//         case null:
//           // TODO: Handle this case.
//       }
//     });

//     postBloc.deleteUserCommentDataStream.listen((event) {
//       switch (event.status) {
//         case Status.LOADING:
//           break;
//         case Status.COMPLETED:
//           getPostDetails();
//           print(event.data);
//           break;
//         case Status.ERROR:
//           print(Status.ERROR);
//           break;
//         case null:
//           // TODO: Handle this case.
//       }
//     });*/

//     getPostDetails();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor:widget.captionTxt != null ?  darkGreyColor:appBgColor,
//         appBar: AppBar(
//           backgroundColor: widget.captionTxt != null ?  darkGreyColor:appBgColor,
//           elevation: 0.0,
//           title: Text("Comment", style: whiteColor20BoldTextStyle,),
//           centerTitle: true,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back_ios_outlined, color: whiteColor,size: 25,), onPressed: () {
//               Navigator.maybePop(context);
//           },
//           ),
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
//             if(state is GetPostDetailsState){
//               stopLoader(context);
//               setState(() {
//                 postData = state.postResponseModel.successForCreatePost!;
//               });

//               if(postData!=null && postData!.comments!=null){
//                 for(int index = 0; index < postData!.comments!.length; index++){
//                   usersList.add(postData!.comments![index].users!);
//                   int id = postData!.comments![index].id!;
//                   if(postData!.comments![index].comments!=null){
//                     List<SuccessComment> comments = [];
//                     for (var value in postData!.comments![index].comments!) {

//                       // value.parentCommentId = 0;
//                       // value.id = id;
//                       // if(comments.indexWhere((element) => element.id == value.id) == -1){
//                       //   comments.add(value);
//                       // }
//                       usersList.add(value.users!);
//                       if(value.comments!=null){
//                         for (var data in value.comments!) {

//                           data.parentCommentId = 0;
//                           data.id = id;
//                           if(comments.indexWhere((element) => element.id == data.id) == -1){
//                             comments.add(data);
//                           }
//                           usersList.add(data.users!);

//                           if(data.comments!=null){
//                             for (var dataA in data.comments!) {

//                               dataA.parentCommentId = 0;
//                               dataA.id = id;
//                               if(comments.indexWhere((element) => element.id == dataA.id) == -1){
//                                 comments.add(dataA);
//                               }
//                               usersList.add(dataA.users!);
//                             }
//                           }
//                         }
//                       }
//                     }
//                     postData!.comments![index].comments!.addAll(comments);
//                   }
//                 }
//               }

//               ///remove comments > comments > comments.
//               if(postData!=null && postData!.comments!=null){
//                 for(int index = 0; index < postData!.comments!.length; index++){
//                   if(postData!.comments![index].comments!=null){
//                     for(int indexx = 0; indexx < postData!.comments![index].comments!.length; indexx++){
//                       if(postData!.comments![index].comments!=null && postData!.comments![index].comments![indexx].comments!=null){
//                         for(int indexxx = 0; indexxx < postData!.comments![index].comments![indexx].comments!.length; indexxx++){
//                           postData!.comments![index].comments![indexx].comments!.clear();
//                         }
//                       }
//                     }
//                   }
//                 }
//               }
//             }
//             if(state is AddCommentState){
//               stopLoader(context);
//               getPostDetails();
//             }
//             if(state is DeleteCommentState){
//               stopLoader(context);
//               getPostDetails();
//             }
//           },
//           builder: (context,_) {
//             return Stack(
//               children: [
//                 GestureDetector(
//                   onTapDown: (_){
//                     FocusScope.of(context).requestFocus(FocusNode());
//                   },
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         if(widget.captionTxt != null)
//                         Container(
//                          // margin: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
//                             color: darkGreyColor,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 10),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: RichText(
//                                     text:TextSpan(text: "${widget.name!} ".capitalize!,style: whiteColor14BoldTextStyle,children: [
//                                       TextSpan(text:widget.captionTxt!,style: whiteColor14TextStyle ),
//                                     ]),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),

//                         ),
//                         if(postData?.comments!=null)
//                        buildCommentList(postData!.comments!, isMainMessage: true)
//                       ],
//                     ),
//                   ),
//                 ),
//                 Align(alignment: Alignment.bottomCenter,child: CommentBox(
//                     textEditingController: _commentTextController, /*focusNode: focusNode,*/ onSubmitted: (String? value){
//                   if(_commentTextController.text.trim().isNotEmpty){
//                     addComment(
//                       comment: _commentTextController.text.trim(),);
//                     _commentTextController.clear();
//                   }else{
//                     Get.snackbar("Octagon", "Please write comment first!");
//                   }

//                 }))
//               ],
//             );
//           }
//         ),
//       ),
//     );
//   }

//   Widget buildMessageItem(SuccessComment comment, int index) {
//     return GestureDetector(
//       onDoubleTap: (){
//         showReplyDialog(comment);
//       },
//       child: Column(
//         children: [
//           ListTile(
//             contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 8),
//             leading: GestureDetector(
//               onTap: (){
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => OtherUserProfileScreen(userId: comment.users!.id)));
//               },
//               child: Container(
//                 height: 35,
//                 width: 35,
//                 decoration: ShapeDecoration(
//                   // color: amberColor,
//                   shape: PolygonBorder(
//                     sides: 8,
//                     rotate: 68,
//                     side: BorderSide(
//                       color: amberColor,
//                     ),
//                   ),
//                 ),
//                 alignment: Alignment.center,
//                 clipBehavior: Clip.antiAlias,
//                 child: OctagonShape(
//                   // bgColor: Colors.black,
//                   child: comment.users != null
//                       ?
//                   CachedNetworkImage(
//                     imageUrl: comment.users?.photo ?? "",
//                     fit: BoxFit.cover,
//                     alignment: Alignment.center,
//                     width: 28,
//                     height: 28,
//                     placeholder: (context, url) => const SizedBox(height: 20),
//                     errorWidget: (context, url, error) => const Icon(Icons.error),
//                   ):null,
//                 ),
//               ),/* OctagonShape(
//                 height: 35,
//                 width: 30,
//                 child: comment.users == null
//                     ? null
//                     : CachedNetworkImage(
//                   imageUrl: comment.users?.photo ?? "",
//                   fit: BoxFit.cover,
//                   alignment: Alignment.center,
//                   width: 80,
//                   height: 100,
//                   placeholder: (context, url) => const SizedBox(height: 20, child: Center(child: CircularProgressIndicator())),
//                   errorWidget: (context, url, error) => const Icon(Icons.error),
//                 ),
//               ),*/
//             ),
//             title: RichText(
//               text:TextSpan(text: "${comment.users?.name??""}\n".capitalize!,style: whiteColor14BoldTextStyle,children: [
//                 TextSpan(text: getUserName(comment.comment ?? "", usersList: usersList),
//                 style: TextStyle(fontSize: 15, color: Colors.blue.withOpacity(0.8))),
//                 TextSpan(
//                   text: "${isReplyMessage(comment.comment ?? "") ? getMessageContent(comment.comment ?? "") : comment.comment ?? ""} ",
//                   style: whiteColor16TextStyle,
//                 )
//               ]),
//             ),
//             trailing: comment.users!.id == myId ?IconButton(
//               padding: EdgeInsets.zero,
//               icon: Icon(
//                 Icons.delete,
//                 color: greyColor,
//                 size: 25,
//               ),
//               onPressed: () {
//                 postBloc.add(DeleteCommentEvent(commentId: comment.id!.toString()));
//               },
//             ): GestureDetector(
//               onTap: (){
//                 showReplyDialog(comment);
//               },
//                 child: const Text("Reply", style: TextStyle(color: Colors.white))),
//           ),
//           if(comment.comments!=null && comment.comments!.isNotEmpty)
//             InkWell(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: <Widget>[
//                   Text(
//                     !comment.isShowMore ? "show reply" : "show less",
//                     style: const TextStyle(color: Colors.blue),
//                   ),
//                 ],
//               ),
//               onTap: () {
//                 setState(() {
//                   comment.isShowMore = !comment.isShowMore;
//                 });
//               },
//             ),
//           if(comment.comments!=null && comment.isShowMore)
//            buildCommentList(comment.comments!)
//         ],
//       ),
//     );
//   }

//   buildCommentList(List<SuccessComment> comments, {bool isMainMessage = false}) {
//     return Container(
//       color: appBgColor,
//       padding: EdgeInsets.only(left: !isMainMessage?20:0),
//       child: ListView.builder(
//           itemCount: comments.length,
//           physics: const NeverScrollableScrollPhysics(),
//           shrinkWrap: true,
//           itemBuilder: (context,index){
//             return buildMessageItem(comments[index], index);
//           }),
//     );
//   }

//   Future<void> _displayTextInputDialog(BuildContext context, String msg) async {
//     return showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text(msg),
//             content: TextField(
//               textCapitalization: TextCapitalization.sentences,
//               controller: messageController,
//               keyboardType: TextInputType.text,
//               onSubmitted: (_){
//                 Navigator.pop(context);
//               },
//               decoration:
//               const InputDecoration(hintText: "add your message here.."),
//             ),
//             actions: <Widget>[
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     // _textFieldController.text = "";
//                     Navigator.pop(context);
//                   });
//                 },
//                 child: const Text('Cancel', style: TextStyle(color: Colors.black)),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     Navigator.pop(context);
//                   });
//                 },
//                 child: Container(
//                   // color: Colors.green,
//                   padding: const EdgeInsets.all(5),
//                   child: const Text('reply',style: TextStyle(color: Colors.black)),
//                 ),
//               ),
//             ],
//           );
//         });
//   }

//   void showReplyDialog(SuccessComment comment) {
//     _displayTextInputDialog(context, getMessageContent(comment.comment ?? "")).then((value) {
//       if(messageController.text.trim().isNotEmpty){
//         addComment(
//             comment: "@${comment.userId} ${messageController.text.trim()}" , parentCommentId: comment.id!.toString());
//         messageController.clear();
//       }else{
//         Get.snackbar("Octagon", "Please write comment first!");
//       }
//     });
//   }

//   void addComment({required String comment, String? parentCommentId}) {
//     /*postBloc.addComment(
//         postId:  widget.postData!.id!,
//         comment: comment,
//         parentCommentId: parentCommentId
//     );*/
//     postBloc.add(AddCommentEvent(
//       postId: widget.postData!.id!.toString(),
//       comment: comment,
//       parentId: parentCommentId
//     ));
//   }

//   void getPostDetails() {
//     //postBloc.getPostDetails(postId: widget.postData!.id!, postType: int.tryParse(widget.postData!.type!)??0);
//     postBloc.add(GetPostDetailsEvent(
//       postId: widget.postData!.id!.toString(),
//       type: widget.postData!.type ?? "0"
//     ));
//   }

// }

String getUserName(String s, {required List<Users> usersList}) {
  try {
    if (s.contains("@")) {
      String name = usersList
              .firstWhere((element) =>
                  element.id.toString() == s.substring(1, s.indexOf(" ")))
              .name ??
          "";

      return "@$name ";
    } else {
      return "";
    }
  } catch (e) {
    return "";
  }
}

class CommentScreen extends StatelessWidget {
  final String? captionTxt;
  final String? name;
  final String? profilePic;
  final PostResponseModelData? postData;

  final controller = Get.put(CommentController());

  CommentScreen(
      {super.key, this.captionTxt, this.name, this.profilePic, this.postData});

  @override
  Widget build(BuildContext context) {
    controller.loadPostDetails(postData!.id.toString(), postData!.type ?? "0");

    return SafeArea(
      child: Scaffold(
        backgroundColor: captionTxt != null ? darkGreyColor : appBgColor,
        appBar: AppBar(
          backgroundColor: captionTxt != null ? darkGreyColor : appBgColor,
          elevation: 0,
          title: Text("Comment", style: whiteColor20BoldTextStyle),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined, color: whiteColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final post = controller.postData.value;
          return Stack(
            children: [
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (captionTxt != null)
                        Container(
                          color: darkGreyColor,
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: "${name!} ".capitalize!,
                                    style: whiteColor14BoldTextStyle,
                                    children: [
                                      TextSpan(
                                          text: captionTxt!,
                                          style: whiteColor14TextStyle),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (post?.comments != null)
                        buildCommentList(post!.comments!, true),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: CommentBox(
                  textEditingController: controller.commentTextController.value,
                  onSubmitted: (val) {
                    controller.addComment(post!.id.toString(), val!);
                    controller.commentTextController.value.clear();
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget buildCommentList(List<SuccessComment> comments, bool isMain) {
    return Container(
      color: appBgColor,
      padding: EdgeInsets.only(left: isMain ? 0 : 20),
      child: ListView.builder(
        itemCount: comments.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, index) {
          return buildCommentItem(comments[index]);
        },
      ),
    );
  }

  Widget buildCommentItem(SuccessComment comment) {
    final controller = Get.find<CommentController>();

    return GestureDetector(
      onDoubleTap: () => showReplyDialog(comment),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: GestureDetector(
              onTap: () => Get.to(
                  () => OtherUserProfileScreen(userId: comment.users!.id!)),
              child: Container(
                height: 35,
                width: 35,
                decoration: ShapeDecoration(
                  shape: PolygonBorder(
                    sides: 8,
                    rotate: 68,
                    side: BorderSide(color: amberColor),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: comment.users?.photo ?? "",
                  fit: BoxFit.cover,
                  width: 28,
                  height: 28,
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    size: 28,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            title: RichText(
              text: TextSpan(
                text: "${comment.users?.name ?? ''}\n".capitalize!,
                style: whiteColor14BoldTextStyle,
                children: [
                  TextSpan(
                    text: getUserName(comment.comment ?? "",
                        usersList: controller.usersList),
                    style: TextStyle(
                        fontSize: 15, color: Colors.blue.withOpacity(0.8)),
                  ),
                  TextSpan(
                    text:
                        "${isReplyMessage(comment.comment ?? "") ? getMessageContent(comment.comment ?? "") : comment.comment ?? ""} ",
                    style: whiteColor16TextStyle,
                  ),
                ],
              ),
            ),
            trailing: comment.users?.id == controller.myId
                ? IconButton(
                    icon: Icon(Icons.delete, color: greyColor),
                    onPressed: () =>
                        controller.deleteComment(comment.id.toString()),
                  )
                : GestureDetector(
                    onTap: () => showReplyDialog(comment),
                    child: const Text("Reply",
                        style: TextStyle(color: Colors.white)),
                  ),
          ),
          if (comment.comments != null && comment.comments!.isNotEmpty)
            InkWell(
              onTap: () => controller.toggleShowReplies(comment),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    comment.isShowMore ? "show less" : "show reply",
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          if (comment.comments != null && comment.isShowMore)
            buildCommentList(comment.comments!, false),
        ],
      ),
    );
  }

  void showReplyDialog(SuccessComment comment) {
    final controller = Get.find<CommentController>();

    Get.defaultDialog(
      title: getMessageContent(comment.comment ?? ""),
      content: TextField(
        controller: controller.replyTextController.value,
        decoration: const InputDecoration(hintText: "add your message here.."),
        onSubmitted: (_) => Get.back(),
      ),
      textConfirm: "Reply",
      textCancel: "Cancel",
      onConfirm: () {
        if (controller.replyTextController.value.text.trim().isNotEmpty) {
          controller.addComment(
            controller.postData.value!.id.toString(),
            "@${comment.userId} ${controller.replyTextController.value.text.trim()}",
            parentId: comment.id.toString(),
          );
          controller.replyTextController.value.clear();
        } else {
          Get.snackbar("Octagon", "Please write comment first!");
        }
        Get.back();
      },
    );
  }
}
