import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:concieltalk/drawers/ratational_drawer/test_sec_standard_drawer.dart';
// import 'package:concieltalk/drawers/standard_drawer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vrouter/vrouter.dart';

class SearchDrawer extends StatelessWidget {
  final BuildContext context;
  final String route;
  const SearchDrawer({Key? key, required this.context, required this.route})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TestSecStandardDrawer(
      showSplines: true,
      context: context,
      left: true,
      borderColor: switch (route) {
        'talk' => personalColorScheme.primary,
        'shop' => personalColorScheme.secondary,
        'book' => personalColorScheme.tertiary,
        _ => personalColorScheme.primary
      },
      splineColor: personalColorScheme.surfaceTint,
      icons: const [
        Icons.person_add_outlined,
        ConcielIcons.history,
        ConcielIcons.camera,
        ConcielIcons.doc_file,
        ConcielIcons.users,
        ConcielIcons.map_marker,
      ],
      onTap: [
        () {
          VRouter.of(context).to(
            '/newprivatechat',
            queryParameters: {'route': '/talk'},
          );
        },
        () {
          VRouter.of(context).to('/archive');
        },
        () async {
          // ignore: unused_local_variable
          final file =
              await ImagePicker().pickImage(source: ImageSource.camera);
        },
        () {
          VRouter.of(context).to('/$route/fileshare');
        },
        () {
          VRouter.of(context)
              .to('/localcontacts', queryParameters: {'route': route});
        },
        () {
          VRouter.of(context).to(
            '/$route/maps',
          );
        },
      ],
    );
  }
}
