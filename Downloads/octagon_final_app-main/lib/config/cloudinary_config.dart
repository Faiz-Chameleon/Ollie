class CloudinaryConfig {
  // Replace these with your actual Cloudinary credentials
  static const String cloudName = 'dwnoq0gag';
  static const String uploadPreset = 'mediauploads';

  // Optional: API Key and Secret (if you need server-side operations)
  static const String apiKey = '442464763234488';
  static const String apiSecret = 'lv4XwowAV4CdBBP5qJ10RCAqHwU';

  // Folder structure for organizing uploads
  static const String postsImagesFolder = 'octagon/posts/images';
  static const String postsVideosFolder = 'octagon/posts/videos';
  static const String storiesFolder = 'octagon/stories';
  static const String reelsFolder = 'octagon/reels';
  static const String profilesFolder = 'octagon/profiles';

  // Group chat media folders
  static const String groupChatImagesFolder = 'octagon/group_chat/images';
  static const String groupChatVideosFolder = 'octagon/group_chat/videos';

  // Image transformation settings
  static const int defaultImageWidth = 800;
  static const int defaultImageHeight = 600;
  static const String defaultImageQuality = 'auto';
  static const String defaultImageFormat = 'auto';

  // Video transformation settings
  static const int defaultVideoWidth = 1280;
  static const int defaultVideoHeight = 720;
  static const int thumbnailWidth = 400;
  static const int thumbnailHeight = 300;

  // Upload settings
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const Duration maxVideoDuration = Duration(seconds: 120);

  // Allowed file types
  static const List<String> allowedImageTypes = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp'
  ];
  static const List<String> allowedVideoTypes = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm'
  ];
}
