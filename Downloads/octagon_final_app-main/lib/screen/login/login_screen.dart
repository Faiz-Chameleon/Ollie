import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:octagon/main.dart';
import 'package:octagon/networking/model/response_model/login_response_model.dart';
import 'package:octagon/screen/login/auth_controller.dart';
import 'package:octagon/screen/login/bloc/login_bloc.dart';
import 'package:octagon/screen/login/bloc/login_event.dart';
import 'package:octagon/screen/login/bloc/login_state.dart';
import 'package:octagon/screen/login/login_controller.dart';
import 'package:octagon/screen/login/mobile_number_screen.dart';
import 'package:octagon/screen/login/otp_screen.dart';
import 'package:octagon/screen/sign_up/sign_up_screen.dart';
import 'package:octagon/utils/analiytics.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/string.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/toast_utils.dart';
import 'package:octagon/widgets/filled_button_widget.dart';
import 'package:octagon/widgets/text_formbox_widget.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../networking/model/user_response_model.dart';
import '../../widgets/common_login_button.dart';
import '../edit_profile/edit_profile.dart';
import '../sport /sport_selection_screen.dart';
import '../tabs_screen.dart';
import '../term_selection/team_selection.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final AuthController authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isValid(String email, String password) {
    if (!emailValidReg.hasMatch(email)) {
      Get.snackbar(AppName, "Please enter valid E-mail");
      return false;
    }
    if (password.length < 6) {
      Get.snackbar(AppName, "Please enter at least 6 character for password");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: appBgColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Text("Login", style: whiteColor24BoldTextStyle),
              Text("Add your details to login", style: greyColor12TextStyle),
              const SizedBox(height: 50),

              // Email
              TextFormBox(
                textEditingController: emailController,
                hintText: "Email",
                suffixIcon: const Icon(Icons.email_outlined, color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Password
              TextFormBox(
                textEditingController: passwordController,
                hintText: "Password",
                passwordVisible: 1,
                suffixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white),
              ),
              const SizedBox(height: 40),

              // Login button
              Obx(() => FilledButtonWidget(
                    isLoading: authController.isLoading.value,
                    "Login",
                    () async {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      if (!isValid(email, password)) return;

                      final result = await authController.loginUser(
                        email: email,
                        password: password,
                        fcmToken: storage.read("fcmToken") ?? "abc",
                      );

                      final data = result.data;
                      if (data == null || data.success == null) {
                        Get.snackbar(AppName, result.error ?? "Login failed");
                        return;
                      }

                      final success = data.success!;
                      storage.write("current_uid", success.userId);
                      storage.write('token', success.token.toString());
                      storage.write('country', success.country ?? '');
                      storage.write('user_name', success.name ?? '');
                      storage.write('image_url', success.photo ?? '');
                      storage.write('email', success.email ?? '');
                      storage.write(userData, success.toJson());

                      if (success.name == null) {
                        Get.off(() => EditProfileScreen(
                              profileData: UserModel(email: success.email ?? ""),
                              isUpdate: false,
                              update: (_) {},
                            ));
                        return;
                      }

                      // final sportInfo = success.sportInfo;
                      // final hasNoSports =
                      //     sportInfo == null || sportInfo.isEmpty;
                      // final hasNoTeams = sportInfo?.first.team == null ||
                      //     sportInfo!.first.team!.isEmpty;

                      // The following condition is commented out as per instructions, not removed:
                      // if (hasNoSports || hasNoTeams) {
                      //   if (hasNoSports) {
                      //     Get.to(() => SportSelection());
                      //   } else {
                      //     final sportDataList = sportInfo!.map((s) {
                      //       return Sports(
                      //         s.strSport ?? '',
                      //         s.id ?? 0,
                      //         s.idSport ?? 0,
                      //         s.strSportThumb ?? '',
                      //         selected: true,
                      //       );
                      //     }).toList();
                      //     Get.to(() => TeamSelectionScreen(sportDataList));
                      //   }
                      // } else {
                      {
                        // storage.write(
                        //     'userDefaultTeam',
                        //     sportInfo!.first.team!.first.strTeamLogo
                        //         .toString());
                        // storage.write('userDefaultTeamName',
                        //     sportInfo.first.team!.first.toJson());
                        // // storage.write(sportInfo, sportInfo.map((e) => e.toJson()).toList());
                        // storage.write('sportInfo',
                        //     sportInfo.map((e) => e.toJson()).toList());

                        Get.snackbar("Octagon", "You logged in as ${success.name}");
                        Get.offAll(() => TabScreen());
                      }
                    },
                    1,
                  )),

              // Forget password
              Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(top: 10),
                child: GestureDetector(
                  onTap: () => Get.to(() => MobileNumberScreen()),
                  child: Text("Forget your password ?", style: whiteColor14TextStyle),
                ),
              ),

              // Social login
              // CommonLoginButton(
              //   isLogin: true,
              //   googlePress: (userCredential) {
              //     print(
              //         "Google login callback - userCredential: $userCredential");
              //     print(
              //         "Google login callback - user: ${userCredential?.user}");
              //     print(
              //         "Google login callback - uid: ${userCredential?.user?.uid}");
              //     print(
              //         "Google login callback - email: ${userCredential?.user?.email}");

              //     if (userCredential?.user?.uid != null) {
              //       authController.handleSocialLogin(
              //         email: userCredential?.user?.email,
              //         socialId: userCredential!.user!.uid,
              //       );
              //     } else {
              //       print("Google login failed - user or uid is null");
              //       Get.snackbar(
              //         "Google Login Failed",
              //         "Please try again or use email/password login",
              //         backgroundColor: Colors.red,
              //         colorText: Colors.white,
              //         duration: const Duration(seconds: 3),
              //       );
              //     }
              //   },
              //   applePress: (user) {
              //     if (user != null) {
              //       authController.handleSocialLogin(
              //         email: user.email,
              //         socialId: user.userIdentifier ?? "",
              //       );
              //     }
              //   },
              // ),

              const Spacer(),

              // Sign up
              GestureDetector(
                onTap: () => Get.to(() => SignupScreen()),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an Account?",
                      style: whiteColor14TextStyle,
                      children: [
                        TextSpan(
                          text: " Sign Up",
                          style: whiteColor16TextStyle,
                          recognizer: TapGestureRecognizer()..onTap = () => Get.to(() => SignupScreen()),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class LoginScreen extends StatefulWidget {
//   // final ThemeNotifier? model;

//   const LoginScreen(/*this.model,*/ {Key? key}) : super(key: key);

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class Sports {
//   bool selected;
//   String sportsName;
//   int sportsId;
//   int sportApiId;
//   String sportsImage;

//   Sports(
//     this.sportsName,
//     this.sportsId,
//     this.sportApiId,
//     this.sportsImage, {
//     this.selected = false,
//   });
// }

// class _LoginScreenState extends State<LoginScreen> {
//   AutovalidateMode isValidate = AutovalidateMode.disabled;
//   final TextEditingController _emailController = TextEditingController(text: "");
//   final TextEditingController _passwordController = TextEditingController(text: "");

//   LoginBloc loginBloc = LoginBloc();
//   // late RegisterBloc registerBloc;
//   LoginResponseModel? loginResponseModel;
//   // RegisterResponseModel? registerResponseModel;
//   List<Sports> sportDataList = [];
//   AuthorizationCredentialAppleID? appleLoginData;

//   bool isLoading = false;

//   @override
//   void initState() {
//     loginBloc = LoginBloc();

//     publishAmplitudeEvent(eventType: 'login $kScreenView');
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: appBgColor,
//       child: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15.0),
//             child: Column(
//               children: [
//                 const SizedBox(
//                   height: 50,
//                 ),
//                 Text(
//                   "Login",
//                   style: whiteColor24BoldTextStyle,
//                 ),
//                 Text(
//                   "Add your details to login",
//                   style: greyColor12TextStyle,
//                 ),
//                 const SizedBox(
//                   height: 50,
//                 ),
//                 Form(
//                   autovalidateMode: isValidate,
//                   child: Column(
//                     children: [
//                       const SizedBox(
//                         height: 20,
//                       ),
//                       TextFormBox(
//                         textEditingController: _emailController,
//                         hintText: "Email",
//                         suffixIcon: Icon(
//                           Icons.email_outlined,
//                           color: whiteColor,
//                           size: 20,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 20,
//                       ),
//                       TextFormBox(
//                         textEditingController: _passwordController,
//                         hintText: "Password",
//                         passwordVisible: 1,
//                         suffixIcon: Icon(
//                           Icons.lock_outline_rounded,
//                           color: whiteColor,
//                           size: 20,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 40,
//                 ),
//                 BlocConsumer(
//                     bloc: loginBloc,
//                     listener: (context, state) {
//                       if (state is LoginLoadingBeginState) {
//                         // onLoading(context);
//                         isLoading = true;
//                         setState(() {});
//                       }
//                       if (state is LoginUserState) {
//                         // stopLoader(context);
//                         isLoading = false;
//                         loginResponseModel = state.responseModel;

//                         setState(() {});

//                         if (loginResponseModel!.error != null) {
//                           showToast(message: "Invalid email or Password!");
//                         } else if (state.responseModel.success?.name == null) {
//                           ///social login/register flow
//                           storage.write("current_uid", state.responseModel.success!.userId);
//                           storage.write('token', state.responseModel.success!.token.toString());

//                           Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => EditProfileScreen(
//                                         profileData: UserModel(email: state.responseModel.success?.email ?? ""),
//                                         isUpdate: false,
//                                         update: (UserModel data) {},
//                                       )));

//                           ///todo open edit profile screen
//                         } else {
//                           ///todo parth copy this in verify otp screen.
//                           storage.write("current_uid", state.responseModel.success!.userId);
//                           storage.write('token', state.responseModel.success!.token.toString());
//                           storage.write('country', state.responseModel.success!.country.toString());
//                           storage.write('user_name', state.responseModel.success!.name.toString());
//                           if (state.responseModel.success?.bio != null) {
//                             storage.write('bio', state.responseModel.success!.bio.toString());
//                           }

//                           storage.write('image_url', state.responseModel.success!.photo.toString());
//                           storage.write('email', state.responseModel.success!.email.toString());

//                           storage.write(userData, state.responseModel.success!.toJson());

//                           setAmplitudeUserProperties();

//                           // Navigator.push(context, MaterialPageRoute(builder: (context)=> SportSelection(widget.model)));

//                           if (state.responseModel.success?.sportInfo == null ||
//                               state.responseModel.success!.sportInfo!.isEmpty ||
//                               state.responseModel.success?.sportInfo?.first.team == null ||
//                               state.responseModel.success!.sportInfo!.first.team!.isEmpty) {
//                             if (state.responseModel.success?.sportInfo?.isEmpty ?? false) {
//                               Navigator.push(context, MaterialPageRoute(builder: (context) => SportSelection(/*widget.model*/)));
//                             } else {
//                               sportDataList = [];
//                               for (var element in state.responseModel.success!.sportInfo!) {
//                                 sportDataList.add(Sports(
//                                     "${element.strSport}", element.id!.toInt(), element.idSport!.toInt(), element.strSportThumb.toString(),
//                                     selected: true));
//                               }
//                               Navigator.push(context, MaterialPageRoute(builder: (context) => TeamSelectionScreen(sportDataList)));
//                             }
//                           } else {
//                             ///first team flag
//                             storage.write('userDefaultTeam', state.responseModel.success!.sportInfo!.first.team!.first.strTeamLogo.toString());
//                             storage.write('userDefaultTeamName', state.responseModel.success!.sportInfo!.first.team!.first.toJson());

//                             List<Map<String, dynamic>> data = [];
//                             state.responseModel.success!.sportInfo?.forEach((element) {
//                               data.add(element.toJson());
//                             });

//                             storage.write(sportInfo, data);

//                             Get.snackbar("Octagon", "You logged in as ${state.responseModel.success!.name}");

//                             Navigator.pushAndRemoveUntil(
//                               context,
//                               MaterialPageRoute(builder: (context) => TabScreen()),
//                               (route) => false,
//                             );
//                             //   Navigator.pushReplacement(context,
//                             // MaterialPageRoute(builder: (context) => TabScreen()));
//                           }
//                         }
//                       }
//                       if (state is LoginErrorState) {
//                         isLoading = false;
//                         setState(() {});
//                         Get.snackbar("Login", "invalid email or password");
//                         // showSnackBarWithTitleAndText("Alert",state.exception.toString());
//                       }
//                     },
//                     builder: (context, _) {
//                       return FilledButtonWidget(isLoading: isLoading, /*widget.model,*/ "Login", () {
//                         if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
//                           if (isValid()) {
//                             loginBloc.add(LoginUserEvent(
//                               email: _emailController.text,
//                               password: _passwordController.text,
//                               // loginType: "social",
//                               fcmToken: storage.read("fcm_token"),
//                             ));
//                           }
//                         } else {
//                           Get.snackbar(AppName, "Please enter Email and Password!");
//                         }
//                       }, 1);
//                     }),
//                 Container(
//                   margin: const EdgeInsets.only(top: 10),
//                   alignment: Alignment.centerRight,
//                   child: GestureDetector(
//                       onTap: () {
//                         Navigator.push(context, MaterialPageRoute(builder: (context) => MobileNumberScreen()));
//                       },
//                       child: Text(
//                         "Forget your password ?",
//                         style: whiteColor14TextStyle,
//                       )),
//                 ),
//                 CommonLoginButton(
//                   isLogin: true,
//                   googlePress: (user) {
//                     if (user != null && user.user != null && user.user!.uid != null) {
//                       ///api calling

//                       isLoading = true;
//                       setState(() {});

//                       loginBloc.add(SocialAuthEvent(email: user.user?.email, fcmToken: storage.read("fcm_token"), socialId: user.user?.uid ?? ""));
//                     }
//                   },
//                   applePress: (user) async {
//                     ///api calling
//                     if (user != null) {
//                       isLoading = true;
//                       setState(() {});

//                       appleLoginData = user;
//                       loginBloc.add(SocialAuthEvent(
//                         email: user.email,
//                         fcmToken: storage.read("fcm_token"),
//                         socialId: user.userIdentifier,
//                       ));
//                     } else {}
//                   },
//                 ),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
//                     },
//                     child: Container(
//                       alignment: Alignment.bottomCenter,
//                       margin: const EdgeInsets.only(bottom: 15),
//                       child: RichText(
//                         text: TextSpan(text: "Don't have an Account?", style: whiteColor14TextStyle, children: [
//                           TextSpan(
//                             recognizer: TapGestureRecognizer()
//                               ..onTap = () {
//                                 Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
//                               },
//                             text: " Sign Up",
//                             style: whiteColor16TextStyle,
//                           )
//                         ]),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   bool isValid() {
//     bool isValid = true;

//     if (!emailValidReg.hasMatch(_emailController.text.trim())) {
//       Get.snackbar(AppName, "Please enter valid E-mail");
//       isValid = false;
//     } else

//     ///pass
//     if (_passwordController.text.trim().length < 6) {
//       Get.snackbar(AppName, "Please enter at least 6 character for password");
//       isValid = false;
//     }

//     return isValid;
//   }
// }
