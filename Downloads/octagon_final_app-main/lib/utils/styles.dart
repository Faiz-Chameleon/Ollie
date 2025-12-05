// Horizontal Spacing
import 'package:flutter/material.dart';
import 'package:octagon/utils/colors.dart' as ColorsR;

const double kBodyTextSize = 16;
const double fontSize8 = 8.0;
const double fontSize9 = 9.0;
const double fontSize10 = 10.0;
const double fontSize11 = 11.0;
const double fontSize12 = 12.0;
const double fontSize13 = 13.0;
const double fontSize14 = 14.0;
const double fontSize15 = 16.0;
const double fontSize16 = 16.0;
const double fontSize17 = 16.0;
const double fontSize18 = 18.0;
const double fontSize20 = 20.0;
const double fontSize22 = 22.0;
const double fontSize24 = 24.0;
const double fontSize26 = 26.0;
const double fontSize28 = 28.0;
const double fontSize32 = 32.0;
const double fontSize34 = 34.0;
const double fontSize36 = 36.0;
const double fontSize100 = 100.0;
// Font Sizing

const double kButtonHeightSize = 48.0;
const double kButtonPadding = 16.0;

/*DIMENSIONS*/
const double kAppBarHeight = 68.0;

const Widget horizontalSpaceTiny = SizedBox(width: 5.0);
const Widget horizontalSpaceSmall = SizedBox(width: 10.0);
const Widget horizontalSpaceRegular = SizedBox(width: 18.0);
const Widget horizontalSpaceMedium = SizedBox(width: 25.0);
const Widget horizontalSpaceLarge = SizedBox(width: 50.0);

const Widget verticalSpaceTiny = SizedBox(height: 5.0);
const Widget verticalSpaceSmall = SizedBox(height: 10.0);
const Widget verticalSpaceRegular = SizedBox(height: 18.0);
const Widget verticalSpaceMedium = SizedBox(height: 25.0);
const Widget verticalSpaceLarge = SizedBox(height: 50.0);

Widget appBarWidget(BuildContext context) {
  return SizedBox(height: statusAndAppBarHeight(context));
}

// Screen Size helpers
double statusAndAppBarHeight(BuildContext context) {
  double statusAndAppBarHeight = kAppBarHeight + statusBarHeight(context) + 4;
  return statusAndAppBarHeight;
}

double statusBarHeight(BuildContext context) {
  double statusBarHeight = MediaQuery.of(context).padding.top;
  return statusBarHeight <= 0 ? 32 : statusBarHeight;
}

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

double screenHeightPercentage(BuildContext context, {double percentage = 1}) =>
    screenHeight(context) * percentage;

double screenWidthPercentage(BuildContext context, {double percentage = 1}) =>
    screenWidth(context) * percentage;

const divider = Divider(
    height: 1,
    thickness: .5,
    indent: 100,
    endIndent: 100,
    color: ColorsR.kcLightGreyColor);

//PADDING
const EdgeInsets kPaddingAll8 = EdgeInsets.all(8.0);
const EdgeInsets kPaddingAll16 = EdgeInsets.all(16.0);

//Text Styles
const TextStyle kTextStyleItalic_16 = TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.italic);

const TextStyle kSectionTitleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w700);

TextStyle kSectionActionTextStyle =
    kSectionTitleTextStyle.copyWith(fontWeight: FontWeight.w200, fontSize: 16);

TextStyle kSectionActionBlack =
    kSectionActionTextStyle.copyWith(color: ColorsR.kcIvoryBlackColor);
TextStyle kSectionActionUnderLineStyle =
    kSectionActionBlack.copyWith(decoration: TextDecoration.underline);

const TextStyle kRestaurantTitleTextStyle = TextStyle(
    fontSize: 16,
    color: ColorsR.kcPurpleColor,
    fontWeight: FontWeight.bold);

TextStyle kRestaurantTitleTextStyleItalic_16 =
    kRestaurantTitleTextStyle.copyWith(fontStyle: FontStyle.italic);
TextStyle kRestaurantDescriptionTextStyleNormal_14 = kRestaurantTitleTextStyle
    .copyWith(fontSize: 14, fontWeight: FontWeight.w400);
TextStyle kRestaurantDescriptionTextStyleItalic_14 =
    kRestaurantDescriptionTextStyleNormal_14.copyWith(
        fontStyle: FontStyle.italic);

TextStyle kTextStyle12 = kRestaurantTitleTextStyle.copyWith(
    fontSize: 12, fontWeight: FontWeight.w400);

// TextStyle
const TextStyle ktsMediumGreyBodyText = TextStyle(
  color: ColorsR.kcMediumGreyColor,
  fontSize: kBodyTextSize,
);

const TextStyle kDrawerMenuItemTextStyleNormal_16 = TextStyle(
    fontSize: 16,
    color: ColorsR.kcPurpleColor,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w600);

/*Toast message */
const TextStyle kTextStyleToastTitle = TextStyle(
    fontSize: 18,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.bold,
    color: ColorsR.kcWhiteColor);
const TextStyle kTextStyleToastContent = TextStyle(
    fontSize: 14,
    fontStyle: FontStyle.normal,
    color: ColorsR.kcWhiteColor);

const TextStyle kTSWhite16Normal = TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.normal,
    color: ColorsR.kcWhiteColor);

// Restaurant Detail info
const TextStyle kTextStyleRestaurantInfoRName = TextStyle(
    fontSize: 22,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.bold,
    color: ColorsR.kcWhiteColor);

const TextStyle kTextStyleRestaurantInfoRDescription = TextStyle(
    fontSize: 14,
    fontStyle: FontStyle.normal,
    color: ColorsR.kcWhiteColor);

const TextStyle kTextStyleRestaurantInfoSectionTitle = TextStyle(
    fontSize: 24,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.bold,
    color: ColorsR.kcIvoryBlackColor);

const TextStyle kTextStyleRestaurantInfoTitle = TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.normal,
    color: ColorsR.kcIvoryBlackColor);

const TextStyle kTextStyleRestaurantInfoDescription = TextStyle(
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.normal,
    color: ColorsR.kcTealColor);

const TextStyle kTextStyleWhiteUnderLine = TextStyle(
    color: ColorsR.kcWhiteColor,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    decoration: TextDecoration.underline);

const TextStyle kTextStyleDescription = TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.normal,
    color: ColorsR.kcIvoryBlackColor);

const TextStyle kTextStyleBackUnderLine = TextStyle(
    color: ColorsR.kcRedColor,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline);

//FLOT BUTTON

const TextStyle kFABOptionsTextStyle_12 = TextStyle(
    fontSize: 12,
    color: ColorsR.kcIvoryBlackColor,
    fontWeight: FontWeight.w400);

const TextStyle restaurantFiltersHeading = TextStyle(
    color: Color(0xff2B2B2B),
    fontSize: 14,
    fontWeight: FontWeight.w600);
const TextStyle restaurantFiltersPrice = TextStyle(
    fontSize: 12, color: Color(0xff9A9A9A));
const TextStyle restaurantFiltersChipButton = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600);

ButtonStyle kFABOptionsButtonStyle = ButtonStyle(
  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(16)),
  foregroundColor: MaterialStateProperty.all<Color>(ColorsR.kcWhiteColor),
  backgroundColor: MaterialStateProperty.all<Color>(ColorsR.kcWhiteColor),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(48.0),
          side: BorderSide(color: ColorsR.kcMediumGreyColor))),
);

//-------------------------- RGULAR


const TextStyle pageTitle = TextStyle(
    fontSize: 16,
    color: ColorsR.kcPurpleColor,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w600);


TextStyle commonRegular = TextStyle(
    color: ColorsR.ColorPalette.ivoryBlack,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400);

 TextStyle regular10Text = commonRegular.copyWith(fontSize: fontSize10);
 TextStyle regular12Text = commonRegular.copyWith(fontSize: fontSize12);
 TextStyle regular14Text = commonRegular.copyWith(fontSize: fontSize14);
 TextStyle regular16Text = commonRegular.copyWith(fontSize: fontSize16);
 TextStyle regular18Text = commonRegular.copyWith(fontSize: fontSize18);


//Sami bold
TextStyle commonSamiBold = TextStyle(
    color: ColorsR.ColorPalette.ivoryBlack,
    fontWeight: FontWeight.w500);

TextStyle samiBold12Text = commonSamiBold.copyWith(fontSize: fontSize12);
TextStyle samiBold14Text = commonSamiBold.copyWith(fontSize: fontSize14);
TextStyle samiBold16Text = commonSamiBold.copyWith(fontSize: fontSize16);
TextStyle samiBold18Text = commonSamiBold.copyWith(fontSize: fontSize18);

// bold
TextStyle commonBold = TextStyle(
    color: ColorsR.ColorPalette.ivoryBlack,
    fontWeight: FontWeight.w700);

TextStyle bold12Text = commonBold.copyWith(fontSize: fontSize12);
TextStyle bold14Text = commonBold.copyWith(fontSize: fontSize14);
TextStyle bold16Text = commonBold.copyWith(fontSize: fontSize16);
TextStyle bold18Text = commonBold.copyWith(fontSize: fontSize18);
TextStyle bold20Text = commonBold.copyWith(fontSize: fontSize20);

////////// PROFILE  LIGHT
const TextStyle lightGrey_16 = TextStyle(
  color: ColorsR.kcLightGreyColor,
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

TextStyle lightGrey_14 = TextStyle(
  color: ColorsR.kcLightGreyColor,
  fontSize: 12,
  fontWeight: FontWeight.w500,
);

const bottomRoundCorner = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
      bottomRight: Radius.circular(32), bottomLeft: Radius.circular(32)),
);

InputDecoration  searchInputDecoration = InputDecoration(
    border: InputBorder.none,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelText: "Options",
    alignLabelWithHint: true,
    hintText: "Type here",
    labelStyle: TextStyle(color: Colors.grey));