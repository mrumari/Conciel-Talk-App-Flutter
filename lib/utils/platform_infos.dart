import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:package_info_plus/package_info_plus.dart';

import '../config/app_config.dart';

abstract class PlatformInfos {
  static bool get isWeb => kIsWeb;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  static bool get isCupertinoStyle => isIOS || isMacOS;

  static bool get isMobile => isAndroid || isIOS;

  /// For desktops which don't support ChachedNetworkImage yet
  static bool get isBetaDesktop => isWindows || isLinux;

  static bool get isDesktop => isLinux || isWindows || isMacOS;

  static bool get usesTouchscreen => !isMobile;

  static bool get platformCanRecord => (isMobile || isMacOS);

  static String get clientName =>
      '${AppConfig.applicationName} ${isWeb ? 'web' : Platform.operatingSystem}${kReleaseMode ? '' : 'Debug'}';

  static Future<String> getVersion() async {
    var version = kIsWeb ? 'Web' : 'Unknown';
    try {
      version = (await PackageInfo.fromPlatform()).version;
    } catch (_) {}
    return version;
  }

  static void infoDialog(BuildContext context) async {
    final version = await PlatformInfos.getVersion();
    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: ListBody(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  IconTheme(
                    data: themeData.iconTheme,
                    child: Image.asset(
                      'assets/logo.png',
                      width: 36,
                      height: 36,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: ListBody(
                        children: <Widget>[
                          Text(
                            AppConfig.applicationName,
                            style: themeData.textTheme.headlineSmall,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            'Version: $version',
                            style: themeData.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              /*
              OutlinedButton(
                onPressed: () => VRouter.of(context).to('logs'),
                child: const Text('Logs'),
              ),
              */
            ],
          ),
          actions: <Widget>[
            Align(
              alignment: Alignment.center,
              child: TextButton(
                child: Text(
                  themeData.useMaterial3
                      ? localizations.closeButtonLabel
                      : localizations.closeButtonLabel.toUpperCase(),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
          scrollable: true,
        );
      },
    );
  }
}
