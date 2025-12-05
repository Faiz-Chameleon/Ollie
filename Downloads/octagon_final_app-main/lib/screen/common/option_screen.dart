import 'dart:ui';

import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/utils/colors.dart';
import 'package:octagon/utils/octagon_common.dart';
import 'package:octagon/widgets/show_more_text.dart';
import 'package:share_plus/share_plus.dart';

import '../../main.dart';
import '../../utils/theme/theme_constants.dart';
import '../mainFeed/comment_screen.dart';

class OptionsScreen extends StatelessWidget {
  PostResponseModelData? postData;
  Function? onFollowPress;
  Function? onLikePress;
  Function? onDeletePostPress;
  Function? onMute;
  Function(String)? onReport;
  bool isMyPost = false;
  bool isVideo = false;
  bool isMute = false;

  bool isFromChat = false;

  final CustomPopupMenuController _controller = CustomPopupMenuController();

  List<String> reportOptions = [
    "I just don't like it",
    "It's spam",
    "Nudity or sexual activity",
    "Hate speech or symbols",
    "Violence or dangerous organizations",
    "Bullying or harassment",
    "False information",
    "Scam or fraud"
        "Sale of illegal or regulated goods",
    "Intellectual property violation",
    "Suicide or self-injury",
    "Eating disorders",
    "The problem isn't listed here"
  ];

  OptionsScreen(
      {this.postData,
      this.isMyPost = false,
      this.onFollowPress,
      this.onDeletePostPress,
      this.onLikePress,
      this.onMute,
      this.onReport,
      this.isMute = false,
      this.isVideo = false,
      this.isFromChat = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.only(top: 25),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              CustomPopupMenu(
                child: Container(
                  child: const Icon(Icons.menu, color: Colors.white),
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 25),
                ),
                menuBuilder: () => ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    color: const Color(0xFF4C4C4C),
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              _controller.hideMenu();
                              buildReportDialog(context);
                            },
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.block,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: const Text(
                                        "Report",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                pressType: PressType.singleClick,
                verticalMargin: -10,
                controller: _controller,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.black.withOpacity(0)],
                          stops: [0.4, 0.75]).createShader(rect);
                    },
                    blendMode: BlendMode.dstOut,
                    child: Column(
                      children: [
                        SizedBox(height: 110),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    /* Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OtherUserProfileScreen(
                                                    userId: postData?.userId)));*/
                                  },
                                  child: OctagonShape(
                                      child: postData?.photo == null
                                          ? null
                                          : CachedNetworkImage(
                                              imageUrl: postData?.photo ?? "",
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => const SizedBox(height: 20),
                                              errorWidget: (context, url, error) => const Icon(Icons.error),
                                            )),
                                ),
                              ),
                              //SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  '${postData!.userName}'.capitalize!,
                                  style: whiteColor20BoldTextStyle,
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(margin: const EdgeInsets.only(bottom: 6), child: const Icon(Icons.verified, size: 15, color: Colors.blue)),
                              const SizedBox(width: 6),
                              Visibility(
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                visible: (postData?.userId != storage.read("current_uid")),
                                child: TextButton(
                                  onPressed: () {
                                    if (onFollowPress != null) {
                                      onFollowPress!.call();
                                    }
                                  },
                                  child: Text(
                                    postData!.isUserFollowedByMe ? 'Following' : 'Follow',
                                    style: TextStyle(color: Colors.blue, fontSize: 20, height: 1, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 6),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.3,
                          child: DescriptionTextWidget(
                            text: postData?.post ?? "",
                            // name: "${postData!.userName}",
                            // style: whiteColor14TextStyle,
                            // trimMode: TrimMode.Line,
                            // colorClickableText: greyColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  )),
              Column(
                children: [
                  // if (isMyPost)
                  //   IconButton(
                  //     padding: EdgeInsets.zero,
                  //     icon: Icon(
                  //       Icons.delete,
                  //       color: greyColor,
                  //       size: 25,
                  //     ),
                  //     onPressed: () {
                  //       showDialog(
                  //         context: context,
                  //         builder: (BuildContext context) {
                  //           return AlertDialog(
                  //             title: const Text('Are you sure?'),
                  //             content: const Text('This will delete this permanently.'),
                  //             actions: <Widget>[
                  //               InkWell(
                  //                 onTap: () => Navigator.pop(context), // Closes the dialog
                  //                 child: const Text('No'),
                  //               ),
                  //               InkWell(
                  //                 onTap: () {
                  //                   if (onDeletePostPress != null) {
                  //                     onDeletePostPress!.call();
                  //                   }
                  //                   Navigator.pop(context); // Closes the dialog
                  //                 },
                  //                 child: const Text('Yes'),
                  //               ),
                  //             ],
                  //           );
                  //       },
                  //       );
                  //     },
                  //   ),
                  if (isVideo)
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Icon(
                          isMute ? Icons.volume_off : Icons.volume_up,
                          color: whiteColor,
                          size: 25,
                        ),
                      ),
                      onPressed: () {
                        onMute!.call();
                      },
                    ),
                  Visibility(
                    visible: !isFromChat,
                    child: AnimatedIconButton(
                      onPressed: () {
                        if (onLikePress != null) {
                          onLikePress!.call();
                        }
                      },
                      splashRadius: 1,
                      padding: EdgeInsets.zero,
                      size: 20,
                      animationDirection: AnimationDirection.forward(),
                      icons: [
                        ///like
                        AnimatedIconItem(
                          icon: Icon(
                            postData!.isLikedByMe ? Icons.favorite : Icons.favorite_outline_outlined,
                            color: postData!.isLikedByMe ? redColor : whiteColor,
                            size: 30,
                          ),
                          onPressed: () {
                            if (onLikePress != null) {
                              onLikePress!.call();
                            }
                          },
                        ),
                        const AnimatedIconItem(
                          icon: Icon(Icons.favorite_rounded, color: Colors.red, size: 30),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: !isFromChat,
                    child: Text(
                      '${postData!.likes}',
                      style: TextStyle(color: Colors.white, fontSize: 15, height: 1, fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(height: 20),
                  if ("${postData?.comment}" == "0")
                    Visibility(
                      visible: !isFromChat,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.mode_comment_outlined,
                          color: kcWhiteColor,
                          size: 25,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CommentScreen(
                                      captionTxt: postData?.title ?? "",
                                      name: postData?.userName ?? "",
                                      profilePic: postData?.photo ?? "",
                                      postData: postData)));
                        },
                      ),
                    ),
                  Visibility(
                    visible: !isFromChat,
                    child: Text(
                      '${postData!.comments!.length}',
                      style: TextStyle(color: Colors.white, fontSize: 15, height: 1, fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(height: 20),
                  Visibility(
                    visible: !isFromChat,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Transform.rotate(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Icon(
                            Icons.send_outlined,
                            color: whiteColor,
                            size: 25,
                          ),
                        ),
                        angle: 330 * 3.14 / 180,
                      ),
                      onPressed: () {
                        Share.share('check out this post:- https://octagonapp.com/post/${postData!.id}', subject: 'Octagon');
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  buildReportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey,
      isDismissible: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.75,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Icon(
              Icons.remove,
              color: Colors.grey[600],
            ),
            const Text(
              "Report",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Why are you reporting this post?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.start),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Your report is anonymous, except if you're reporting an intellectual property infringement, If"
                "someone is in immediate danger, call the local emergency services - don't wait.",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: reportOptions.length,
                itemBuilder: (_, index) {
                  return GestureDetector(
                    onTap: () {
                      if (onReport != null) {
                        onReport!(reportOptions[index]);
                      }
                      Navigator.pop(context);
                    },
                    child: Card(
                      color: Colors.grey,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          reportOptions[index],
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
