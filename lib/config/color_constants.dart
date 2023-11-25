import 'package:flutter/material.dart';

// const businessColorScheme = ColorScheme(
//  brightness: Brightness.light,
//  primary: Color(0xFF006398),
//  onPrimary: Color(0xFFFFFFFF),
//  primaryContainer: Color(0xFFCDE5FF),
//  onPrimaryContainer: Color(0xFF001D32),
//  secondary: Color(0xFF386B00),
//  onSecondary: Color(0xFFFFFFFF),
//  secondaryContainer: Color(0xFF99FB3F),
//  onSecondaryContainer: Color(0xFF0D2000),
//  tertiary: Color(0xFFBE003E),
//  onTertiary: Color(0xFFFFFFFF),
//  tertiaryContainer: Color(0xFFFFDADB),
//  onTertiaryContainer: Color(0xFF40000F),
//  error: Color(0xFFBA1A1A),
//  errorContainer: Color(0xFFFFDAD6),
//  onError: Color(0xFFFFFFFF),
//  onErrorContainer: Color(0xFF410002),
//  background: Color(0xFFFFFBFF),
//  onBackground: Color(0xFF030865),
//  surface: Color(0xFFFFFBFF),
//  onSurface: Color(0xFF030865),
//  surfaceVariant: Color(0xFFDEE3EB),
//  onSurfaceVariant: Color(0xFF42474E),
//  outline: Color(0xFF72787E),
//  onInverseSurface: Color(0xFFF1EFFF),
//  inverseSurface: Color(0xFF1E2578),
//  inversePrimary: Color(0xFF94CCFF),
//  shadow: Color(0xFF000000),
//  surfaceTint: Color(0xFF006398),
//  outlineVariant: Color(0xFFC2C7CF),
//  scrim: Color(0xFF000000),
//);
const Color primaryColor = Color(0xFF12a3f5);
const Color primaryColorOff = Color(0x5512A3F5);
const Color secondaryContainer = Color(0xFF534F5C);
const Color cubeFaceLeft = Color(0xFF1B1A25);
Color cubeFaceRight = const Color(0xFF2E2C39).withOpacity(0.15);
const Color cubeFaceTop = Color(0xFF2E2C39);
const Color cubeFaceFront = Color(0xFF1B1A25);
Color cubeFaceBack = const Color(0xFF2E2C39).withOpacity(0.15);
const Color cubeFaceBottom = Color(0xFF2E2C39);

enum ImgProvType { asset, memory, network }

const personalColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF12a3f5),
  onPrimary: Color(0xFF003352),
  primaryContainer: Color(0xFF322d3b),
  onPrimaryContainer: Color(0xFF534F5C),
  secondary: Color(0xFF85e527),
  onSecondary: Color(0xFF1A3700),
  secondaryContainer: Color(0xFF534F5C),
  onSecondaryContainer: Color(0xFF99FB3F),
  tertiary: Color(0xFFfe3863),
  onTertiary: Color(0xFF67001E),
  tertiaryContainer: Color(0xFF534F5C),
  onTertiaryContainer: Color(0xFFFFDADB),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF201F2C),
  onBackground: Color(0xFFcccccc),
  surface: Color(0xFF201f2c),
  onSurface: Color(0xFF999999),
  surfaceVariant: Color(0xFF201A24),
  onSurfaceVariant: Color(0xFFC4C4C4),
  outline: Color(0xFFcccccc),
  onInverseSurface: Color(0xFF201A24),
  inverseSurface: Color(0xFFE0E0FF),
  inversePrimary: Color(0xFF006398),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF534F5C),
  outlineVariant: Color(0xFFdddddd),
  scrim: Color(0xFF000000),
);

const personalColorSchemeLt = ColorScheme(
  brightness: Brightness.light,
  primary: Color.fromARGB(255, 10, 109, 167),
  onPrimary: Color(0xFF003352),
  primaryContainer: Color(0xFF322d3b),
  onPrimaryContainer: Color(0xFF534F5C),
  secondary: Color.fromARGB(255, 79, 134, 24),
  onSecondary: Color(0xFF1A3700),
  secondaryContainer: Color(0xFF534F5C),
  onSecondaryContainer: Color(0xFF99FB3F),
  tertiary: Color.fromARGB(255, 156, 33, 59),
  onTertiary: Color(0xFF67001E),
  tertiaryContainer: Color(0xFF534F5C),
  onTertiaryContainer: Color(0xFFFFDADB),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFFcccccc),
  onBackground: Color(0xFFcccccc),
  surface: Color(0xFFcccccc),
  onSurface: Color(0xFF999999),
  surfaceVariant: Color(0xFF201A24),
  onSurfaceVariant: Color(0xFFC4C4C4),
  outline: Color(0xFFcccccc),
  onInverseSurface: Color(0xFF201A24),
  inverseSurface: Color(0xFFE0E0FF),
  inversePrimary: Color(0xFF006398),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF534F5C),
  outlineVariant: Color(0xFFdddddd),
  scrim: Color(0xFF000000),
);

//class AppColors {
//  AppColors._();

//  static const Color spaceLight = Color(0xff2b3a67);
//  static const Color orangeWeb = Color(0xFFf59400);
//  static const Color white = Color(0xFFf5f5f5);
//  static const Color greyColor = Color(0xffaeaeae);
//  static const Color greyColor2 = Color(0xffE8E8E8);
//  static const Color lightGrey = Color(0xff928a8a);
//  static const Color burgundy = Color(0xFF880d1e);
//  static const Color indyBlue = personalColorScheme.onPrimary;
//  static const Color spaceCadet = Color(0xFF2a2d43);
//}
