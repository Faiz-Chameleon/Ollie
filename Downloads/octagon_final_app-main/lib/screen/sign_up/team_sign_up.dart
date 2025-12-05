// import 'package:country_picker/country_picker.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get/get.dart';
// import 'package:octagon/main.dart';
// import 'package:octagon/networking/model/response_model/login_response_model.dart';
// import 'package:octagon/networking/model/response_model/register_response_model.dart';
// import 'package:octagon/screen/login/bloc/login_bloc.dart';
// import 'package:octagon/screen/login/bloc/login_event.dart';
// import 'package:octagon/screen/login/bloc/login_state.dart';
// import 'package:octagon/screen/login/login_controller.dart';
// import 'package:octagon/screen/login/login_screen.dart';
// import 'package:octagon/utils/analiytics.dart';
// import 'package:octagon/utils/constants.dart';
// import 'package:octagon/utils/string.dart';
// import 'package:octagon/utils/theme/theme_constants.dart';
// import 'package:octagon/utils/toast_utils.dart';
// import 'package:octagon/widgets/filled_button_widget.dart';
// import 'package:octagon/widgets/text_formbox_widget.dart';

// import '../login/otp_screen.dart';
// import '../sport /sport_selection_screen.dart';
// import '../tabs_screen.dart';
// import '../term_selection/team_selection.dart';


// class TeamSignupScreen extends StatefulWidget {

//   const TeamSignupScreen({Key? key}) : super(key: key);

//   @override
//   State<TeamSignupScreen> createState() => _TeamSignupScreenState();
// }

// class _TeamSignupScreenState extends State<TeamSignupScreen> {
//   AutovalidateMode isValidate = AutovalidateMode.disabled;
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   // final TextEditingController _mobileController = TextEditingController();
//   final TextEditingController _countryController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();

//   // int typeOfGender = 0;///0 = other, 1 = male, 2 = female

//   Country? selectedCountry;
//   LoginBloc loginBloc = LoginBloc();
//   LoginResponseModel? loginResponseModel;
//   RegisterResponseModel? registerResponseModel;

//   bool isLoading = false;
// /*
//   late OtpVerifyBloc otpVerifyBloc;
//   */

//   List<Sports> sportDataList = [];

//   bool isAgreeWithTermsAndCondition = false;

//   @override
//   void initState() {
//     loginBloc = LoginBloc();
    
//     publishAmplitudeEvent(eventType: 'signup $kScreenView');
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: appBgColor,
//       body: GestureDetector(
//         onTap: (){
//           closeKeyboard();
//         },
//         child: SingleChildScrollView(
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15.0),
//               child: Column(
//                 children: [
//                   const SizedBox(
//                     height: 50,
//                   ),
//                   Text(
//                     "Signup",
//                     style: whiteColor24BoldTextStyle,
//                   ),
//                   Text(
//                     "Add your details to signup",
//                     style: greyColor12TextStyle,
//                   ),
//                   const SizedBox(
//                     height: 30,
//                   ),
//                   Form(
//                     autovalidateMode: isValidate,
//                     child: Column(
//                       children: [
//                         const SizedBox(
//                           height: 20,
//                         ),
//                         TextFormBox(
//                           textEditingController: _nameController,
//                           hintText: "UserName",
//                           isMaxLengthEnable: true,
//                           maxCharcter: 40,
//                           suffixIcon: Icon(
//                             Icons.person_outline_rounded,
//                             color: whiteColor,
//                             size: 20,
//                           ),
//                         ),
//                         // const SizedBox(
//                         //   height: 20,
//                         // ),
//                         TextFormBox(
//                           textEditingController: _emailController,
//                           hintText: "Email",
//                           suffixIcon: Icon(
//                             Icons.email_outlined,
//                             color: whiteColor,
//                             size: 20,
//                           ),
//                         ),
                       
//                         const SizedBox(
//                           height: 20,
//                         ),
                      
//                         TextFormBox(
//                           textEditingController: _countryController,
//                           hintText: "Country",
//                           isEnable: false,
//                           onClick: (){
//                             showCountryPicker(
//                               context: context,
//                               showPhoneCode: true, // optional. Shows phone code before the country name.
//                               onSelect: (Country country) {
//                                 _countryController.text = country.name;
//                                 selectedCountry = country;
//                                 print('Select country: ${country.displayName}');
//                               },
//                             );
//                           },
//                           suffixIcon: Icon(
//                             Icons.place_outlined,
//                             color: whiteColor,
//                             size: 20,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 20,
//                         ),
//                         TextFormBox(
//                           textEditingController: _passwordController,
//                           hintText: "Password",
//                           passwordVisible: 1,
//                           suffixIcon: Icon(
//                             Icons.lock_outline_rounded,
//                             color: whiteColor,
//                             size: 20,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 20,
//                         ),
//                         TextFormBox(
//                           textEditingController: _confirmPasswordController,
//                           hintText: "Confirm password",
//                           passwordVisible: 1,
//                           suffixIcon: Icon(
//                             Icons.lock_outline_rounded,
//                             color: whiteColor,
//                             size: 20,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Container(
//                     alignment: Alignment.bottomCenter,
//                     child: Row(
//                       children: [
//                         Checkbox(
//                           side:
//                           BorderSide(width: 2, color: Colors.green),
//                           checkColor: Colors.greenAccent,
//                           activeColor: purpleColor,
//                           value: isAgreeWithTermsAndCondition,
//                           onChanged: (bool? value) {
//                             setState(() {
//                               isAgreeWithTermsAndCondition = value?? false;
//                             });
//                           },
//                         ),
//                         RichText(
//                           maxLines: 2,
//                           text: TextSpan(
//                               text: "Agree with",
//                               style: whiteColor12TextStyle,
//                               children: [
//                                 TextSpan(
//                                   recognizer: TapGestureRecognizer()
//                                     ..onTap = () {
//                                       /*Navigator.push(
//                                           context,
//                                           MaterialPageRoute(builder: (context) => WebViewScreen(screenName: "Terms Conditions", url: termsAndConditionURL,)));*/
//                                     },
//                                   text: " Terms Conditions",
//                                   style: blueColor12TextStyle,
//                                 ),
//                                 TextSpan(
//                                   recognizer: TapGestureRecognizer(),
//                                   text: " and",
//                                   style: whiteColor12TextStyle,
//                                 ),
//                                 TextSpan(
//                                   recognizer: TapGestureRecognizer()
//                                     ..onTap = () {
//                                       /*Navigator.push(
//                                           context,
//                                           MaterialPageRoute(builder: (context) => WebViewScreen(screenName: "Privacy Policy", url: privacyPolicyURL,)));*/
//                                     },
//                                   text: " Privacy Policy",
//                                   style: blueColor12TextStyle,
//                                 )
//                               ]),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   BlocConsumer(
//                       bloc: loginBloc,
//                       listener: (context,state){
//                         if(state is LoginLoadingBeginState){
//                           isLoading = true;
//                           setState(() {

//                           });
//                           // onLoading(context);
//                         }
//                         if(state is LoginLoadingEndState){
//                           isLoading = false;
//                           setState(() {

//                           });
//                           // stopLoader(context);
//                         }
//                         if(state is RegisterUserState) {
//                           isLoading = false;
//                           setState(() {

//                           });
//                           registerResponseModel = state.responseModel;
//                           if (registerResponseModel!.error != null) {
//                             // storage.write('token', registerResponseModel!.success!.token.toString());
//                             showToast(message: registerResponseModel?.error ?? "");
//                             Navigator.pop(context);
//                             // Navigator.push(context, MaterialPageRoute(builder: (context)=> OTPScreen(/*widget.model*/_emailController.text.trim())));
//                           } else {
//                             storage.write('token', registerResponseModel!.success!
//                                 .token.toString());
//                             Navigator.push(context, MaterialPageRoute(builder: (context)=> OTPScreen(/*widget.model*/_emailController.text.trim())));

//                             ///parth verifying Static OTP.
//                             // loginBloc.add(VerifyOtpEvent(
//                             //   email: _emailController.text,
//                             //   otp: "123456"
//                             // ));
//                             print(state.responseModel);
//                           }
//                         }
//                         if (state is VerifyOtpState) {
//                           isLoading = false;
//                           setState(() {

//                           });
//                           loginResponseModel = state.responseModel;
//                           if (loginResponseModel!.error != null) {
//                             showToast(message: loginResponseModel?.error ?? "");
//                             // Navigator.push(context, MaterialPageRoute(builder: (context)=> OTPScreen(/*widget.model*/_emailController.text.trim(), isFromLogin: true,)));
//                           } else {
//                             ///todo todo parth copy this in verify otp screen.
//                             storage.write(
//                                 "current_uid", loginResponseModel!.success!.userId);
//                             storage.write(
//                                 'token', loginResponseModel!.success!.token.toString());
//                             storage.write('country',
//                                 loginResponseModel!.success!.country.toString());
//                             storage.write('user_name',
//                                 loginResponseModel!.success!.name.toString());
//                             if(loginResponseModel?.success?.bio!=null){
//                               storage.write('bio', loginResponseModel!.success!.bio.toString());
//                             }

//                             storage.write('image_url',
//                                 loginResponseModel!.success!.photo.toString());
//                             storage.write(
//                                 'email', loginResponseModel!.success!.email.toString());

//                             storage.write(
//                                 userData, loginResponseModel!.success!.toJson());

//                             setAmplitudeUserProperties();

//                             // Navigator.push(context, MaterialPageRoute(builder: (context)=> SportSelection(widget.model)));

//                             if (loginResponseModel?.success?.sportInfo == null ||
//                                 loginResponseModel!.success!.sportInfo!.isEmpty ||
//                                 loginResponseModel?.success?.sportInfo?.first.team ==
//                                     null ||
//                                 loginResponseModel!
//                                     .success!.sportInfo!.first.team!.isEmpty) {
//                               if (loginResponseModel?.success?.sportInfo?.isEmpty ??
//                                   false) {
//                                 Navigator.push(context, MaterialPageRoute(builder: (context)=> SportSelection()));
//                               } else {
//                                 sportDataList = [];
//                                 for (var element
//                                 in loginResponseModel!.success!.sportInfo!) {
//                                   sportDataList.add(Sports(
//                                       "${element.strSport}",
//                                       element.id!.toInt(),
//                                       element.idSport!.toInt(),
//                                       element.strSportThumb.toString(),
//                                       selected: true));
//                                 }
//                                 Navigator.push(context, MaterialPageRoute(
//                                     builder: (context) => TeamSelectionScreen(sportDataList)));
//                               }
//                             } else {
//                               ///first team flag
//                               storage.write(
//                                   'userDefaultTeam',
//                                   loginResponseModel!
//                                       .success!.sportInfo!.first.team!.first.strTeamLogo
//                                       .toString());
//                               storage.write(
//                                   'userDefaultTeamName',
//                                   loginResponseModel!
//                                       .success!.sportInfo!.first.team!.first
//                                       .toJson());

//                               List<Map<String, dynamic>> data = [];
//                               state.responseModel.success!.sportInfo?.forEach((element) {
//                                 data.add(element.toJson());
//                               });

//                               storage.write(sportInfo, data);

//                               Get.snackbar("Octagon",
//                                   "You logged in as ${loginResponseModel!.success!.name}");

//                               Navigator.pushReplacement(context,
//                                   MaterialPageRoute(builder: (context) => TabScreen()));
//                             }
//                           }
//                         }
//                         if(state is LoginErrorState){
//                           isLoading = false;
//                           setState(() {

//                           });
//                           Get.snackbar("Signup", state.exception.toString());
//                         }
//                       },
//                       builder: (context,_) {
//                         return FilledButtonWidget(
//                             isLoading: isLoading,
//                             "Sign Up", () {

//                           if(isAgreeWithTermsAndCondition){
//                             if(_nameController.text.trim().isNotEmpty &&
//                                 // _mobileController.text.trim().isNotEmpty &&
//                                 _emailController.text.trim().isNotEmpty &&
//                                 _confirmPasswordController.text.trim().isNotEmpty &&
//                                 _passwordController.text.trim().isNotEmpty &&
//                                 _countryController.text.trim().isNotEmpty
//                             ){
//                               if(isValid()){
//                                 /*registerBloc.registerUser(RegisterRequestModel(
//                                   name: _nameController.text,
//                                   mobile: "",
//                                   email: _emailController.text,
//                                   // gender: typeOfGender,
//                                   cPassword: _confirmPasswordController.text,
//                                   password: _passwordController.text,
//                                   country: _countryController.text.trim()
//                               ));*/
//                                 loginBloc.add(RegisterUserEvent(
//                                     email: _emailController.text,
//                                     name: _nameController.text,
//                                     mobile: "",
//                                     password: _passwordController.text,
//                                     country: _countryController.text,
//                                     cPassword: _confirmPasswordController.text
//                                 ));
//                               }
//                             }else{
//                               Get.snackbar(AppName, "Please enter valid data!");
//                             }
//                           }else{
//                             Get.snackbar(AppName, "Please agree with Terms Conditions and Privacy Policy!");
//                           }

//                           // Navigator.pushReplacement(
//                           //     context,
//                           //     MaterialPageRoute(
//                           //         builder: (context) =>
//                           //             SportSelection(widget.model)));

//                         }, 1);
//                       }
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Container(
//                     alignment: Alignment.bottomCenter,
//                     child: RichText(
//                       text: TextSpan(
//                           text: "Already have an Account?",
//                           style: whiteColor14TextStyle,
//                           children: [
//                             TextSpan(
//                               recognizer: TapGestureRecognizer()
//                                 ..onTap = () {
//                                   Navigator.pushAndRemoveUntil(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               LoginScreen()),(Route<dynamic> route) => false);
//                                 },
//                               text: " Login",
//                               style: whiteColor16TextStyle,
//                             )
//                           ]),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   bool isValid() {
//     bool isValid = true;

//     if(!emailValidReg.hasMatch(_emailController.text.trim())){
//       Get.snackbar(AppName, "Please enter valid E-mail");
//       isValid = false;
//     }else

//       // if(_mobileController.text.trim().length != 10){
//       //   Get.snackbar(AppName, "Please enter valid mobile number");
//       //   isValid = false;
//       // }else

//       ///pass
//     if(_passwordController.text.trim().length < 8){
//       Get.snackbar(AppName, "Please enter at least 8 character for password");
//       isValid = false;
//     }else

//       ///c pass
//     if(_passwordController.text.trim().toLowerCase() != _confirmPasswordController.text.trim().toLowerCase()){
//       Get.snackbar(AppName, "Password & Confirm password must be same!");
//       isValid = false;
//     }

//     return isValid;
//   }
// }
