// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:flutter/material.dart';

class ConcielIcons {
  ConcielIcons._();
  static const _kFontFam = 'ConcielIcons';
  static const _kFontPkg = null;
  static const IconData msg_notifier =
      IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData blank = Icons.check_box_outline_blank;
  static const IconData share =
      IconData(0xe802, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData chat =
      IconData(0xe803, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData fav =
      IconData(0xe804, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData fav_empty =
      IconData(0xe805, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData mail =
      IconData(0xe806, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData book =
      IconData(0xe807, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData shop =
      IconData(0xe808, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData settings =
      IconData(0xe80c, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData back =
      IconData(0xe81b, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData user =
      IconData(0xe81c, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData video_camera =
      IconData(0xe825, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData camera =
      IconData(0xe826, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData picture =
      IconData(0xe827, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData users =
      IconData(0xe82b, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData phone =
      IconData(0xe830, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData map_marker =
      IconData(0xe833, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData microphone =
      IconData(0xe85e, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData history =
      IconData(0xe863, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData vote_yes =
      IconData(0xe86d, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData vote_no =
      IconData(0xe86e, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData search =
      IconData(0xe86f, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData filter =
      IconData(0xe88f, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData doc_file =
      IconData(0xf0f6, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData pdf_file =
      IconData(0xf1c1, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData image_file =
      IconData(0xf1c5, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData audio_file =
      IconData(0xf1c7, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData video_file =
      IconData(0xf1c8, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}

Widget rotatedIcon(IconData icon, {double? size, Color? color, double? angle}) {
  double rotate = angle ?? 0;
  rotate = rotate * pi / 180;
  return Transform.rotate(
    angle: rotate,
    child: Icon(
      icon,
      color: color ?? Colors.white,
      size: size ?? 24.0,
    ),
  );
}
