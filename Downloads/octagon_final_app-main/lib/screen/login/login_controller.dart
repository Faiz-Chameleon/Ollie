import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:octagon/main.dart';

import 'package:octagon/screen/sport%20/sport_selection_screen.dart';
import 'package:octagon/screen/tabs_screen.dart';
import 'package:octagon/screen/term_selection/team_selection.dart';
import 'package:octagon/utils/constants.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final emailController = TextEditingController();

  final sportsList = <Sports>[].obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // void handleNavigation(Success user) {
  //   final sports = user.sportInfo;
  //   if (sports == null || sports.isEmpty || sports.first.team?.isEmpty == true) {
  //     if (sports?.isEmpty ?? true) {
  //       Get.to(() => SportSelection());
  //     } else {
  //       sportsList.clear();
  //       for (var s in sports!) {
  //         sportsList.add(Sports(s.strSport!, s.id!, s.idSport!, s.strSportThumb!, selected: true));
  //       }
  //       Get.to(() => TeamSelectionScreen(sportsList));
  //     }
  //   } else {
  //     storage.write('userDefaultTeam', sports.first.team!.first.strTeamLogo);
  //     storage.write('userDefaultTeamName', sports.first.team!.first.toJson());
  //     storage.write(sportInfo, sports.map((e) => e.toJson()).toList());
  //     Get.snackbar("Octagon", "You logged in as ${user.name}");
  //     Get.offAll(() => TabScreen());
  //   }
  // }

  void loginUser() async {
    if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }
    isLoading.value = true;

    // Simulate login
    await Future.delayed(Duration(seconds: 2));
    isLoading.value = false;
    Get.offAllNamed('/home');
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class Sports {
  bool selected;
  String sportsName;
  int sportsId;
  int sportApiId;
  String sportsImage;

  Sports(this.sportsName, this.sportsId, this.sportApiId, this.sportsImage, {this.selected = false});
}
