import 'package:get/get.dart';
import 'package:octagon/model/user_data_model.dart';

import 'package:octagon/screen/edit_profile/edit_profile_repo.dart';

class UserController extends GetxController {
  final EditProfileRepo repo = EditProfileRepo();
  var user = Rxn<Users>();
  var isLoading = false.obs;
  var isUpdating = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;
  var hasLoaded = false.obs;

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

  String? get userType => user.value?.userType;
}
