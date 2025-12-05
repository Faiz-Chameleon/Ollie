import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:get/get.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:octagon/networking/model/request_model/create_post_request.dart';
import 'package:octagon/networking/model/resource.dart';
import 'package:octagon/networking/network.dart';
import 'package:octagon/utils/image_picker_inapp.dart';
import 'package:octagon/utils/toast_utils.dart';
import 'package:octagon/widgets/showCustomLoadingDialog.dart';
import '../../../utils/constants.dart';
import '../../../widgets/video_editor_screen.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class PostFile {
  String filePath;
  bool isVideo;

  PostFile({required this.filePath, this.isVideo = false});
}

class CreatePostController extends GetxController {
  final _api = NetworkAPICall();
  final storage = GetStorage();

  final descriptionController = TextEditingController();
  final postTitleController = TextEditingController(text: "Octagon");
  final images = <PostFile>[].obs;
  final videos = <PostFile>[].obs;
  final isCommentEnabled = false.obs;
  final isLoading = false.obs;
  final dropdownValue = 'Post'.obs;

  final ImagePicker picker = ImagePicker();
  final imagePath = <String>[];

  final List<String> postTypes = ['Post', 'Story', 'Reels'];

  Future<List<http.MultipartFile>> convertFiles(List<PostFile> files, String fieldName) async {
    List<http.MultipartFile> multipartFiles = [];
    for (var file in files) {
      multipartFiles.add(await http.MultipartFile.fromPath(fieldName, file.filePath));
    }
    return multipartFiles;
  }

  Future<void> submitPost({bool isFromChat = false}) async {
    if (images.isEmpty && videos.isEmpty) {
      showToast(message: "Please upload media first!");
      return;
    }

    // if (descriptionController.text.trim().isEmpty) {
    //   showToast(message: "Please add a description!");
    //   return;
    // }

    isLoading.value = true;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://3.134.119.154/api/save-user-post'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${getUserToken()}',
      });

      request.fields.addAll({
        'type': (postTypes.indexOf(dropdownValue.value) + 1).toString(),
        'title': postTitleController.text,
        'post': descriptionController.text,
        'location': postTitleController.text,
        'comment': isCommentEnabled.value ? '1' : '0',
        'category': '',
      });

      // Add images
      final imageFiles = await convertFiles(images, 'photo[]');
      request.files.addAll(imageFiles);

      // Add videos
      final videoFiles = await convertFiles(videos, 'video[]');
      request.files.addAll(videoFiles);

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print("Success: $responseBody");
        showToast(message: "Post created successfully!");
        clearForm();
        Get.back(result: true);
      } else {
        print("Error: ${response.statusCode}");
        showToast(message: "Failed to create post! Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
      showToast(message: "Error creating post: $e");
    } finally {
      isLoading.value = false;
    }
  }
  // Future<void> submitPost({bool isFromChat = false}) async {
  //   if (images.isEmpty && videos.isEmpty) {
  //     showToast(message: "Please upload media first!");
  //     return;
  //   }

  //   if (descriptionController.text.trim().isEmpty) {
  //     showToast(message: "Please add a description!");
  //     return;
  //   }

  //   isLoading.value = true;
  //   print('Starting post submission...');

  //   try {
  //     print(
  //         'Creating post with ${images.length} images and ${videos.length} videos...');

  //     // Build the request body using all user-provided values
  //     final body = {
  //       "title": postTitleController.text,
  //       "post": descriptionController.text,
  //       "type": postTypes.indexOf(dropdownValue.value) +
  //           1, // 1=Post, 2=Story, 3=Reels
  //       "location": postTitleController
  //           .text, // Replace with a location controller if you have one
  //       "comment": isCommentEnabled.value ? 1 : 0,
  //       "category": "", // Add a category controller if you have one
  //       "photo[]": images.toList(), // Pass PostFile list directly
  //       "video[]": videos.toList(), // Pass PostFile list directly
  //     };

  //     print('Sending post to API...');
  //     print('Request body: $body');

  //     // Send to API - this will handle file upload internally
  //     final result =
  //         await _api.createPostRequest(createPostApiUrl, body, true, "POST");

  //     print('API Response: $result');
  //     print('Response type: \${result.runtimeType}');

  //     // Handle different response structures
  //     if (result is Map<String, dynamic>) {
  //       print('Response is Map: $result');

  //       // Check if response has success field
  //       if (result.containsKey('success')) {
  //         final response = CreatePostResponseModel.fromJson(result);
  //         if (response.success != null) {
  //           print('Post created successfully!');
  //           showToast(message: "Post created successfully!");
  //           Get.back(result: true);
  //         } else {
  //           print('Failed to create post - success is null');
  //           showToast(message: "Failed to create post!");
  //         }
  //       } else if (result.containsKey('message')) {
  //         // API returned a message (success or error)

  //         if (result['message']?.toString().toLowerCase().contains('success') ==
  //             true) {
  //           print('Post created successfully!');
  //           showToast(message: "Post created successfully!");
  //           Get.back(result: true);
  //         } else {
  //           showToast(message: "Failed to create post: \${result['message']}");
  //         }
  //       } else {
  //         // Unknown response structure
  //         print('Unknown response structure: $result');
  //         showToast(message: "Post created successfully!");
  //         Get.back(result: true);
  //       }
  //     } else {
  //       print('Unexpected response type: \${result.runtimeType}');
  //       showToast(message: "Post created successfully!");
  //       Get.back(result: true);
  //     }
  //   } catch (e) {
  //     print('Error creating post: $e');
  //     showToast(message: "Error creating post: $e");
  //   } finally {
  //     isLoading.value = false;
  //     print('Post submission completed');
  //   }
  // }

  var pics = [];
  filter() {
    pics.clear();
    for (var i = 0; i < images.length; i++) {
      pics.add(images[i].filePath);
      print("pics:>$pics");
    }
  }

  var vids = [];
  filterVids() {
    pics.clear();
    for (var i = 0; i < videos.length; i++) {
      pics.add(videos[i].filePath);
      print("videos:>$vids");
    }
  }

  Future<Resource<CreatePostResponseModel>> createPost(BuildContext context, var request) async {
    // This method is kept for backward compatibility
    // The new implementation uses submitPost() method above
    return Resource(
      error: "Use submitPost() method instead",
      data: null,
    );
  }

  Future<void> pickMedia({required BuildContext context}) async {
    try {
      print('Starting media picker...');
      final source = await showImagePicker(context);
      print('Selected source: $source');

      // Check if user cancelled
      if (source == null && source != null) {
        print('Invalid source selection');
        return;
      }

      if (source == null) {
        // Video selection
        print('Video selection mode');
        final file = await picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 120),
        );
        if (file != null) {
          print('Video selected: ${file.path}');
          videos.add(PostFile(filePath: file.path, isVideo: true));
        } else {
          print('No video selected');
        }
      } else if (source == ImageSource.camera) {
        // Camera image
        print('Camera image selection mode');
        final file = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (file != null) {
          print('Image selected from camera: ${file.path}');
          images.add(PostFile(filePath: file.path, isVideo: false));
        } else {
          print('No image selected from camera');
        }
      } else {
        // Gallery images (multi-image)
        print('Gallery image selection mode');
        try {
          final fileList = await picker.pickMultiImage();
          if (fileList.isNotEmpty) {
            print('Images selected from gallery: ${fileList.length}');
            for (var file in fileList) {
              images.add(PostFile(filePath: file.path, isVideo: false));
            }
          } else {
            print('No images selected from gallery');
          }
        } catch (e) {
          print('Error picking multi images: $e');
          // Fallback to single image picker
          try {
            final file = await picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 80,
            );
            if (file != null) {
              print('Single image selected from gallery: ${file.path}');
              images.add(PostFile(filePath: file.path, isVideo: false));
            }
          } catch (e2) {
            print('Error picking single image: $e2');
            showToast(message: "Error picking image: $e2");
          }
        }
      }

      print('Media selection completed. Images: ${images.length}, Videos: ${videos.length}');
    } catch (e) {
      print('Error picking media: $e');
      showToast(message: "Error picking media: $e");
    }
  }

  void removeFile(int index, {bool isVideo = false}) {
    if (isVideo) {
      if (index < videos.length) {
        videos.removeAt(index);
      }
    } else {
      if (index < images.length) {
        images.removeAt(index);
      }
    }
  }

  void clearAllFiles() {
    images.clear();
    videos.clear();
  }

  void clearForm() {
    descriptionController.clear();
    postTitleController.text = "Octagon";
    images.clear();
    videos.clear();
    isCommentEnabled.value = false;
    dropdownValue.value = 'Post';
  }

  @override
  void onClose() {
    descriptionController.dispose();
    postTitleController.dispose();
    super.onClose();
  }
}
