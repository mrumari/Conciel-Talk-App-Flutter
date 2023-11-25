import 'package:concieltalk/config/profile.dart';
import 'package:concieltalk/config/profile_constants.dart';
import 'package:concieltalk/pages/login/login_page.dart';
import 'package:flutter/material.dart';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/widgets/layouts/login_scaffold.dart';
import 'package:hive/hive.dart';
import 'homeserver_picker.dart';

class HomeserverPickerView extends StatelessWidget {
  final HomeserverPickerController controller;

  const HomeserverPickerView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
/*
    final identityProviders = controller.identityProviders;
    final errorText = controller.error;
*/
    return LoginScaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : LoginPage(
                      authenticated: (Cube cube) {
                        controller.picked = cube;
                        controller.login();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void userBasicProfileSheet(
    BuildContext context,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: false,
      context: context,
      builder: (context) {
        final Box settingsDB = Hive.box(Conciel.settingsDB);
        settingsDB.put(useFingerprint, true);
        settingsDB.put(stayLoggedIn, false);
        settingsDB.put(haptix, true);
        settingsDB.put(dateTime, true);
        settingsDB.put(darkMode, true);
        settingsDB.put(notifications, true);
        settingsDB.put(language, 'English');
        settingsDB.put(firstName, '');
        settingsDB.put(surname, '');
        return profileLevel1(
          context,
        );
      },
    );
  }
}

class LoginButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final void Function() onPressed;

  const LoginButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onPressed,
        icon: icon,
        label: Text(label),
      ),
    );
  }
}
