import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vrouter/vrouter.dart';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/utils/id_share.dart';
import 'package:concieltalk/utils/platform_infos.dart';
import 'package:concieltalk/widgets/avatar.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'settings.dart';

class SettingsView extends StatelessWidget {
  final SettingsController controller;
  final String? start;

  const SettingsView(this.controller, {Key? key, this.start}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showChatBackupBanner = controller.showChatBackupBanner;
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          onPressed: () {
            VRouter.of(context).pop();
          },
        ),
        title: Text(L10n.of(context)!.settings),
        actions: [
          TextButton.icon(
            onPressed: controller.logoutAction,
            label: Text(L10n.of(context)!.logout),
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: ListTileTheme(
        iconColor: Theme.of(context).colorScheme.onBackground,
        child: ListView(
          key: const Key('SettingsListViewContent'),
          children: <Widget>[
            FutureBuilder<Profile>(
              future: controller.profileFuture,
              builder: (context, snapshot) {
                final profile = snapshot.data;
                final mxid =
                    Matrix.of(context).client.userID ?? L10n.of(context)!.user;
                final displayname =
                    profile?.displayName ?? mxid.localpart ?? mxid;
                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 8,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Stack(
                        children: [
                          Material(
                            elevation: Theme.of(context)
                                    .appBarTheme
                                    .scrolledUnderElevation ??
                                4,
                            shadowColor:
                                Theme.of(context).appBarTheme.shadowColor,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                              borderRadius: BorderRadius.circular(
                                Avatar.defaultSize * 2.5,
                              ),
                            ),
                            child: Avatar(
                              mxContent: profile?.avatarUrl,
                              name: displayname,
                              size: Avatar.defaultSize * 2.5,
                              fontSize: 18 * 2.5,
                            ),
                          ),
                          if (profile != null)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: FloatingActionButton(
                                mini: true,
                                onPressed: controller.setAvatarAction,
                                heroTag: null,
                                child: Icon(
                                  ConcielIcons.camera,
                                  color: personalColorScheme.outline
                                      .withOpacity(0.75),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: controller.setDisplaynameAction,
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 16,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.onBackground,
                            ),
                            label: Text(
                              displayname,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => IdentityShare.share(mxid, context),
                            icon: const Icon(
                              Icons.copy_outlined,
                              size: 14,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                            label: Text(
                              mxid,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const Divider(thickness: 1),
            ListTile(
              leading: Text(
                String.fromCharCode(Icons.format_paint_outlined.codePoint),
                style: TextStyle(
                  inherit: false,
                  color: personalColorScheme.outline.withOpacity(0.9),
                  fontSize: 24.0,
                  fontWeight: FontWeight.w100,
                  fontFamily: Icons.format_paint_outlined.fontFamily,
                  package: Icons.format_paint_outlined.fontPackage,
                ),
              ),
              title: Text(L10n.of(context)!.changeTheme),
              onTap: () => VRouter.of(context).to('style'),
              trailing: rotatedIcon(
                ConcielIcons.back,
                size: 12,
                color: personalColorScheme.outline,
                angle: 180,
              ),
            ),
            ListTile(
              leading: const Icon(ConcielIcons.user),
              title: const Text('Personal Information'),
              onTap: () => VRouter.of(context).to('style'),
              trailing: rotatedIcon(
                ConcielIcons.back,
                size: 12,
                color: personalColorScheme.outline,
                angle: 180,
              ),
            ),
            ListTile(
              leading: Icon(
                ConcielIcons.msg_notifier,
                color: personalColorScheme.outline.withOpacity(0.9),
              ),
              title: Text(L10n.of(context)!.notifications),
              onTap: () => VRouter.of(context).to('notifications'),
              trailing: rotatedIcon(
                ConcielIcons.back,
                size: 12,
                color: personalColorScheme.outline,
                angle: 180,
              ),
            ),
            ListTile(
              leading: Text(
                String.fromCharCode(Icons.computer_outlined.codePoint),
                style: TextStyle(
                  inherit: false,
                  color: personalColorScheme.outline.withOpacity(0.9),
                  fontSize: 24.0,
                  fontWeight: FontWeight.w100,
                  fontFamily: Icons.computer_outlined.fontFamily,
                  package: Icons.computer_outlined.fontPackage,
                ),
              ),
              title: Text(L10n.of(context)!.devices),
              onTap: () => VRouter.of(context).to('devices'),
              trailing: rotatedIcon(
                ConcielIcons.back,
                size: 12,
                color: personalColorScheme.outline,
                angle: 180,
              ),
            ),
            ListTile(
              leading: const Icon(ConcielIcons.chat),
              title: Text(L10n.of(context)!.chat),
              onTap: () => VRouter.of(context).to('chat'),
              trailing: rotatedIcon(
                ConcielIcons.back,
                size: 12,
                color: personalColorScheme.outline,
                angle: 180,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: Text(L10n.of(context)!.security),
              onTap: () => VRouter.of(context).to('security'),
              trailing: rotatedIcon(
                ConcielIcons.back,
                size: 12,
                color: personalColorScheme.outline.withOpacity(0.9),
                angle: 180,
              ),
            ),
            const Divider(thickness: 1),
            if (showChatBackupBanner == null)
              ListTile(
                leading: Icon(
                  Icons.backup_outlined,
                  color: personalColorScheme.outline.withOpacity(0.9),
                ),
                title: Text(L10n.of(context)!.chatBackup),
                trailing: const CircularProgressIndicator.adaptive(),
              )
            else
              SwitchListTile.adaptive(
                controlAffinity: ListTileControlAffinity.trailing,
                value: controller.showChatBackupBanner == false,
                secondary: Icon(
                  Icons.backup_outlined,
                  color: personalColorScheme.outline.withOpacity(0.9),
                ),
                title: Text(L10n.of(context)!.chatBackup),
                onChanged: controller.firstRunBootstrapAction,
              ),
            const Divider(thickness: 1),
            ListTile(
              leading: const Icon(Icons.help_outline_outlined),
              title: Text(L10n.of(context)!.help),
              onTap: () => launchUrlString(AppConfig.supportUrl),
              trailing: const Icon(Icons.open_in_new_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.shield_sharp),
              title: Text(L10n.of(context)!.privacy),
              onTap: () => launchUrlString(AppConfig.privacyUrl),
              trailing: const Icon(Icons.open_in_new_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(L10n.of(context)!.about),
              onTap: () => PlatformInfos.infoDialog(context),
              trailing: rotatedIcon(
                ConcielIcons.back,
                size: 12,
                color: personalColorScheme.outline,
                angle: 180,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
