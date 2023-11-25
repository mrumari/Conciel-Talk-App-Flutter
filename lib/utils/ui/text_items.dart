import 'package:concieltalk/config/color_constants.dart';
import 'package:flutter/material.dart';

Widget customTextField({
  TextEditingController? textEditController,
  String? hintText,
  bool addKey = false,
  bool passwordField = false,
  bool obscureText = false,
  VoidCallback? onVisibilityToggle,
}) {
  return TextField(
    key: addKey ? Key(hintText!) : null,
    obscureText: passwordField && obscureText,
    autocorrect: false,
    controller: textEditController,
    cursorColor: personalColorScheme.primary,
    decoration: InputDecoration(
      suffixIcon: passwordField
          ? IconButton(
              onPressed: onVisibilityToggle,
              icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
            )
          : null,
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 16,
        color: Colors.grey.withOpacity(0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(5.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(
          color: Colors.grey,
        ),
      ),
    ),
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
  );
}

class IconButtonWithText extends StatelessWidget {
  final IconData icon;
  final double size;
  final String text;
  final Color color;
  final VoidCallback? onPressed;

  const IconButtonWithText({
    Key? key,
    required this.text,
    required this.icon,
    required this.size,
    required this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          height: 18,
          width: 10,
        ),
        IconButton(
          visualDensity: const VisualDensity(
            horizontal: VisualDensity.minimumDensity,
            vertical: VisualDensity.minimumDensity,
          ),
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: size * 1.5,
            color: color,
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: size,
            color: personalColorScheme.outlineVariant,
            overflow: TextOverflow.fade,
            fontFamily: 'Exo',
            letterSpacing: 1,
            fontWeight: FontWeight.normal,
            height: 0.5,
          ),
        ),
      ],
    );
  }
}
