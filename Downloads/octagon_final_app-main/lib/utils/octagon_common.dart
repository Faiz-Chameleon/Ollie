import 'package:flutter/material.dart';
import 'package:octagon/utils/polygon/polygon_border.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:shape_maker/shape_maker.dart';


class OctagonShape extends StatelessWidget {
  Widget? child;
  double height = 50, width = 50;
  Color? bgColor = purpleColor;

  OctagonShape(
      {this.bgColor, this.child, this.height = 50, this.width = 50, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShapeMaker(
      height: height,
      width: width,
      bgColor: child == null ?Colors.yellow:Colors.transparent,
      widget: child?? Container(
        margin: EdgeInsets.all(height / 20),
        child: ShapeMaker(
          bgColor: Colors.black,
          height: height / 2,
          width: width /2 ,
          widget: Container(
            margin: EdgeInsets.all(height / 7),
            child: ShapeMaker(
                height: height / 3,
                width: width /3 ,
                bgColor: Colors.white,
                widget: Center(child: child)
            ),
          ),
        ),
      ),
    );
     Stack(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          height: height,
          width: width,
          decoration: const ShapeDecoration(
            color: Colors.black,
            shape: PolygonBorder(
              sides: 8,
              rotate: 68,
            ),
          ),
          child: child ??
              Container(
                decoration: const ShapeDecoration(
                  shape: PolygonBorder(
                    sides: 8,
                    rotate: 68,
                    side: BorderSide(color: Colors.black, width: 8),
                  ),
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: const ShapeDecoration(
                    shape: PolygonBorder(
                      sides: 8,
                      rotate: 68,
                      side: BorderSide(color: Colors.white, width: 8),
                    ),
                  ),
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                ),
              ),
        ),
        Container(
          height: height,
          width: width,
          decoration: ShapeDecoration(
            shape: PolygonBorder(
              sides: 8,
              rotate: 68,
              side: BorderSide(
                  color: bgColor ?? Colors.yellow,
                  width: bgColor != null
                      ? 8
                      : child == null
                          ? 7
                          : 0),
            ),
          ),
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
        ),
      ],
    );
  }
}
