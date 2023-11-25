import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:concieltalk/drawers/standard_drawer.dart';
import 'package:concieltalk/pages/chat/chat_send_actions.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

class ConcielDrawer extends StatefulWidget {
  final BuildContext context;
  const ConcielDrawer({Key? key, required this.context}) : super(key: key);
  @override
  State<ConcielDrawer> createState() => _ConcielDrawerState();
}

class _ConcielDrawerState extends State<ConcielDrawer> {
  @override
  Widget build(BuildContext context) {
    return StandardDrawer(
      showSplines: true,
      context: context,
      left: true,
      borderColor: personalColorScheme.primary,
      splineColor: Colors.transparent,
      icons: const [
        ConcielIcons.settings,
        ConcielIcons.history,
        ConcielIcons.camera,
        ConcielIcons.share,
        ConcielIcons.filter,
        ConcielIcons.vote_no,
      ],
      onTap: [
        () => VRouter.of(context).to(
              'settings',
            ),
        () => VRouter.of(context).to('/archive'),
        () {
          final matrix = Matrix.of(context);
          final id = Matrix.of(context).activeRoomId;
          final Room room = Room(id: id!, client: matrix.client);
          openCameraAction(context, room);
        },
        () {
          final matrix = Matrix.of(context);
          final id = Matrix.of(context).activeRoomId;
          final Room room = Room(id: id!, client: matrix.client);
          sendImageAction(context, room);
        },
        () => {},
        () async {
          final matrix = Matrix.of(context);
          await showFutureLoadingDialog(
            context: context,
            future: () => matrix.client.logout(),
          );
          if (mounted) {
            VRouter.of(context).to('/biometrics');
          }
        },
      ],
    );
  }
}
