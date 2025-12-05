import 'package:flutter/material.dart';
import 'package:octagon/utils/theme/theme_constants.dart';


/// Displays a text field styled to easily add comments to posts.
///
/// Quickly add emoji reactions.
class CommentBox extends StatelessWidget {
  /// Creates a [CommentBox].
  const CommentBox({
    Key? key,
    required this.textEditingController,
    // required this.focusNode,
    required this.onSubmitted,
  }) : super(key: key);


  final TextEditingController textEditingController;
  // final FocusNode focusNode;
  final Function(String?) onSubmitted;

  @override
  Widget build(BuildContext context) {
    final border = _border(context);
    return Container(
      decoration: BoxDecoration(
        color: appBgColor,
        border: Border(
            top: BorderSide(
              color: greyColor,
            )),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _emojiText('❤️'),
                _emojiText('🙌'),
                _emojiText('🔥'),
                _emojiText('👏🏻'),
                _emojiText('😢'),
                _emojiText('😍'),
                _emojiText('😮'),
                _emojiText('😂'),
              ],
            ),
          ),
          Row(
            children: [
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: CircleAvatar(
              //     backgroundColor: greyColor,
              //     radius: 21,
              //     child: const CircleAvatar(
              //       backgroundImage: NetworkImage("https://randomuser.me/api/portraits/men/46.jpg"),
              //     ),
              //   ),
              // ),
              Expanded(
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: textEditingController,
                  //focusNode: focusNode,
                  onSubmitted: (value){
                    onSubmitted(value);
                  },
                  minLines: 1,
                  maxLines: 10,
                  style: whiteColor16TextStyle,
                  decoration: InputDecoration(
                      suffix: _DoneButton(
                        //textEditorFocusNode: focusNode,
                        textEditingController: textEditingController,
                        onSubmitted: (value){
                          onSubmitted(value!);
                        },//onSubmitted,
                      ),
                      hintText: 'Add a comment...',
                      hintStyle: whiteColor16TextStyle,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      focusedBorder: border,
                      border: border,
                      enabledBorder: border),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
            ],
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      borderSide: BorderSide(
        color: greyColor,
        width: 0.5,
      ),
    );
  }

  Widget _emojiText(String emoji) {
    return GestureDetector(
      onTap: () {
        //focusNode.requestFocus();
        textEditingController.text = textEditingController.text + emoji;
        textEditingController.selection = TextSelection.fromPosition(
            TextPosition(offset: textEditingController.text.length));
      },
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

class _DoneButton extends StatefulWidget {
  const _DoneButton({
    Key? key,
    required this.onSubmitted,
    //required this.textEditorFocusNode,
    required this.textEditingController,
  }) : super(key: key);

  final Function(String?) onSubmitted;
  //final FocusNode textEditorFocusNode;
  final TextEditingController textEditingController;

  @override
  State<_DoneButton> createState() => _DoneButtonState();
}

class _DoneButtonState extends State<_DoneButton> {
  final fadedTextStyle =
  blueColor16BoldTextStyle;
  late TextStyle textStyle = fadedTextStyle;

  @override
  void initState() {
    super.initState();
    widget.textEditingController.addListener(() {
      if (widget.textEditingController.text.isNotEmpty) {
        textStyle = greyColor16BoldTextStyle;
      } else {
        textStyle = fadedTextStyle;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return /*widget.textEditorFocusNode.hasFocus
        ?*/ GestureDetector(
      onTap: () {
        widget.onSubmitted(widget.textEditingController.text);
      },
      child: Text(
        'Done',
        style: textStyle,
      ),
    );
        /*: const SizedBox.shrink();*/
  }



}