import 'package:flutter/material.dart';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/themes.dart';
import 'package:concieltalk/utils/platform_infos.dart';

Future<T?> showAdaptiveBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isDismissible = true,
  bool isScrollControlled = true,
}) =>
    showModalBottomSheet(
      context: context,
      builder: builder,
      useRootNavigator: !PlatformInfos.isMobile,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      constraints: const BoxConstraints(
        maxHeight: 480,
        maxWidth: ConcielThemes.columnWidth * 1.5,
      ),
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConfig.borderRadius),
          topRight: Radius.circular(AppConfig.borderRadius),
        ),
      ),
    );
