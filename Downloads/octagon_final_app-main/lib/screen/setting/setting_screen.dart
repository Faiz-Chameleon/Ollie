import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import '../../model/user_profile_response.dart';
import '../../utils/constants.dart';
import 'setting_controller.dart';

class SettingScreen extends StatelessWidget {
  final UserProfileResponseModel? profileData;

  const SettingScreen({super.key, this.profileData});

  @override
  Widget build(BuildContext context) {
    final SettingController controller =
        Get.put(SettingController(context, profileData));

    return Scaffold(
      backgroundColor: appBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _section("Account", controller.accountMenu),
                const SizedBox(height: 25),
                _section("Groups", controller.groupMenu),
                // const SizedBox(height: 25),
                // _section("Teams", controller.teamMenu),
                const SizedBox(height: 25),
                _section("Content", controller.contentMenu),
                const SizedBox(height: 25),
                _section("Cache", controller.cacheMenu),
                const SizedBox(height: 25),
                _section("About", controller.aboutMenu),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: controller.logout,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                      child:
                          Text("Logout", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Octagon 0.0.1/Build 1.0.0",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.close, size: 36, color: Colors.transparent),
        const Text(
          "Setting",
          style: TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.close, size: 36, color: Colors.white),
        ),
      ],
    );
  }

  Widget _section(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            // color: Color(0xFF2D2244),
            // color: purpleColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(spacing: 10, children: items),
          ),
        ),
      ],
    );
  }
}
