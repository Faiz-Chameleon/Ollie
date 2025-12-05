import 'package:flutter/material.dart';
import 'package:octagon/utils/theme/theme_constants.dart';

class FollowButton extends StatelessWidget {
  final Function()? onClick;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? text;
  final TextStyle? textStyle;
  FollowButton({
    Key? key,
     this.backgroundColor,
     this.borderColor,
     this.text,
     this.textStyle,
    this.onClick
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onClick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: backgroundColor ?? purpleColor,
          borderRadius: BorderRadius.circular(5),
        ),
        alignment: Alignment.center,
        //width: 61,
        height: 21,
        child: Text(
          text!,
          style: textStyle ?? whiteColor14BoldTextStyle,
        ),
      ),
    );
  }
}