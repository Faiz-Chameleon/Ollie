import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/user_data_model.dart';
import '../../model/edit_profile_response_model.dart';
import 'edit_profile_repo.dart';

class EditProfileController extends GetxController {
  final EditProfileRepo repo = EditProfileRepo();
  var isLoading = false.obs;
  var isUpdating = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;
  var user = Rxn<Users>();
  var editProfileResponse = Rxn<EditProfileResponseModel>();
  final ImagePicker picker = ImagePicker();
  File? photoFile;
  File? backgroundFile;

  Future<void> fetchUserDetails(String userId, String token) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';
    try {
      user.value = (await repo.fetchUserDetails(userId, token)) as Users?;
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(String token, Map<String, String> fields) async {
    isUpdating.value = true;
    errorMessage.value = '';
    successMessage.value = '';
    try {
      final response = await repo.updateProfile(token, fields,
          photoFile: photoFile, backgroundFile: backgroundFile);
      editProfileResponse.value = response;
      user.value = response.user;
      successMessage.value = 'Profile updated successfully!';
      photoFile = null;
      update();

      Get.snackbar(
        'Success',
        successMessage.value,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      Get.back();
    } catch (e) {
      errorMessage.value = 'Error: $e';

      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> pickPhoto() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      photoFile = File(picked.path);
      update();
    }
  }

  Future<void> pickBackground() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      backgroundFile = File(picked.path);
      update();
    }
  }
}
