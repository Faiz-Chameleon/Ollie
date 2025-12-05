import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octagon/utils/theme/theme_constants.dart';

class TextFormBox extends StatefulWidget {
  final String? hintText;
  final TextEditingController? textEditingController;
  final Icon? suffixIcon;
  bool isIconEnable = true;
  int maxLines;
  bool isEnable = true;
  Function? onClick;
  bool isNumber = false;
  bool isMaxLengthEnable = false;
  int maxCharcter = 250;
  int passwordVisible = 0;

  ///0 no pass, 1 pass visible, 2 pass no visible

  TextFormBox(
      {this.hintText,
      this.textEditingController,
      this.suffixIcon,
      this.isEnable = true,
      this.onClick,
      this.isNumber = false,
      this.isIconEnable = true,
      this.maxCharcter = 250,
      this.passwordVisible = 0,
      this.isMaxLengthEnable = false,
      this.maxLines = 1,
      Key? key})
      : super(key: key);

  @override
  _TextFormBoxState createState() => _TextFormBoxState();
}

class _TextFormBoxState extends State<TextFormBox> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textEditingController,
      style: whiteColor14TextStyle,
      maxLines: widget.maxLines,
      obscureText:
          widget.passwordVisible == 0 ? false : widget.passwordVisible == 1,
      keyboardType: widget.isNumber ? TextInputType.number : TextInputType.text,
      maxLength: widget.isMaxLengthEnable ? widget.maxCharcter : null,
      // enabled: widget.isEnable,
      readOnly: !widget.isEnable,
      textCapitalization: TextCapitalization.sentences,
      onTap: () {
        if (widget.onClick != null) {
          widget.onClick!.call();
        }
      },
      decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: greyColor14TextStyle,
          counterStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(
              color: greyColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(
              color: greyColor,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(
              color: greyColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: whiteColor, width: 2),
          ),
          suffixIcon: widget.isIconEnable
              ? IconButton(
                  icon: widget.passwordVisible != 0
                      ? Icon(
                          widget.passwordVisible == 1
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white)
                      : widget.suffixIcon!,
                  onPressed: () {
                    if (widget.passwordVisible != 0) {
                      // Update the state i.e. toogle the state of passwordVisible variable
                      setState(() {
                        widget.passwordVisible =
                            widget.passwordVisible == 1 ? 2 : 1;
                      });
                    }
                  },
                )
              : null),
    );
  }
}
