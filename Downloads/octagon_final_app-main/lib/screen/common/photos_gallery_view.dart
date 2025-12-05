import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';

import '../../model/post_response_model.dart';
import '../../utils/theme/theme_constants.dart';

class GalleryPhotoViewWrapper extends StatefulWidget {
  final List<String> galleryItems;
  final PageController pageController;
  final int initialIndex;
  String? title;
  bool isVideo = false;

  PostResponseModelData message;

  GalleryPhotoViewWrapper(this.galleryItems,
      {Key? key, required this.initialIndex,
        required this.message,
        this.isVideo = false, this.title})
      : pageController = PageController(initialPage: initialIndex);

  @override
  _GalleryPhotoViewWrapperState createState() =>
      _GalleryPhotoViewWrapperState();
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  int currentIndex = 0;

  ChewieController? _playerController;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();

    if (widget.isVideo) initializePlayer(widget.galleryItems[0]);
  }

  Future initializePlayer(String? data) async {
    _videoPlayerController = VideoPlayerController.network(data!);
    await Future.wait([_videoPlayerController!.initialize()]);

    _playerController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        showControls: true,
        allowMuting: true,
        looping: true,
        autoInitialize: true,
        allowFullScreen: false,
        //zoomAndPan: false,
        allowedScreenSleep: false,
        allowPlaybackSpeedChanging: false);
    print("object");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appBgColor,
        appBar: AppBar(
            // leading: InkWell(
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            //   child: const Icon(
            //     Icons.arrow_back_ios,
            //     color: Colors.white,
            //   ),
            // ),
            actions: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                      Icons.close,
                      size: 36,
                      color: Colors.white
                  ))
            ],
            title: Text(widget.title ?? ""), backgroundColor: appBgColor),
        body: widget.isVideo ? buildVideoView() : buildImageView());
  }

  buildImageView() {
    return Stack(
      alignment: FractionalOffset.bottomCenter,
      children: [
        Container(
          child: PhotoViewGallery.builder(
            onPageChanged: (int index) {
              setState(() {
                currentIndex = index;
              });
            },
            pageController: widget.pageController,
            scrollPhysics: ClampingScrollPhysics(),
            backgroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: appBgColor,
            ),
            enableRotation: true,
            builder: (BuildContext context, int index) {
              String value = widget.galleryItems[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(value),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            itemCount: widget.galleryItems.length,
            loadingBuilder: (context, event) => Center(
              child: Container(
                width: 30.0,
                height: 30.0,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.orange,
                  value: event == null
                      ? 0
                      : (event.cumulativeBytesLoaded /
                          (event.expectedTotalBytes ?? 1)),
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(16.0),
          child: DotsIndicator(
            dotsCount: widget.galleryItems.length,
            position: currentIndex.toDouble(),
            decorator: DotsDecorator(
                size: Size(6, 6),
                color: Colors.grey,
                activeColor: Colors.blueGrey),
          ),
        ),
      ],
    );
  }

  buildVideoView() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: (_playerController != null &&
          _playerController!
              .videoPlayerController.value.isInitialized)
          ? Chewie(
        controller: _playerController!,
      )
          : Center(child: const CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    if(widget.isVideo){
      _videoPlayerController!.dispose();
      _playerController!.dispose();
    }
    super.dispose();
  }
}
