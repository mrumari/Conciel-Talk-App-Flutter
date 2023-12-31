import 'package:concieltalk/config/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vrouter/vrouter.dart';

import 'package:concieltalk/utils/platform_infos.dart';
import 'app_config.dart';

abstract class ConcielThemes {
  static const double columnWidth = 360.0;

  static const double navRailWidth = 64.0;

  static bool isColumnModeByWidth(double width) =>
      width > columnWidth * 2 + navRailWidth;

  static bool isColumnMode(BuildContext context) =>
      isColumnModeByWidth(MediaQuery.sizeOf(context).width);

  static bool getDisplayNavigationRail(BuildContext context) =>
      !VRouter.of(context).path.startsWith('/settings');

  static const fallbackTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontFamilyFallback: ['NotoEmoji'],
  );

  static var fallbackTextTheme = const TextTheme(
    bodyLarge: fallbackTextStyle,
    bodyMedium: fallbackTextStyle,
    labelLarge: fallbackTextStyle,
    bodySmall: fallbackTextStyle,
    labelSmall: fallbackTextStyle,
    displayLarge: fallbackTextStyle,
    displayMedium: fallbackTextStyle,
    displaySmall: fallbackTextStyle,
    headlineMedium: fallbackTextStyle,
    headlineSmall: fallbackTextStyle,
    titleLarge: fallbackTextStyle,
    titleMedium: fallbackTextStyle,
    titleSmall: fallbackTextStyle,
  );

  static LinearGradient backgroundGradient(
    BuildContext context,
    int alpha,
  ) {
    const colorScheme = personalColorScheme;
    return LinearGradient(
      begin: Alignment.topCenter,
      colors: [
        colorScheme.primaryContainer.withAlpha(alpha),
        colorScheme.secondaryContainer.withAlpha(alpha),
        colorScheme.tertiaryContainer.withAlpha(alpha),
        colorScheme.primaryContainer.withAlpha(alpha),
      ],
    );
  }

  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Curve animationCurve = Curves.easeInOut;

  static ThemeData buildTheme(Brightness brightness, [Color? seed]) =>
      ThemeData(
        visualDensity: VisualDensity.standard,
        useMaterial3: true,
        brightness: brightness,
        colorSchemeSeed: seed ?? AppConfig.colorSchemeSeed,
        textTheme: PlatformInfos.isDesktop || PlatformInfos.isWeb
            ? brightness == Brightness.light
                ? Typography.material2018().black.merge(fallbackTextTheme)
                : Typography.material2018().white.merge(fallbackTextTheme)
            : null,
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
        dividerColor: brightness == Brightness.light
            ? Colors.blueGrey.shade50
            : Colors.blueGrey.shade900,
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: UnderlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
          ),
          filled: true,
        ),
        appBarTheme: AppBarTheme(
          surfaceTintColor: brightness == Brightness.light
              ? personalColorScheme.surfaceVariant
              : personalColorScheme.surfaceTint,
          shadowColor: Colors.black.withAlpha(64),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: personalColorScheme.background,
            systemNavigationBarDividerColor: personalColorScheme.surfaceVariant,
            systemNavigationBarContrastEnforced: false,
            systemStatusBarContrastEnforced: false,
            systemNavigationBarIconBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light, // Android (dark icons)
            statusBarBrightness: Brightness.dark,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
            ),
          ),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            ),
          ),
        ),
      );
}

extension on Brightness {
  // ignore: unused_element
  Brightness get reversed =>
      this == Brightness.dark ? Brightness.light : Brightness.dark;
}
