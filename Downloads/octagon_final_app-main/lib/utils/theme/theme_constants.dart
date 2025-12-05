import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///Global Theme
ThemeData globalThemeData = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    //primaryColor: Colors.pink[800],
    fontFamily: "Roboto",
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: purpleColor,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }));

///Colors
Color purpleColor = Color(0xFF643ff5);
Color appBgColor = Color(0xFF1a1a24);
Color greyColor = Color(0xFF6c7690);

Color greenColor = Color(0xFF006400);
Color darkGreyColor = Color(0xFF2c2e41);
Color textFieldColor = Color(0xFFE6EBF3);
Color blackColor = Color(0xFF1A202E);
Color buttonGreyColor = Color(0xFFC1C8D1);
Color whiteColor = Color(0xFFFFFFFF);
Color lightGreyColor = Color(0xFF99B0CF);
Color redColor = Color(0xFFB31B0E);
Color amberColor = Color(0xFFffbf00);
Color lightRedColor = Color(0xFFF7E8E7);
Color lightBlueColor = const Color(0xFFD6DBF3);

///StatusBar
Color statusBarColor = purpleColor;
Color navigationBarColor = purpleColor;
Brightness statusBarBrightness = Brightness.dark;

///Initial Screen
String largeLogo = "assets/images/large_logo.svg";

///Filled Button
Color filledButtonBGColor = purpleColor;
Color disableButtonBGColor = buttonGreyColor;
double filledButtonHeight = 60;
double filledButtonWidth = 327;
Color filledButtonTextColor = whiteColor;

BoxDecoration filledButtonDecoration = BoxDecoration(borderRadius: BorderRadius.circular(10), color: purpleColor);

//disable button
BoxDecoration basicButtonDecoration = BoxDecoration(borderRadius: BorderRadius.circular(10), color: darkGreyColor);

///Border Button
Color borderButtonBorderColor = purpleColor;
double borderButtonHeight = 60;
double borderButtonWidth = 327;
Color borderButtonTextColor = purpleColor;
BoxDecoration borderButtonDecoration =
    BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: borderButtonBorderColor, width: 1.5));

BoxDecoration borderButtonDarkDecoration = BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: whiteColor, width: 1.5));

///Main Actions (HomeScreen)
EdgeInsets mainActionPadding = EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 8);
Alignment mainActionAlignment = Alignment.center;
double mainActionWidth = 80;
double mainActionHeight = 80;
Color mainActionBorderColor = purpleColor;

double mainActionBorderWidth = 1.5;

BoxDecoration mainActionDecoration =
    BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: mainActionBorderColor, width: mainActionBorderWidth));
BoxDecoration mainActionDarkDecoration = BoxDecoration(
    backgroundBlendMode: BlendMode.difference,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: lightBlueColor, width: mainActionBorderWidth),
    color: blackColor);

///Error Box
EdgeInsets errorBoxPadding = EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 8);
Alignment errorBoxAlignment = Alignment.center;
Color errorBoxBgColor = lightRedColor;

BoxDecoration errorBoxDecoration = BoxDecoration(
  borderRadius: BorderRadius.circular(8),
  color: errorBoxBgColor,
);

///WhiteColor 40 Bold
TextStyle whiteColor40BoldTextStyle = TextStyle(
  color: whiteColor,
  fontSize: 40,
  fontWeight: FontWeight.w700,
);

///BlackColor 40 Bold
TextStyle blackColor40BoldTextStyle = TextStyle(
  color: Colors.black,
  fontSize: 40,
  fontWeight: FontWeight.w700,
);

///WhiteColor 32 Bold
TextStyle whiteColor32BoldTextStyle = TextStyle(
  color: whiteColor,
  fontSize: 32,
  fontWeight: FontWeight.w700,
);

///BlueColor 32 Bold
TextStyle blueColor32BoldTextStyle = TextStyle(
  color: whiteColor,
  fontSize: 32,
  fontWeight: FontWeight.w700,
);

///BlackColor 32 Bold
TextStyle blackColor32BoldTextStyle = TextStyle(
  color: blackColor,
  fontSize: 32,
  fontWeight: FontWeight.w700,
);

///LightGreyColor 32 Bold
TextStyle greyColor32BoldTextStyle = TextStyle(
  color: greyColor,
  fontSize: 32,
  fontWeight: FontWeight.w700,
);

///LightGreyColor 32 Bold
TextStyle lightGreyColor32BoldTextStyle = TextStyle(
  color: lightGreyColor,
  fontSize: 32,
  fontWeight: FontWeight.w700,
);

///BlackColor 24 Bold
TextStyle blackColor24BoldTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: blackColor,
);

///WhiteColor 24 Bold
TextStyle whiteColor24BoldTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: whiteColor,
);

///WhiteColor 20 Bold
TextStyle whiteColor20BoldTextStyle = TextStyle(
  fontSize: 20,
  color: whiteColor,
  fontWeight: FontWeight.w700,
);

///BlueColor 20 Bold
TextStyle blueColor20BoldTextStyle = TextStyle(
  fontSize: 20,
  color: purpleColor,
  fontWeight: FontWeight.w700,
);

///LightGrey 20 Bold
TextStyle lightGrey20BoldTextStyle = TextStyle(
  fontSize: 20,
  color: lightGreyColor,
  fontWeight: FontWeight.w700,
);

///BlueColor 24 Bold
TextStyle blueColor24BoldTextStyle = TextStyle(
  fontSize: 24,
  color: purpleColor,
  fontWeight: FontWeight.w700,
);

///BlackColor 20 Bold
TextStyle blackColor20BoldTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: blackColor,
);

///LightBlue 20 Bold
TextStyle lightBlueColor20BoldTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: lightBlueColor,
);

///GreyColor 20 Bold
TextStyle greyColor20BoldTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: greyColor,
);

///RedColor 20 Bold
TextStyle redColor20BoldTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: redColor,
);

///BlackColor 16 bold
TextStyle blackColor16BoldTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w700,
  color: blackColor,
);

///WhiteColor 16 bold
TextStyle whiteColor16BoldTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w700,
  color: whiteColor,
);

///WhiteColor 14 bold
TextStyle whiteColor14BoldTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w700,
  color: whiteColor,
);

///BlueColor 16 bold
TextStyle blueColor16BoldTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w700,
  color: purpleColor,
);

///GreyColor 16 bold
TextStyle greyColor16BoldTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w700,
  color: greyColor,
);

///BlueColor 12 Bold
TextStyle blueColor12BoldTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: purpleColor);

TextStyle chatTimeTextStyle = TextStyle(fontFamily: "Roboto", fontSize: 10, color: lightGreyColor);

///WhiteColor 12 Bold
TextStyle whiteColor12BoldTextStyle = TextStyle(fontFamily: "Roboto", fontSize: 12, fontWeight: FontWeight.w700, color: whiteColor);

///LightBlueColor 12 Bold
TextStyle lightBlueColor12BoldTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: lightBlueColor);

///BlackColor 12 Bold
TextStyle blackColor12BoldTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: blackColor);

///GreyColor 12 Bold
TextStyle greyColor12BoldTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: greyColor);

///WhiteColor 20 normal
TextStyle whiteColor20TextStyle = TextStyle(
  fontSize: 20,
  color: whiteColor,
  fontWeight: FontWeight.w400,
);

///BlueColor 20 normal
TextStyle blueColor20TextStyle = TextStyle(
  fontSize: 20,
  color: purpleColor,
  fontWeight: FontWeight.w400,
);

///BlackColor 20 normal
TextStyle blackColor20TextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w400,
  color: blackColor,
);

///GreyColor 20 normal
TextStyle greyColor20TextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w400,
  color: greyColor,
);

///BlackColor 16 normal
TextStyle blackColor16TextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: blackColor,
);

///BlueColor 16 normal
TextStyle blueColor16TextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: purpleColor,
);

///WhiteColor 16 normal
TextStyle whiteColor16TextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: whiteColor,
);

///GreyColor 16 normal
TextStyle greyColor16TextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: greyColor,
);

///LightBlue Color 16 normal
TextStyle lightBlueColor16TextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: lightBlueColor,
);

///BlueColor 12 normal
TextStyle blueColor12TextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: purpleColor);

///whiteColor 12 normal
TextStyle whiteColor12TextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: whiteColor);

///whiteColor 14 normal
TextStyle whiteColor14TextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: whiteColor);

///BlackColor 12 normal
TextStyle blackColor12TextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: blackColor);

///GreyColor 12 normal
TextStyle greyColor12TextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: greyColor);

///GreyColor 14 normal
TextStyle greyColor14TextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: greyColor);

///GreyColor 14 normal
TextStyle greyColor14BoldTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: greyColor);

///RedColor 12 normal
TextStyle redColor12TextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: redColor);

///GreenColor 16 bold
TextStyle greenColor16BoldTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w700,
  color: greenColor,
);
