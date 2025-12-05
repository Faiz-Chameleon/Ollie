import 'package:flutter/material.dart';
import 'package:octagon/main.dart';

const String AppName = "Octagon";

const String RESET = "Reset Password";

///api url

///dev
// const String baseUrl = "http://54.159.252.38/api/";
///prod
const String baseUrl = "http://3.134.119.154/api/";
const String getUserDetailsUrl = "user-details";
const String getOtherUserDetailsUrl = "user-profile";

///other user details
const String socketUrl = "http://3.134.119.154:2024";

const String registerApiUrl = "register";
const String loginApiUrl = "login";
const String forgetPasswordApiUrl = "forgot-password";
const String otpVerifyApiUrl = "otp-verify";
const String resendOtpApiUrl = "otp-create";
const String resetPasswordApiUrl = "reset-password";
const String sportListApiUrl = "sport-list";
const String teamListApiUrl = "team-list";
const String saveUserSportsApiUrl = "save-user-sports";
const String saveUserTeamsApiUrl = "save-user-teams";
const String getUserPostApiUrl = "get-user-posts";
const String getSavePostApiUrl = "get-save-post";
const String getUserLikePostApiUrl = "get-like-posts";
const String likeUserPostApiUrl = "save-likes";
const String saveUserPostApiUrl = "save-post";

///save to collection
const String userRemoveApiUrl = "user-remove";
const String reportUserPostApiUrl = "save-post-report";

const String createPostApiUrl = "save-user-post";

///create post
const String deletePostApiUrl = "delete-user-post";

///delete post

const String uploadFileApiUrl = "user-upload-file";

const String deleteCommentApiUrl = "delete-user-comment";

///delete comment

const String followUserApiUrl = "set-user-followers";

///follow unfollow
const String removeFollowerUrl = "remove-following";
const String getTrendingListApiUrl = "get-tranding-list";
const String getPostDetailsApiUrl = "get-post-details";
const String addCommentApiUrl = "save-user-comment";
const String notificationUrl = "notification-list";
const String profileUpdateUrl = "user-update";
const String socialAuthUrl = "social-auth";

const String userBlockUrl = "user-block";
const String userUnBlockUrl = "user-unblock";
const String blockUserListUrl = "user-block-list";

const String saveUserFavoriteApiUrl = "save-post-favorite"; // missing
const String getUserFavoriteApiUrl = "get-post-favorite"; // missing
const String getUserCommentApiUrl = "get-user-comment"; // optional if used
const String editUserPostApiUrl = "edit-user-post"; // optional if used

///pref
const String sportInfo = "sportInfo";
const String userData = "user_data";

///webview URLs
const String privacyPolicyURL = "https://termify.io/privacy-policy/WfTM1ohKVF";
const String contactUsUrl = "https://form.jotform.com/230652878720461";
const String termsAndConditionURL = "https://termify.io/terms-and-conditions/FNwDnP0vr3";

/// validation
RegExp emailValidReg = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$');

getUserToken() {
  return storage.read("token");
}

void onLoading(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: false,
    barrierLabel: "Dialog",
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      return const Center(
          child: CircularProgressIndicator(
        color: Colors.white,
      ));
    },
  );
}

void stopLoader(BuildContext context) {
  Navigator.pop(context);
}

void showLoader(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(color: Colors.white),
    ),
  );
}

void closeKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}
