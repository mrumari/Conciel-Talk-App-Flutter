import 'dart:async';
import 'package:concieltalk/config/color_constants.dart';
import 'package:flutter/material.dart';

Future<bool> openDialog(
  BuildContext context,
  String title,
  String question,
  String buttonPos,
  String buttonNeg,
  IconData icon,
) async {
  switch (await showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return SimpleDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              style: TextStyle(color: personalColorScheme.primary),
              title,
            ),
            Icon(
              icon,
              size: 28,
              color: personalColorScheme.primary,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        children: [
          Text(
            question,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Text(
                  style: TextStyle(color: personalColorScheme.secondary),
                  buttonNeg,
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: personalColorScheme.tertiary,
                    ),
                    buttonPos,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  )) {
    case 0:
      return false;
    case 1:
      return true;
  }
  return false;
}
