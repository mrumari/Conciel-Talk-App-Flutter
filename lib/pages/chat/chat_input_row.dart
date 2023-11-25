import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:animations/animations.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:new_keyboard_shortcuts/keyboard_shortcuts.dart';
import 'package:matrix/matrix.dart';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/utils/platform_infos.dart';
import 'package:concieltalk/widgets/avatar.dart';
import 'package:concieltalk/widgets/matrix.dart';
import '../../config/themes.dart';
import 'chat.dart';
import 'input_bar.dart';

class ChatInputRow extends StatelessWidget {
  final ChatController controller;

  const ChatInputRow(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.showEmojiPicker &&
        controller.emojiPickerType == EmojiPickerType.reaction) {
      return const SizedBox.shrink();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: controller.selectMode
          ? <Widget>[
              SizedBox(
                height: 56,
                child: TextButton(
                  onPressed: controller.forwardEventsAction,
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.keyboard_arrow_left_outlined),
                      Text(L10n.of(context)!.forward),
                    ],
                  ),
                ),
              ),
              controller.selectedEvents.length == 1
                  ? controller.selectedEvents.first
                          .getDisplayEvent(controller.timeline!)
                          .status
                          .isSent
                      ? SizedBox(
                          height: 56,
                          child: TextButton(
                            onPressed: controller.replyAction,
                            child: Row(
                              children: <Widget>[
                                Text(L10n.of(context)!.reply),
                                const Icon(Icons.keyboard_arrow_right),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 56,
                          child: TextButton(
                            onPressed: controller.sendAgainAction,
                            child: Row(
                              children: <Widget>[
                                Text(L10n.of(context)!.tryToSendAgain),
                                const SizedBox(width: 4),
                                const Icon(Icons.send_outlined, size: 16),
                              ],
                            ),
                          ),
                        )
                  : const SizedBox.shrink(),
            ]
          : <Widget>[
              KeyBoardShortcuts(
                keysToPress: {
                  LogicalKeyboardKey.altLeft,
                  LogicalKeyboardKey.keyA,
                },
                onKeysPressed: () =>
                    controller.onAddPopupMenuButtonSelected('file'),
                helpLabel: L10n.of(context)!.sendFile,
                child: AnimatedContainer(
                  duration: ConcielThemes.animationDuration,
                  curve: ConcielThemes.animationCurve,
                  height: 56,
                  width: controller.inputText.isEmpty ? 32 : 0,
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  child: IconButton(
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: const Icon(Icons.add_outlined),
                  ),
                ),
              ),
              Container(
                height: 56,
                alignment: Alignment.center,
                child: KeyBoardShortcuts(
                  keysToPress: {
                    LogicalKeyboardKey.altLeft,
                    LogicalKeyboardKey.keyE,
                  },
                  onKeysPressed: controller.emojiPickerAction,
                  helpLabel: L10n.of(context)!.emojis,
                  child: IconButton(
                    tooltip: L10n.of(context)!.emojis,
                    icon: PageTransitionSwitcher(
                      transitionBuilder: (
                        Widget child,
                        Animation<double> primaryAnimation,
                        Animation<double> secondaryAnimation,
                      ) {
                        return SharedAxisTransition(
                          animation: primaryAnimation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.scaled,
                          fillColor: Colors.transparent,
                          child: child,
                        );
                      },
                      child: Icon(
                        controller.showEmojiPicker
                            ? Icons.keyboard
                            : Icons.emoji_emotions_outlined,
                        key: ValueKey(controller.showEmojiPicker),
                      ),
                    ),
                    onPressed: controller.emojiPickerAction,
                  ),
                ),
              ),
              if (Matrix.of(context).isMultiAccount &&
                  Matrix.of(context).hasComplexBundles &&
                  Matrix.of(context).currentBundle!.length > 1)
                Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: _ChatAccountPicker(controller),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: InputBar(
                    room: controller.room,
                    minLines: 1,
                    maxLines: 8,
                    autofocus: !PlatformInfos.isMobile,
                    keyboardType: TextInputType.multiline,
                    textInputAction:
                        AppConfig.sendOnEnter ? TextInputAction.send : null,
                    onSubmitted: controller.onInputBarSubmitted,
                    focusNode: controller.inputFocus,
                    controller: controller.sendController,
                    decoration: InputDecoration(
                      hintText: L10n.of(context)!.writeAMessage,
                      hintMaxLines: 1,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      filled: false,
                    ),
                    onChanged: controller.onInputBarChanged,
                  ),
                ),
              ),
              if (PlatformInfos.platformCanRecord &&
                  controller.inputText.isEmpty)
                Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: IconButton(
                    tooltip: L10n.of(context)!.voiceMessage,
                    icon: const Icon(Icons.mic_none_outlined),
                    onPressed: controller.voiceMessageAction,
                  ),
                ),
              if (!PlatformInfos.isMobile || controller.inputText.isNotEmpty)
                Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: const Icon(Icons.send_outlined),
                    onPressed: controller.send,
                    tooltip: L10n.of(context)!.send,
                  ),
                ),
            ],
    );
  }
}

class _ChatAccountPicker extends StatelessWidget {
  final ChatController controller;

  const _ChatAccountPicker(this.controller, {Key? key}) : super(key: key);

  void _popupMenuButtonSelected(String mxid, BuildContext context) {
    final client = Matrix.of(context)
        .currentBundle!
        .firstWhere((cl) => cl!.userID == mxid, orElse: () => null);
    if (client == null) {
      Logs().w('Attempted to switch to a non-existing client $mxid');
      return;
    }
    controller.setSendingClient(client);
  }

  @override
  Widget build(BuildContext context) {
    final clients = controller.currentRoomBundle;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<Profile>(
        future: controller.sendingClient.fetchOwnProfile(),
        builder: (context, snapshot) => PopupMenuButton<String>(
          onSelected: (mxid) => _popupMenuButtonSelected(mxid, context),
          itemBuilder: (BuildContext context) => clients
              .map(
                (client) => PopupMenuItem<String>(
                  value: client!.userID,
                  child: FutureBuilder<Profile>(
                    future: client.fetchOwnProfile(),
                    builder: (context, snapshot) => ListTile(
                      leading: Avatar(
                        mxContent: snapshot.data?.avatarUrl,
                        name: snapshot.data?.displayName ??
                            client.userID!.localpart,
                        size: 20,
                      ),
                      title: Text(snapshot.data?.displayName ?? client.userID!),
                      contentPadding: const EdgeInsets.all(0),
                    ),
                  ),
                ),
              )
              .toList(),
          child: Avatar(
            mxContent: snapshot.data?.avatarUrl,
            name: snapshot.data?.displayName ??
                Matrix.of(context).client.userID!.localpart,
            size: 20,
          ),
        ),
      ),
    );
  }
}
