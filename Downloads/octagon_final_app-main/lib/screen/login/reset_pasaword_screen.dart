import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octagon/screen/login/auth_controller.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/widgets/filled_button_widget.dart';
import 'package:octagon/widgets/text_formbox_widget.dart';

class ResetPassScreen extends StatefulWidget {
  // final ThemeNotifier? model;
  const ResetPassScreen(/*this.model,*/ {Key? key}) : super(key: key);

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  AutovalidateMode isValidate = AutovalidateMode.disabled;
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmNewPassController = TextEditingController();
  late final AuthController _authController;
  //late ResetPasswordBloc resetPasswordBloc;

  @override
  void initState() {
    super.initState();
    _authController = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : Get.put(AuthController());
    // resetPasswordBloc = ResetPasswordBloc();
    // resetPasswordBloc.loginStream.listen((event) {
    //   switch (event.status) {
    //     case Status.LOADING:
    //       break;
    //     case Status.COMPLETED:
    //       showToast(message: "Your password is reset now!");
    //       Navigator.pop(context);
    //       // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
    //       //     builder: (context) => LoginScreen(/*widget.model*/)), (route) => false,);
    //       break;
    //     case Status.ERROR:
    //       print(Status.ERROR);
    //       break;
    //   }
    // });
    // super.initState();
    //
    // publishAmplitudeEvent(eventType: 'Reset Password $kScreenView');
  }

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmNewPassController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final newPassword = _newPassController.text.trim();
    final confirmPassword = _confirmNewPassController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty || confirmPassword.length < 5) {
      Get.snackbar(AppName, "Please enter valid Password!");
      return;
    }
    if (confirmPassword != newPassword) {
      Get.snackbar("new Password", "password not Matched");
      return;
    }

    final result = await _authController.resetPassword(password: newPassword);
    final response = result.data;

    if (response != null) {
      final message =
          response is Map<String, dynamic> && response["success"] != null ? response["success"].toString() : "Your password is reset now!";
      Get.snackbar(AppName, message);
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    Get.snackbar(AppName, result.error ?? "Something went wrong, Please try again later");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        title: Text(
          "Reset password",
          style: whiteColor20BoldTextStyle,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                // Text("Reset password", style: whiteColor24BoldTextStyle,),
                Text(
                  "Please type-in a new password",
                  style: greyColor12TextStyle,
                ),
                const SizedBox(
                  height: 50,
                ),
                Form(
                  autovalidateMode: isValidate,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormBox(
                        textEditingController: _newPassController,
                        hintText: "New password",
                        passwordVisible: 1,
                        suffixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: whiteColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormBox(
                        textEditingController: _confirmNewPassController,
                        hintText: "Confirm password",
                        passwordVisible: 1,
                        suffixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: whiteColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 40,
                ),

                Obx(
                  () => FilledButtonWidget(
                    isLoading: _authController.isLoading.value,
                    /*widget.model, */ "Reset",
                    _resetPassword,
                    1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
