import 'package:flutter/material.dart';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import 'package:concieltalk/config/themes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'chat.dart';

class ChatEmojiPicker extends StatelessWidget {
  final ChatController controller;
  const ChatEmojiPicker(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: ConcielThemes.animationDuration,
      curve: ConcielThemes.animationCurve,
      height: controller.showEmojiPicker ? 1.sh / 2 : 0,
      child: controller.showEmojiPicker
          ? EmojiPicker(
              onEmojiSelected: controller.onEmojiSelected,
              onBackspacePressed: controller.emojiPickerBackspace,
            )
          : null,
    );
  }
}
