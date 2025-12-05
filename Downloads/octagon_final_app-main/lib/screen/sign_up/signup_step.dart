import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/theme/theme_constants.dart';
import '../../widgets/filled_button_widget.dart';
import '../login/login_screen.dart';

class SignupStepScreen extends StatefulWidget {
  const SignupStepScreen({super.key});

  @override
  State<SignupStepScreen> createState() => _SignupStepScreenState();
}

class _SignupStepScreenState extends State<SignupStepScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appBgColor,
        body: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Spacer(),
              // Text("Octagon", style: GoogleFonts.comicNeue(fontSize: 68, color: Colors.white, fontWeight: FontWeight.w600),),
              // Stack(
              //   alignment: Alignment.center,
              //   children: [
              //     Container(
              //       color: Colors.white,
              //       height: 100,
              //       width: 100,
              //     ),
              //     Image.asset("assets/ic/octagon_shape.png", height: 250,
              //       width: 250,),
              //   ],
              // ),
              FilledButtonWidget(
                "Personal Profile", () {Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => LoginScreen()));}, 1),
              SizedBox(
                height: 20,
              ),
              FilledButtonWidget(
                  "Team Profile", () {Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => LoginScreen()));}, 1),
              Spacer(),
            ],
          ),
        ));
  }
}
