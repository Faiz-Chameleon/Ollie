import 'package:flutter/cupertino.dart';

Widget defaultThumb() {
  return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        "assets/splash/splash.png",
        fit: BoxFit.cover,
      ));
}
