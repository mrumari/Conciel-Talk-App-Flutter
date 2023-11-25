import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/pages/chat_list/chat_list.dart';
import 'package:concieltalk/pages/user_bottom_sheet/user_bottom_sheet.dart';
import 'package:concieltalk/utils/adaptive_bottom_sheet.dart';
import 'package:flutter/material.dart';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:concieltalk/utils/room_status_extension.dart';
import '../../config/themes.dart';
import 'package:concieltalk/utils/date_time_extension.dart';
import 'package:concieltalk/widgets/avatar.dart';
import 'package:concieltalk/widgets/matrix.dart';
import '../chat/send_file_dialog.dart';

enum ArchivedRoomAction { delete, rejoin }

class ChatListItem extends StatelessWidget {
  final Room room;
  final bool activeChat;
  final bool selected;
  final ChatListController? controller;
  final void Function()? onTap;
  final void Function()? onLongPress;

  const ChatListItem(
    this.room, {
    this.controller,
    this.activeChat = false,
    this.selected = false,
    this.onTap,
    this.onLongPress,
    Key? key,
  }) : super(key: key);

  void clickAction(BuildContext context) async {
    onTap!();
    if (activeChat) return;
    if (room.membership == Membership.invite) {
      final joinResult = await showFutureLoadingDialog(
        context: context,
        future: () async {
          final waitForRoom = room.client.waitForRoomInSync(
            room.id,
            join: true,
          );
          await room.join();
          await waitForRoom;
        },
      );
      if (joinResult.error != null) return;
    }

    if (room.membership == Membership.ban) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.youHaveBeenBannedFromThisChat),
        ),
      );
      return;
    }

    if (room.membership == Membership.leave) {
      VRouter.of(context).toSegments(['archive', room.id]);
    }

    if (room.membership == Membership.join) {
      // Share content into this room
      final shareContent = Matrix.of(context).shareContent;
      if (shareContent != null) {
        final shareFile = shareContent.tryGet<MatrixFile>('file');
        if (shareContent.tryGet<String>('msgtype') ==
                'conciel.talk.shared_file' &&
            shareFile != null) {
          await showDialog(
            context: context,
            useRootNavigator: false,
            builder: (c) => SendFileDialog(
              files: [shareFile],
              room: room,
            ),
          );
        } else {
          room.sendEvent(shareContent);
        }
        Matrix.of(context).shareContent = null;
      }
      final String share =
          VRouter.of(context).queryParameters['share'] ?? 'no-file';

      VRouter.of(context)
          .toSegments(['rooms', room.id], queryParameters: {'share': share});
    }
  }

  Future<void> archiveAction(BuildContext context) async {
    {
      if ([Membership.leave, Membership.ban].contains(room.membership)) {
        await showFutureLoadingDialog(
          context: context,
          future: () => room.forget(),
        );
        return;
      }
      final confirmed = await showOkCancelAlertDialog(
        useRootNavigator: false,
        context: context,
        title: L10n.of(context)!.areYouSure,
        okLabel: L10n.of(context)!.yes,
        cancelLabel: L10n.of(context)!.no,
      );
      if (confirmed == OkCancelResult.cancel) return;
      await showFutureLoadingDialog(
        context: context,
        future: () => room.leave(),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMuted = room.pushRuleState != PushRuleState.notify;
    final typingText = room.getLocalizedTypingText(context);
    final ownMessage =
        room.lastEvent?.senderId == Matrix.of(context).client.userID;
    final unread = room.isUnread || room.membership == Membership.invite;
    final unreadBubbleSize = unread || room.hasNewMessages
        ? room.notificationCount > 0
            ? 20.0
            : 14.0
        : 0.0;
    final displayname = room.getLocalizedDisplayname(
      MatrixLocals(L10n.of(context)!),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 1,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        clipBehavior: Clip.hardEdge,
        color: selected
            ? Theme.of(context).colorScheme.primaryContainer
            : activeChat
                ? Theme.of(context).colorScheme.secondaryContainer
                : Colors.transparent,
        child: Container(
          alignment: Alignment.centerLeft,
          height: 60,
          child: ListTile(
            visualDensity: const VisualDensity(vertical: -0.5),
            tileColor: room.notificationCount > 0 && AppConfig.showTile
                ? personalColorScheme.primary.withOpacity(0.3)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            onLongPress: onLongPress,
            title: Row(
              children: [
                selected
                    ? Padding(
                        padding: const EdgeInsets.only(
                          bottom: 14.0,
                          right: 16,
                        ),
                        child: SizedBox(
                          height: 60,
                          width: 44,
                          child: Material(
                            color: personalColorScheme.tertiary.withAlpha(80),
                            borderRadius:
                                BorderRadius.circular(Avatar.defaultSize),
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(
                          bottom: 14.0,
                        ),
                        child: Container(
                          height: 60,
                          width: 60,
                          alignment: Alignment.centerLeft,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                width: Avatar.defaultSize,
                                height: Avatar.defaultSize,
                                clipBehavior: Clip.hardEdge,
                                decoration: ShapeDecoration(
                                  color: personalColorScheme.primary,
                                  shape: CircleBorder(
                                    side: BorderSide(
                                      strokeAlign:
                                          BorderSide.strokeAlignOutside,
                                      color: room.isFavourite
                                          ? personalColorScheme.tertiary
                                          : personalColorScheme.primary,
                                      width: room.notificationCount == 0 &&
                                              !unread &&
                                              !room.hasNewMessages
                                          ? 0.5
                                          : 2,
                                    ),
                                  ),
                                ),
                                child: Avatar(
                                  mxContent: room.avatar,
                                  name: displayname,
                                  onTap: () => controller?.selectMode !=
                                          SelectMode.normal
                                      ? controller!.toggleSelection(room.id)
                                      : room.isDirectChat
                                          ? showAdaptiveBottomSheet(
                                              context: context,
                                              builder: (c) => UserBottomSheet(
                                                user: room
                                                    .unsafeGetUserFromMemoryOrFallback(
                                                  room.directChatMatrixID!,
                                                ),
                                                outerContext: context,
                                                /*onMention: () => controller.sendController.text +=
                                        '${room.unsafeGetUserFromMemoryOrFallback(room.id).mention} ',*/
                                              ),
                                            )
                                          : room.isArchived
                                              ? null
                                              : VRouter.of(context).toSegments(
                                                  ['rooms', room.id, 'details'],
                                                  queryParameters: {
                                                    'view': 'top',
                                                  },
                                                ),
                                ),
                              ),
                              AppConfig.showBadge
                                  ? AnimatedContainer(
                                      duration: ConcielThemes.animationDuration,
                                      curve: ConcielThemes.animationCurve,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                      ),
                                      height: unreadBubbleSize,
                                      width: room.notificationCount == 0 &&
                                              !unread &&
                                              !room.hasNewMessages
                                          ? 0
                                          : (unreadBubbleSize - 9) *
                                                  room.notificationCount
                                                      .toString()
                                                      .length +
                                              9,
                                      decoration: BoxDecoration(
                                        color: room.highlightCount > 0 ||
                                                room.membership ==
                                                    Membership.invite
                                            ? Colors.amber
                                            : room.notificationCount > 0 ||
                                                    room.markedUnread
                                                ? room.isFavourite
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .tertiary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          AppConfig.borderRadius,
                                        ),
                                      ),
                                      child: Center(
                                        child: room.notificationCount > 0 &&
                                                AppConfig.showCount
                                            ? Text(
                                                room.notificationCount
                                                    .toString(),
                                                style: TextStyle(
                                                  color: room.highlightCount > 0
                                                      ? Colors.white
                                                      : room.notificationCount >
                                                              0
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .outline
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .onPrimaryContainer,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              displayname,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: TextStyle(
                                fontWeight: unread ? FontWeight.bold : null,
                              ),
                            ),
                          ),
                          if (isMuted)
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(
                                Icons.notifications_off_outlined,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          if (typingText.isEmpty &&
                              ownMessage &&
                              room.lastEvent!.status.isSending) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          AnimatedContainer(
                            width: typingText.isEmpty ? 0 : 18,
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(),
                            duration: ConcielThemes.animationDuration,
                            curve: ConcielThemes.animationCurve,
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.edit_outlined,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 14,
                            ),
                          ),
                          /*
                      Expanded(
                        child: typingText.isNotEmpty
                            ? Text(
                                typingText,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                maxLines: 1,
                                softWrap: false,
                              )
                            : FutureBuilder<String>(
                                future: room.lastEvent?.calcLocalizedBody(
                                      MatrixLocals(L10n.of(context)!),
                                      hideReply: true,
                                      hideEdit: true,
                                      plaintextBody: true,
                                      removeMarkdown: true,
                                      withSenderNamePrefix: !room.isDirectChat ||
                                          room.directChatMatrixID !=
                                              room.lastEvent?.senderId,
                                    ) ??
                                    Future.value(L10n.of(context)!.emptyChat),
                                builder: (context, snapshot) {
                                  return Text(
                                    room.membership == Membership.invite
                                        ? L10n.of(context)!.youAreInvitedToThisChat
                                        : snapshot.data ??
                                            room.lastEvent?.calcLocalizedBodyFallback(
                                              MatrixLocals(L10n.of(context)!),
                                              hideReply: true,
                                              hideEdit: true,
                                              plaintextBody: true,
                                              removeMarkdown: true,
                                              withSenderNamePrefix:
                                                  !room.isDirectChat ||
                                                      room.directChatMatrixID !=
                                                          room.lastEvent?.senderId,
                                            ) ??
                                            L10n.of(context)!.emptyChat,
                                    softWrap: false,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: unread ? FontWeight.w600 : null,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      decoration: room.lastEvent?.redacted == true
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  );
                                },
                              ),
                      ),
                      */
                          Text(
                            room.lastEvent?.originServerTs == null
                                ? ''
                                : room.timeCreated.localizedTime(context),
                            style: TextStyle(
                              fontSize: 13,
                              color: unread
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => controller?.selectMode != SelectMode.normal
                ? controller!.toggleSelection(room.id)
                : clickAction(context),
          ),
        ),
      ),
    );
  }
}
