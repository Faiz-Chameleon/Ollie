import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:octagon/screen/mainFeed/bloc/post_bloc.dart';
import 'package:octagon/screen/mainFeed/bloc/post_event.dart';
import 'package:octagon/screen/mainFeed/bloc/post_state.dart';
import 'package:octagon/utils/colors.dart' as ColorR;
import 'package:octagon/utils/styles.dart' as StylesR;

import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/toast_utils.dart';
import 'package:octagon/widgets/text_formbox_widget.dart';
import 'package:path_provider/path_provider.dart';
import '../../networking/response.dart';
import '../../utils/analiytics.dart';
import '../../utils/constants.dart';
import '../../utils/image_picker_inapp.dart';
import '../../utils/string.dart';
import '../../widgets/filled_button_widget.dart';
import '../../widgets/video_editor_screen.dart';

// class PostFile {
//   String filePath = "";
//   bool isVideo = false;

//   PostFile({this.filePath = "", this.isVideo = false});
// }

// class CreatePostScreen extends StatefulWidget {
//   bool isFromChat = false;

//   CreatePostScreen({Key? key, this.isFromChat = false}) : super(key: key);

//   @override
//   State<CreatePostScreen> createState() => _CreatePostScreenState();
// }

// class _CreatePostScreenState extends State<CreatePostScreen> {
//   PostBloc postBloc = PostBloc();

//   AutovalidateMode isValidate = AutovalidateMode.disabled;
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _postTitleController = TextEditingController(text: "Octagon");

//   List<PostFile> files = [];

//   final ImagePicker _picker = ImagePicker();
//   bool isCommentEnable = false;
//   bool isVideo = false;

//   bool isLoading = false;

//   List<String> imagePath = [];

//   String dropdownValue = 'Post';
//   var items = [
//     'Post',
//     'Story',
//     'Reels',
//   ];

//   @override
//   void initState() {
//     super.initState();

//     postBloc = PostBloc();

// /*    postBloc.createPostDataStream.listen((event) {
//       setState(() {
//         switch (event.status) {
//           case Status.LOADING:
//             isLoading = true;
//             break;
//           case Status.COMPLETED:
//             setState(() {
//               event.data!;
//             });
//             showToast(message: "Post created successfully!");
//             isLoading = false;
//             Navigator.pop(context, true);
//             print(event.data);
//             break;
//           case Status.ERROR:
//             isLoading = false;
//             print(Status.ERROR);
//             break;
//           case null:
//             // TODO: Handle this case.
//         }
//       });
//     });*/

//     publishAmplitudeEvent(eventType: 'Create Post $kScreenView');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: appBgColor,
//       child: WillPopScope(
//         onWillPop: () {
//           if (isLoading) {
//             showToast(message: "Posting is on going please wait..");
//           }
//           return Future(() => !isLoading);
//         },
//         child: SafeArea(
//           child: Scaffold(
//             backgroundColor: appBgColor,
//             appBar: AppBar(
//               backgroundColor: appBgColor,
//               elevation: 0.0,
//               title: Text(
//                 "Create Post",
//                 style: whiteColor20BoldTextStyle,
//               ),
//               leading: IconButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 icon: const Icon(
//                   Icons.arrow_back,
//                   color: Colors.white,
//                 ),
//               ),
//               centerTitle: true,
//             ),
//             body: SingleChildScrollView(
//               child: BlocConsumer(
//                   bloc: postBloc,
//                   listener: (context, state) {
//                     if (state is PostLoadingBeginState) {
//                       // onLoading(context);
//                       setState(() {
//                         isLoading = true;
//                       });
//                     }
//                     if (state is PostErrorState) {
//                       // stopLoader(context);
//                       setState(() {
//                         isLoading = false;
//                       });
//                     }
//                     if (state is CreatePostState) {
//                       // stopLoader(context);
//                       showToast(message: "Post created successfully!");

//                       setState(() {
//                         isLoading = false;
//                       });
//                       Navigator.pop(context, true);
//                     }
//                   },
//                   builder: (context, _) {
//                     return Center(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 15.0),
//                         child: Column(
//                           children: [
//                             const SizedBox(
//                               height: 36,
//                             ),
//                             // Text(
//                             //   "Add your $dropdownValue!",
//                             //   style: greyColor12TextStyle.copyWith(
//                             //     color: Colors.white
//                             //   ),
//                             // ),
//                             const SizedBox(
//                               height: 36,
//                             ),
//                             Form(
//                               autovalidateMode: isValidate,
//                               child: Column(
//                                 children: [
//                                   // const SizedBox(
//                                   //   height: 20,
//                                   // ),
//                                   // TextFormBox(
//                                   //   textEditingController: _postTitleController,
//                                   //   hintText: "Post title",
//                                   //   suffixIcon: Icon(
//                                   //     Icons.title,
//                                   //     color: whiteColor,
//                                   //     size: 20,
//                                   //   ),
//                                   // ),
//                                   buildThumbnailView(),
//                                   const SizedBox(
//                                     height: 20,
//                                   ),
//                                   TextFormBox(
//                                     textEditingController: _descriptionController,
//                                     hintText: "Description",
//                                     maxLines: 5,
//                                     isMaxLengthEnable: true,
//                                     isIconEnable: false,
//                                   ),
//                                   const SizedBox(
//                                     height: 20,
//                                   ),

//                                   // buildDropDownButton(),
//                                   if (!widget.isFromChat)
//                                     Row(
//                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       mainAxisSize: MainAxisSize.max,
//                                       children: [
//                                         Text(
//                                           "Comment ${!isCommentEnable ? 'Enabled' : 'Disabled'}",
//                                           style: const TextStyle(color: Colors.white),
//                                         ),
//                                         commentSwitch(),
//                                       ],
//                                     ),
//                                   FilledButtonWidget(isLoading: isLoading, "Create $dropdownValue", () {
//                                     if (!isLoading) {
//                                       if (files
//                                               .isNotEmpty /*_descriptionController.text.trim().isNotEmpty &&
//                                 _postTitleController.text.trim().isNotEmpty*/
//                                           ) {
//                                         if (widget.isFromChat) {
//                                           Navigator.pop(context, [!isVideo, files, _descriptionController.text.trim()]);
//                                         } else {
//                                           /* postBloc.createPost(
//                                               postTitle:
//                                                   _postTitleController.text.trim(),
//                                               description: _descriptionController
//                                                   .text
//                                                   .trim(),
//                                               isCommentEnable: isCommentEnable,
//                                               postType:
//                                                   items.indexOf(dropdownValue) + 1,
//                                               photos: isVideo ? [] : files,
//                                               videos: isVideo ? files : []);*/
//                                           postBloc.add(CreatePostEvent(
//                                               postTitle: _postTitleController.text.trim(),
//                                               description: _descriptionController.text.trim(),
//                                               isCommentEnable: isCommentEnable,
//                                               postType: items.indexOf(dropdownValue) + 1,
//                                               photos: isVideo ? [] : files,
//                                               videos: isVideo ? files : []));
//                                         }
//                                       } else {
//                                         Get.snackbar(AppName, "Please enter valid data!");
//                                       }
//                                     } else {
//                                       showToast(message: "Posting is on going please wait..");
//                                     }
//                                   }, 1)
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 40,
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildThumbnailView() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         buildTitles("Thumbnails"),
//         Flexible(
//             fit: FlexFit.loose,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 buildEmptyImageView(context, onImagePicker: (List<String> imageItems, bool isVideo) {
//                   setState(() {
//                     for (var element in imageItems) {
//                       files.add(PostFile(filePath: element, isVideo: isVideo));
//                     }
//                   });
//                   // bloc.events.setImages(images);
//                 }),
//                 Expanded(
//                   child: GridView.count(
//                     physics: const NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     crossAxisCount: 3,
//                     childAspectRatio: 1,
//                     children: List.generate((files.length), (index) {
//                       /*if (index == files.length) {
//                         return buildEmptyImageView(context, onImagePicker:
//                             (List<String> imageItems, bool isVideo) {
//                           setState(() {
//                             imageItems.forEach((element) {
//                               files.add(PostFile(
//                                   filePath: element, isVideo: isVideo));
//                             });
//                           });
//                           // bloc.events.setImages(images);
//                         });
//                       } else*/
//                       {
//                         PostFile uploadModel = files[index];
//                         return buildImageView(uploadModel, onDelete: () {
//                           setState(() {
//                             files.removeAt(index);
//                             // bloc.events.setImages(images);
//                           });
//                         });
//                       }
//                     }),
//                   ),
//                 ),
//               ],
//             ))
//       ],
//     );
//   }

//   Widget buildTitles(String text) {
//     return Align(
//         alignment: Alignment.topLeft,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Text(text, textAlign: TextAlign.left, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
//         ));
//   }

//   Widget buildEmptyImageView(BuildContext context, {required Function(List<String> list, bool isVideo) onImagePicker}) {
//     return Container(
//       height: 95,
//       width: 95,
//       padding: EdgeInsets.all(12),
//       child: DottedBorder(
//           options: RectDottedBorderOptions(
//             dashPattern: [4, 4],
//             strokeWidth: 1,
//             strokeCap: StrokeCap.round,
//             // borderType: BorderType.Rect,

//             color: ColorR.kcLightGreyColor,
//           ),
//           child: Center(
//             child: IconButton(
//               color: ColorR.kcMediumGreyColor,
//               icon: Icon(Icons.cloud_upload_outlined),
//               onPressed: () async {
//                 showImagePicker(context, onImageSelection: (ImageSource? imageSource) async {
//                   try {
//                     List<Uint8List> imageItems = [];

//                     if (imageSource == null) {
//                       isVideo = true;

//                       final pickedFileList = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 120));
//                       if (pickedFileList?.path != null) {
//                         imagePath.add(pickedFileList!.path);
//                         await pickedFileList.readAsBytes().then((value) {
//                           imageItems.add(value);
//                         });
//                       }
//                     } else if (imageSource == ImageSource.camera) {
//                       isVideo = false;

//                       final pickedFileList = await _picker.pickImage(source: imageSource, imageQuality: 50);
//                       if (pickedFileList?.path != null) {
//                         imagePath.add(pickedFileList!.path);
//                         await pickedFileList.readAsBytes().then((value) {
//                           imageItems.add(value);
//                         });
//                       }
//                     } else {
//                       isVideo = false;

//                       final pickedFileList = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
//                       if (pickedFileList != null) {
//                         // pickedFileList.map((file) => file.readAsBytes()).toList();
//                         // pickedFileList.map((file) => file.readAsBytes());
//                         imagePath.add(pickedFileList.path);
//                         // for (var element in pickedFileList) {
//                         //   imagePath.add(element.path);
//                         //   await   element.readAsBytes().then((value) {
//                         //     imageItems.add(value);
//                         //   });
//                         // }

//                         await pickedFileList.readAsBytes().then((value) {
//                           imageItems.add(value);
//                         });
//                       }
//                     }
//                     if (mounted && imageItems[0] != null) {
//                       if (isVideo) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (BuildContext context) => VideoEditor(file: File(imagePath[0])),
//                           ),
//                         ).then((value) {
//                           if (value != null) {
//                             onImagePicker([value], isVideo);
//                           }
//                         });
//                       } else {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ImageEditor(
//                               image: imageItems[0],
//                               // <-- Uint8List of image
//                               // allowCamera: false,
//                               // allowGallery: false,
//                               savePath: Directory.fromUri(Uri.file(imagePath[0])).toString(),
//                               // appBarColor: Colors.blue,
//                               // bottomBarColor: Colors.blue,
//                             ),
//                           ),
//                         ).then((value) {
//                           if (value != null) {
//                             saveImage(value).then((value) {
//                               onImagePicker([value], isVideo);
//                             });
//                           }
//                         });
//                       }
//                     }
//                   } catch (e) {
//                     print(e);
//                   }
//                 });
//               },
//             ),
//           )),
//     );
//   }

//   Widget buildImageView(PostFile uploadModel, {required Function() onDelete}) {
//     return Container(
//       padding: EdgeInsets.all(2),
//       child: Stack(
//         children: <Widget>[
//           FutureBuilder(
//               future: getImagePath(uploadModel.filePath ?? "", isVideo: uploadModel.isVideo),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   return Align(
//                     alignment: Alignment.bottomCenter,
//                     child: Card(
//                       clipBehavior: Clip.antiAlias,
//                       child: Container(width: 96, height: 96, child: Image.file(File("${snapshot.data!}"), fit: BoxFit.fill)),
//                     ),
//                   );
//                 } else {
//                   return Container(
//                     width: 96,
//                     height: 96,
//                     color: Colors.transparent,
//                     child: Image.file(File(uploadModel.filePath), fit: BoxFit.fill),
//                   );
//                 }
//               }),
//           Positioned(
//             right: 2,
//             top: 4,
//             child: GestureDetector(
//               onTap: () {
//                 onDelete();
//               },
//               child: CircleAvatar(
//                   radius: 10.0, backgroundColor: ColorR.kcLightGreyColor, child: Icon(Icons.close, color: ColorR.kcWhiteColor, size: 16)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   buildDropDownButton() {
//     return DropdownButton(
//       value: dropdownValue,
//       icon: const Icon(Icons.keyboard_arrow_down),
//       items: items.map((String items) {
//         return DropdownMenuItem(
//           value: items,
//           child: Text(items, style: TextStyle(color: Colors.grey)),
//         );
//       }).toList(),
//       // After selecting the desired option,it will
//       // change button value to selected value
//       onChanged: (String? newValue) {
//         setState(() {
//           dropdownValue = newValue!;
//         });
//       },
//     );
//   }

//   commentSwitch() {
//     return Switch(
//       onChanged: (bool value) {
//         setState(() {
//           isCommentEnable = value;
//         });
//       },
//       value: isCommentEnable,
//     );
//   }
// }

// Future<String> saveImage(Uint8List value) async {
//   ///temp path of directory
//   final Directory duplicateFilePath = await getTemporaryDirectory();

//   ///saving image to temp path
//   await XFile.fromData(value).saveTo(duplicateFilePath.path + "octagon.jpeg");
//   return duplicateFilePath.path + "octagon.jpeg";
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:octagon/utils/colors.dart' as ColorR;
import 'package:octagon/widgets/filled_button_widget.dart';
import 'package:octagon/widgets/text_formbox_widget.dart';
import '../../../utils/constants.dart';
import 'create_post_controller.dart';

class CreatePostScreen extends StatelessWidget {
  final bool isFromChat;

  CreatePostScreen({super.key, this.isFromChat = false});

  final controller = Get.put(CreatePostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: appBgColor,
        elevation: 0,
        title: const Text("Create Post", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _buildThumbnails(context),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.descriptionController,
                  maxLength: 120, // Flutter automatically displays this count below the TextFormField
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Description",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: greyColor), borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: greyColor), borderRadius: BorderRadius.circular(12))),
                ),
                // TextFormBox(
                //   textEditingController: controller.descriptionController,
                //   hintText: "Description",
                //   maxLines: 5,
                //   isMaxLengthEnable: true,
                //   isIconEnable: false,
                // ),

                const SizedBox(height: 20),
                if (!isFromChat)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text(
                            "Comments ${controller.isCommentEnabled.value ? 'Enabled' : 'Disabled'}",
                            style: const TextStyle(color: Colors.white),
                          )),
                      Obx(() => Switch(
                            value: controller.isCommentEnabled.value,
                            onChanged: (val) => controller.isCommentEnabled.value = val,
                          )),
                    ],
                  ),
                const SizedBox(height: 30),
                Obx(() {
                  print('Create button - isLoading: ${controller.isLoading.value}');
                  return FilledButtonWidget(
                    "Create ${controller.dropdownValue.value}",
                    () async {
                      print('=== CREATE BUTTON TAPPED ===');
                      print('Create button pressed');

                      // Don't allow multiple taps while loading
                      if (controller.isLoading.value) {
                        print('Already loading, ignoring tap');
                        return;
                      }

                      // Validate input
                      // if (controller.descriptionController.text
                      //     .trim()
                      //     .isEmpty) {
                      //   print('Description is empty');
                      //   Get.snackbar(
                      //     "Error",
                      //     "Please add a description",
                      //     backgroundColor: Colors.red,
                      //     colorText: Colors.white,
                      //   );
                      //   return;
                      // }

                      if (controller.images.isEmpty && controller.videos.isEmpty) {
                        print('No media selected');
                        Get.snackbar(
                          "Error",
                          "Please upload media first",
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      print('Starting post creation...');
                      print('Images count: ${controller.images.length}');
                      print('Videos count: ${controller.videos.length}');
                      print('Description: ${controller.descriptionController.text}');

                      // Call the new submitPost method
                      await controller.submitPost(isFromChat: isFromChat);
                    },
                    1,
                    isLoading: controller.isLoading.value,
                  );
                }),
              ],
            ),
          ),
          // Loading overlay
          Obx(() => controller.isLoading.value
              ? Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Creating post...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildThumbnails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Thumbnails", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildUploadButton(context),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(() {
                // Combine images and videos for display
                List<PostFile> allFiles = [];
                allFiles.addAll(controller.images);
                allFiles.addAll(controller.videos);

                return GridView.builder(
                  shrinkWrap: true,
                  itemCount: allFiles.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                  ),
                  itemBuilder: (_, index) {
                    PostFile file = allFiles[index];
                    return Stack(
                      children: [
                        // Show image or video thumbnail
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: file.isVideo
                                ? _buildVideoThumbnail(file.filePath)
                                : Image.file(
                                    File(file.filePath),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                          ),
                        ),
                        // Play icon for videos
                        if (file.isVideo)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        // Delete button
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => controller.removeFile(index, isVideo: file.isVideo),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.black,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildVideoThumbnail(String videoPath) {
    // You can use video_thumbnail package to generate thumbnails
    // For now, showing a placeholder with video icon
    return Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(
          Icons.videocam,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.pickMedia(context: context),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: ColorR.kcLightGreyColor,
          strokeWidth: 1,
          dashPattern: const [4, 4],
          radius: const Radius.circular(10),
        ),
        child: const SizedBox(
          width: 95,
          height: 95,
          child: Center(child: Icon(Icons.cloud_upload_outlined, color: Colors.white)),
        ),
      ),
    );
  }
}
