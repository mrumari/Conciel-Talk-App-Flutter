import 'dart:io';
import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:concieltalk/config/profile_constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ConcielSettingsList extends StatelessWidget {
  final List<SettingsSection> sections;
  final ScrollController controller;

  const ConcielSettingsList({
    Key? key,
    required this.sections,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DevicePlatform device;
    Platform.isAndroid
        ? device = DevicePlatform.android
        : device = DevicePlatform.iOS;
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        brightness: Brightness.dark,
        colorScheme: personalColorScheme,
      ),
      child: SettingsTheme(
        themeData: const SettingsThemeData(),
        platform: device,
        child: ListView.builder(
          controller: controller,
          itemCount: sections.length,
          itemBuilder: (context, index) => sections[index],
        ),
      ),
    );
  }
}

Widget profileLevel1(
  BuildContext context,
) {
  final ScrollController profileScroll = ScrollController();
  final GlobalKey accountKey = GlobalKey();

  void scrollToSection(GlobalKey sectionKey) {
    final RenderBox box =
        sectionKey.currentContext!.findRenderObject() as RenderBox;
    final double position = box.localToGlobal(Offset.zero).dy;
    profileScroll.animateTo(
      position,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  final Box settingsDB = Hive.box(Conciel.settingsDB);
  Mandatory mandatorySettings;
  if (settingsDB.get(register)) {
    final Mandatory newSettings = Mandatory(
      nickname: '',
      phoneNumber: '',
      email: '',
    );
    mandatorySettings = newSettings;
    settingsDB.put(mandatory, mandatorySettings);
  } else {
    final Mandatory getSettings = settingsDB.get(mandatory) as Mandatory;
    mandatorySettings = getSettings;
  }
  return ConcielSettingsList(
    controller: profileScroll,
    sections: [
      const SettingsSection(
        title: Text(''),
        tiles: <SettingsTile>[],
      ),
      const SettingsSection(
        title: Text(
          'Profile Level 1',
          style: TextStyle(fontSize: 18),
        ),
        tiles: <SettingsTile>[],
      ),
      SettingsSection(
        key: accountKey,
        title: const Text('Account'),
        tiles: <SettingsTile>[
          SettingsTile.navigation(
            leading: const Icon(ConcielIcons.user),
            title: const Text('Display name'),
            trailing: const Text('*'),
            value: Text(mandatorySettings.nickname),
          ),
          SettingsTile.navigation(
            leading: const Icon(ConcielIcons.phone),
            title: const Text('Mobile number'),
            value: Text(mandatorySettings.phoneNumber),
            trailing: const Text('*'),
            onPressed: (context) async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: TextFieldUpdate(
                    database: settingsDB,
                    dbKey: mandatory,
                    hiveType: 1,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        settingsDB.put(register, false);
                        Navigator.pop(context);
                        mandatorySettings =
                            settingsDB.get(mandatory) as Mandatory;
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(color: personalColorScheme.secondary),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: personalColorScheme.tertiary),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SettingsTile.navigation(
            leading: const Icon(ConcielIcons.mail),
            title: const Text('Email'),
            value: Text(mandatorySettings.email),
            trailing: const Text('*'),
          ),
          SettingsTile.switchTile(
            onToggle: (value) {
              value = settingsDB.get(useFingerprint);
              value = !value;
              settingsDB.put(useFingerprint, value);
            },
            initialValue: true,
            leading: const Icon(Icons.fingerprint),
            title: const Text('Use fingerprint'),
          ),
          SettingsTile.switchTile(
            leading: const Icon(Icons.logout),
            title: const Text('Stay logged in'),
            initialValue: settingsDB.get(stayLoggedIn),
            onToggle: (value) {
              value = settingsDB.get(stayLoggedIn);
              value = !value;
              settingsDB.put(stayLoggedIn, value);
            },
          ),
        ],
      ),
      SettingsSection(
        title: const Text('Personal'),
        tiles: <SettingsTile>[
          SettingsTile.navigation(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            value: const Text('English'),
          ),
          SettingsTile.navigation(
            leading: const Icon(Icons.person),
            title: const Text('First name'),
            value: Text(settingsDB.get(firstName)),
          ),
          SettingsTile.navigation(
            leading: const Icon(Icons.group),
            title: const Text('Surname'),
            value: Text(settingsDB.get(surname)),
          ),
        ],
      ),
      SettingsSection(
        title: const Text('Application'),
        tiles: <SettingsTile>[
          SettingsTile.switchTile(
            onToggle: (value) {},
            initialValue: settingsDB.get(dateTime),
            leading: const Icon(Icons.today),
            title: const Text('Date & time'),
          ),
          SettingsTile.switchTile(
            onToggle: (value) {},
            initialValue: settingsDB.get(useLocation),
            leading: const Icon(Icons.share_location),
            title: const Text('Enable location'),
          ),
          SettingsTile.switchTile(
            onToggle: (value) {},
            initialValue: settingsDB.get(darkMode),
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark mode'),
          ),
          SettingsTile.switchTile(
            onToggle: (value) {},
            initialValue: settingsDB.get(notifications),
            leading: const Icon(ConcielIcons.msg_notifier),
            title: const Text('Enable notifications'),
          ),
          SettingsTile.switchTile(
            onToggle: (value) {},
            initialValue: settingsDB.get(haptix),
            leading: const Icon(Icons.vibration),
            title: const Text('Haptic feedback'),
          ),
        ],
      ),
      SettingsSection(
        title: const Text('Accept / Login'),
        tiles: <SettingsTile>[
          SettingsTile.switchTile(
            onToggle: (value) {
              mandatorySettings = settingsDB.get(mandatory) as Mandatory;
              if (mandatorySettings.phoneNumber == '') {
                Fluttertoast.showToast(
                  msg: 'Mobile number required',
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 1,
                );
                scrollToSection(accountKey);
              }
              if (mandatorySettings.email == '') {
                Fluttertoast.showToast(
                  msg: 'email required',
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 1,
                );
                scrollToSection(accountKey);
              }
              if (mandatorySettings.nickname == '') {
                Fluttertoast.showToast(
                  msg: 'Name required',
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 1,
                );
                scrollToSection(accountKey);
              }
//                AutoRouter.of(context).push(SplashRoute(wcontext: false));
            },
            initialValue: false,
            leading: const Icon(Icons.login),
            title: const Text('Login'),
          ),
        ],
      ),
    ],
  );
}

final SettingsList profileLevel2 = SettingsList(
  sections: [
    SettingsSection(
      title: const Text('Security'),
      tiles: <SettingsTile>[
        SettingsTile.navigation(
          leading: const Icon(Icons.event),
          title: const Text('Date of birth'),
          value: const Text(''),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.badge),
          title: const Text('Identitification'),
          value: const Text(''),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.person),
          title: const Text('Signature'),
          value: const Text(''),
        ),
        SettingsTile.switchTile(
          onToggle: (value) {},
          initialValue: true,
          leading: const Icon(Icons.password),
          title: const Text('Change password'),
        ),
      ],
    ),
  ],
);

class TextFieldUpdate extends StatefulWidget {
  final Box database;
  final String dbKey;
  final int hiveType;
  const TextFieldUpdate({
    super.key,
    required this.database,
    required this.dbKey,
    required this.hiveType,
  });

  @override
  TextFieldUpdateState createState() => TextFieldUpdateState();
}

class TextFieldUpdateState extends State<TextFieldUpdate> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen for changes in the text field
    _controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    _controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    // Update the value in the Hive box whenever the text changes
    switch (widget.hiveType) {
      case 1:
        var data = widget.database.get(widget.dbKey) as Mandatory;
        debugPrint(data.phoneNumber);
        final Mandatory mandatorySettings = Mandatory(
          nickname: data.nickname,
          phoneNumber: _controller.text,
          email: data.email,
        );
        widget.database.put(widget.dbKey, mandatorySettings);
        data = widget.database.get(widget.dbKey) as Mandatory;
        debugPrint(data.phoneNumber);
        break;
      case 2:
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
    );
  }
}
