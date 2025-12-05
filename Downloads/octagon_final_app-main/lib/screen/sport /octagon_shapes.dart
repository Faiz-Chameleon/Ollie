import 'package:flutter/material.dart';

class OctagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    final double s = w < h ? w : h;
    const double k = 0.293;

    return Path()
      ..moveTo(k * s, 0)
      ..lineTo((1 - k) * s, 0)
      ..lineTo(s, k * s)
      ..lineTo(s, (1 - k) * s)
      ..lineTo((1 - k) * s, s)
      ..lineTo(k * s, s)
      ..lineTo(0, (1 - k) * s)
      ..lineTo(0, k * s)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class OctagonBorderPainter extends CustomPainter {
  OctagonBorderPainter({
    this.borderColor = Colors.yellow,
    this.strokeWidth = 4.5,
  });

  final Color borderColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double s = w < h ? w : h;
    const double k = 0.293;

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..moveTo(k * s, 0)
      ..lineTo((1 - k) * s, 0)
      ..lineTo(s, k * s)
      ..lineTo(s, (1 - k) * s)
      ..lineTo((1 - k) * s, s)
      ..lineTo(k * s, s)
      ..lineTo(0, (1 - k) * s)
      ..lineTo(0, k * s)
      ..close();

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is OctagonBorderPainter) {
      return oldDelegate.borderColor != borderColor || oldDelegate.strokeWidth != strokeWidth;
    }
    return true;
  }
}
