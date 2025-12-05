import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/theme/theme_constants.dart';
import 'apple_signin_out.dart';
import 'common_text_style.dart';
import 'google_sign_in.dart';

class CommonLoginButton extends StatefulWidget {
  Function(UserCredential?) googlePress;
  // Function facebookPress;
  Function(AuthorizationCredentialAppleID?) applePress;
  bool isLogin = false;
  CommonLoginButton(
      {super.key,
      required this.applePress,
      /*required this.facebookPress,*/ required this.googlePress,
      this.isLogin = false});

  @override
  State<CommonLoginButton> createState() => _CommonLoginButtonState();
}

class _CommonLoginButtonState extends State<CommonLoginButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 1.5.h),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  margin: EdgeInsets.only(right: 2.w),
                  width: 23.5.w,
                  height: 0.70.w,
                  color: widget.isLogin ? whiteColor : Colors.amber //dark,
                  ),
              Text("OR CONTINUE WITH",
                  style: getNormalFontStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: widget.isLogin ? whiteColor : Colors.amber // dark,
                      )),
              Container(
                  margin: EdgeInsets.only(left: 2.w),
                  width: 23.5.w,
                  height: 0.70.w,
                  color: widget.isLogin ? whiteColor : Colors.amber //dark,
                  ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () async {
                  try {
                    final userCredential = await signInWithGoogle();
                    print(
                        "CommonLoginButton - Google sign-in result: $userCredential");
                    widget.googlePress.call(userCredential);
                  } catch (e) {
                    print("CommonLoginButton - Google sign-in error: $e");
                    widget.googlePress.call(null);
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  width: 28.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Image.asset("assets/ic/ic_google.png"),
                ),
              ),
              // GestureDetector(
              //   onTap: (){
              //
              //     // showToast(msg: "Coming soon..");
              //     signInWithFacebook().then((user) {
              //       widget.facebookPress.call(user);
              //     });
              //   },
              //   child: Container(
              //     padding: EdgeInsets.all(6.w),
              //     width: 28.w,
              //     height: 16.w,
              //     decoration: BoxDecoration(
              //         color: fbBlueColor, borderRadius: BorderRadius.circular(10)),
              //     child: Image.asset("assets/icons/ic_facebook.png"),
              //   ),
              // ),
              if (Platform.isIOS)
                GestureDetector(
                  onTap: () {
                    signInWithApple().then((user) {
                      widget.applePress.call(user);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    width: 28.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10)),
                    child: Image.asset("assets/ic/ic_apple.png"),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}
