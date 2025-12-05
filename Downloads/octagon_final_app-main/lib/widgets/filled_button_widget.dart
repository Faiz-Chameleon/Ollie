import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:octagon/utils/theme/theme_constants.dart';

class FilledButtonWidget extends StatefulWidget {
  String? buttonName;
  VoidCallback? buttonPressed;
  bool isLoading = false;
  int? btnType; //1 = colored , 2= basic
  // ThemeNotifier? model;
  FilledButtonWidget(/*this.model,*/ this.buttonName, this.buttonPressed, this.btnType, {this.isLoading = false, Key? key}) : super(key: key);

  @override
  _FilledButtonWidgetState createState() => _FilledButtonWidgetState();
}

class _FilledButtonWidgetState extends State<FilledButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.isLoading) {
          widget.buttonPressed!.call();
        }
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        /*height: filledButtonHeight,
        width: filledButtonWidth,*/
        decoration: widget.btnType == 1
            ? filledButtonDecoration
            // : widget.btnType == 2
            //     ? widget.model.mode?borderButtonDarkDecoration:borderButtonDecoration
            : basicButtonDecoration,
        child: widget.isLoading
            ? const Center(
                child: SizedBox(
                  width: 23.0,
                  height: 23.0,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ),
              )
            : Text(widget.buttonName!,
                style: widget.btnType == 1
                    ? /*widget.model!=null && widget.model!.mode ? whiteColor16BoldTextStyle:*/ whiteColor16BoldTextStyle
                    : greyColor16TextStyle),
      ),
    );
  }
}
