import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octagon/screen/mainFeed/home/postController.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/toast_utils.dart';
import 'package:video_player/video_player.dart';

import '../../model/post_response_model.dart';
import 'option_screen.dart';

class ContentScreen extends StatefulWidget {
  final PostResponseModelData? postData;
  final Function? updateData;
  final Duration? videoDuration;
  final int userId;
  final bool isFromChat;
  final VideoPlayerController? videoPlayerController;

  const ContentScreen({
    Key? key,
    required this.postData,
    required this.userId,
    this.videoDuration,
    this.updateData,
    this.isFromChat = false,
    this.videoPlayerController,
  }) : super(key: key);

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  late final VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool isMute = false;
  bool isVideo = false;
  int _currentPage = 0;

  final PostController controller = Get.find<PostController>();

  @override
  void initState() {
    super.initState();
    // Initialize video player if videos exist
    if (widget.postData?.videos?.isNotEmpty ?? false) {
      isVideo = true;
      initializePlayer(widget.postData!.videos!.first.filePath ?? "");
    }
  }

  Future<void> initializePlayer(String url) async {
    try {
      _videoPlayerController = widget.videoPlayerController ?? VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
        showControls: true, // Show controls in full screen
        allowMuting: true,
        startAt: widget.videoDuration,
      );
      setState(() {});
    } catch (e) {
      print('Error initializing video player: $e');
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (isVideo && widget.videoPlayerController == null) {
      _videoPlayerController.dispose();
    }
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.postData!;

    final hasImages = post.images != null && post.images!.isNotEmpty;
    final hasVideos = post.videos != null && post.videos!.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Handle all three scenarios
        if (hasImages && hasVideos)
          _buildCombinedMediaView(post)
        else if (hasVideos)
          _buildVideoView(post)
        else if (hasImages)
          _buildImageView(post)
        else
          Container(color: purpleColor),

        OptionsScreen(
          postData: post,
          isMute: isMute,
          isVideo: isVideo,
          isFromChat: widget.isFromChat,
          isMyPost: post.userId.toString() == widget.userId.toString(),
          onMute: () {
            isMute = !isMute;
            if (_chewieController != null) {
              _videoPlayerController.setVolume(isMute ? 0 : 1);
            }
          },
          onDeletePostPress: () async {
            await controller.deletePost(post.id.toString());
            widget.updateData?.call();
          },
          onFollowPress: () async {
            await controller.followUser(
              post.userId.toString(),
              !post.isUserFollowedByMe,
            );
            setState(() {
              post.isUserFollowedByMe = !post.isUserFollowedByMe;
            });
            widget.updateData?.call();
          },
          onLikePress: () async {
            await controller.likePost(
              post.id.toString(),
              !post.isLikedByMe,
              post.type ?? "1",
            );
            setState(() {
              post.isLikedByMe = !post.isLikedByMe;
            });
            widget.updateData?.call();
          },
          onReport: (reason) async {
            await controller.reportPost(
              contentId: post.id.toString(),
              title: reason,
              type: post.type ?? "1",
            );
            showToast(message: "Thanks for reporting this post.");
            widget.updateData?.call();
          },
        ),
      ],
    );
  }

  Widget _buildCombinedMediaView(PostResponseModelData post) {
    final images = post.images ?? [];
    final videos = post.videos ?? [];

    // Combine all media items
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
        'thumbUrl': post.thumbUrl ?? "",
        'type': 'video',
      }, true)); // true = video
    }

    return PageView.builder(
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
          // Show video player or thumbnail
          return (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized && _currentPage == index)
              ? SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Chewie(
                    controller: _chewieController!,
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: mediaData['thumbUrl'] != null && mediaData['thumbUrl'].toString().isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: mediaData['thumbUrl'],
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
                );
        } else {
          // Show image
          return CachedNetworkImage(
            imageUrl: mediaData['filePath'],
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        }
      },
    );
  }

  Widget _buildVideoView(PostResponseModelData post) {
    return (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized)
        ? SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Chewie(
              controller: _chewieController!,
            ),
          )
        : Container(
            width: double.infinity,
            height: double.infinity,
            child: post.thumbUrl != null && post.thumbUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: post.thumbUrl!,
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
          );
  }

  Widget _buildImageView(PostResponseModelData post) {
    final images = post.images ?? [];

    if (images.isEmpty) {
      return Container(color: purpleColor);
    }

    return PageView.builder(
      itemCount: images.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: images[index].filePath ?? "",
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
      },
    );
  }
}
