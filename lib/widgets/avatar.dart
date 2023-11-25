import 'package:concieltalk/config/app_config.dart';
import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:concieltalk/widgets/mxc_image.dart';

class Avatar extends StatelessWidget {
  final Uri? mxContent;
  final String? name;
  final double size;
  final void Function()? onTap;
  static const double defaultSize = 44;
  final Client? client;
  final double fontSize;

  const Avatar({
    this.mxContent,
    this.name,
    this.size = defaultSize,
    this.onTap,
    this.client,
    this.fontSize = 18,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late String fallbackLetters;
    final name = this.name;
    fallbackLetters = name ?? '@';
    if (name != null) {
      if (name.runes.length >= 2) {
        fallbackLetters = String.fromCharCodes(name.runes, 0, 2);
        fallbackLetters = fallbackLetters.substring(0, 1).toUpperCase() +
            fallbackLetters.substring(1, 2);
      } else if (name.runes.length == 1) {
        fallbackLetters = name;
      }
    }
    final noPic = mxContent == null ||
        mxContent.toString().isEmpty ||
        mxContent.toString() == 'null';
    final textWidget = Center(
      child: Text(
        fallbackLetters,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
        ),
      ),
    );
    final borderRadius = BorderRadius.circular(size / 2);
    final container = ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          noPic
              ? Image(
                  image: concielAvatarThumb,
                  height: size,
                  width: size,
                  fit: BoxFit.cover,
                )
              : const SizedBox.shrink(),
          Container(
            width: size,
            height: size,
            color: noPic
                ? Colors.grey // name?.lightColorAvatar
                : Theme.of(context).secondaryHeaderColor,
            child: noPic
                ? textWidget
                : MxcImage(
                    key: Key(mxContent.toString()),
                    uri: mxContent,
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                    placeholder: (_) => textWidget,
                    cacheKey: mxContent.toString(),
                  ),
          ),
        ],
      ),
    );
    if (onTap == null) return container;
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: container,
    );
  }
}
