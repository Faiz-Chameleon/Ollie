import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:octagon/screen/login/auth_controller.dart';
import 'package:octagon/screen/login/bloc/login_bloc.dart';
import 'package:octagon/screen/login/bloc/login_event.dart';
import 'package:octagon/screen/login/bloc/login_state.dart';
import 'package:octagon/screen/login/login_screen.dart';
import 'package:octagon/utils/analiytics.dart';
import 'package:octagon/utils/constants.dart';
import 'package:octagon/utils/string.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/utils/toast_utils.dart';
import 'package:octagon/widgets/filled_button_widget.dart';
import 'package:octagon/widgets/text_formbox_widget.dart';
import 'package:resize/resize.dart';

class MobileNumberScreen extends StatelessWidget {
  MobileNumberScreen({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    publishAmplitudeEvent(eventType: 'MobileNumber $kScreenView');

    return Material(
      color: appBgColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Text(RESET, style: whiteColor24BoldTextStyle),
                SizedBox(height: 1.vh),
                Text(
                  "Please enter your Email address to\n         receive a new password",
                  style: greyColor12TextStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.vh),
                TextFormBox(
                  textEditingController: emailController,
                  isNumber: false,
                  hintText: "Email address",
                  suffixIcon: const Icon(Icons.email_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 40),
                Obx(() => FilledButtonWidget(
                      isLoading: authController.isLoading.value,
                      "Send",
                      () async {
                        final email = emailController.text.trim();
                        if (!emailValidReg.hasMatch(email)) {
                          Get.snackbar(AppName, "Please enter valid E-mail");
                          return;
                        }

                        final result = await authController.forgetPassword(email: email);

                        if (result.data != null) {
                          Get.off(() => LoginScreen());
                        } else {
                          Get.snackbar(AppName, "Something went wrong, Please try again later");
                        }
                      },
                      1,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




// class MobileNumberScreen extends StatefulWidget {

//   // final ThemeNotifier? model;
//   const MobileNumberScreen(/*this.model,*/ {Key? key}) : super(key: key);

//   @override
//   State<MobileNumberScreen> createState() => _MobileNumberScreenState();
// }

// class _MobileNumberScreenState extends State<MobileNumberScreen> {

//   AutovalidateMode isValidate = AutovalidateMode.disabled;
//   final TextEditingController _emailController = TextEditingController();
  
//   LoginBloc loginBloc = LoginBloc();

//   bool isLoading = false;

//   @override
//   void initState() {
//     loginBloc = LoginBloc();
    
//      publishAmplitudeEvent(eventType: 'MobileNumber $kScreenView');
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
//                 Text(RESET, style: whiteColor24BoldTextStyle,),
//                 SizedBox(
//                   height: 1.vh,
//                 ),
//                 Text("Please enter your Email address to\n         receive a new password", style: greyColor12TextStyle,),
//                 SizedBox(
//                   height: 4.vh,
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
//                         isNumber: false,
//                         hintText: "Email address",
//                         suffixIcon: Icon(Icons.email_outlined,color: whiteColor,size: 20,),
//                       ),
//                       SizedBox(
//                         height: 4.vh,
//                       ),

//                     ],
//                   ),

//                 ),

//                 const SizedBox(
//                   height: 40,
//                 ),

//                 BlocConsumer(
//                   bloc: loginBloc,
//                   listener: (context,state){
//                     if(state is LoginLoadingBeginState){
//                       setState(() {
//                         isLoading = true;
//                       });

//                       // onLoading(context);
//                     }
//                     if(state is LoginLoadingEndState){
//                       setState(() {
//                         isLoading = false;
//                       });
//                       // stopLoader(context);
//                     }
//                     if(state is ForgetPasswordState){
//                       setState(() {
//                         isLoading = false;
//                       });

//                             Navigator.push(context, MaterialPageRoute(
//                                 builder: (context) => LoginScreen(/*widget.model*/)));
//                     }

//                     if(state is LoginErrorState){
//                       setState(() {
//                         isLoading = false;
//                       });
//                       showToast(message: "Something went wrong, Please try again later");
//                     }
//                   },
//                   builder: (context,_) {
//                     return FilledButtonWidget(isLoading: isLoading,/*widget.model,*/ "Send", (){
//                       if(!emailValidReg.hasMatch(_emailController.text.trim())){
//                         Get.snackbar(AppName, "Please enter valid E-mail");
//                       }else{
//                         loginBloc.add(ForgetPasswordEvent(
//                           email: _emailController.text
//                         ));
//                       }

//                     }, 1);
//                   }
//                 ),

//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }