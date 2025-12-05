import 'package:flutter/material.dart';
import 'package:octagon/utils/polygon/polygon_border.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:shape_maker/shape_maker.dart';

class TeamOctagonShape extends StatelessWidget {
  Widget? child;
  double height = 50, width = 50;
  Color? bgColor = purpleColor;
  bool isHighlighted = false;

  TeamOctagonShape(
      {this.bgColor, this.child, this.height = 50, this.width = 50, Key? key, this.isHighlighted = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          height: height,
          width: width,
          decoration: const ShapeDecoration(
            color: Colors.black,
            shape: PolygonBorder(
              sides: 8,
              rotate: 68,
            ),
          ),
          child: child!=null?
              ShapeMaker(
                    bgColor: isHighlighted ? Colors.yellow : Colors.black,
                    widget: Container(
                      margin: const EdgeInsets.all(5),
                      child: ShapeMaker(
                      bgColor: Colors.black,
                      widget: child,
                      ),
                    ),
                  ) :
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
        // if(isHighlighted)
        // Container(
        //   height: height,
        //   width: width,
        //   decoration: ShapeDecoration(
        //     shape: PolygonBorder(
        //       sides: 8,
        //       rotate: 68,
        //       side: BorderSide(
        //           color: bgColor ?? Colors.yellow,
        //           width: bgColor != null
        //               ? 8
        //               : child == null
        //               ? 7
        //               : isHighlighted ? 2 : 0),
        //     ),
        //   ),
        //   alignment: Alignment.center,
        //   clipBehavior: Clip.antiAlias,
        // ),
      ],
    );
  }
}
