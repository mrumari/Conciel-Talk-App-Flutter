import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/pages/settings/user_token_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

import 'package:concieltalk/utils/id_share.dart';
import 'package:concieltalk/widgets/avatar.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/presence_extension.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'user_bottom_sheet.dart';

class UserBottomSheetView extends StatelessWidget {
  final UserBottomSheetController controller;

  const UserBottomSheetView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = controller.widget.user;
    final client = Matrix.of(context).client;
    final presence = client.presences[user.id];
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: CloseButton(
            onPressed: Navigator.of(context, rootNavigator: false).pop,
          ),
          title: Text(user.calcDisplayname()),
        ),
        body: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog.fullscreen(
                          insetAnimationCurve: Curves.ease,
                          insetAnimationDuration: const Duration(
                            milliseconds: 200,
                          ),
                          backgroundColor:
                              personalColorScheme.background.withOpacity(0.5),
                          child: Stack(
                            children: [
                              Positioned(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 120),
                                  child: IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.close),
                                  ),
                                ),
                              ),
                              Center(
                                child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Avatar(
                                    mxContent: user.avatarUrl,
                                    name: user.calcDisplayname(),
                                    size: Avatar.defaultSize * 6,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    icon: Avatar(
                      mxContent: user.avatarUrl,
                      name: user.calcDisplayname(),
                      size: Avatar.defaultSize * 2,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
            ListTile(
              contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0),
              title: Text(user.id),
              subtitle: presence == null
                  ? null
                  : Text(presence.getLocalizedLastActiveAgo(context)),
              trailing: IconButton(
                icon: Icon(Icons.adaptive.share),
                onPressed: () => IdentityShare.share(
                  user.id,
                  context,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton.icon(
                onPressed: () =>
                    controller.participantAction(UserBottomSheetAction.message),
                icon: const Icon(Icons.forum_outlined),
                label: Text(L10n.of(context)!.sendAMessage),
              ),
            ),
            if (controller.widget.onMention != null)
              ListTile(
                leading: const Icon(Icons.alternate_email_outlined),
                title: Text(L10n.of(context)!.mention),
                onTap: () async {
                  final FirebaseMessaging firebase = FirebaseMessaging.instance;
                  final String? fcmToken = await firebase.getToken();
                  writeFcmTokenReference(user, fcmToken!);
                  // controller.participantAction(UserBottomSheetAction.mention);
                },
              ),
            if (user.canChangePowerLevel)
              ListTile(
                title: Text(L10n.of(context)!.setPermissionsLevel),
                leading: const Icon(Icons.edit_attributes_outlined),
                onTap: () => controller
                    .participantAction(UserBottomSheetAction.permission),
              ),
            if (user.canKick)
              ListTile(
                title: Text(L10n.of(context)!.kickFromChat),
                leading: const Icon(Icons.exit_to_app_outlined),
                onTap: () =>
                    controller.participantAction(UserBottomSheetAction.kick),
              ),
            if (user.canBan && user.membership != Membership.ban)
              ListTile(
                title: Text(L10n.of(context)!.banFromChat),
                leading: const Icon(Icons.warning_sharp),
                onTap: () =>
                    controller.participantAction(UserBottomSheetAction.ban),
              )
            else if (user.canBan && user.membership == Membership.ban)
              ListTile(
                title: Text(L10n.of(context)!.unbanFromChat),
                leading: const Icon(Icons.warning_outlined),
                onTap: () =>
                    controller.participantAction(UserBottomSheetAction.unban),
              ),
            if (user.id != client.userID &&
                !client.ignoredUsers.contains(user.id))
              ListTile(
                textColor: Theme.of(context).colorScheme.onErrorContainer,
                iconColor: Theme.of(context).colorScheme.onErrorContainer,
                title: Text(L10n.of(context)!.ignore),
                leading: const Icon(Icons.block),
                onTap: () =>
                    controller.participantAction(UserBottomSheetAction.ignore),
              ),
            if (user.id != client.userID)
              ListTile(
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                title: Text(L10n.of(context)!.reportUser),
                leading: const Icon(Icons.shield_outlined),
                onTap: () =>
                    controller.participantAction(UserBottomSheetAction.report),
              ),
          ],
        ),
      ),
    );
  }
}
