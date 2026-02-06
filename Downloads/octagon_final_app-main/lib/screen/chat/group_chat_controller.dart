import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:octagon/utils/image_picker_inapp.dart';
import 'package:octagon/screen/common/create_post_controller.dart';
import 'package:octagon/screen/mainFeed/home/postController.dart';
import 'package:octagon/widgets/video_editor_screen.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:octagon/services/cloudinary_service.dart';
import 'package:octagon/config/cloudinary_config.dart';
import 'package:octagon/utils/constants.dart';

class GroupChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final storage = GetStorage();
  final postController = Get.put(PostController());
  final CreatePostController _createPostController = Get.put(CreatePostController());
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  var messages = <Map<String, dynamic>>[].obs;
  var isPublicGroup = true.obs;
  var isUploading = false.obs;
  var isGroupCreator = false.obs;
  var isLoadingGroupDetails = false.obs;
  var groupDetails = <String, dynamic>{}.obs;
  var replyingTo = Rxn<Map<String, dynamic>>();
  var mentionResults = <Map<String, dynamic>>[].obs;
  var isMentionLoading = false.obs;

  TextEditingController messageController = TextEditingController();

  late String groupId;

  void setGroup(String id, bool isPublic) {
    groupId = id;
    isPublicGroup.value = isPublic;
    mentionResults.clear();
    // listenToMessages();
    fetchGroupDetails();
  }

  void startReply(Map<String, dynamic>? message) {
    replyingTo.value = message;
  }

  void clearReply() {
    replyingTo.value = null;
  }

  void clearMentionResults() {
    mentionResults.clear();
    isMentionLoading.value = false;
  }

  Future<void> searchGroupMembers(String query) async {
    if (query.trim().isEmpty) {
      clearMentionResults();
      return;
    }
    final token = storage.read("token") ?? storage.read("auth_token");
    if (token == null) return;
    try {
      isMentionLoading.value = true;
      final request = http.MultipartRequest('POST', Uri.parse('${baseUrl}groups-member-search'));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      request.fields.addAll({'group_id': groupId, 'search': query});
      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final decoded = json.decode(body);
        mentionResults.assignAll(_normalizeMemberSearch(decoded));
      } else {
        print('Member search failed: ${response.statusCode} $body');
        clearMentionResults();
      }
    } catch (e) {
      print('Member search error: $e');
      clearMentionResults();
    } finally {
      isMentionLoading.value = false;
    }
  }

  List<Map<String, dynamic>> _normalizeMemberSearch(dynamic payload) {
    final List<Map<String, dynamic>> normalized = [];
    if (payload == null) return normalized;
    dynamic raw = payload;
    if (payload is Map<String, dynamic>) {
      raw = payload['success'] ?? payload['data'] ?? payload['members'] ?? payload['results'];
      if (raw is Map) raw = raw.values.toList();
    }
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final rawName = item["user"]['name'] ?? item['full_name'] ?? item['username'] ?? item['user_name'] ?? '';
          final displayName = (rawName?.toString() ?? '').trim();
          if (displayName.isEmpty) continue;
          final rawUsername = item['username'] ?? item['user_name'] ?? displayName;
          final username = (rawUsername?.toString() ?? '').trim();
          final idValue = item["user"]['user_id'] ?? item['id'] ?? item['member_id'] ?? '';
          final imageValue = item["user"]['photo'] ?? item['photo'] ?? item['avatar'] ?? item['image'] ?? '';
          normalized.add({
            'id': idValue?.toString() ?? '',
            'name': displayName,
            'username': username.isNotEmpty ? username : displayName,
            'image': imageValue?.toString() ?? '',
          });
        }
      }
    }
    return normalized;
  }

  /// Upload a local video file directly to the messenger API for a given thread.
  /// Sends a multipart POST to `messenger/threads/{thread}/videos` with a
  /// `temporary_id` so the server can echo it back for optimistic UI replacement.
  Future<Map<String, dynamic>?> uploadVideoToThread(String threadId, File file, {String? caption}) async {
    try {
      final token = storage.read("token");
      if (token == null) {
        print('No auth token available');
        return null;
      }

      final uri = Uri.parse('${baseUrl}messenger/threads/$threadId/videos');
      final request = http.MultipartRequest('POST', uri);
      final tempId = Uuid().v4();

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields.addAll({
        'temporary_id': tempId,
      });
      if (caption != null && caption.trim().isNotEmpty) {
        request.fields['extra'] = json.encode({'caption': caption.trim()});
      }

      request.files.add(await http.MultipartFile.fromPath('video', file.path));

      print('Sending video to $uri (temp id: $tempId) ...');
      final streamed = await request.send();
      final respBody = await streamed.stream.bytesToString();
      print('Video upload response status: ${streamed.statusCode}');
      print('Video upload response body: $respBody');

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        try {
          final decoded = json.decode(respBody);
          // return parsed response so caller can update UI/messages accordingly
          return decoded is Map<String, dynamic> ? decoded : {'response': decoded};
        } catch (e) {
          // non-JSON response
          return {'response_text': respBody};
        }
      } else {
        print('Failed to upload video: ${streamed.statusCode} ${streamed.reasonPhrase}');
        return {'error': streamed.statusCode, 'body': respBody};
      }
    } catch (e, st) {
      print('Exception uploading video to thread: $e\n$st');
      return null;
    }
  }

  /// Upload a local image file directly to the messenger API for a given thread.
  /// This mirrors [uploadVideoToThread] but targets the `/images` endpoint and
  /// sends the picked file under the `image` field.
  Future<Map<String, dynamic>?> uploadImageToThread(String threadId, File file, {String? caption}) async {
    try {
      final token = storage.read("token");
      if (token == null) {
        print('No auth token available');
        return null;
      }

      final uri = Uri.parse('${baseUrl}messenger/threads/$threadId/images');
      final request = http.MultipartRequest('POST', uri);
      final tempId = Uuid().v4();

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields.addAll({'temporary_id': tempId});
      if (caption != null && caption.trim().isNotEmpty) {
        request.fields['extra'] = json.encode({'caption': caption.trim()});
      }
      request.files.add(await http.MultipartFile.fromPath('image', file.path));

      print('Sending image to $uri (temp id: $tempId) ...');
      final streamed = await request.send();
      final respBody = await streamed.stream.bytesToString();
      print('Image upload response status: ${streamed.statusCode}');
      print('Image upload response body: $respBody');

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        try {
          final decoded = json.decode(respBody);
          return decoded is Map<String, dynamic> ? decoded : {'response': decoded};
        } catch (e) {
          return {'response_text': respBody};
        }
      } else {
        print('Failed to upload image: ${streamed.statusCode} ${streamed.reasonPhrase}');
        return {'error': streamed.statusCode, 'body': respBody};
      }
    } catch (e, st) {
      print('Exception uploading image to thread: $e\n$st');
      return null;
    }
  }

  // void listenToMessages() {
  //   _firestore
  //       .collection('groups')
  //       .doc(groupId)
  //       .collection('messages')
  //       .orderBy('timestamp', descending: true)
  //       .snapshots()
  //       .listen((QuerySnapshot snapshot) {
  //     messages.value = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  //   });
  // }

  Future<void> fetchGroupDetails() async {
    isLoadingGroupDetails.value = true;

    try {
      final token = storage.read("token");
      if (token == null) {
        print("No token found in storage");
        isLoadingGroupDetails.value = false;
        return;
      }

      final currentUserId = storage.read("current_uid");
      if (currentUserId == null) {
        print("No user ID found in storage");
        isLoadingGroupDetails.value = false;
        return;
      }

      var headers = {'Authorization': 'Bearer $token'};
      var request = http.MultipartRequest('POST', Uri.parse('http://3.134.119.154/api/user-groups-get-by-id'));
      request.fields.addAll({'group_id': groupId});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var data = json.decode(responseBody);

        if (data['success'] != null && data['success'].isNotEmpty) {
          var groupJson = data['success'];
          int groupCreatorId = groupJson["0"]['user_id'];

          // Save all group details
          groupDetails.value = groupJson["0"];

          // Check if current user is the group creator
          isGroupCreator.value = groupCreatorId.toString() == currentUserId.toString();
          print("Group creator ID: $groupCreatorId, Current user ID: $currentUserId, Is creator: ${isGroupCreator.value}");
        }
      } else {
        print("Failed to fetch group details: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error fetching group details: $e");
    } finally {
      isLoadingGroupDetails.value = false;
    }
  }

  // Future<void> sendMessage(String userId, String userName, String userImage) async {
  //   final text = messageController.text.trim();
  //   if (text.isEmpty) return;

  //   await _firestore.collection('groups').doc(groupId).collection('messages').add({
  //     'text': text,
  //     'sender_id': userId,
  //     'sender_name': userName,
  //     'sender_image': userImage,
  //     'timestamp': FieldValue.serverTimestamp(),
  //     'type': 'text',
  //   });

  //   messageController.clear();
  // }

  // Future<void> sendMediaMessage(String userId, String userName, String mediaUrl, String mediaType, String? thumbnailUrl) async {
  //   final userImage = storage.read("image_url") ?? "";

  //   await _firestore.collection('groups').doc(groupId).collection('messages').add({
  //     'sender_id': userId,
  //     'sender_name': userName,
  //     'sender_image': userImage,
  //     'timestamp': FieldValue.serverTimestamp(),
  //     'type': mediaType, // 'image' or 'video'
  //     'media_url': mediaUrl,
  //     'thumbnail_url': thumbnailUrl,
  //   });
  // }

  // Send multiple media files in a single message
  Future<void> sendMultipleMediaMessage(String userId, String userName, List<String> mediaUrls, String mediaType, List<String?> thumbnailUrls) async {
    final userImage = storage.read("image_url") ?? "";

    await _firestore.collection('groups').doc(groupId).collection('messages').add({
      'sender_id': userId,
      'sender_name': userName,
      'sender_image': userImage,
      'timestamp': FieldValue.serverTimestamp(),
      'type': mediaType, // 'images' or 'videos'
      'media_urls': mediaUrls, // Array of URLs
      'thumbnail_urls': thumbnailUrls, // Array of thumbnail URLs
    });
  }

  Future<Map<String, dynamic>?> reactToMessage({required String threadId, required String messageId, required String emoji}) async {
    try {
      final token = storage.read("token") ?? storage.read("auth_token");
      if (token == null) {
        throw Exception('Missing authentication token');
      }
      final uri = Uri.parse('${baseUrl}messenger/threads/$threadId/messages/$messageId/reactions');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      request.fields['reaction'] = emoji;
      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (body.isEmpty) return null;
        try {
          final decoded = json.decode(body);
          if (decoded is Map<String, dynamic>) return decoded;
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        } catch (_) {}
        return null;
      } else {
        throw Exception(body.isNotEmpty ? body : 'Failed to react (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Upload file to Cloudinary
  Future<String?> uploadFileToCloudinary(File file, String fileName, bool isVideo) async {
    try {
      print('=== CLOUDINARY UPLOAD START ===');
      print('File path: ${file.path}');
      print('File name: $fileName');
      print('Is video: $isVideo');
      print('File exists: ${await file.exists()}');
      print('File size: ${await file.length()} bytes');

      final userId = storage.read("current_uid").toString();
      print('User ID: $userId');

      // Use Cloudinary service to upload
      String? mediaUrl;
      if (isVideo) {
        mediaUrl = await _cloudinaryService.uploadVideo(
          file,
          folder: '${CloudinaryConfig.groupChatVideosFolder}/$groupId',
        );
      } else {
        mediaUrl = await _cloudinaryService.uploadImage(
          file,
          folder: '${CloudinaryConfig.groupChatImagesFolder}/$groupId',
        );
      }

      if (mediaUrl != null) {
        print('Media uploaded to Cloudinary: $mediaUrl');
        print('=== CLOUDINARY UPLOAD SUCCESS ===');
        return mediaUrl;
      } else {
        print('Failed to upload to Cloudinary');
        print('=== CLOUDINARY UPLOAD FAILED ===');
        return null;
      }
    } catch (e, stackTrace) {
      print('=== CLOUDINARY UPLOAD ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('=== CLOUDINARY UPLOAD ERROR END ===');
      return null;
    }
  }

  // Generate thumbnail for video using Cloudinary
  Future<String?> generateVideoThumbnail(String videoUrl) async {
    try {
      print('=== GENERATING VIDEO THUMBNAIL ===');

      // Use Cloudinary's automatic thumbnail generation
      final thumbnailUrl = _cloudinaryService.getVideoThumbnailUrl(
        videoUrl,
        width: CloudinaryConfig.thumbnailWidth,
        height: CloudinaryConfig.thumbnailHeight,
      );

      print('Thumbnail URL generated: $thumbnailUrl');
      print('=== VIDEO THUMBNAIL GENERATED ===');
      return thumbnailUrl;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  Future<void> pickMedia(
    BuildContext context, {
    String? threadId,
    void Function(Map<String, dynamic> payload)? onMessengerMessage,
    bool usePostApi = false,
  }) async {
    try {
      print('Starting media picker...');
      final source = await showImagePicker(context);
      print('Selected source: $source');

      // Check if user cancelled
      if (source == null && source != null) {
        print('Invalid source selection');
        Get.snackbar("Error", "Invalid source selection");
        return;
      }

      isUploading.value = true;
      List<PostFile> selectedFiles = [];
      bool isVideo = false;

      if (source == null) {
        // Video selection (when user selects "Video" option)
        print('Video selection mode');
        final file = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 120),
        );
        if (file != null) {
          print('Video selected: ${file.path}');
          selectedFiles.add(PostFile(filePath: file.path, isVideo: true));
          isVideo = true;
        } else {
          print('No video selected');
          Get.snackbar("Error", "No video selected");
        }
      } else if (source == ImageSource.camera) {
        // Camera image selection
        print('Camera image selection mode');
        final file = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 50,
        );
        if (file != null) {
          print('Image selected from camera: ${file.path}');
          selectedFiles.add(PostFile(filePath: file.path, isVideo: false));
          isVideo = false;
        } else {
          print('No image selected from camera');
          Get.snackbar("Error", "No image selected from camera");
        }
      } else {
        // Gallery image selection (multi-image)
        print('Gallery image selection mode');
        try {
          final fileList = await _picker.pickMultiImage();
          if (fileList.isNotEmpty) {
            print('Images selected from gallery: ${fileList.length}');
            for (var file in fileList) {
              selectedFiles.add(PostFile(filePath: file.path, isVideo: false));
            }
            isVideo = false;
          } else {
            print('No images selected from gallery');
            Get.snackbar("Error", "No images selected from gallery");
          }
        } catch (e) {
          print('Error picking multi images: $e');
          Get.snackbar("Error", "Error picking multi images: $e");
          // Fallback to single image picker
          try {
            final file = await _picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 50,
            );
            if (file != null) {
              print('Single image selected from gallery: ${file.path}');
              selectedFiles.add(PostFile(filePath: file.path, isVideo: false));
              isVideo = false;
            }
          } catch (e2) {
            print('Error picking single image: $e2');
            Get.snackbar("Error", "Error picking single image: $e2");
          }
        }
      }

      print('Selected files count: ${selectedFiles.length}');
      print('Is video: $isVideo');

      if (selectedFiles.isEmpty) {
        print('No files selected. Exiting.');
        Get.snackbar("Error", "No files selected");
        isUploading.value = false;
        return;
      }

      print('Processing selected files...');

      // Process each file (edit if needed)
      List<PostFile> processedFiles = [];

      for (var file in selectedFiles) {
        try {
          if (file.isVideo) {
            // Skip editing, just add the picked file
            print('Picked video: \\${file.filePath}');
            processedFiles.add(file);
          } else {
            // Edit image
            print('Editing image: ${file.filePath}');
            try {
              final imageBytes = await File(file.filePath).readAsBytes();
              final edited = await Get.to(() => ImageEditor(image: imageBytes));
              if (edited != null) {
                print('Image edited');
                final savedPath = await saveImage(edited);
                print('Image saved to: $savedPath');
                processedFiles.add(PostFile(filePath: savedPath, isVideo: false));
              } else {
                print('Image editing cancelled');
              }
            } catch (e) {
              print('Error processing image: $e');
              // If editing fails, use original file
              processedFiles.add(file);
            }
          }
        } catch (e) {
          print('Error processing file: $e');
          // If processing fails, use original file
          processedFiles.add(file);
        }
      }

      print('Processed files count: ${processedFiles.length}');

      if (processedFiles.isNotEmpty) {
        print('Starting Cloudinary upload...');
        try {
          final userId = storage.read("current_uid").toString();
          final userName = storage.read("user_name").toString();

          print('User ID: $userId');
          print('User name: $userName');
          print('Group ID: $groupId');

          // Check if we have multiple images
          final imageFiles = processedFiles.where((file) => !file.isVideo).toList();
          final videoFiles = processedFiles.where((file) => file.isVideo).toList();

          if (usePostApi) {
            final posted = await _createPostController.submitPostFromFiles(
              images: imageFiles,
              videos: videoFiles,
            );
            if (!posted) {
              Get.snackbar('Error', 'Failed to create post');
            }
            isUploading.value = false;
            return;
          }

          // If we have threadId, prefer uploading media directly to messenger API
          if (threadId != null && (videoFiles.isNotEmpty || imageFiles.isNotEmpty)) {
            if (imageFiles.isNotEmpty) {
              print('Uploading ${imageFiles.length} image(s) directly to messenger API for thread $threadId');
              for (var i = 0; i < imageFiles.length; i++) {
                final file = imageFiles[i];
                try {
                  final caption = await _promptMediaCaption(
                    context,
                    isVideo: false,
                    position: i + 1,
                    total: imageFiles.length,
                  );
                  if (caption == null) {
                    Get.snackbar('Upload cancelled', 'Image upload cancelled');
                    isUploading.value = false;
                    return;
                  }
                  final uploadRes = await uploadImageToThread(
                    threadId,
                    File(file.filePath),
                    caption: caption.isEmpty ? null : caption,
                  );
                  print('Direct image upload result: $uploadRes');
                  if (uploadRes != null) {
                    Get.snackbar('Success', 'Image uploaded to thread');
                    if (uploadRes.isNotEmpty) {
                      if (caption.isNotEmpty) {
                        _injectCaptionIntoPayload(uploadRes, caption);
                      }
                      onMessengerMessage?.call(uploadRes);
                    }
                  } else {
                    Get.snackbar('Error', 'Failed to upload image to thread');
                  }
                } catch (e) {
                  print('Error uploading image to thread: $e');
                  Get.snackbar('Error', 'Failed to upload image to thread: $e');
                }
              }
            }

            if (videoFiles.isNotEmpty) {
              print('Uploading ${videoFiles.length} video(s) directly to messenger API for thread $threadId');
              for (var i = 0; i < videoFiles.length; i++) {
                final file = videoFiles[i];
                try {
                  final caption = await _promptMediaCaption(
                    context,
                    isVideo: true,
                    position: i + 1,
                    total: videoFiles.length,
                  );
                  if (caption == null) {
                    Get.snackbar('Upload cancelled', 'Video upload cancelled');
                    isUploading.value = false;
                    return;
                  }
                  final uploadRes = await uploadVideoToThread(
                    threadId,
                    File(file.filePath),
                    caption: caption.isEmpty ? null : caption,
                  );
                  print('Direct video upload result: $uploadRes');
                  if (uploadRes != null) {
                    Get.snackbar('Success', 'Video uploaded to thread');
                    if (uploadRes.isNotEmpty) {
                      if (caption.isNotEmpty) {
                        _injectCaptionIntoPayload(uploadRes, caption);
                      }
                      onMessengerMessage?.call(uploadRes);
                    }
                  } else {
                    Get.snackbar('Error', 'Failed to upload video to thread');
                  }
                } catch (e) {
                  print('Error uploading video to thread: $e');
                  Get.snackbar('Error', 'Failed to upload video to thread: $e');
                }
              }
            }

            isUploading.value = false;
            return;
          }

          // Handle multiple images in a single message
          if (imageFiles.length > 1) {
            print('Processing multiple images: ${imageFiles.length}');
            List<String> imageUrls = [];
            List<String?> thumbnailUrls = [];

            for (int i = 0; i < imageFiles.length; i++) {
              var file = imageFiles[i];
              print('Processing image file ${i + 1}/${imageFiles.length}: ${file.filePath}');
              final fileName = file.filePath.split('/').last;
              final mediaUrl = await uploadFileToCloudinary(File(file.filePath), fileName, false);

              if (mediaUrl != null) {
                print('Image ${i + 1} uploaded successfully: $mediaUrl');
                imageUrls.add(mediaUrl);
                thumbnailUrls.add(null); // Images don't need thumbnails
              } else {
                print('Failed to upload image ${i + 1}: ${file.filePath}');
                Get.snackbar(
                  "Warning",
                  "Failed to upload image ${i + 1}",
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              }
            }

            if (imageUrls.isNotEmpty) {
              print('Sending multiple images message to Firestore...');
              await sendMultipleMediaMessage(
                userId,
                userName,
                imageUrls,
                'images',
                thumbnailUrls,
              );
              print('Multiple images message sent successfully');

              if (imageUrls.length < imageFiles.length) {
                Get.snackbar(
                  "Partial Success",
                  "${imageUrls.length}/${imageFiles.length} images uploaded successfully",
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  "Success",
                  "All ${imageUrls.length} images uploaded successfully",
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            } else {
              Get.snackbar(
                "Error",
                "Failed to upload any images",
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          }
          // Handle multiple videos in a single message
          else if (videoFiles.length > 1) {
            print('Processing multiple videos: ${videoFiles.length}');
            List<String> videoUrls = [];
            List<String?> thumbnailUrls = [];

            for (int i = 0; i < videoFiles.length; i++) {
              var file = videoFiles[i];
              print('Processing video file ${i + 1}/${videoFiles.length}: ${file.filePath}');
              final fileName = file.filePath.split('/').last;
              final mediaUrl = await uploadFileToCloudinary(File(file.filePath), fileName, true);

              if (mediaUrl != null) {
                print('Video ${i + 1} uploaded successfully: $mediaUrl');
                videoUrls.add(mediaUrl);

                // Generate thumbnail for video
                print('Generating video thumbnail ${i + 1}...');
                final thumbnailUrl = await generateVideoThumbnail(mediaUrl);
                thumbnailUrls.add(thumbnailUrl);
                print('Thumbnail URL ${i + 1}: $thumbnailUrl');
              } else {
                print('Failed to upload video ${i + 1}: ${file.filePath}');
                thumbnailUrls.add(null);
                Get.snackbar(
                  "Warning",
                  "Failed to upload video ${i + 1}",
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              }
            }

            if (videoUrls.isNotEmpty) {
              print('Sending multiple videos message to Firestore...');
              await sendMultipleMediaMessage(
                userId,
                userName,
                videoUrls,
                'videos',
                thumbnailUrls,
              );
              print('Multiple videos message sent successfully');

              if (videoUrls.length < videoFiles.length) {
                Get.snackbar(
                  "Partial Success",
                  "${videoUrls.length}/${videoFiles.length} videos uploaded successfully",
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  "Success",
                  "All ${videoUrls.length} videos uploaded successfully",
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            } else {
              Get.snackbar(
                "Error",
                "Failed to upload any videos",
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          }
          // Handle mixed media (images + videos) or single files
          else {
            // Handle single files (image or video) as before
            for (var file in processedFiles) {
              print('Processing file: ${file.filePath}');
              print('Is video: ${file.isVideo}');

              final fileName = file.filePath.split('/').last;
              print('File name: $fileName');

              final mediaUrl = await uploadFileToCloudinary(File(file.filePath), fileName, file.isVideo);

              if (mediaUrl != null) {
                print('Media uploaded successfully: $mediaUrl');

                String? thumbnailUrl;

                if (file.isVideo) {
                  // Generate thumbnail for video using Cloudinary
                  print('Generating video thumbnail...');
                  thumbnailUrl = await generateVideoThumbnail(mediaUrl);
                  print('Thumbnail URL: $thumbnailUrl');
                }

                print('Sending media message to Firestore...');
                // Send media message
                // await sendMediaMessage(
                //   userId,
                //   userName,
                //   mediaUrl,
                //   file.isVideo ? 'video' : 'image',
                //   thumbnailUrl,
                // );

                print('Media message sent successfully');
              } else {
                print('Failed to upload media to Cloudinary');
                Get.snackbar(
                  "Error",
                  "Failed to upload media",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            }
          }
        } catch (e) {
          print('Error during Cloudinary upload: $e');
          Get.snackbar(
            "Error",
            "Failed to upload media: $e",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        print('No files processed successfully');
      }
    } catch (e) {
      print('Media pick error: $e');
      Get.snackbar(
        "Error",
        "Failed to upload media: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
      print('Media picker finished');
    }
  }

  Future<String?> _promptMediaCaption(
    BuildContext context, {
    required bool isVideo,
    required int position,
    required int total,
  }) async {
    final TextEditingController captionController = TextEditingController();
    final String mediaLabel = isVideo ? 'Video' : 'Photo';
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff1F1A37),
          title: Text(
            'Add $mediaLabel Caption',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (total > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Media $position of $total',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              TextField(
                controller: captionController,
                maxLines: 3,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Add an optional caption...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xff2A2444),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(''),
              child: const Text('Skip', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(captionController.text.trim()),
              child: const Text('Attach', style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  void _injectCaptionIntoPayload(Map<String, dynamic> payload, String caption) {
    if (caption.trim().isEmpty) return;
    final existingExtra = payload['extra'];
    if (existingExtra == null) {
      payload['extra'] = {'caption': caption};
      return;
    }
    if (existingExtra is Map) {
      existingExtra['caption'] = caption;
      return;
    }
    if (existingExtra is String && existingExtra.trim().isNotEmpty) {
      try {
        final decoded = json.decode(existingExtra);
        if (decoded is Map) {
          decoded['caption'] = caption;
          payload['extra'] = decoded;
          return;
        }
      } catch (_) {}
    }
    payload['extra'] = {'caption': caption};
  }

  Future<String> saveImage(Uint8List data) async {
    final dir = await getTemporaryDirectory();
    final path = "${dir.path}/octagon_${DateTime.now().millisecondsSinceEpoch}.jpeg";
    await XFile.fromData(data).saveTo(path);
    return path;
  }
}
