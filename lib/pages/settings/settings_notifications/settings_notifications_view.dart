import 'package:concieltalk/config/app_config.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';

import 'package:concieltalk/widgets/layouts/max_width_body.dart';
import 'package:concieltalk/utils/localized_exception_extension.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'settings_notifications.dart';

class SettingsNotificationsView extends StatelessWidget {
  final SettingsNotificationsController controller;

  const SettingsNotificationsView(this.controller, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(L10n.of(context)!.notifications),
      ),
      body: MaxWidthBody(
        withScrolling: true,
        child: StreamBuilder(
          stream: Matrix.of(context)
              .client
              .onAccountData
              .stream
              .where((event) => event.type == 'm.push_rules'),
          builder: (BuildContext context, _) {
            return Column(
              children: [
                SwitchListTile.adaptive(
                  value: !Matrix.of(context).client.allPushNotificationsMuted,
                  title: Text(
                    L10n.of(context)!.notificationsEnabledForThisAccount,
                  ),
                  onChanged: (_) => showFutureLoadingDialog(
                    context: context,
                    future: () => Matrix.of(context)
                        .client
                        .setMuteAllPushNotifications(
                          !Matrix.of(context).client.allPushNotificationsMuted,
                        ),
                  ),
                ),
                if (!Matrix.of(context).client.allPushNotificationsMuted) ...{
                  const Divider(thickness: 1),
                  ListTile(
                    title: Text(
                      L10n.of(context)!.notifications,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SwitchListTile.adaptive(
                    value: AppConfig.showBadge,
                    title: Text('${L10n.of(context)!.notifications} badge'),
                    onChanged: (bool enabled) => controller.showBadge(),
                  ),
                  SwitchListTile.adaptive(
                    value: AppConfig.showCount,
                    title: Text('${L10n.of(context)!.notifications} count'),
                    onChanged: !AppConfig.showBadge
                        ? null
                        : (bool enabled) => controller.showCount(),
                  ),
                  SwitchListTile.adaptive(
                    value: AppConfig.showTile,
                    title: Text('${L10n.of(context)!.notifications} highlight'),
                    onChanged: (bool enabled) => controller.showTile(),
                  ),
                  // ignore: equal_elements_in_set
                  const Divider(thickness: 1),
                  ListTile(
                    title: Text(
                      L10n.of(context)!.pushRules,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // ignore: prefer_final_in_for_each
                  for (var item in NotificationSettingsItem.items)
                    SwitchListTile.adaptive(
                      value: controller.getNotificationSetting(item) ?? true,
                      title: Text(item.title(context)),
                      onChanged: (bool enabled) =>
                          controller.setNotificationSetting(item, enabled),
                    ),
                },
                const Divider(thickness: 1),
                ListTile(
                  title: Text(
                    L10n.of(context)!.devices,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FutureBuilder<List<Pusher>?>(
                  future: controller.pusherFuture ??=
                      Matrix.of(context).client.getPushers(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      Center(
                        child: Text(
                          snapshot.error!.toLocalizedString(context),
                        ),
                      );
                    }
                    if (snapshot.connectionState != ConnectionState.done) {
                      const Center(
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      );
                    }
                    final pushers = snapshot.data ?? [];
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: pushers.length,
                      itemBuilder: (_, i) => ListTile(
                        title: Text(
                          '${pushers[i].appDisplayName} - ${pushers[i].appId}',
                        ),
                        subtitle: Text(pushers[i].data.url.toString()),
                        onTap: () => controller.onPusherTap(pushers[i]),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
