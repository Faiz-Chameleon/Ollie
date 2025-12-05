import 'dart:convert';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:octagon/config/cloudinary_config.dart';
import 'package:octagon/utils/constants.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  late CloudinaryPublic cloudinary;
  bool _isInitialized = false;
  final storage = GetStorage();

  /// Initialize Cloudinary with your credentials
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      cloudinary = CloudinaryPublic(
        CloudinaryConfig.cloudName,
        CloudinaryConfig.uploadPreset,
        cache: false,
      );
      _isInitialized = true;
      print('Cloudinary initialized successfully');
    } catch (e) {
      print('Error initializing Cloudinary: $e');
      rethrow;
    }
  }

  /// Upload image to Cloudinary
  Future<String?> uploadImage(File imageFile, {String? folder}) async {
    try {
      print('=== CLOUDINARY IMAGE UPLOAD START ===');
      print('File path: ${imageFile.path}');
      print('File exists: ${await imageFile.exists()}');

      if (!_isInitialized) {
        print('Initializing Cloudinary...');
        await initialize();
      }

      // Validate file size
      final fileSize = await imageFile.length();
      print('File size: ${fileSize} bytes (${fileSize ~/ (1024 * 1024)}MB)');
      if (fileSize > CloudinaryConfig.maxImageSize) {
        throw Exception(
            'Image file too large. Maximum size is ${CloudinaryConfig.maxImageSize ~/ (1024 * 1024)}MB');
      }

      final userId = storage.read("current_uid") ?? "anonymous";
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_${timestamp}';

      print('Cloud Name: ${CloudinaryConfig.cloudName}');
      print('Upload Preset: ${CloudinaryConfig.uploadPreset}');
      print('Folder: ${folder ?? CloudinaryConfig.postsImagesFolder}');
      print('File Name: $fileName');

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: folder ?? CloudinaryConfig.postsImagesFolder,
          publicId: fileName,
        ),
      );

      print('Image uploaded to Cloudinary: ${response.secureUrl}');
      print('=== CLOUDINARY IMAGE UPLOAD SUCCESS ===');
      return response.secureUrl;
    } catch (e) {
      print('=== CLOUDINARY IMAGE UPLOAD ERROR ===');
      print('Error uploading image to Cloudinary: $e');
      print('=== CLOUDINARY IMAGE UPLOAD ERROR END ===');
      return null;
    }
  }

  /// Upload video to Cloudinary
  Future<String?> uploadVideo(File videoFile, {String? folder}) async {
    try {
      print('=== CLOUDINARY VIDEO UPLOAD START ===');
      print('File path: ${videoFile.path}');
      print('File exists: ${await videoFile.exists()}');

      if (!_isInitialized) {
        print('Initializing Cloudinary...');
        await initialize();
      }

      // Validate file size
      final fileSize = await videoFile.length();
      print('File size: ${fileSize} bytes (${fileSize ~/ (1024 * 1024)}MB)');
      if (fileSize > CloudinaryConfig.maxVideoSize) {
        throw Exception(
            'Video file too large. Maximum size is ${CloudinaryConfig.maxVideoSize ~/ (1024 * 1024)}MB');
      }

      final userId = storage.read("current_uid") ?? "anonymous";
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_${timestamp}';

      print('Cloud Name: ${CloudinaryConfig.cloudName}');
      print('Upload Preset: ${CloudinaryConfig.uploadPreset}');
      print('Folder: ${folder ?? CloudinaryConfig.postsVideosFolder}');
      print('File Name: $fileName');

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          videoFile.path,
          resourceType: CloudinaryResourceType.Video,
          folder: folder ?? CloudinaryConfig.postsVideosFolder,
          publicId: fileName,
        ),
      );

      print('Video uploaded to Cloudinary: ${response.secureUrl}');
      print('=== CLOUDINARY VIDEO UPLOAD SUCCESS ===');
      return response.secureUrl;
    } catch (e) {
      print('=== CLOUDINARY VIDEO UPLOAD ERROR ===');
      print('Error uploading video to Cloudinary: $e');
      print('=== CLOUDINARY VIDEO UPLOAD ERROR END ===');
      return null;
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages(List<File> imageFiles,
      {String? folder}) async {
    List<String> uploadedUrls = [];

    for (File imageFile in imageFiles) {
      final url = await uploadImage(imageFile, folder: folder);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    return uploadedUrls;
  }

  /// Get optimized image URL with transformations
  String getOptimizedImageUrl(
    String originalUrl, {
    int width = CloudinaryConfig.defaultImageWidth,
    int height = CloudinaryConfig.defaultImageHeight,
    String quality = CloudinaryConfig.defaultImageQuality,
    String format = CloudinaryConfig.defaultImageFormat,
  }) {
    if (!originalUrl.contains('cloudinary.com')) {
      return originalUrl; // Return original if not Cloudinary URL
    }

    // Parse the URL and add transformations
    final uri = Uri.parse(originalUrl);
    final pathSegments = uri.pathSegments;

    if (pathSegments.length >= 3) {
      final cloudName = pathSegments[0];
      final resourceType = pathSegments[1];
      final transformations = 'w_$width,h_$height,q_$quality,f_$format';

      return 'https://res.cloudinary.com/$cloudName/$resourceType/upload/$transformations/${pathSegments.sublist(2).join('/')}';
    }

    return originalUrl;
  }

  /// Get video thumbnail URL
  String getVideoThumbnailUrl(
    String videoUrl, {
    int width = CloudinaryConfig.thumbnailWidth,
    int height = CloudinaryConfig.thumbnailHeight,
  }) {
    if (!videoUrl.contains('cloudinary.com')) {
      return videoUrl; // Return original if not Cloudinary URL
    }

    // Find the index of '/upload/' in the URL
    final uploadIndex = videoUrl.indexOf('/upload/');
    if (uploadIndex == -1) return videoUrl;

    // Insert the transformation string after '/upload/'
    final before =
        videoUrl.substring(0, uploadIndex + 8); // includes '/upload/'
    final after = videoUrl.substring(uploadIndex + 8);

    // Remove the extension from the video file and add .jpg
    String afterNoExt = after.replaceAll(RegExp(r'\.[^/.]+$'), '');
    if (!afterNoExt.endsWith('.jpg')) {
      afterNoExt += '.jpg';
    }

    final transformations = 'w_${width},h_${height},c_fill';

    return '$before$transformations/$afterNoExt';
  }
}
