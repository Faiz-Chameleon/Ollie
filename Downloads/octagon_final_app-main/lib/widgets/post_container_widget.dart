import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:jiffy/jiffy.dart';
import 'package:octagon/screen/chat/new_groupchat_screen.dart';
import 'package:octagon/screen/common/full_screen_post.dart';
import 'package:octagon/screen/mainFeed/comment_screen.dart';
import 'package:octagon/screen/profile/other_user_profile.dart';
import 'package:octagon/screen/tabs_screen.dart';
import 'package:octagon/utils/octagon_common.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/time_extenstionn.dart';
import 'package:octagon/widgets/follow_button_widget.dart';
import 'package:resize/resize.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../main.dart';
import '../model/post_response_model.dart';
import '../utils/chat_room.dart';
import '../utils/polygon/polygon_border.dart';
import 'comment_widget.dart';
import 'default_user_image.dart';

class PostWidgets extends StatefulWidget {
  PostResponseModelData? postData;

  final String? name;
  final String? groupType;
  final DateTime? dateTime;
  final String? post;
  int likes = 0;
  final String? imgUrl;

  bool isInView = false;

  Function onLike;
  Function onSavePost;
  Function onFollow;

  Function? updateData;

  PostWidgets(
      {this.name,
      this.dateTime,
      this.post,
      this.imgUrl,
      this.isInView = false,
      this.postData,
      this.updateData,
      required this.onLike,
      required this.onFollow,
      required this.onSavePost,
      this.groupType});

  @override
  _PostWidgetsState createState() => _PostWidgetsState();
}

class _PostWidgetsState extends State<PostWidgets> {
  String likedBy = "Liked by";

  ChewieController? _playerController;
  VideoPlayerController? _videoPlayerController;
  bool isCurrentPageOpen = true;

  Widget _errorBuilder(BuildContext context, String url, dynamic error) {
    return const Center(
      child: Icon(
        Icons.error,
        color: Colors.red,
        size: 40,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.postData != null && widget.postData!.userLikes != null) {
      String temp = "";
      for (var element in widget.postData!.userLikes!) {
        temp = "$element ,";
      }
      if (widget.postData!.userLikes!.isEmpty) {
        likedBy = "";
      }
      likedBy = likedBy /* + temp*/;
    } else {
      likedBy = "";
    }

    // Initialize video player if videos exist
    if (widget.postData?.videos != null && widget.postData!.videos!.isNotEmpty) {
      initializePlayer(widget.postData!.videos![0].filePath);
    }

    setState(() {});

    currentPage.stream.listen((event) {
      if (event != 0) {
        isCurrentPageOpen = false;
        if (_playerController != null) {
          _playerController!.pause();
          _videoPlayerController!.setVolume(0);
        }
      } else {
        isCurrentPageOpen = true;
      }
    });
  }

  @override
  void dispose() {
    _playerController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future initializePlayer(String? data) async {
    try {
      // Only dispose if we're creating a new controller for a different video
      if (_videoPlayerController != null && _videoPlayerController!.dataSource != data) {
        _playerController?.dispose();
        _videoPlayerController?.dispose();
        _playerController = null;
        _videoPlayerController = null;
      }

      if (data == null || data.isEmpty) {
        print('Video URL is null or empty');
        return;
      }

      // If we already have a controller for this video, don't recreate it
      if (_videoPlayerController != null && _videoPlayerController!.dataSource == data && _playerController != null) {
        print('Video player already initialized for this URL');
        return;
      }

      print('Initializing video player with URL: $data');

      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(data));
      await _videoPlayerController!.initialize();

      _playerController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false, // Changed to false to prevent auto-play
        showControls: true, // Changed to true to show controls
        allowMuting: true,
        looping: false,
        errorBuilder: (context, errorMessage) {
          print('Video player error: $errorMessage');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.white, size: 50),
                SizedBox(height: 10),
                Text(
                  'Video Error',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      setState(() {});
      print('Video player initialized successfully');
    } catch (e) {
      print('Error initializing video player: $e');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_videoPlayerController != null) {
    //   if (!isMute) {
    //     if (widget.isInView && isCurrentPageOpen) {
    //       _videoPlayerController!.setVolume(1.0);
    //     } else {
    //       _videoPlayerController!.setVolume(0);
    //     }
    //   } else {
    //     _videoPlayerController!.setVolume(0);
    //   }
    // }

    final hasImages = widget.postData?.images != null && widget.postData!.images!.isNotEmpty;
    final hasVideos = widget.postData?.videos != null && widget.postData!.videos!.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        ///title, description, follow button
        ///image
        // if (hasImages)
        AnimatedContainer(
          margin: const EdgeInsets.only(top: 10),
          duration: const Duration(seconds: 2),
          child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///user thumb

                      widget.groupType == "team"
                          ? GestureDetector(
                              onTap: () {
                                print('Navigating to user profile with userId: ${widget.postData!.userId}');
                                Get.to(() => OtherUserProfileScreen(userId: widget.postData!.userId!));
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  // Octagon background image
                                  Image.asset(
                                    // widget.postData?.groupType == "personal"
                                    //     ?
                                    // 'assets/ic/Group 5.png'
                                    // :
                                    'assets/ic/Group 4.png', // Your uploaded PNG asset
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),

                                  // Centered network image
                                  ClipPath(
                                    clipper: OctagonClipper(),
                                    child: CustomPaint(
                                      painter: OctagonBorderPainter(
                                        strokeWidth: 20.0,
                                        borderColor: Color(0xff211D39), // Change border color
                                      ),
                                      child: Image.network(
                                        widget.postData!.user_group_img!.contains("http")
                                            ? '${widget.postData?.user_group_img}'
                                            : "http://3.134.119.154/${widget.postData?.user_group_img}", // Replace with your image URL
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
                                  ),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                print('Navigating to user profile with userId: ${widget.postData!.userId}');
                                Get.to(() => OtherUserProfileScreen(userId: widget.postData!.userId!));
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    height: 85,
                                  ),
                                  Container(
                                      width: 50,
                                      height: 65,
                                      decoration: BoxDecoration(
                                          color: greyColor,
                                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                                          image: DecorationImage(
                                            image: NetworkImage(widget.postData?.photo ?? ""),
                                            fit: BoxFit.fill,
                                          )),
                                      child: !isProfilePicAvailable(widget.postData?.photo) ? defaultThumb() : null),
                                  Positioned(
                                    top: 45,
                                    left: 7,
                                    right: 7,
                                    child: Container(
                                      height: 35,
                                      width: 35,
                                      child: ClipPath(
                                        clipper: OctagonClipper(),
                                        child: CustomPaint(
                                          painter: OctagonBorderPainter(
                                            strokeWidth: 20.0,
                                            borderColor: Color(0xff211D39), // Change border color
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(7.0),
                                            child: ClipPath(
                                              clipper: OctagonClipper(),
                                              child: Image.network(
                                                widget.postData!.user_group_img!.contains("http")
                                                    ? '${widget.postData?.user_group_img}'
                                                    : "http://3.134.119.154/${widget.postData?.user_group_img}", // Replace with your image URL
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.fill,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  width: 40,
                                                  height: 40,
                                                  color: Color(0xff211D39),
                                                  child: Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          // color: Colors.amber,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              widget.postData?.is_repost == 1
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.reply_outlined, color: Colors.white, size: 18),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            "${widget.postData?.userName ?? ""} Reposted From ${widget.postData?.originalUser?.name ?? ""}",
                                            style: whiteColor16BoldTextStyle,
                                            softWrap: true,
                                          ),
                                        ),
                                        if (widget.postData?.userId != storage.read("current_uid"))
                                          FollowButton(
                                            text: widget.postData!.isUserFollowedByMe ? "Following" : "Follow",
                                            onClick: () {
                                              widget.onFollow();
                                              print("follow");
                                            },
                                          ),
                                      ],
                                    )
                                  : Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(widget.name?.capitalize ?? "", style: whiteColor16BoldTextStyle),
                                        if (widget.postData?.userId != storage.read("current_uid"))
                                          FollowButton(
                                            text: widget.postData!.isUserFollowedByMe ? "Following" : "Follow",
                                            onClick: () {
                                              widget.onFollow();
                                              print("follow");
                                            },
                                          ),
                                      ],
                                    ),
                              RichText(
                                maxLines: 3,
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                    text:
                                        "${(widget.postData?.post ?? "").length > 120 ? (widget.postData?.post ?? "").substring(0, 120) : (widget.postData?.post ?? "")}",
                                    style: greyColor14TextStyle.copyWith(
                                      color: Colors.white,
                                      // fontSize: 13,
                                    ),
                                    children: [
                                      if ((widget.postData?.post ?? "").length > 100)
                                        TextSpan(
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => FullScreenPost(
                                                            postData: widget.postData,
                                                            updateData: () {
                                                              widget.updateData!.call();
                                                            },
                                                          )));
                                            },
                                          text: " Show More",
                                          style: blueColor12TextStyle,
                                        ),
                                    ]),
                              ),
                              // Text(
                              //   '${(widget.postData?.post ?? "").length > 60?
                              //   (widget.postData?.post ?? "").substring(0, 60): (widget.postData?.post ?? "")} ${(widget.postData?.post ?? "").length > 50? "Show More":""}',
                              //   style: greyColor14TextStyle.copyWith(
                              //     color: Colors.white,
                              //     fontSize: 13,
                              //   ),
                              //   overflow: TextOverflow.clip,
                              //   maxLines: 3,
                              //   textAlign: TextAlign.start,
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
        // else if (!hasVideos)
        //   AnimatedContainer(
        //     margin: const EdgeInsets.only(top: 10),
        //     duration: const Duration(seconds: 2),
        //     child: Row(
        //       mainAxisSize: MainAxisSize.max,
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Expanded(
        //           child: Row(
        //             mainAxisSize: MainAxisSize.max,
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               ///user thumb
        //               GestureDetector(
        //                 onTap: () {
        //                   Navigator.push(
        //                       context,
        //                       MaterialPageRoute(
        //                           builder: (context) => OtherUserProfileScreen(
        //                               userId: widget.postData!.userId!)));
        //                 },
        //                 child: Stack(
        //                   children: [
        //                     Container(
        //                       height: 80,
        //                     ),
        //                     Container(
        //                         width: 50,
        //                         height: 65,
        //                         decoration: BoxDecoration(
        //                             color: greyColor,
        //                             borderRadius: const BorderRadius.all(
        //                                 Radius.circular(20)),
        //                             image: DecorationImage(
        //                                 image: NetworkImage(
        //                                     widget.postData?.photo ?? ""),
        //                                 fit: BoxFit.cover)),
        //                         child: !isProfilePicAvailable(
        //                                 widget.postData?.photo)
        //                             ? defaultThumb()
        //                             : null),
        //                     Positioned(
        //                       top: 45,
        //                       left: 0,
        //                       right: 0,
        //                       child: Container(
        //                         height: 35,
        //                         width: 35,
        //                         decoration: ShapeDecoration(
        //                           color: appBgColor,
        //                           shape: PolygonBorder(
        //                             sides: 8,
        //                             rotate: 68,
        //                             side: BorderSide(
        //                               color: Colors.black,
        //                             ),
        //                           ),
        //                         ),
        //                         alignment: Alignment.center,
        //                         clipBehavior: Clip.antiAlias,
        //                         child: OctagonShape(
        //                           // bgColor: Colors.black,
        //                           child: isTeamLogo()
        //                               ? CachedNetworkImage(
        //                                   imageUrl: /*isTeamLogo() ?*/
        //                                       widget.postData?.sportInfo?.first
        //                                           .team?.first.strTeamLogo
        //                                   /* :
        //                             ""*/
        //                                   ,
        //                                   fit: BoxFit.cover,
        //                                   alignment: Alignment.center,
        //                                   width: 30,
        //                                   height: 30,
        //                                   placeholder: (context, url) =>
        //                                       const SizedBox(height: 20),
        //                                   errorWidget: (context, url, error) =>
        //                                       const Icon(Icons.error),
        //                                 )
        //                               : null,
        //                         ),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //               Flexible(
        //                 child: Container(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Column(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     mainAxisAlignment: MainAxisAlignment.start,
        //                     mainAxisSize: MainAxisSize.max,
        //                     children: [
        //                       Row(
        //                         crossAxisAlignment: CrossAxisAlignment.center,
        //                         mainAxisAlignment:
        //                             MainAxisAlignment.spaceBetween,
        //                         children: [
        //                           Text(widget.name!.capitalize!,
        //                               style: whiteColor16BoldTextStyle),
        //                           if (widget.postData?.userId !=
        //                               storage.read("current_uid"))
        //                             FollowButton(
        //                               text: widget.postData!.isUserFollowedByMe
        //                                   ? "Following"
        //                                   : "Follow",
        //                               onClick: () {
        //                                 widget.onFollow();
        //                                 print("follow");
        //                               },
        //                             ),
        //                         ],
        //                       ),
        //                       SizedBox(height: 1.vh),
        //                       Text(
        //                         widget.postData?.post ?? "",
        //                         style: greyColor14TextStyle.copyWith(
        //                           color: Colors.white,
        //                           fontSize: 14,
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),

        ///media content - handle all three scenarios
        if (hasImages && hasVideos)
          buildCombinedMediaView()
        else if (hasImages)
          buildImageView()
        else if (hasVideos)
          buildVideoView()
        else
          const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.only(right: 10.0, top: 4),
          child: Text(
            getDateTime(widget.postData?.createdAt),
            style: const TextStyle(color: Colors.white),
          ),
        ),

        ///like comment share and save buttons
        Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              widget.onLike();
                            },
                            child: Icon(
                              widget.postData!.isLikedByMe ? Icons.favorite : Icons.favorite_outline_outlined,
                              color: widget.postData!.isLikedByMe ? Colors.red : greyColor,
                              size: 25,
                            ),
                          ),
                          /*AnimatedIconButton(
                                onPressed: () {
                                  print('all icons pressed');
                                },
                                splashRadius: 1,
                                padding: EdgeInsets.zero,
                                size: 20,
                                animationDirection: AnimationDirection.forward(),
                                icons: [
                                  AnimatedIconItem(
                                    icon: Icon(
                                      widget.postData!.isLikedByMe
                                          ? Icons.favorite
                                          : Icons.favorite_outline_outlined,
                                      color: widget.postData!.isLikedByMe
                                          ? Colors.red
                                          : greyColor,
                                      size: 25,
                                    ),
                                    onPressed: () {
                                      widget.onLike();
                                    },
                                  ),
                                  const AnimatedIconItem(
                                    icon: Icon(Icons.favorite_rounded,
                                        color: Colors.red, size: 25),
                                  ),
                                ],
                              ),*/
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              "${widget.postData?.likes ?? 0} likes",
                              style: whiteColor12TextStyle,
                            ),
                          )
                        ],
                      ),
                    ),
                    // if ("${widget.postData?.comment}" == "0")
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            child: Icon(
                              Icons.mode_comment_outlined,
                              color: greyColor,
                              size: 25,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommentScreen(
                                    captionTxt: widget.postData?.title ?? "",
                                    name: widget.name!,
                                    profilePic: widget.imgUrl ?? "",
                                    postData: widget.postData,
                                  ),
                                ),
                              );
                            },
                          ),
                          Text(
                            "${widget.postData?.comments?.length}",
                            style: whiteColor12TextStyle,
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            child: Transform.rotate(
                              angle: 330 * 3.14 / 185,
                              child: Icon(
                                Icons.send_outlined,
                                color: greyColor,
                                size: 23,
                              ),
                            ),
                            onTap: () {
                              Share.share('check out this post:- https://octagonapp.com/post/${widget.postData!.id}', subject: 'Octagon');
                            },
                          ),
                          Text(
                            " ",
                            style: whiteColor12TextStyle,
                          )
                        ],
                      ),
                    ),
                  ]),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    widget.postData!.isSaveByMe ? Icons.bookmark : Icons.bookmark_border_outlined,
                    color: greyColor,
                    size: 30,
                  ),
                  onPressed: () {
                    widget.onSavePost();
                    print('on save post to favorite');
                  },
                ),
              ],
            )),

        ///first few comments
        // if (widget.postData?.comments != null &&
        //     widget.postData!.comments!.isNotEmpty)
        //   Container(
        //     alignment: Alignment.centerLeft,
        //     margin: const EdgeInsets.only(left: 10, bottom: 25),
        //     child: Row(
        //       children: [
        //         Container(
        //           height: 35,
        //           width: 35,
        //           decoration: ShapeDecoration(
        //             // color: appBgColor,
        //             shape: PolygonBorder(
        //               sides: 8,
        //               rotate: 68,
        //               side: BorderSide(
        //                 color: amberColor,
        //               ),
        //             ),
        //           ),
        //           alignment: Alignment.center,
        //           clipBehavior: Clip.antiAlias,
        //           child: widget.postData?.comments?.first.users != null
        //               ? CachedNetworkImage(
        //                   imageUrl:
        //                       widget.postData?.comments?.first.users?.photo ??
        //                           "",
        //                   fit: BoxFit.cover,
        //                   alignment: Alignment.center,
        //                   width: 26,
        //                   height: 26,
        //                   placeholder: (context, url) =>
        //                       const SizedBox(height: 20),
        //                   errorWidget: (context, url, error) =>
        //                       const Icon(Icons.error),
        //                 )
        //               : null,
        //         ),
        //         /*OctagonShape(
        //           child: widget.postData?.comments?.first.users == null
        //               ? null
        //               : CachedNetworkImage(
        //                   fit: BoxFit.cover,
        //                   alignment: Alignment.center,
        //                   width: 100,
        //                   height: 100,
        //                   imageUrl:  widget.postData?.comments?.first.users?.photo ??
        //                   "",
        //                   placeholder: (context, url) => const SizedBox(height: 20, child: Center(child: CircularProgressIndicator())),
        //                   errorWidget: (context, url, error) => const Icon(Icons.error),
        //                   ),
        //           height: 35,
        //           width: 30,
        //         ),*/
        //         // Expanded(
        //         //   child: RichText(
        //         //     text: TextSpan(
        //         //         text: " ${widget.postData?.comments?.first.users?.name}"
        //         //             .capitalize!,
        //         //         style: whiteColor16BoldTextStyle,
        //         //         children: [
        //         //           TextSpan(
        //         //             text:
        //         //                 " ${widget.postData?.comments?.first.comment}",
        //         //             style: whiteColor12TextStyle,
        //         //           )
        //         //         ]),
        //         //   ),
        //         // ),
        //         // Container(
        //         //   margin: EdgeInsets.only(left: 10),
        //         //   child: Text("${widget.postData?.comments?.first.users?.name}: ${widget.postData?.comments?.first.comment}",style: TextStyle(
        //         //     color: Colors.white
        //         //   ),overflow: TextOverflow.clip,),
        //         // ),
        //       ],
        //     ),
        //   )
      ],
    );
  }

  Widget buildLikedUserProfile({String imgUrl = "", double leftSide = 0.0}) {
    return Positioned(
      left: leftSide,
      child: CircleAvatar(
        backgroundColor: appBgColor,
        radius: 15,
        child: CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage(imgUrl),
        ),
      ),
    );
  }

  Widget buildLikedBy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              //alignment:new Alignment(x, y)
              children: widget.postData!.userLikes!.map((e) => buildLikedUserProfile(imgUrl: "")).toList(),
            ),
          ),
          Expanded(
              child: Text(
            likedBy,
            style: whiteColor12TextStyle,
          ))
        ],
      ),
    );
  }

  bool isPostImageAvailable() {
    bool isAvailable = false;
    if (widget.postData?.images != null) {
      if (widget.postData?.images?.isNotEmpty ?? false) {
        isAvailable = true;
      }
    }
    return isAvailable;
  }

  String getDateTime(DateTime? createdAt) {
    return timeAgo(Jiffy.parse((createdAt ?? DateTime.now()).toString()).dateTime);
  }

  String timeAgo(DateTime dateTime) {
    // Convert the UTC time to local time
    DateTime localDateTime = dateTime.toLocal();

    Duration diff = DateTime.now().difference(localDateTime);

    if (diff.inSeconds < 60) {
      return "just now";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago";
    } else if (diff.inDays < 7) {
      return "${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago";
    } else if (diff.inDays < 30) {
      int weeks = (diff.inDays / 7).floor();
      return "$weeks week${weeks == 1 ? '' : 's'} ago";
    } else if (diff.inDays < 365) {
      int months = (diff.inDays / 30).floor();
      return "$months month${months == 1 ? '' : 's'} ago";
    } else {
      int years = (diff.inDays / 365).floor();
      return "$years year${years == 1 ? '' : 's'} ago";
    }
  }

  int _currentPage = 0; // Add this to your state

  buildImageView() {
    final images = widget.postData?.images ?? [];

    if (images.isEmpty) {
      return AnimatedContainer(
        duration: const Duration(seconds: 2),
        color: appBgColor,
        height: 400, // Fixed height like Instagram
        width: double.infinity,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          color: Colors.transparent,
          height: 400, // Fixed height like Instagram
          width: double.infinity,
          child: GestureDetector(
            onDoubleTap: () => widget.onLike(),
            onTap: () => goToFullScreenPost(),
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: images[index].filePath ?? "",
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: 400,
                  placeholder: (context, url) => Container(
                      height: 400, width: double.infinity, color: Colors.grey[700], child: const Center(child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) => Container(
                    height: 400,
                    width: double.infinity,
                    color: Colors.grey[700],
                    child: const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == index ? 10 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? purpleColor : Colors.grey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  buildCombinedMediaView() {
    final images = widget.postData?.images ?? [];
    final videos = widget.postData?.videos ?? [];

    // Combine all media items with metadata
    final allMedia = <MapEntry<Map<String, dynamic>, bool>>[];

    // Add images first
    for (var image in images) {
      allMedia.add(MapEntry({
        'filePath': image.filePath ?? "",
        'type': 'image',
      }, false)); // false = image
    }

    // Add videos
    for (var video in videos) {
      allMedia.add(MapEntry({
        'filePath': video.filePath ?? "",
        'thumbUrl': widget.postData?.thumbUrl ?? "",
        'type': 'video',
      }, true)); // true = video
    }

    if (allMedia.isEmpty) {
      return AnimatedContainer(
        duration: const Duration(seconds: 2),
        color: appBgColor,
        height: 400, // Fixed height like Instagram
        width: double.infinity,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          color: Colors.transparent,
          height: 400, // Fixed height like Instagram
          width: double.infinity,
          child: GestureDetector(
            onDoubleTap: () => widget.onLike(),
            onTap: () => goToFullScreenPost(),
            child: PageView.builder(
              itemCount: allMedia.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });

                // Initialize video if the current page is a video
                final currentMedia = allMedia[index];
                if (currentMedia.value) {
                  // isVideo
                  final videoPath = currentMedia.key['filePath'];
                  if (videoPath != null && videoPath.isNotEmpty) {
                    initializePlayer(videoPath);
                  }
                }
              },
              itemBuilder: (context, index) {
                final mediaItem = allMedia[index];
                final isVideo = mediaItem.value;
                final mediaData = mediaItem.key;

                if (isVideo) {
                  // Show video with thumbnail and play icon overlay
                  return Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Video player or thumbnail
                      (_playerController != null &&
                              _playerController!.videoPlayerController.value.isInitialized &&
                              _currentPage == index &&
                              _videoPlayerController?.dataSource == mediaData['filePath'])
                          ? SizedBox(
                              width: double.infinity,
                              height: 400,
                              child: Chewie(
                                controller: _playerController!,
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              height: 400,
                              child: mediaData['thumbUrl'] != null && mediaData['thumbUrl'].toString().isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: mediaData['thumbUrl'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 400,
                                      placeholder: (context, url) => Container(
                                        color: Colors.black,
                                        width: double.infinity,
                                        height: 400,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.black,
                                        width: double.infinity,
                                        height: 400,
                                        child: const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.video_file,
                                                color: Colors.white,
                                                size: 48,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Video',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.black,
                                      width: double.infinity,
                                      height: 400,
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.video_file,
                                              color: Colors.white,
                                              size: 48,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Video',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                      // Play icon overlay
                      if (_playerController == null || !_playerController!.videoPlayerController.value.isInitialized || _currentPage != index)
                        Container(
                          width: double.infinity,
                          height: 400,
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                        ),
                    ],
                  );
                } else {
                  // Show image
                  return CachedNetworkImage(
                    imageUrl: mediaData['filePath'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 400,
                    placeholder: (context, url) => Container(
                        height: 400, width: double.infinity, color: Colors.grey[700], child: const Center(child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) => Container(
                      height: 400,
                      width: double.infinity,
                      color: Colors.grey[700],
                      child: const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
        if (allMedia.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(allMedia.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == index ? 10 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? purpleColor : Colors.grey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  buildVideoView() {
    return GestureDetector(
      onDoubleTap: () => widget.onLike(),
      onTap: () => goToFullScreenPost(),
      child: Container(
        color: Colors.transparent,
        height: 55.vh,
        width: 100.vw,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Video player or thumbnail
            (_playerController != null && _playerController!.videoPlayerController.value.isInitialized)
                ? SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Chewie(
                      controller: _playerController!,
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: widget.postData?.thumbUrl != null && widget.postData!.thumbUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.postData!.thumbUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.black,
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.black,
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                  size: 80,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.black,
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                                size: 80,
                              ),
                            ),
                          ),
                  ),
            // Play button overlay (when video is not playing)
            if (_playerController == null || !_playerController!.videoPlayerController.value.isInitialized)
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    // Initialize and play video when play button is tapped
                    if (widget.postData?.videos != null && widget.postData!.videos!.isNotEmpty) {
                      initializePlayer(widget.postData!.videos![0].filePath);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            // Video indicator
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "VIDEO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  isTeamLogo() {
    if (widget.postData != null && widget.postData?.user_group_img != null && widget.postData!.user_group_img!.isNotEmpty
        // widget.postData?.sportInfo?.first.team != null &&
        // widget.postData!.sportInfo!.first.team!.isNotEmpty &&
        // widget.postData?.sportInfo?.first.team?.first.strTeamLogo != null
        ) {
      return true;
    } else {
      return false;
    }
  }

  void goToFullScreenPost() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.position.then((value) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FullScreenPost(
                      postData: widget.postData,
                      videoDuration: value,
                      videoPlayerController: _videoPlayerController,
                      updateData: () {
                        widget.updateData!.call();
                      },
                    )));
      });
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FullScreenPost(
                    postData: widget.postData,
                    videoPlayerController: _videoPlayerController,
                    updateData: () {
                      widget.updateData!.call();
                    },
                  )));
    }
  }
}
