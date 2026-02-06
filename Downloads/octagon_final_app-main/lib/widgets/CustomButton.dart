import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  String ButtonText;
  double width;
  final VoidCallback? tap;
  double? height;
  Color? colors;
  Color? borderColor;
  var gradients;
  var textColor;

  CustomButton({
    Key? key,
    this.textColor,
    this.gradients,
    this.colors,
    this.height,
    this.borderColor,
    this.tap,
    required this.width,
    required this.ButtonText,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.tap!(),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          border: Border.all(color: widget.borderColor ?? Colors.transparent),
          color: widget.colors,
          borderRadius: BorderRadius.circular(12),
          gradient: widget.gradients,
        ),
        child: Center(child: Text(widget.ButtonText, style: TextStyle(fontSize: 18, color: widget.textColor, fontWeight: FontWeight.w500))),
      ),
    );
  }
}
