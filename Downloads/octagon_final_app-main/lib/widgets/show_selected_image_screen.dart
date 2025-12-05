import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:octagon/widgets/text_formbox_widget.dart';
import 'package:video_player/video_player.dart';
import '../model/post_response_model.dart';
import '../utils/theme/theme_constants.dart';

class SelectedImageScreen extends StatefulWidget {

  List<String>? imageItems = [];
  String postText = "";
  bool isVideo = false;

  SelectedImageScreen({this.imageItems, this.isVideo = false, this.postText = "", Key? key}) : super(key: key);

  @override
  State<SelectedImageScreen> createState() => _SelectedImageScreenState();
}

class _SelectedImageScreenState extends State<SelectedImageScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if(widget.isVideo && widget.imageItems!.isNotEmpty){
      initializePlayer(widget.imageItems!.first);
    }
  }

  @override
  void dispose() {
    if(widget.isVideo){
      _videoPlayerController.dispose();
      _chewieController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     initializePlayer(widget.imageItems!.first);
      //   },
      // ),
      appBar: AppBar(
        backgroundColor: appBgColor,
        actions: [
          IconButton(onPressed: (){
            Navigator.pop(context, [
              !widget.isVideo, widget.isVideo? widget.imageItems??[] : widget.imageItems??[]
              , _descriptionController.text.trim()
            ]);
          }, icon: Text("Save", style: whiteColor16BoldTextStyle,))
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            widget.isVideo && _chewieController!=null? Chewie(
              controller: _chewieController!,
            ) : isPostImageAvailable()?Image.file(File(widget.imageItems?.first ??
                ""),
              // fit: BoxFit.cover,
              alignment: Alignment.center,
            ):Container(
              color: purpleColor,
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: TextFormBox(
                  textEditingController: _descriptionController,
                  hintText: "text..",
                  maxCharcter: 150,
                  maxLines: 1,
                  suffixIcon: Icon(
                    Icons.description_outlined,
                    color: whiteColor,
                    size: 20,
                  ),
                ),
              ),
            )
          ],
        )
      ),
    );
  }

  Future initializePlayer(String? data) async {
    try{
      File file = File.fromUri(Uri.file(data!));
      _videoPlayerController = VideoPlayerController.file(file);
      await Future.wait([_videoPlayerController.initialize()]);
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        showControls: false,
        allowMuting: false,
        looping: true,
      );
      setState(() {});
      print("hio");
    }catch(e){
      print(e);
    }
  }

  bool isPostImageAvailable() {
    bool isAvailable = false;
    if (widget.imageItems != null) {
      if (widget.imageItems?.isNotEmpty ?? false) {
        isAvailable = true;
      }
    }
    return isAvailable;
  }

}
