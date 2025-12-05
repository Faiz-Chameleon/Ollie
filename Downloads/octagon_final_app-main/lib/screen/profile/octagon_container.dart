import 'package:flutter/material.dart';

class OctagonContainer extends StatelessWidget {
  final double size;
  final Color color; // Your custom color parameter
  final Widget? child;
  final double borderWidth;
  final Color borderColor;

  const OctagonContainer({
    super.key,
    required this.size,
    required this.color, // Make color required
    this.child,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _OctagonPainter(color, borderWidth, borderColor),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(size * 0.1), // Adjust for octagon shape
          child: child,
        ),
      ),
    );
  }
}

class _OctagonPainter extends CustomPainter {
  final Color color;
  final double borderWidth;
  final Color borderColor;

  _OctagonPainter(this.color, this.borderWidth, this.borderColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = _createOctagonPath(size);

    canvas.drawPath(path, paint);
    if (borderWidth > 0) {
      canvas.drawPath(path, borderPaint);
    }
  }

  Path _createOctagonPath(Size size) {
    final path = Path();
    final double cut = size.width * 0.25; // Adjust corner size

    path.moveTo(cut, 0);
    path.lineTo(size.width - cut, 0);
    path.lineTo(size.width, cut);
    path.lineTo(size.width, size.height - cut);
    path.lineTo(size.width - cut, size.height);
    path.lineTo(cut, size.height);
    path.lineTo(0, size.height - cut);
    path.lineTo(0, cut);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
