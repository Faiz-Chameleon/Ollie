// colors
import 'dart:ui';

import 'package:flutter/material.dart';

const Color kcPrimaryColor = Color(0xff22A45D);
const Color kcSecondaryColor = Color(0xffB82C0E);

const Color kcMediumGreyColor = Color(0xff868686);
const Color kcTealColor = Color(0xff00adab);
const Color kcGreyColor = Color(0xffEAEAEA);
const Color kcDarkGreyColor = Color(0xff4A4A4A);
const Color kcLightTealColor = Color(0xffccf0ef);
const Color kcMustardColor = Color(0xfff7a400);
const Color kcRedColor = Color(0xffe63812);
const Color kcLightRedColor = Color(0xffFBD3CA);

const Color kcWhiteColor = Color(0xffffffff);
const Color kcOffWhiteColor = Color(0xffF2F2F2);

const Color kcPurpleColor = Color(0xff452b5c);
const Color kcIvoryBlackColor = Color(0xff231f20);
const Color kcBlackColor = Color(0xff000000);
const Color kcLightGreyColor = Color(0xfffacacac);
const Color kcTransparentColor = Colors.transparent;

Color kcBackground = kcWhiteColor.withAlpha(220);

abstract class ColorPalette {
  static Color primary_green = _color("#00ADAA");
  static Color light_grey = _color("#E8E8E8");
  static Color meduim_grey = _color("#a1a3a5");
  static Color dark_grey = _color("#A0A4A8");
  static Color orange = _color("#FAA41A");
  static Color red = _color("#EF4623");
  static Color black = _color("#25282B");
  static Color grey_badge = _color("#EAEAEA");
  static Color ivoryBlack = _color("#231F20");
  static Color teal = _color("#00adab");
  static Color white = _color("#ffffff");


  static Color _color(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  ColorPalette._();
}
