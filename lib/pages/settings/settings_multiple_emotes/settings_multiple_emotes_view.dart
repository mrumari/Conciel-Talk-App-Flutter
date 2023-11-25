import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

import 'package:concieltalk/pages/settings/settings_multiple_emotes/settings_multiple_emotes.dart';
import 'package:concieltalk/widgets/matrix.dart';

class MultipleEmotesSettingsView extends StatelessWidget {
  final MultipleEmotesSettingsController controller;

  const MultipleEmotesSettingsView(this.controller, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final room = Matrix.of(context).client.getRoomById(controller.roomId!)!;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(L10n.of(context)!.emotePacks),
      ),
      body: StreamBuilder(
        stream: room.onUpdate.stream,
        builder: (context, snapshot) {
          final packStateEvents = room.states['im.ponies.room_emotes'];
          // we need to manually convert the map using Map.of, otherwise assigning null will throw a type error.
          final Map<String, Event?> packs = packStateEvents != null
              ? Map<String, Event?>.of(packStateEvents)
              : <String, Event?>{};
          if (!packs.containsKey('')) {
            packs[''] = null;
          }
          final keys = packs.keys.toList();
          keys.sort();
          return ListView.separated(
            separatorBuilder: (BuildContext context, int i) =>
                const SizedBox.shrink(),
            itemCount: keys.length,
            itemBuilder: (BuildContext context, int i) {
              final event = packs[keys[i]];
              final eventPack =
                  event?.content.tryGetMap<String, Object?>('pack');
              final packName = eventPack?.tryGet<String>('displayname') ??
                  eventPack?.tryGet<String>('name') ??
                  (keys[i].isNotEmpty ? keys[i] : 'Default Pack');

              return ListTile(
                title: Text(packName),
                onTap: () async {
                  VRouter.of(context).toSegments(
                    ['rooms', room.id, 'details', 'emotes', keys[i]],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
