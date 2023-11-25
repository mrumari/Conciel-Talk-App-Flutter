import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:vrouter/vrouter.dart';

import 'package:concieltalk/pages/chat/chat.dart';
import 'package:concieltalk/pages/user_bottom_sheet/user_bottom_sheet.dart';
import 'package:concieltalk/utils/adaptive_bottom_sheet.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:concieltalk/widgets/avatar.dart';

class ChatAppBarTitle extends StatelessWidget {
  final ChatController controller;
  const ChatAppBarTitle(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final room = controller.room;
    if (controller.selectedEvents.isNotEmpty) {
      return Text(controller.selectedEvents.length.toString());
    }
    final directChatMatrixID = room.directChatMatrixID;
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: directChatMatrixID != null
          ? () => showAdaptiveBottomSheet(
                context: context,
                builder: (c) => UserBottomSheet(
                  user: room
                      .unsafeGetUserFromMemoryOrFallback(directChatMatrixID),
                  outerContext: context,
                  onMention: () => controller.sendController.text +=
                      '${room.unsafeGetUserFromMemoryOrFallback(directChatMatrixID).mention} ',
                ),
              )
          : controller.isArchived
              ? null
              : () =>
                  VRouter.of(context).toSegments(['rooms', room.id, 'details']),
      child: Row(
        children: [
          Hero(
            tag: 'content_banner',
            child: Avatar(
              mxContent: room.avatar,
              name: room.getLocalizedDisplayname(
                MatrixLocals(L10n.of(context)!),
              ),
              size: 36,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              room.getLocalizedDisplayname(MatrixLocals(L10n.of(context)!)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
