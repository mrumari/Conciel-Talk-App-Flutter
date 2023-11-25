import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

import 'package:concieltalk/widgets/avatar.dart';
import 'package:concieltalk/widgets/matrix.dart';

class ProfileBottomSheet extends StatelessWidget {
  final String userId;
  final BuildContext outerContext;

  const ProfileBottomSheet({
    required this.userId,
    required this.outerContext,
    Key? key,
  }) : super(key: key);

  void _startDirectChat(BuildContext context) async {
    final client = Matrix.of(context).client;
    final result = await showFutureLoadingDialog<String>(
      context: context,
      future: () => client.startDirectChat(userId, enableEncryption: false),
    );
    if (result.error == null) {
      VRouter.of(context).toSegments(['rooms', result.result!]);
      Navigator.of(context, rootNavigator: false).pop();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Profile>(
        future: Matrix.of(context).client.getProfileFromUserId(userId),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          return Scaffold(
            body: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                ),
                AppBar(
                  leading: CloseButton(
                    onPressed: Navigator.of(context, rootNavigator: false).pop,
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlinedButton.icon(
                        onPressed: () => _startDirectChat(context),
                        icon: Icon(Icons.adaptive.share_outlined),
                        label: Text(L10n.of(context)!.share),
                      ),
                    ),
                  ],
                ),
                ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  contentPadding: const EdgeInsets.only(right: 16.0),
                  title: Text(
                    profile?.displayName ?? userId.localpart ?? userId,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  subtitle: Text(
                    userId,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Avatar(
                      mxContent: profile?.avatarUrl,
                      name: profile?.displayName ?? userId,
                      size: Avatar.defaultSize * 3,
                      fontSize: 36,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: FloatingActionButton.extended(
                    backgroundColor: personalColorScheme.onSecondary,
                    onPressed: () => _startDirectChat(context),
                    label: Text(
                      L10n.of(context)!.newChat,
                      style: TextStyle(color: personalColorScheme.primary),
                    ),
                    icon: Icon(
                      ConcielIcons.vote_yes,
                      color: personalColorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
