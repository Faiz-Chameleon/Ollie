import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:octagon/screen/login/login_screen.dart';
import 'package:octagon/screen/sign_up/sign_up_screen.dart';
import 'package:octagon/screen/sign_up/signup_step.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:octagon/widgets/filled_button_widget.dart';
import 'package:resize/resize.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Resize(builder: () {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Octagon',
        color: appBgColor,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Builder(builder: (context) {
          return Scaffold(
            backgroundColor: appBgColor,
            body: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Octagon",
                          style: const TextStyle(
                              fontSize: 68,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              color: Colors.white,
                              height: 100,
                              width: 100,
                            ),
                            Image.asset(
                              "assets/ic/octagon_shape.png",
                              height: 250,
                              width: 250,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FilledButtonWidget(/*widget.model, */ "Login", () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        }, 1),

                        const SizedBox(
                          height: 20,
                        ),

                        // FilledButtonWidget(
                        //   /*widget.model, */"Team Login", () {Navigator.pushReplacement(context, MaterialPageRoute(
                        //     builder: (context) => LoginScreen(isTeam: true)));}, 1),

                        SizedBox(
                          height: 2.vh,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupScreen()));
                      },
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        child: RichText(
                          text: TextSpan(
                              text: "New to Octagon?",
                              style: greyColor14TextStyle,
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SignupScreen()));
                                    },
                                  text: " Sign Up",
                                  style: whiteColor16TextStyle,
                                )
                              ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      );
    });
  }
}
