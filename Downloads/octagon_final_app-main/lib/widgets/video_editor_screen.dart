import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';
import 'package:flutter/cupertino.dart';
// import 'package:helpers/helpers.dart' show OpacityTransition;
import '../utils/analiytics.dart';
import '../utils/string.dart';
import '../utils/theme/theme_constants.dart';
import 'crop.dart';


class VideoEditor extends StatefulWidget {
  const VideoEditor({Key? key, required this.file});

  final File file;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  late final VideoEditorController _controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 120),
  );

  @override
  void initState() {
    super.initState();
    _controller
        .initialize(/*aspectRatio: 9 / 16*/)
        .then((_) => setState(() {}))
        .catchError((error) {
      // handle minumum duration bigger than video duration error
      Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError);

    publishAmplitudeEvent(eventType: 'Video Editor $kScreenView');
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(color: Colors.black),),
          duration: const Duration(seconds: 1),
        ),
      );

  void _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;
    // NOTE: To use `-crf 1` and [VideoExportPreset] you need `ffmpeg_kit_flutter_min_gpl` package (with `ffmpeg_kit` only it won't work)

    final config = VideoFFmpegVideoEditorConfig(_controller,
      isFiltersEnabled: true,);

    // Returns the generated command and the output path
    final FFmpegVideoEditorExecute execute = await config.getExecuteConfig();

    Navigator.pop(context, execute.outputPath);

    // await _controller.exportVideo(
    //   // preset: VideoExportPreset.medium,
    //   // customInstruction: "-crf 17",
    //   isFiltersEnabled: true,
    //   onProgress: (stats, value) => _exportingProgress.value = value,
    //   onError: (e, s) => _showErrorSnackBar("Error on export video :("),
    //   onCompleted: (file) {
    //     _isExporting.value = false;
    //     if (!mounted) return;
    //
    //     Navigator.pop(context, file.path);
    //     // showDialog(
    //     //   context: context,
    //     //   builder: (_) => VideoResultPopup(video: file),
    //     // );
    //   },
    // );
  }

  // void _exportCover() async {
  //   await _controller.extractCover(
  //     onError: (e, s) => _showErrorSnackBar("Error on cover exportation :("),
  //     onCompleted: (cover) {
  //       if (!mounted) return;
  //
  //       // showDialog(
  //       //   context: context,
  //       //   builder: (_) => CoverResultPopup(cover: cover),
  //       // );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: appBgColor,
        body: _controller.initialized
            ? SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _topNavBar(),
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: TabBarView(
                              physics:
                              const NeverScrollableScrollPhysics(),
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CropGridViewer.preview(
                                        controller: _controller),
                                    AnimatedBuilder(
                                      animation: _controller.video,
                                      builder: (_, __) =>
                                      ///todo parth
                                          GestureDetector(
                                            onTap: _controller.video.play,
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration:
                                              const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.play_arrow,
                                                color: Colors.black,
                                              ),
                                            ),
                                          )
                                          // OpacityTransition(
                                          //   visible: !_controller.isPlaying,
                                          //   child: GestureDetector(
                                          //     onTap: _controller.video.play,
                                          //     child: Container(
                                          //       width: 40,
                                          //       height: 40,
                                          //       decoration:
                                          //       const BoxDecoration(
                                          //         color: Colors.white,
                                          //         shape: BoxShape.circle,
                                          //       ),
                                          //       child: const Icon(
                                          //         Icons.play_arrow,
                                          //         color: Colors.black,
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                    ),
                                  ],
                                ),
                                CoverViewer(controller: _controller)
                              ],
                            ),
                          ),
                          Container(
                            height: 200,
                            margin: const EdgeInsets.only(top: 10),
                            child: Column(
                              children: [
                                TabBar(
                                  tabs: [
                                    Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: const [
                                          Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(
                                                  Icons.content_cut)),
                                          Text('Trim')
                                        ]),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: const [
                                        Padding(
                                            padding: EdgeInsets.all(5),
                                            child:
                                            Icon(Icons.video_label)),
                                        Text('Cover')
                                      ],
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: _trimSlider(),
                                      ),
                                      _coverSelection(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: _isExporting,
                            builder: (_, bool export, __) =>
                            ///todo parth
                            AlertDialog(
                              title: ValueListenableBuilder(
                                valueListenable: _exportingProgress,
                                builder: (_, double value, __) => Text(
                                  "Exporting video ${(value * 100).ceil()}%",
                                  style:  TextStyle(fontSize: 12, color: darkGreyColor),
                                ),
                              ),
                            ),
                            //     OpacityTransition(
                            //       visible: export,
                            //       child: AlertDialog(
                            //         title: ValueListenableBuilder(
                            //           valueListenable: _exportingProgress,
                            //           builder: (_, double value, __) => Text(
                            //             "Exporting video ${(value * 100).ceil()}%",
                            //             style: const TextStyle(fontSize: 12, color: Colors.white),
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                tooltip: 'Leave editor',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.left),
                icon: const Icon(Icons.rotate_left, color: Colors.white),
                tooltip: 'Rotate unclockwise',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(Icons.rotate_right, color: Colors.white),
                tooltip: 'Rotate clockwise',
              ),
            ),
            // Expanded(
            //   child: IconButton(
            //     onPressed: () => Navigator.push(
            //       context,
            //       MaterialPageRoute<void>(
            //         builder: (context) => CropScreen(controller: _controller),
            //       ),
            //     ),
            //     icon: const Icon(Icons.crop),
            //     tooltip: 'Open crop screen',
            //   ),
            // ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: IconButton(
                tooltip: 'Open export menu',
                icon: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 20),),
                onPressed: (){
                  _exportVideo();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
    duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
    duration.inSeconds.remainder(60).toString().padLeft(2, '0')
  ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final duration = _controller.videoDuration.inSeconds;
          final pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(formatter(_controller.startTrim)),
                const SizedBox(width: 10),
                Text(formatter(_controller.endTrim)),
              ])
              ///todo parth
              // OpacityTransition(
              //   visible: _controller.isTrimming,
              //   child: Row(mainAxisSize: MainAxisSize.min, children: [
              //     Text(formatter(_controller.startTrim)),
              //     const SizedBox(width: 10),
              //     Text(formatter(_controller.endTrim)),
              //   ]),
              // ),
            ]),
          );
        },
      ),
      // Container(
      //   width: MediaQuery.of(context).size.width,
      //   margin: EdgeInsets.symmetric(vertical: height / 4),
      //   child: TrimSlider(
      //     controller: _controller,
      //     height: height,
      //     horizontalMargin: height / 4,
      //     child: TrimTimeline(
      //       controller: _controller,
      //       padding: const EdgeInsets.only(top: 10),
      //     ),
      //   ),
      // )
    ];
  }

  Widget _coverSelection() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: _controller,
            size: height + 10,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  Icon(
                    Icons.check_circle,
                    color: const CoverSelectionStyle().selectedBorderColor,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}