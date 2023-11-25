import 'dart:math';

import 'package:concieltalk/config/color_constants.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vrouter/vrouter.dart';

import 'package:concieltalk/pages/new_private_chat/new_private_chat.dart';
import 'package:concieltalk/utils/platform_infos.dart';
import 'package:concieltalk/widgets/layouts/max_width_body.dart';
import 'package:concieltalk/widgets/matrix.dart';

class NewPrivateChatView extends StatelessWidget {
  final NewPrivateChatController controller;

  const NewPrivateChatView(this.controller, {Key? key}) : super(key: key);

  static const double _qrCodePadding = 8;

  @override
  Widget build(BuildContext context) {
    final qrCodeSize = min(1.sw - 16.w, 256.w).toDouble();
    final route = VRouter.of(context).queryParameters['route'] ?? 'pop';
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => route == 'pop'
              ? VRouter.of(context).pop()
              : VRouter.of(context).to(route),
        ),
        title: Row(
          children: [
/*
            Text(L10n.of(context)!.newChat),
*/
            Text(
              'Connect ',
              style: TextStyle(color: personalColorScheme.primary),
            ),
            Icon(
              Icons.add_reaction_outlined,
              color: personalColorScheme.primary,
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          TextButton(
            onPressed: () => VRouter.of(context).to('/newgroup'),
            child: Icon(
              Icons.group_add_outlined,
              color: personalColorScheme.secondary,
              size: 28,
            ),
/*
              Text(
                L10n.of(context)!.createNewGroup,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
*/
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 32,
          ),
          Expanded(
            child: MaxWidthBody(
              withScrolling: true,
              child: Container(
                margin: const EdgeInsets.all(_qrCodePadding),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(_qrCodePadding * 2),
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  elevation: 10,
                  color: personalColorScheme.outline,
                  shadowColor: Theme.of(context).appBarTheme.shadowColor,
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 32,
                      ),
                      QrImageView(
                        backgroundColor: Colors.white,
                        data:
                            'https://matrix.to/#/${Matrix.of(context).client.userID}',
                        version: QrVersions.auto,
                        size: qrCodeSize * 0.6,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          fixedSize:
                              Size.fromWidth(qrCodeSize - (2 * _qrCodePadding)),
                          foregroundColor: Colors.black,
                        ),
                        icon: Icon(Icons.adaptive.share_outlined),
                        label: Text(L10n.of(context)!.shareYourInviteLink),
                        onPressed: controller.inviteAction,
                      ),
                      const SizedBox(height: 8),
                      if (PlatformInfos.isMobile) ...[
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            fixedSize: Size.fromWidth(
                              qrCodeSize * .8,
                            ),
                          ),
                          icon: const Icon(Icons.qr_code_scanner_outlined),
                          label: Text(L10n.of(context)!.scanQrCode),
                          onPressed: controller.openScannerAction,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Text(
            'or enter a Conciel ID to send an Invite',
            style: TextStyle(
              color: personalColorScheme.primary,
            ),
          ),
          MaxWidthBody(
            withScrolling: false,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: controller.formKey,
                child: TextFormField(
                  controller: controller.controller,
                  autocorrect: false,
                  textInputAction: TextInputAction.go,
                  focusNode: controller.textFieldFocus,
                  onFieldSubmitted: controller.submitAction,
                  validator: controller.validateForm,
                  inputFormatters: controller.removeMatrixToFormatters,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    labelText: 'Enter Conciel ID',
                    hintText: '@username',
//                    prefixText: NewPrivateChatController.prefixNoProtocol,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send_outlined),
                      onPressed: controller.submitAction,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
