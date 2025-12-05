import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:octagon/screen/tabs_screen.dart';
import 'package:octagon/utils/colors.dart';
import 'package:octagon/utils/theme/theme_constants.dart';
import 'package:resize/resize.dart';
import '../model/team_list_response.dart';
import '../networking/model/chat_room.dart';
import '../utils/chat_room.dart';
import '../utils/polygon/polygon_border.dart';
import '../utils/team_icon_bg.dart';

class FacebookCardStory extends StatelessWidget {
  final String? profile_image;
  final String? board_image;
  final bool? isVisible;
  // final String? user_name;
  final String? roomId;
  final TeamData? sportInfo;
  bool isUserSelected = false;

  FacebookCardStory(
      {this.profile_image,
      this.board_image,
      this.isVisible,
      this.isUserSelected = false,
      // this.user_name,
      required this.roomId,
      this.sportInfo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // currentPage.add(10);///chat page number
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoomScreen(sportInfo: sportInfo, chatRoom: ChatRoom(id: roomId))));
      },
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            OctagonBorderContainer(
              isSelected: isUserSelected,
              child: CachedNetworkImage(
                imageUrl: profile_image!,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                width: 65,
                height: 65,
                placeholder: (context, url) => const SizedBox(height: 20, child: Center(child: Icon(Icons.image_rounded))),
                errorWidget: (context, url, error) => const Icon(Icons.error, color: kcPurpleColor, size: 30),
              ),
            )

            // Container(
            //   height: 10.vh,
            //   width: 85,
            //   // decoration: const ShapeDecoration(
            //   //   color: Colors.yellow,
            //   //   shape: PolygonBorder(
            //   //     sides: 8,
            //   //     rotate: 68,
            //   //   ),
            //   // ),
            //   alignment: Alignment.center,
            //   // clipBehavior: Clip.antiAlias,
            //   child: Container(
            //     height: 85,
            //     width: 85,
            //     decoration: const ShapeDecoration(
            //       color: Colors.black,
            //       shape: PolygonBorder(
            //         sides: 8,
            //         rotate: 68,
            //       ),
            //     ),
            //     alignment: Alignment.center,
            //     clipBehavior: Clip.antiAlias,
            //     child: TeamOctagonShape(
            //       width: 75,
            //       height: 75,
            //       isHighlighted: isUserSelected,
            //       child:
            //       CachedNetworkImage(
            //         imageUrl: profile_image!,
            //         fit: BoxFit.cover,
            //         alignment: Alignment.center,
            //         width: 65,
            //         height: 65,
            //         placeholder: (context, url) => const SizedBox(height: 20, child: Center(child: CircularProgressIndicator())),
            //         errorWidget: (context, url, error) => const Icon(Icons.error),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class Facebook_Fav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () {},
      shape: CircleBorder(),
      fillColor: Colors.white,
      constraints: BoxConstraints.tightFor(width: 42.0, height: 42.0),
      child: Icon(
        Icons.add,
        color: whiteColor,
        size: 30,
      ),
    );
  }
}

class OctagonBorderContainer extends StatelessWidget {
  final Widget child;
  final double size;
  final bool isSelected;

  const OctagonBorderContainer({
    Key? key,
    required this.child,
    this.size = 80,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: isSelected ? _OctagonPainter() : null,
      child: Container(
        height: size,
        width: size,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _OctagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Paint paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final Path path = Path();
    const int sides = 8;
    final angle = (2 * pi) / sides;
    final double inset = 8;

    for (int i = 0; i <= sides; i++) {
      final x = radius + (radius - inset) * cos(angle * i - pi / 8);
      final y = radius + (radius - inset) * sin(angle * i - pi / 8);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
