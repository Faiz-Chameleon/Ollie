import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octagon/main.dart';
import 'package:octagon/model/update_profile_response_model.dart';
import 'package:octagon/networking/model/resource.dart';
import 'package:octagon/networking/model/response_model/login_response_model.dart';
import 'package:octagon/networking/model/response_model/register_response_model.dart';

import 'package:octagon/networking/model/user_response_model.dart';

import 'package:octagon/networking/network.dart';
import 'package:octagon/screen/edit_profile/edit_profile.dart';
import 'package:octagon/screen/login/login_controller.dart';
import 'package:octagon/screen/sport%20/sport_selection_screen.dart';
import 'package:octagon/screen/tabs_screen.dart';
import 'package:octagon/screen/term_selection/team_selection.dart';
import 'package:octagon/utils/analiytics.dart';
import 'package:octagon/utils/constants.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  RxString selectedProfile = 'personal'.obs;
  onChangedProfile(String value) {
    selectedProfile.value = value;
  }

  var loginData = Rxn<LoginResponseModel>();
  var otpVerifyData = Rxn<LoginResponseModel>();
  var registerData = Rxn<RegisterResponseModel>();
  var profileData = Rxn<UpdateProfileResponseModel>();
  var apiResult = Rxn<dynamic>();
  void handleSocialLogin({String? email, required String socialId}) async {
    final fcmToken = storage.read("fcm_token") ?? "";

    print("Attempting social login with email: $email, socialId: $socialId");

    final response = await socialAuth(
      email: email,
      socialId: socialId,
      fcmToken: fcmToken,
    );

    final data = response.data;
    if (data == null || data.success == null) {
      print("Social auth failed: ${response.error}");

      // If social auth fails and we have an email, suggest regular login
      if (email != null) {
        Get.snackbar(
          "Social Login Not Available",
          "Please use email/password login instead",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          "Login Failed",
          "Please try again or contact support",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return;
    }

    final success = data.success!;
    storage.write("current_uid", success.userId);
    storage.write('token', success.token ?? '');
    storage.write('country', success.country ?? '');
    storage.write('user_name', success.name ?? '');
    if (success.bio != null) storage.write('bio', success.bio!);
    storage.write('image_url', success.photo ?? '');
    storage.write('email', success.email ?? '');
    storage.write(userData, success.toJson());

    setAmplitudeUserProperties();

    if (success.name == null) {
      // Social login registration flow
      Get.off(() => EditProfileScreen(
            profileData: UserModel(email: success.email ?? ""),
            isUpdate: false,
            update: (_) {},
          ));
      return;
    }

    // Handle sport info cases
    final sports = success.sportInfo ?? [];

    if (sports.isEmpty || (sports.first.team?.isEmpty ?? true)) {
      if (sports.isEmpty) {
        Get.to(() => SportSelection());
      } else {
        final sportDataList = sports.map((s) {
          return Sports(s.strSport!, s.id!, s.idSport!, s.strSportThumb!, selected: true);
        }).toList();
        Get.to(() => TeamSelectionScreen(sportDataList));
      }
    } else {
      storage.write('userDefaultTeam', sports.first.team!.first.strTeamLogo ?? '');
      storage.write('userDefaultTeamName', sports.first.team!.first.toJson());
      storage.write('sportInfo', sports.map((e) => e.toJson()).toList());

      Get.snackbar("Octagon", "You logged in as ${success.name}");
      Get.offAll(() => TabScreen());
    }
  }

  Future<Resource<LoginResponseModel>> loginUser({
    required String email,
    required String password,
    required String fcmToken,
  }) async {
    isLoading.value = true;
    try {
      final body = {
        "email": email,
        "password": password,
        "fcm_token": fcmToken,
      };

      final result = await NetworkAPICall().multiPartPostRequest(
        loginApiUrl,
        body,
        false,
        "POST",
      );

      final model = LoginResponseModel.fromJson(result);
      loginData.value = model;

      return Resource(data: model);
    } catch (e) {
      return Resource(error: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<Resource<LoginResponseModel>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    isLoading.value = true;
    try {
      final body = {
        "email": email,
        "otp": otp,
        "fcm_token": storage.read("fcm_token"),
      };

      final result = await NetworkAPICall().multiPartPostRequest(
        otpVerifyApiUrl,
        body,
        false,
        "POST",
      );

      final model = LoginResponseModel.fromJson(result);
      otpVerifyData.value = model;

      return Resource(data: model);
    } catch (e) {
      return Resource(error: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<Resource<dynamic>> resendOtp({required String email}) async {
    isLoading.value = true;
    try {
      final result = await NetworkAPICall().multiPartPostRequest(
        resendOtpApiUrl,
        {"email": email},
        false,
        "POST",
      );
      apiResult.value = result;
      return Resource(data: result);
    } catch (e) {
      return Resource(error: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<Resource<dynamic>> forgetPassword({required String email}) async {
    isLoading.value = true;
    try {
      final result = await NetworkAPICall().multiPartPostRequest(
        forgetPasswordApiUrl,
        {"email": email},
        false,
        "POST",
      );
      apiResult.value = result;
      return Resource(data: result);
    } catch (e) {
      return Resource(error: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required int userType,
    required String mobile,
    required String password,
    required String cPassword,
    required String country,
    required String gender,
    required VoidCallback onSuccess,
    required Function(String message) onError,
  }) async {
    isLoading.value = true;
    try {
      final body = {
        "name": name,
        "email": email,
        "user_type": userType,
        "mobile": mobile,
        "password": password,
        "c_password": cPassword,
        "country": country,
        "gender": 0,
      };

      final result = await NetworkAPICall().multiPartPostRequest(
        registerApiUrl,
        body,
        false,
        "POST",
      );

      final model = RegisterResponseModel.fromJson(result);
      registerData.value = model;

      if (model.error != null) {
        onError(model.error!);
      } else {
        storage.write('token', model.success?.token ?? '');
        onSuccess();
      }
    } catch (e) {
      onError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<Resource<UpdateProfileResponseModel>> editProfile({
    required String name,
    required String dob,
    required String profilePic,
    String? bgPic,
    required String country,
    required String bio,
  }) async {
    isLoading.value = true;
    try {
      final body = {
        "name": name,
        "dob": dob,
        "profilePic": profilePic,
        "country": country,
        "bio": bio,
      };
      if (bgPic != null) {
        body["bgPic"] = bgPic;
      }

      final result = await NetworkAPICall().editProfileApi(
        profileUpdateUrl,
        body,
        true,
        "POST",
      );

      final model = UpdateProfileResponseModel.fromJson(result);
      profileData.value = model;
      return Resource(data: model);
    } catch (e) {
      return Resource(error: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<Resource<LoginResponseModel>> socialAuth({
    String? socialId,
    String? email,
    String? fcmToken,
  }) async {
    isLoading.value = true;
    try {
      // Try different approaches based on what the backend supports
      Map<String, dynamic> body = {
        if (email != null) "email": email,
        if (fcmToken != null) "fcm_token": fcmToken,
      };

      // Only add social_id if it's a real social ID (not manual fallback)
      if (socialId != null && !socialId.startsWith('manual_')) {
        body["social_id"] = socialId;
      }

      print("Social auth request body: $body");

      final result = await NetworkAPICall().multiPartPostRequest(
        socialAuthUrl,
        body,
        false,
        "POST",
      );

      final model = LoginResponseModel.fromJson(result);
      loginData.value = model;
      return Resource(data: model);
    } catch (e) {
      print("Social auth error: $e");
      return Resource(error: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
