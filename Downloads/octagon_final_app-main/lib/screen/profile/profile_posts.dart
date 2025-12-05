import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:octagon/model/post_response_model.dart';
import 'package:octagon/model/user_profile_response.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../utils/image_picker_inapp.dart';
import '../common/full_screen_post.dart';
import '../mainFeed/story_screen.dart';

class ProfilePosts extends StatefulWidget {
  List<PostResponseModelData> postDataList = [];
  bool isSavedPost = false;
  Function(PostResponseModelData)? onButtonPress;
  bool isOtherUser = false;
  bool isLoading = false;

  ProfilePosts(
      {Key? key,
      this.onButtonPress,
      this.isLoading = false,
      required this.postDataList,
      this.isSavedPost = false,
      this.isOtherUser = false})
      : super(key: key);

  @override
  _ProfilePostsState createState() => _ProfilePostsState();
}

class _ProfilePostsState extends State<ProfilePosts> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: widget.postDataList.isEmpty,
        replacement: GridView(
          // physics: const NeverScrollableScrollPhysics(),
          //shrinkWrap: true,
          semanticChildCount: 2,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          gridDelegate: SliverQuiltedGridDelegate(
            crossAxisCount: 2,
            mainAxisSpacing: 2,
            crossAxisSpacing: 4,
            repeatPattern: QuiltedGridRepeatPattern.inverted,
            pattern: [
              const QuiltedGridTile(2, 1),
              const QuiltedGridTile(1, 1),
            ],
          ),
          children: widget.postDataList.map((e) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FullScreenPost(
                              postData: e,
                              updateData: () {},
                            )));
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 2.5,
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (isPostImageAvailable(e) || isPostVideoAvailable(e))
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: isPostImageAvailable(e)
                              ? buildImageView(e)
                              : buildVideoView(e)),

                    ///delete button
                    if (!widget.isOtherUser)
                      // if (!widget.isSavedPost)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            widget.isSavedPost ? Icons.bookmark : Icons.delete,
                            color: greyColor,
                            size: 25,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Octagon'),
                                  content: Text(
                                      'Are you sure you want to ${!widget.isSavedPost ? 'delete' : 'Unsaved'} this post!.'),
                                  actions: <Widget>[
                                    InkWell(
                                      onTap: () => Navigator.pop(context),
                                      // Closes the dialog
                                      child: const Text('No',
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (widget.onButtonPress != null) {
                                          widget.onButtonPress!.call(e);
                                        }
                                        Navigator.pop(
                                            context); // Closes the dialog
                                      },
                                      child: const Text('Yes',
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      )
                  ],
                ),
              ),
            );
          }).toList(),
          // childrenDelegate: SliverChildBuilderDelegate(
          //   (context, index) => Padding(
          //     padding: const EdgeInsets.all(2.0),
          //     child: ClipRRect(
          //       borderRadius: BorderRadius.circular(10),
          //       child: Image.asset(
          //         "assets/splash/splash.png",
          //         fit: BoxFit.cover,
          //       ),
          //     ),
          //   ),
          // ),
        ),
        child: widget.isLoading
            ? GestureDetector(
                onTap: () {},
                child: Container(),
              )
            : Center(
                child: Text(
                widget.isSavedPost
                    ? "No saved post at this moment"
                    : "No data available!",
                style: TextStyle(color: Colors.white),
              )));
  }

  bool isPostImageAvailable(PostResponseModelData e) {
    bool isAvailable = false;
    if (e?.images != null) {
      if (e?.images?.isNotEmpty ?? false) {
        isAvailable = true;
      }
    }
    return isAvailable;
  }

  bool isPostVideoAvailable(PostResponseModelData e) {
    bool isAvailable = false;
    if (e?.videos != null) {
      if (e?.videos?.isNotEmpty ?? false) {
        isAvailable = true;
      }
    }
    return isAvailable;
  }

  buildImageView(PostResponseModelData e) {
    return CachedNetworkImage(
      imageUrl: e.images != null &&
              e.images?.first.filePath != null &&
              e.images!.first.filePath!.isNotEmpty
          ? e.images!.first.filePath!
          : "https://picsum.photos/250?image=1",
      fit: BoxFit.cover,
      placeholder: (context, url) => const SizedBox(height: 20),
      errorWidget: (context, url, error) => const Icon(Icons.error),
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
            );
          } else {
            return Container(
              height: 250,
              width: 300,
              color: Colors.transparent,
            );
          }
        });
  }
}
