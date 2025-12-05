import 'package:flutter/material.dart';
import 'package:octagon/utils/colors.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:sizer/sizer.dart';

void showCustomLoadingDialog({required BuildContext context}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 0.4.sh, horizontal: 0.1.sw),
          height: 20.sh,
          width: 80.sw,
          decoration: BoxDecoration(
              color: kcWhiteColor, borderRadius: BorderRadius.circular(10)),
          child: Center(
              child: CircularProgressIndicator.adaptive(
                  backgroundColor: purpleColor)),
        ),
      );
    },
  );
}
