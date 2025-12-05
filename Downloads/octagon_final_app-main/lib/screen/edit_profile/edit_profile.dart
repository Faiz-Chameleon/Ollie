import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:octagon/main.dart';
import 'package:octagon/screen/login/auth_controller.dart';
import 'package:octagon/screen/login/bloc/login_bloc.dart';
import 'package:octagon/screen/login/bloc/login_event.dart';
import 'package:octagon/screen/login/bloc/login_state.dart';
import 'package:octagon/utils/analiytics.dart';
import 'package:octagon/utils/polygon/polygon_border.dart';
import 'package:octagon/utils/string.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/toast_utils.dart';
import 'package:octagon/widgets/filled_button_widget.dart';
import 'package:octagon/widgets/text_formbox_widget.dart';
import 'package:octagon/utils/colors.dart' as ColorR;
import 'package:octagon/utils/styles.dart' as StylesR;
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../networking/model/user_response_model.dart';
import '../../utils/common_image_view.dart';
import '../../utils/constants.dart';
import '../sport /sport_selection_screen.dart';
import '../../model/user_data_model.dart';
import 'edit_profile_repo.dart';
import 'edit_profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  UserModel? profileData;
  Function(UserModel) update;

  bool isUpdate = true;

  EditProfileScreen({Key? key, required this.update, this.profileData, this.isUpdate = true}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  AutovalidateMode isValidate = AutovalidateMode.disabled;

  final ImagePicker _picker = ImagePicker();
  String profilePhoto = "";
  bool isLocalImage = false;
  String bgPhoto = "";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  final controller = Get.put(AuthController());

  Country? selectedCountry;

  final EditProfileController editProfileController = Get.put(EditProfileController());
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      // Populate with existing data if available
      _populateControllersWithExistingData();
      // Use post-frame callback to avoid build-time state changes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        editProfileController.fetchUserDetails(storage.read('current_uid').toString(), storage.read('token'));
      });
    }
  }

  void _populateControllersWithExistingData() {
    if (widget.profileData != null) {
      _nameController.text = widget.profileData!.name?.toString() ?? '';
      _emailController.text = widget.profileData!.email?.toString() ?? '';
      _bioController.text = widget.profileData!.bio?.toString() ?? '';
      _dobController.text = widget.profileData!.dob?.toString() ?? '';
      _countryController.text = widget.profileData!.country?.toString() ?? '';
      if (widget.profileData!.photo != null && widget.profileData!.photo!.isNotEmpty) {
        profilePhoto = widget.profileData!.photo!;
      }
    }
  }

  void _populateControllersWithApiData(Users userData) {
    _nameController.text = userData.name ?? '';
    _emailController.text = userData.email ?? '';
    _bioController.text = userData.bio ?? '';
    _dobController.text = userData.dob ?? '';
    _countryController.text = userData.country ?? '';
    if (userData.photo != null && userData.photo!.isNotEmpty) {
      profilePhoto = userData.photo!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: appBgColor,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: appBgColor,
          appBar: AppBar(
            leading: widget.isUpdate
                ? InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  )
                : null,
            elevation: 0,
            centerTitle: true,
            backgroundColor: appBgColor,
            title: Text(
              widget.isUpdate ? "Edit Profile" : "Profile Details",
              style: whiteColor20BoldTextStyle,
            ),
          ),
          body: Obx(() {
            final isLoading = editProfileController.isLoading.value;
            final userData = editProfileController.user.value;
            final isUpdating = editProfileController.isUpdating.value;

            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            // Handle initial data loading
            if (userData != null && !isUpdating) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _populateControllersWithApiData(userData);
                editProfileController.user.value = null; // Clear to prevent re-population
              });
            }

            // Handle successful update
            if (userData != null && isUpdating) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleSuccessfulUpdate(userData);
              });
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text("", style: whiteColor24BoldTextStyle),
                      widget.profileData!.userType == "2" ? SizedBox.shrink() : Text("Select your profile photo.", style: greyColor12TextStyle),
                      widget.profileData!.userType == "2"
                          ? SizedBox.shrink()
                          : Container(
                              height: 150,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: GestureDetector(
                                onTap: () {
                                  editProfileController.pickPhoto();
                                },
                                child: buildProfileWidget(),
                              ),
                            ),
                      const SizedBox(height: 30),
                      Form(
                        autovalidateMode: isValidate,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            TextFormBox(
                              textEditingController: _emailController,
                              hintText: "Email",
                              isMaxLengthEnable: true,
                              maxCharcter: 40,
                              isEnable: !widget.isUpdate,
                              suffixIcon: const Icon(Icons.email_outlined, color: Colors.white, size: 20),
                            ),
                            widget.profileData!.userType == "2" ? SizedBox.shrink() : const SizedBox(height: 20),
                            widget.profileData!.userType == "2"
                                ? SizedBox.shrink()
                                : TextFormBox(
                                    textEditingController: _nameController,
                                    hintText: "Name",
                                    isMaxLengthEnable: true,
                                    maxCharcter: 40,
                                    suffixIcon: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
                                  ),
                            widget.profileData!.userType == "2" ? SizedBox.shrink() : const SizedBox(height: 20),
                            widget.profileData!.userType == "2"
                                ? SizedBox.shrink()
                                : TextFormBox(
                                    textEditingController: _bioController,
                                    hintText: "Bio",
                                    maxCharcter: 150,
                                    isMaxLengthEnable: true,
                                    suffixIcon: const Icon(Icons.description, color: Colors.white, size: 20),
                                  ),
                            const SizedBox(height: 20),
                            TextFormBox(
                              textEditingController: _dobController,
                              hintText: "DOB",
                              isEnable: false,
                              onClick: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now().subtract(const Duration(days: 2555)),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now().subtract(const Duration(days: 2555)),
                                ).then((value) {
                                  if (value != null) {
                                    _dobController.text = "${value.month}/${value.day}/${value.year}";
                                  }
                                });
                              },
                              suffixIcon: const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 20),
                            ),
                            const SizedBox(height: 20),
                            TextFormBox(
                              textEditingController: _countryController,
                              hintText: "Country",
                              isEnable: false,
                              onClick: () {
                                showCountryPicker(
                                  context: context,
                                  showPhoneCode: true,
                                  onSelect: (Country country) {
                                    _countryController.text = country.name;
                                    selectedCountry = country;
                                  },
                                );
                              },
                              suffixIcon: const Icon(Icons.place_outlined, color: Colors.white, size: 20),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      FilledButtonWidget(widget.isUpdate ? "Update Profile" : "Save Profile", () async {
                        showLoader(context);
                        await editProfileController.updateProfile(
                          storage.read('token'),
                          {
                            'name': _nameController.text.trim(),
                            'dob': _dobController.text.trim(),
                            'bio': _bioController.text.trim(),
                            'country': _countryController.text.trim(),
                          },
                        );
                        // After update, if user data is available, update UI and local state
                        if (editProfileController.user.value != null) {
                          _handleSuccessfulUpdate(editProfileController.user.value!);
                        }
                        stopLoader(context);
                      }, 1),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void showImagePicker(context, {Function(ImageSource imageSource)? onImageSelection}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: ColorR.kcBackground,
              border: Border.all(
                color: ColorR.kcLightGreyColor,
                width: 1.0,
              ),
            ),
            child: Wrap(
              children: <Widget>[
                Column(),
                ListTile(
                    leading: Icon(Icons.photo_library, color: ColorR.kcTealColor),
                    title: Text(
                      "Picker Gallery",
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.normal, fontWeight: FontWeight.normal, color: ColorR.kcIvoryBlackColor),
                    ),
                    onTap: () {
                      onImageSelection?.call(ImageSource.gallery);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: new Icon(Icons.photo_camera, color: ColorR.kcTealColor),
                  title: Text("Picker Camera", style: StylesR.kTextStyleRestaurantInfoTitle),
                  onTap: () {
                    onImageSelection?.call(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                StylesR.verticalSpaceMedium,
                ListTile(
                  title: Text(
                    "Cancel",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.normal, fontWeight: FontWeight.normal, color: ColorR.kcIvoryBlackColor),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  buildProfileWidget() {
    return GetBuilder<EditProfileController>(
      builder: (controller) {
        if (controller.photoFile != null) {
          return Container(
            height: 150,
            width: 150,
            decoration: const ShapeDecoration(
              shape: PolygonBorder(
                sides: 8,
                rotate: 68,
                side: BorderSide(
                  color: Colors.blue,
                ),
              ),
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: Image.file(
              controller.photoFile!,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              width: 150,
              height: 150,
            ),
          );
        } else {
          return Container(
            height: 150,
            width: 150,
            decoration: const ShapeDecoration(
              shape: PolygonBorder(
                sides: 8,
                rotate: 68,
                side: BorderSide(
                  color: Colors.blue,
                ),
              ),
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: ImageViewWidget(
              image: widget.profileData?.photo ?? "https://uifaces.co/our-content/donated/3799Ffxy.jpeg",
            ),
          );
        }
      },
    );
  }

  bool checkIsEmpty() {
    if (widget.profileData != null && widget.profileData?.photo != null && widget.profileData!.photo!.isNotEmpty) {
      return true;
    }
    return false;
  }

  void _handleSuccessfulUpdate(Users updateData) {
    if (updateData.country != null) storage.write('country', updateData.country!);
    if (updateData.name != null) storage.write('user_name', updateData.name!);
    if (updateData.bio != null) storage.write('bio', updateData.bio!);
    if (updateData.photo != null) storage.write('image_url', updateData.photo!);
    if (updateData.email != null) storage.write('email', updateData.email!);

    setAmplitudeUserProperties();

    if (widget.profileData != null) {
      if (updateData.name != null) widget.profileData!.name = updateData.name!;
      if (updateData.photo != null) widget.profileData!.photo = updateData.photo!;
      if (updateData.bio != null) widget.profileData!.bio = updateData.bio!;
      if (updateData.dob != null) widget.profileData!.dob = updateData.dob!;
      if (updateData.country != null) widget.profileData!.country = updateData.country!;
      widget.update.call(widget.profileData!);
    }

    editProfileController.user.value = null;

    Future.delayed(Duration.zero, () {
      stopLoader(context);
      if (widget.isUpdate) {
        showToast(message: "Your profile has been updated successfully!");
        Navigator.pop(context);
      } else {
        showToast(message: "Your profile has been saved successfully!");
        Get.to(() => SportSelection());
      }
    });
  }
}
