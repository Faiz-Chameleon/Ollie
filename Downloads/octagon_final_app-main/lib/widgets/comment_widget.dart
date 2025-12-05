import 'package:flutter/material.dart';
import 'package:octagon/utils/heart_icon_animation.dart';
import 'package:octagon/utils/theme/theme_constants.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;

  CommentWidget(this.comment);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}
const currentUser = User(name: "nick");
class _CommentWidgetState extends State<CommentWidget> {
  void _toggleIsLiked() {
    setState(() => widget.comment.toggleLikeFor(currentUser));
  }

  Text _buildRichText() {
    var currentTextData = StringBuffer();
    var textSpans = <TextSpan>[
      TextSpan(text: '${widget.comment.user!.name} ', style: whiteColor14BoldTextStyle),
    ];
    this.widget.comment.text!.split(' ').forEach((word) {
      if (word.startsWith('#') && word.length > 1) {
        if (currentTextData.isNotEmpty) {
          textSpans.add(TextSpan(text: currentTextData.toString()));
          currentTextData.clear();
        }
        textSpans.add(TextSpan(text: '$word ', style: whiteColor14TextStyle));
      } else {
        currentTextData.write('$word ');
      }
    });
    if (currentTextData.isNotEmpty) {
      textSpans.add(TextSpan(text: currentTextData.toString()));
      currentTextData.clear();
    }
    return Text.rich(TextSpan(children: textSpans));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: <Widget>[
          _buildRichText(),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: HeartIconAnimator(
              isLiked: widget.comment.isLikedBy(currentUser),
              size: 14.0,
              onTap: _toggleIsLiked,
            ),
          ),
        ],
      ),
    );
  }
}

class User {
  final String? name;

  final String? imageUrl;

  const User({
 this.name,
    this.imageUrl,
  });
}

class Comment {
  String? text;
  final User? user;
  final DateTime? commentedAt;
  List<Like>? likes;

  bool isLikedBy(User user) {
    return likes!.any((like) => like.user!.name == user.name);
  }

  void toggleLikeFor(User user) {
    if (isLikedBy(user)) {
      likes!.removeWhere((like) => like.user!.name == user.name);
    } else {
      likes!.add(Like(user: user));
    }
  }

  Comment({
     this.text,
     this.user,
     this.commentedAt,
     this.likes,
  });
}

class Like {
  final User? user;

  Like({@required this.user});
}