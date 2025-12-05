import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';


//Copy this CustomPainter code to the Bottom of the File
class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    Path path_0 = Path();
    path_0.moveTo(size.width*0.09062135,size.height*0.3305087);
    path_0.lineTo(size.width*0.04129316,size.height*0.4488892);
    path_0.cubicTo(size.width*0.03872772,size.height*0.4540681,size.width*0.03659730,size.height*0.4598994,size.width*0.03480223,size.height*0.4658951);
    path_0.cubicTo(size.width*0.02638166,size.height*0.4931522,size.width*0.02957957,size.height*0.5221883,size.width*0.04015301,size.height*0.5481335);
    path_0.lineTo(size.width*0.09067637,size.height*0.6696241);
    path_0.lineTo(size.width*0.1395043,size.height*0.7882119);
    path_0.cubicTo(size.width*0.1413523,size.height*0.7936880,size.width*0.1439692,size.height*0.7993176,size.width*0.1469396,size.height*0.8048265);
    path_0.cubicTo(size.width*0.1602591,size.height*0.8300545,size.width*0.1830521,size.height*0.8483248,size.width*0.2088748,size.height*0.8591943);
    path_0.lineTo(size.width*0.3305076,size.height*0.9093760);
    path_0.lineTo(size.width*0.4488889,size.height*0.9587039);
    path_0.cubicTo(size.width*0.4540678,size.height*0.9612693,size.width*0.4598991,size.height*0.9633997,size.width*0.4658949,size.height*0.9651947);
    path_0.cubicTo(size.width*0.4931522,size.height*0.9736153,size.width*0.5221883,size.height*0.9704175,size.width*0.5481337,size.height*0.9598440);
    path_0.lineTo(size.width*0.6696251,size.height*0.9093210);
    path_0.lineTo(size.width*0.7882136,size.height*0.8604934);
    path_0.cubicTo(size.width*0.7936898,size.height*0.8586454,size.width*0.7993195,size.height*0.8560286,size.width*0.8048285,size.height*0.8530582);
    path_0.cubicTo(size.width*0.8300566,size.height*0.8397387,size.width*0.8483270,size.height*0.8169459,size.width*0.8591965,size.height*0.7911233);
    path_0.lineTo(size.width*0.9093786,size.height*0.6694914);
    path_0.lineTo(size.width*0.9587068,size.height*0.5511108);
    path_0.cubicTo(size.width*0.9612722,size.height*0.5459319,size.width*0.9634027,size.height*0.5401006,size.width*0.9651977,size.height*0.5341048);
    path_0.cubicTo(size.width*0.9736183,size.height*0.5068478,size.width*0.9704205,size.height*0.4778118,size.width*0.9598469,size.height*0.4518666);
    path_0.lineTo(size.width*0.9093237,size.height*0.3303759);
    path_0.lineTo(size.width*0.8604957,size.height*0.2117882);
    path_0.cubicTo(size.width*0.8586476,size.height*0.2063121,size.width*0.8560308,size.height*0.2006824,size.width*0.8530603,size.height*0.1951734);
    path_0.cubicTo(size.width*0.8397408,size.height*0.1699455,size.width*0.8169478,size.height*0.1516752,size.width*0.7911252,size.height*0.1408058);
    path_0.lineTo(size.width*0.6694923,size.height*0.09062395);
    path_0.lineTo(size.width*0.5511111,size.height*0.04129611);
    path_0.cubicTo(size.width*0.5459321,size.height*0.03873067,size.width*0.5401008,size.height*0.03660027,size.width*0.5341050,size.height*0.03480526);
    path_0.cubicTo(size.width*0.5068478,size.height*0.02638467,size.width*0.4778116,size.height*0.02958259,size.width*0.4518663,size.height*0.04015603);
    path_0.lineTo(size.width*0.3303748,size.height*0.09067901);
    path_0.lineTo(size.width*0.2117863,size.height*0.1395066);
    path_0.cubicTo(size.width*0.2063102,size.height*0.1413546,size.width*0.2006805,size.height*0.1439715,size.width*0.1951715,size.height*0.1469419);
    path_0.cubicTo(size.width*0.1699434,size.height*0.1602613,size.width*0.1516730,size.height*0.1830541,size.width*0.1408034,size.height*0.2088767);
    path_0.lineTo(size.width*0.09062135,size.height*0.3305087);
    path_0.close();

    Paint paint_0_stroke = Paint()..style=PaintingStyle.stroke..strokeWidth=size.width*0.01000000;
    paint_0_stroke.color=Color(0xff000000).withOpacity(1);
    canvas.drawPath(path_0,paint_0_stroke);

    Paint paint_0_fill = Paint()..style=PaintingStyle.fill;
    paint_0_fill.color = Color(0xff729fcf).withOpacity(1.0);
    canvas.drawPath(path_0,paint_0_fill);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}