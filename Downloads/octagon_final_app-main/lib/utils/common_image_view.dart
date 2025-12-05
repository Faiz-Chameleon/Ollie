import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget ImageViewWidget({required String image}) {
  print(image);
  // String data = image.replaceAll(" ", " ");
  return isSvgImage(imageUrl: image)
      ? SvgPicture.network(
          image,
          fit: BoxFit.cover,
          placeholderBuilder: (BuildContext context) => const SizedBox(
              height: 20, child: Center(child: CircularProgressIndicator())),
          // errorWidget: (context, url, error) => const Icon(Icons.error),
        )
      : CachedNetworkImage(
          imageUrl: image,
          fit: BoxFit.cover,
          placeholder: (context, url) => const SizedBox(
              height: 20, child: Center(child: CircularProgressIndicator())),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
  // CachedNetworkImage(
  //   imageUrl: image,
  //   fit: BoxFit.cover,
  //   placeholder: (context, url) => const SizedBox(height: 20, child: Center(child: CircularProgressIndicator())),
  //   errorWidget: (context, url, error) => const Icon(Icons.error),
  // );
}

isSvgImage({required String imageUrl}) {
  if (imageUrl.isNotEmpty) {
    return imageUrl.toLowerCase().contains("svg");
  }
  return false;
}
