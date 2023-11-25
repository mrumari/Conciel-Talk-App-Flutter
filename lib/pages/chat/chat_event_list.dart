import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'package:concieltalk/pages/chat/chat.dart';
import 'package:concieltalk/pages/chat/events/message.dart';
import 'package:concieltalk/pages/chat/seen_by_row.dart';
import 'package:concieltalk/pages/chat/typing_indicators.dart';
import 'package:concieltalk/pages/user_bottom_sheet/user_bottom_sheet.dart';
import 'package:concieltalk/utils/adaptive_bottom_sheet.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/filtered_timeline_extension.dart';
import 'package:concieltalk/utils/platform_infos.dart';

class ChatEventList extends StatelessWidget {
  final ChatController controller;
  const ChatEventList({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final thisEventsKeyMap = <String, int>{};
    for (var i = 0; i < controller.timeline!.events.length; i++) {
      thisEventsKeyMap[controller.timeline!.events[i].eventId] = i;
    }
    return ListView.custom(
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 4,
        left: 0,
        right: 0,
      ),
      reverse: true,
      controller: controller.scrollController,
      keyboardDismissBehavior: PlatformInfos.isIOS
          ? ScrollViewKeyboardDismissBehavior.onDrag
          : ScrollViewKeyboardDismissBehavior.manual,
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int i) {
          // Footer to display typing indicator and read receipts:
          if (i == 0) {
            if (controller.timeline!.isRequestingFuture) {
              return const Center(
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              );
            }
            if (controller.timeline!.canRequestFuture) {
              return Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => controller.requestFuture(),
                  );
                  return Center(
                    child: IconButton(
                      onPressed: controller.requestFuture,
                      icon: const Icon(Icons.refresh_outlined),
                    ),
                  );
                },
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SeenByRow(controller),
                TypingIndicators(controller),
              ],
            );
          }

          // Request history button or progress indicator:
          if (i == controller.timeline!.events.length + 1) {
            if (controller.timeline!.isRequestingHistory) {
              return const Center(
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              );
            }
            if (controller.timeline!.canRequestHistory) {
              return Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => controller.requestHistory(),
                  );
                  return Center(
                    child: IconButton(
                      onPressed: controller.requestHistory,
                      icon: const Icon(Icons.refresh_outlined),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          }

          // The message at this index:
          final index = i - 1;
          final event = controller.timeline!.events[index];
          bool visible = event.isVisibleInGui;
          if (event.isVisibleInGui) {
            if (event.type == EventTypes.CallAnswer ||
                event.type == EventTypes.CallHangup ||
                event.type == EventTypes.CallReject) {
              visible = event.callVisible;
            }
          }
          return AutoScrollTag(
            key: ValueKey(event.eventId),
            index: index,
            controller: controller.scrollController,
            child: visible
                ? Message(
                    event,
                    onSwipe: (direction) =>
                        controller.replyAction(replyTo: event),
                    onInfoTab: controller.showEventInfo,
                    onAvatarTab: (Event event) => showAdaptiveBottomSheet(
                      context: context,
                      builder: (c) => UserBottomSheet(
                        user: event.senderFromMemoryOrFallback,
                        outerContext: context,
                        onMention: () => controller.sendController.text +=
                            '${event.senderFromMemoryOrFallback.mention} ',
                      ),
                    ),
                    onSelect: controller.onSelectMessage,
                    scrollToEventId: (String eventId) =>
                        controller.scrollToEventId(eventId),
                    longPressSelect: controller.selectedEvents.isEmpty,
                    selected: controller.selectedEvents
                        .any((e) => e.eventId == event.eventId),
                    timeline: controller.timeline!,
                    displayReadMarker:
                        controller.readMarkerEventId == event.eventId &&
                            controller.timeline?.allowNewEvent == false,
                    nextEvent: i < controller.timeline!.events.length
                        ? controller.timeline!.events[i]
                        : null,
                  )
                : const SizedBox.shrink(),
          );
        },
        childCount: controller.timeline!.events.length + 2,
        findChildIndexCallback: (key) =>
            controller.findChildIndexCallback(key, thisEventsKeyMap),
      ),
    );
  }
}
