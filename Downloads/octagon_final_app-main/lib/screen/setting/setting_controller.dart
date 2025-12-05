import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octagon/screen/login/login_controller.dart';
import 'package:octagon/screen/profile/ProfileController.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/widgets/block_user_screen.dart';
import 'package:share_plus/share_plus.dart';
import '../../main.dart';
import '../../networking/model/response_model/SportInfoModel.dart';
import '../../networking/model/user_response_model.dart';

import '../../screen/edit_profile/edit_profile.dart';
import '../../screen/login/login_screen.dart';
import '../../screen/login/reset_pasaword_screen.dart';
import '../../screen/setting/your_groups_screen.dart';
import '../../screen/sport /sport_selection_screen.dart';
import '../../screen/tabs_screen.dart';
import '../../widgets/webview_screen.dart';
import '../../utils/constants.dart';
import '../../utils/string.dart';
import '../../utils/analiytics.dart';

class SettingController extends GetxController {
  List<Widget> accountMenu = [];
  List<Widget> groupMenu = [];
  List<Widget> teamMenu = [];
  List<Widget> contentMenu = [];
  List<Widget> cacheMenu = [];
  List<Widget> aboutMenu = [];
  List<Sports> sportDataList = [];

  final BuildContext context;
  final dynamic profileData;

  SettingController(this.context, this.profileData);

  @override
  void onInit() {
    super.onInit();
    _loadSportsData();
    _buildMenuLists();
    publishAmplitudeEvent(eventType: 'Setting $kScreenView');
  }

  void _loadSportsData() {
    final data = storage.read(sportInfo);
    if (data != null) {
      (data as List).forEach((element) {
        final value = SportInfo.fromJson(element);
        sportDataList.add(Sports(
          value.strSport ?? '',
          value.id!.toInt(),
          value.idSport!.toInt(),
          value.strSportThumb.toString(),
          selected: true,
        ));
      });
    }
  }

  void _buildMenuLists() {
    accountMenu = [
      _menuTile(Icons.person, "Edit Profile", () {
        Get.to(() => EditProfileScreen(profileData: profileData?.success?.user, update: (data) {}));
      }),
      _menuTile(Icons.password_outlined, "Reset Password", () => Get.to(() => ResetPassScreen())),
      _menuTile(Icons.delete, "Delete account", () => _showDeleteDialog(() {})),
    ];

    groupMenu = [
      _menuTile(Icons.groups, "Your Groups", () => Get.to(() => YourGroupsScreen())),
    ];

    teamMenu = [
      _menuTile(Icons.person, "Teams", () {
        Get.to(() => SportSelection(sportDataList: sportDataList, isUpdate: true));
      }),
    ];

    contentMenu = [
      _menuTile(Icons.notifications, "Notification", () => Get.to(() => TabScreen(selectedPage: 2))),
      _menuTile(Icons.near_me_rounded, "Share", () {
        Share.share('My Favourite app for sports https://octagonapp.com/app-download');
      }),
      _menuTile(Icons.person_off, "Blocked Users", () => Get.to(() => BlockUserListScreen())),
    ];

    cacheMenu = [
      _menuTile(Icons.delete_rounded, "Clear Cache", () {
        _showForgetMeDialog("This will clear local cache memory!", () {});
      }),
    ];

    aboutMenu = [
      _menuTile(Icons.contact_support_rounded, "Contact Us", () {
        Get.to(() => WebViewScreen(screenName: "Contact Us", url: contactUsUrl));
      }),
      _menuTile(Icons.lock, "Privacy Policy", () {
        Get.to(() => WebViewScreen(screenName: "Privacy Policy", url: privacyPolicyURL));
      }),
    ];
  }

  Widget _menuTile(IconData icon, String label, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // color: purpleColor,
          color: Color(0xFF2D2244),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white))),
            const Icon(Icons.arrow_forward_ios_sharp, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  void _showForgetMeDialog(String title, Function() onYes) {
    Get.defaultDialog(
      title: "Octagon",
      middleText: title,
      textCancel: "No",
      textConfirm: "Yes",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        onYes();
      },
    );
  }

  void _showDeleteDialog(Function() onDelete) {
    Get.defaultDialog(
      title: "Are you sure?",
      middleText: "This will delete your account permanently.",
      textCancel: "No",
      textConfirm: "Yes",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        onDelete();
      },
    );
  }

  void logout() {
    _showForgetMeDialog("Are you sure you want to logout?", () async {
      // Clear profile data first
      try {
        final profileController = Get.find<ProfileController>();
        profileController.clearUserData();
      } catch (e) {
        // ProfileController might not exist, which is fine
      }

      // Save the current FCM token before erasing storage
      final fcmToken = storage.read("fcmToken");
      await storage.erase();
      if (fcmToken != null) {
        await storage.write("fcmToken", fcmToken);
      }
      Get.offAll(() => LoginScreen());
    });
  }
}
