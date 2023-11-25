import 'package:concieltalk/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

import 'package:concieltalk/pages/new_private_chat/new_private_chat_view.dart';
import 'package:concieltalk/pages/new_private_chat/qr_scanner_modal.dart';
import 'package:concieltalk/utils/adaptive_bottom_sheet.dart';
import 'package:concieltalk/utils/id_share.dart';
import 'package:concieltalk/utils/platform_infos.dart';
import 'package:concieltalk/utils/url_launcher.dart';
import 'package:concieltalk/widgets/matrix.dart';

class NewPrivateChat extends StatefulWidget {
  const NewPrivateChat({Key? key}) : super(key: key);

  @override
  NewPrivateChatController createState() => NewPrivateChatController();
}

class NewPrivateChatController extends State<NewPrivateChat> {
  final TextEditingController controller = TextEditingController();
  final FocusNode textFieldFocus = FocusNode();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  bool exists = false;
  String profilecheck = '';

  // remove leading matrix.to from text field in order to simplify pasting
  final List<TextInputFormatter> removeMatrixToFormatters = [
    FilteringTextInputFormatter.deny(NewPrivateChatController.prefix),
    FilteringTextInputFormatter.deny(NewPrivateChatController.prefixNoProtocol),
  ];

  static const Set<String> supportedSigils = {'@', '!', '#'};

  static const String prefix = 'https://matrix.to/#/';
  static const String prefixNoProtocol = 'matrix.to/#/';

  void submitAction([_]) async {
    controller.text = controller.text.trim();
    controller.text.contains(':${AppConfig.defaultDomain}')
        ? null
        : profilecheck = '${controller.text}:${AppConfig.defaultDomain}';
    exists = await fetchUserProfile(profilecheck);
    if (!formKey.currentState!.validate()) return;
    UrlLauncher(context, '$prefix${controller.text}').openMatrixToUrl();
    controller.text.contains(':${AppConfig.defaultDomain}')
        ? controller.text = controller.text.split(':').first
        : null;
  }

  Future<bool> fetchUserProfile(String userId) async {
    try {
      await Matrix.of(context).client.getProfileFromUserId(userId);
      return true;
    } catch (e) {
      Logs().e('Failed to fetch user profile: $e');
      return false;
    }
  }

  String? validateForm(String? value) {
    if (value!.isEmpty) {
      return L10n.of(context)!.pleaseEnterAMatrixIdentifier;
    }
    controller.text.contains(':${AppConfig.defaultDomain}')
        ? null
        : controller.text = '${controller.text}:${AppConfig.defaultDomain}';
    if (!controller.text.isValidMatrixId ||
        !supportedSigils.contains(controller.text.sigil)) {
      return L10n.of(context)!.makeSureTheIdentifierIsValid;
    }
    if (controller.text == Matrix.of(context).client.userID) {
      return L10n.of(context)!.youCannotInviteYourself;
    }
    if (!exists) {
      controller.text.contains(':${AppConfig.defaultDomain}')
          ? controller.text = controller.text.split(':').first
          : null;
      return 'Invalid Conciel user ID - please check.';
    }
    return null;
  }

  void inviteAction() => IdentityShare.share(
        Matrix.of(context).client.userID!,
        context,
      );

  void openScannerAction() async {
    if (PlatformInfos.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt < 21) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              L10n.of(context)!.unsupportedAndroidVersionLong,
            ),
          ),
        );
        return;
      }
    }
    await showAdaptiveBottomSheet(
      context: context,
      builder: (_) => const QrScannerModal(),
    );
  }

  @override
  Widget build(BuildContext context) => NewPrivateChatView(this);
}
