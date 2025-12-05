import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:octagon/utils/colors.dart' as ColorR;
import 'package:octagon/utils/styles.dart' as StylesR;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

Future<ImageSource?> showImagePicker(BuildContext context) async {
  return await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (BuildContext bc) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: ColorR.kcBackground,
          border: Border.all(
            color: ColorR.kcLightGreyColor,
            width: 1.0,
          ),
        ),
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_library, color: ColorR.kcTealColor),
              title: Text("Gallery",
                  style: TextStyle(color: ColorR.kcIvoryBlackColor)),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.photo_camera, color: ColorR.kcTealColor),
              title:
                  Text("Camera", style: StylesR.kTextStyleRestaurantInfoTitle),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.videocam, color: ColorR.kcTealColor),
              title:
                  Text("Video", style: StylesR.kTextStyleRestaurantInfoTitle),
              onTap: () =>
                  Navigator.of(context).pop(null), // signal to pick a video
            ),
            ListTile(
              title: Text("Cancel",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ColorR.kcIvoryBlackColor)),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    },
  );
}

Future<String?> getImagePath(String path, {bool isVideo = true}) async {
  try {
    if (path.isEmpty || !isVideo) {
      return path;
    }

    String? thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: path,
      timeMs: 1,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 250,
      maxWidth: 250,
      quality: 75,
    );
    print(thumbnailPath);
    return thumbnailPath;
  } catch (e) {
    print(e);
    return null;
  }
}
