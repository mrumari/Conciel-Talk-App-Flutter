import 'dart:math';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:concieltalk/utils/ui/central_buttons.dart';
import 'package:concieltalk/utils/ui/page_transitions.dart';
import 'package:concieltalk/utils/ui/ring_widgets.dart';
import 'package:cubixd/cubixd.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:concieltalk/widgets/layouts/max_width_body.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'settings_style.dart';

class SettingsStyleView extends StatelessWidget {
  final SettingsStyleController controller;

  const SettingsStyleView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const colorPickerSize = 32.0;
    final wallpaper = Matrix.of(context).wallpaper;
    final size = Size(1.sw, 1.sh);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(L10n.of(context)!.changeTheme),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: MaxWidthBody(
        withScrolling: true,
        child: Column(
          children: [
            const Divider(height: 1),
            ListTile(
              title: Text(
                'Scale UI',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Text('× ${AppConfig.cubeRingScale}'),
            ),
            Slider.adaptive(
              min: 0.75,
              max: 1.0,
              divisions: 10,
              value: AppConfig.cubeRingScale,
              semanticFormatterCallback: (d) => d.toString(),
              onChanged: controller.changeRingCubeScale,
            ),
            Transform.scale(
              scale: AppConfig.cubeRingScale,
              child: Container(
                height: size.width,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RingWidget(
                      animateNow: false,
                      key: controller.ringWidgetKey,
                      trackColor: personalColorScheme.surfaceVariant,
                      innerRingColor:
                          personalColorScheme.primary.withOpacity(0.3),
                    ),
                    // WHERE and CLOUD
                    ArcButton(
                      startAngle: 0,
                      sweepAngle: 120,
                      radius: 96.r,
                      strokeWidth: 50.r,
                      onTap: () {},
                      child: ConcielArcText(
                        radius: 96.r,
                        start: -120,
                        sweep: 120,
                        text: 'CLOUD',
                        color: personalColorScheme.outline,
                        fontSize: 18,
                      ),
                    ),
                    // WHAT and SOCIAL
                    ArcButton(
                      startAngle: 120,
                      sweepAngle: 120,
                      radius: 96.r,
                      strokeWidth: 50.r,
                      onTap: () {},
                      child: ConcielArcText(
                        radius: 96.r,
                        start: 0,
                        sweep: 120,
                        text: 'SOCIAL',
                        color: personalColorScheme.outline,
                        fontSize: 18,
                      ),
                    ),
                    // WHEN and PLAN
                    ArcButton(
                      startAngle: 240,
                      sweepAngle: 120,
                      radius: 96.r,
                      strokeWidth: 50.r,
                      onTap: () {},
                      child: ConcielArcText(
                        radius: 96.r,
                        start: 120,
                        sweep: 120,
                        text: 'PLAN',
                        color: personalColorScheme.outline,
                        fontSize: 18,
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 96.w,
                          height: 96.w,
                          decoration: const ShapeDecoration(
                            color: Colors.transparent,
                            shape: StarBorder.polygon(sides: 6),
                          ),
                        ),
                        AnimatedCubixD(
                          stars: false,
                          size: 89.6.w,
                          onPanUpdate: () {},
                          afterSelDel: const Duration(seconds: 2),
                          shadow: false,
                          advancedXYposAnim: AnimRequirements(
                            controller: controller.cubeAnimCtl,
                            xAnimation:
                                controller.xTween!.animate(controller.xCurve),
                            yAnimation:
                                controller.yTween!.animate(controller.yCurve),
                          ),
                          onSelected: (SelectedSide opt) {
                            switch (opt) {
                              case SelectedSide.none:
                                return false;
                              case SelectedSide.top: // CHAT
                                return true;
                              case SelectedSide.bottom:
                                return true;
                              case SelectedSide.left:
                                return true;
                              case SelectedSide.right: // PHONE
                                return true;
                              case SelectedSide.front: // MAIL
                                return true;
                              case SelectedSide.back:
                                return true;
                            }
                          },
                          left: cubeFace(
                            // WHERE
                            0,
                            ConcielIcons.blank,
                            personalColorScheme.outline,
                            cubeFaceLeft,
                            cubeFaceLeft,
                          ),
                          front: cubeFace(
                            0,
                            ConcielIcons.mail,
                            personalColorScheme.outline,
                            primaryColorOff,
                            cubeFaceFront,
                          ),
                          back: cubeFace(
                            // WHEN
                            0,
                            ConcielIcons.blank,
                            personalColorScheme.outline,
                            cubeFaceBack,
                            cubeFaceBack,
                          ),
                          top: cubeFace(
                            -45 * pi / 180,
                            ConcielIcons.chat,
                            personalColorScheme.outline,
                            primaryColorOff,
                            cubeFaceTop,
                          ),
                          bottom: cubeFace(
                            // WHAT
                            0,
                            ConcielIcons.blank,
                            personalColorScheme.outline,
                            cubeFaceBottom,
                            cubeFaceBottom,
                          ),
                          right: cubeFace(
                            -90 * pi / 180,
                            ConcielIcons.phone,
                            personalColorScheme.outline,
                            primaryColorOff,
                            cubeFaceRight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              title: Text(
                L10n.of(context)!.messages,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Material(
                color: Theme.of(context).colorScheme.primary,
                elevation: 6,
                shadowColor:
                    Theme.of(context).secondaryHeaderColor.withAlpha(100),
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                child: Padding(
                  padding: EdgeInsets.all(16 * AppConfig.bubbleSizeFactor),
                  child: Text(
                    'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize:
                          AppConfig.messageFontSize * AppConfig.fontSizeFactor,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text(L10n.of(context)!.fontSize),
              trailing: Text('× ${AppConfig.fontSizeFactor}'),
            ),
            Slider.adaptive(
              min: 0.5,
              max: 2.5,
              divisions: 20,
              value: AppConfig.fontSizeFactor,
              semanticFormatterCallback: (d) => d.toString(),
              onChanged: controller.changeFontSizeFactor,
            ),
            ListTile(
              title: Text(L10n.of(context)!.bubbleSize),
              trailing: Text('× ${AppConfig.bubbleSizeFactor}'),
            ),
            Slider.adaptive(
              min: 0.5,
              max: 1.5,
              divisions: 4,
              value: AppConfig.bubbleSizeFactor,
              semanticFormatterCallback: (d) => d.toString(),
              onChanged: controller.changeBubbleSizeFactor,
            ),
            SizedBox(
              height: colorPickerSize + 24,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: SettingsStyleController.customColors
                    .map(
                      (color) => Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(colorPickerSize),
                          onTap: () => controller.setChatColor(color),
                          child: color == null
                              ? Material(
                                  elevation:
                                      AppConfig.colorSchemeSeed?.value == null
                                          ? 100
                                          : 0,
                                  shadowColor: AppConfig.colorSchemeSeed,
                                  borderRadius:
                                      BorderRadius.circular(colorPickerSize),
                                  child: Image.asset(
                                    'assets/colors.png',
                                    width: colorPickerSize,
                                    height: colorPickerSize,
                                  ),
                                )
                              : Material(
                                  color: color,
                                  elevation: 6,
                                  borderRadius:
                                      BorderRadius.circular(colorPickerSize),
                                  child: SizedBox(
                                    width: colorPickerSize,
                                    height: colorPickerSize,
                                    child: controller.currentColor == color
                                        ? const Center(
                                            child: Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Divider(height: 1),
            RadioListTile<ThemeMode>(
              groupValue: controller.currentTheme,
              value: ThemeMode.system,
              title: Text(L10n.of(context)!.systemTheme),
              onChanged: controller.switchTheme,
            ),
            RadioListTile<ThemeMode>(
              groupValue: controller.currentTheme,
              value: ThemeMode.light,
              title: Text(L10n.of(context)!.lightTheme),
              onChanged: controller.switchTheme,
            ),
            RadioListTile<ThemeMode>(
              groupValue: controller.currentTheme,
              value: ThemeMode.dark,
              title: Text(L10n.of(context)!.darkTheme),
              onChanged: controller.switchTheme,
            ),
            const Divider(height: 1),
            ListTile(
              title: Text(
                L10n.of(context)!.wallpaper,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (wallpaper != null)
              ListTile(
                title: Image.file(
                  wallpaper,
                  height: 38,
                  fit: BoxFit.cover,
                ),
                trailing: const Icon(
                  Icons.delete_outlined,
                  color: Colors.red,
                ),
                onTap: controller.deleteWallpaperAction,
              ),
            Builder(
              builder: (context) {
                return ListTile(
                  title: Text(L10n.of(context)!.changeWallpaper),
                  trailing: Icon(
                    Icons.photo_outlined,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  onTap: controller.setWallpaperAction,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
