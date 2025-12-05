import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

TextStyle getNormalFontStyle({double? fontSize, Color color = Colors.white,FontWeight fontWeight = FontWeight.normal }){
  return GoogleFonts.overpass(
      fontSize: fontSize ?? 12.sp,
      color: color,
      fontWeight:fontWeight,
  );
}

getUnderLineFontStyle({double? fontSize, Color color = Colors.white,FontWeight fontWeight = FontWeight.normal }){
  return GoogleFonts.overpass(
    fontSize: fontSize ?? 12.sp,
    color: color,
    // decorationColor: blueColor,
    decoration: TextDecoration.underline,
    fontWeight:fontWeight,
  );
}

getMediumFontStyle({double? fontSize, Color color = Colors.white,FontWeight fontWeight = FontWeight.w500 }){
  return GoogleFonts.overpass(
    fontSize: fontSize ?? 12.sp,
    color: color,
    fontWeight:fontWeight,
  );
}

getSemiBoldFontStyle({double? fontSize, Color color = Colors.white,FontWeight fontWeight = FontWeight.bold }){
  return GoogleFonts.overpass(
    fontSize: fontSize ?? 12.sp,
    color: color,
    fontWeight:fontWeight,
  );
}