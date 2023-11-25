import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:flutter/material.dart';

import 'package:badges/badges.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/pages/chat_list/chat_list.dart';
import 'package:concieltalk/widgets/unread_rooms_badge.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'chat_list_body.dart';

class ChatListView extends StatelessWidget {
  final ChatListController controller;
  const ChatListView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String share =
        VRouter.of(context).queryParameters['share'] ?? 'no-file';
    if (share == 'direct') controller.scaffoldKey.currentState!.openEndDrawer();
    return StreamBuilder<Object?>(
      stream: Matrix.of(context).onShareContentChanged.stream,
      builder: (_, __) {
        return VWidgetGuard(
          onSystemPop: (redirector) async {
            final selMode = controller.selectMode;
            if (selMode != SelectMode.normal) {
              controller.cancelAction();
              redirector.stopRedirection();
              return;
            }
            if (controller.activeFilter !=
                (AppConfig.separateChatTypes
                    ? ActiveFilter.messages
                    : ActiveFilter.allChats)) {
              controller
                  .onDestinationSelected(AppConfig.separateChatTypes ? 1 : 0);

              redirector.stopRedirection();
              return;
            }
            for (int i = 0; i < controller.filteredRooms.length; i++) {
              controller.filteredRooms[i]
                  .stopStaleCallsChecker(controller.filteredRooms[i].id);
            }
            await controller.slidePage!.forward();
            redirector.to('/talk');
          },
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: FocusManager.instance.primaryFocus?.unfocus,
                  onLongPress: () => VRouter.of(context).to('/newprivatechat'),
                  excludeFromSemantics: true,
                  behavior: HitTestBehavior.translucent,
                  child: // Primary list of chats / groups / spaces
                      ChatListViewBody(
                    controller,
                    controller.scrollController,
                    false,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

List<NavigationDestination> getNavigationDestinations(
  BuildContext context,
  ChatListController controller,
) {
  final badgePosition = BadgePosition.topEnd(top: -12, end: -8);
  return [
    NavigationDestination(
      icon: Container(
        padding: const EdgeInsets.only(right: 26).r,
        child: Icon(
          ConcielIcons.share,
          color: personalColorScheme.outline,
        ),
      ),
      label: '', // L10n.of(context)!.chats,
    ),
    if (AppConfig.separateChatTypes) ...[
      NavigationDestination(
        icon: UnreadRoomsBadge(
          badgePosition: badgePosition,
          filter: controller.getRoomFilterByActiveFilter(ActiveFilter.messages),
          child: const Icon(Icons.forum_outlined),
        ),
        selectedIcon: UnreadRoomsBadge(
          badgePosition: badgePosition,
          filter: controller.getRoomFilterByActiveFilter(ActiveFilter.messages),
          child: const Icon(Icons.forum),
        ),
        label: L10n.of(context)!.messages,
      ),
      NavigationDestination(
        icon: UnreadRoomsBadge(
          badgePosition: badgePosition,
          filter: controller.getRoomFilterByActiveFilter(ActiveFilter.groups),
          child: const Icon(Icons.group_outlined),
        ),
        selectedIcon: UnreadRoomsBadge(
          badgePosition: badgePosition,
          filter: controller.getRoomFilterByActiveFilter(ActiveFilter.groups),
          child: const Icon(Icons.group),
        ),
        label: L10n.of(context)!.groups,
      ),
    ] else if (controller.spaces.isNotEmpty)
      NavigationDestination(
        icon: UnreadRoomsBadge(
          badgePosition: badgePosition,
          filter: controller.getRoomFilterByActiveFilter(ActiveFilter.allChats),
          child: const Icon(Icons.forum_outlined),
        ),
        selectedIcon: UnreadRoomsBadge(
          badgePosition: badgePosition,
          filter: controller.getRoomFilterByActiveFilter(ActiveFilter.allChats),
          child: const Icon(Icons.forum),
        ),
        label: L10n.of(context)!.chats,
      )
    else
      NavigationDestination(
        icon: UnreadRoomsBadge(
          badgePosition: badgePosition,
          filter: controller.getRoomFilterByActiveFilter(ActiveFilter.allChats),
          child: Icon(
            ConcielIcons.msg_notifier,
            size: 26,
            color: personalColorScheme.outline.withOpacity(0.75),
          ),
        ),
        label: '',
      ),
    if (controller.spaces.isNotEmpty)
      const NavigationDestination(
        icon: Icon(Icons.workspaces_outlined),
        selectedIcon: Icon(Icons.workspaces),
        label: '',
      ),
    NavigationDestination(
      icon: Container(
        padding: const EdgeInsets.only(left: 26).r,
        child: const Icon(ConcielIcons.users),
      ),
      label: '', // L10n.of(context)!.chats,
    ),
  ];
}
