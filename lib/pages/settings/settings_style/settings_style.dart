import 'dart:math';

import 'package:concieltalk/utils/ui/page_transitions.dart';
import 'package:concieltalk/widgets/base_ring_state.dart';
import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/setting_keys.dart';
import 'package:concieltalk/widgets/theme_builder.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'settings_style_view.dart';

class SettingsStyle extends StatefulWidget {
  const SettingsStyle({Key? key}) : super(key: key);

  @override
  SettingsStyleController createState() => SettingsStyleController();
}

class SettingsStyleController extends State<SettingsStyle>
    with TickerProviderStateMixin {
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();
  late AnimationController cubeAnimCtl;
  late CurvedAnimation xCurve;
  late CurvedAnimation yCurve;
  Tween<double>? xTween;
  Tween<double>? yTween;

  @override
  void initState() {
    final cubeData = initCube(this, 500);
    cubeAnimCtl = cubeData[0];
    xCurve = cubeData[1];
    yCurve = cubeData[2];
    xTween = Tween<double>(begin: 0, end: 45 * pi / 180);
    yTween = Tween<double>(begin: -145 * pi / 180, end: 35 * pi / 180);
    cubeAnimCtl.forward();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ringWidgetKey.currentState?.animateColors();
    });
  }

  @override
  void dispose() {
// Dispose of the AnimationController to properly dispose of the Ticker
    cubeAnimCtl.dispose();
    super.dispose();
  }

  void setWallpaperAction() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
    );
    final pickedFile = picked?.files.firstOrNull;

    if (pickedFile == null) return;
    await Matrix.of(context)
        .store
        .setItem(SettingKeys.wallpaper, pickedFile.path);
    setState(() {});
  }

  void deleteWallpaperAction() async {
    Matrix.of(context).wallpaper = null;
    await Matrix.of(context).store.deleteItem(SettingKeys.wallpaper);
    setState(() {});
  }

  void setChatColor(Color? color) async {
    AppConfig.colorSchemeSeed = color;
    ThemeController.of(context).setPrimaryColor(color);
  }

  ThemeMode get currentTheme => ThemeController.of(context).themeMode;
  Color? get currentColor => ThemeController.of(context).primaryColor;

  static final List<Color?> customColors = [
    AppConfig.chatColor,
    Colors.indigo,
    Colors.green,
    Colors.orange,
    Colors.pink,
    Colors.blueGrey,
    null,
  ];

  void switchTheme(ThemeMode? newTheme) {
    if (newTheme == null) return;
    switch (newTheme) {
      case ThemeMode.light:
        ThemeController.of(context).setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.dark:
        ThemeController.of(context).setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.system:
        ThemeController.of(context).setThemeMode(ThemeMode.system);
        break;
    }
    setState(() {});
  }

  void changeFontSizeFactor(double d) {
    setState(() => AppConfig.fontSizeFactor = d);
    Matrix.of(context).store.setItem(
          SettingKeys.fontSizeFactor,
          AppConfig.fontSizeFactor.toString(),
        );
  }

  void changeRingCubeScale(double d) {
    setState(() => AppConfig.cubeRingScale = d);
    Matrix.of(context).store.setItem(
          SettingKeys.cubeRingScale,
          AppConfig.cubeRingScale.toString(),
        );
  }

  void changeBubbleSizeFactor(double d) {
    setState(() => AppConfig.bubbleSizeFactor = d);
    Matrix.of(context).store.setItem(
          SettingKeys.bubbleSizeFactor,
          AppConfig.bubbleSizeFactor.toString(),
        );
  }

  @override
  Widget build(BuildContext context) => SettingsStyleView(this);
}
