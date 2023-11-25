import 'package:concieltalk/config/color_constants.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/pages/chat_list/chat_list.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:concieltalk/widgets/avatar.dart';
import 'chat_list_body.dart';

class ChatPeekView extends StatelessWidget {
  const ChatPeekView({
    super.key,
    required this.share,
    required this.controller,
  });

  final String share;
  final ChatListController controller;

  @override
  Widget build(BuildContext context) {
    late double sizeFactor;
    switch (1.sh) {
      case <= 710:
        sizeFactor = AppConfig.chatItemHeight / 10;
        break;
      case > 710 && <= 900:
        sizeFactor = AppConfig.chatItemHeight / 2 - 6;
      case > 900:
        sizeFactor = AppConfig.chatItemHeight - 18;
      default:
        sizeFactor = 0;
    }

    return SizedBox(
      height: 1.sh / 2 - AppConfig.chatItemHeight * 3 - sizeFactor,
      child: Column(
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: ShapeDecoration(
              color: personalColorScheme.tertiary,
              shape: const CircleBorder(),
            ),
            child: Avatar(
              size: share != 'make-call'
                  ? controller.selectMode != SelectMode.normal
                      ? 0
                      : (Avatar.defaultSize * 2.2).h
                  : (Avatar.defaultSize * 3).h,
              fontSize: 32,
              mxContent:
                  controller.filteredRooms[controller.splineIndex].avatar,
              name: controller.filteredRooms[controller.splineIndex]
                  .getLocalizedDisplayname(
                MatrixLocals(L10n.of(context)!),
              ),
              onTap: () => chatTap(
                context,
                controller.filteredRooms[controller.splineIndex],
              ),
            ),
          ),
          if (share != 'make-call')
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: GestureDetector(
                  onTap: () => chatTap(
                    context,
                    controller.filteredRooms[controller.splineIndex],
                  ),
                  child: Text(
                    controller.filteredRooms[controller.splineIndex]
                        .getLocalizedDisplayname(
                      MatrixLocals(
                        L10n.of(context)!,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 23,
                      color: personalColorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          if (share != 'make-call')
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 64).r,
                child: GestureDetector(
                  onTap: () => chatTap(
                    context,
                    controller.filteredRooms[controller.splineIndex],
                  ),
                  child: FutureBuilder<String>(
                    future: controller
                            .filteredRooms[controller.splineIndex].lastEvent
                            ?.calcLocalizedBody(
                          MatrixLocals(
                            L10n.of(context)!,
                          ),
                          hideReply: true,
                          plaintextBody: true,
                          removeMarkdown: true,
                          withSenderNamePrefix: !controller
                                  .filteredRooms[controller.splineIndex]
                                  .isDirectChat ||
                              controller.filteredRooms[controller.splineIndex]
                                      .directChatMatrixID !=
                                  controller
                                      .filteredRooms[controller.splineIndex]
                                      .lastEvent
                                      ?.senderId,
                        ) ??
                        Future.value(
                          '',
                        ),
                    builder: (context, snapshot) {
                      String previewTxt = snapshot.data ?? '';
                      if (previewTxt.contains(
                        'm.call.reject',
                      )) {
                        previewTxt = 'Call declined';
                      }
                      final unread = controller
                              .filteredRooms[controller.splineIndex].isUnread ||
                          controller.filteredRooms[controller.splineIndex]
                                  .membership ==
                              Membership.invite;
                      return Text(
                        controller.filteredRooms[controller.splineIndex]
                                    .membership ==
                                Membership.invite
                            ? L10n.of(
                                context,
                              )!
                                .youAreInvitedToThisChat
                            : previewTxt,
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: unread ? FontWeight.w600 : null,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant,
                          decoration: controller
                                      .filteredRooms[controller.splineIndex]
                                      .lastEvent
                                      ?.redacted ==
                                  true
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void chatTap(BuildContext context, Room room) {
  final String share =
      VRouter.of(context).queryParameters['share'] ?? 'no-file';
  switch (share) {
    case 'make-call':
      onPhoneButtonTap(
        context,
        room,
      );
      break;
    case 'direct':
      VRouter.of(context).toSegments(
        [
          'rooms',
          room.id,
        ],
        queryParameters: {
          'share': share,
        },
      );
      break;
    default:
      VRouter.of(context).toSegments(
        [
          'rooms',
          room.id,
        ],
        queryParameters: {
          'share': share,
        },
      );
  }
}
