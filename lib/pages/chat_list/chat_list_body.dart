import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/pages/chat_list/chat_list_header.dart';
import 'package:concieltalk/utils/localized_exception_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:animations/animations.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';

import 'package:concieltalk/pages/chat_list/chat_list.dart';
import 'package:concieltalk/pages/chat_list/chat_list_item.dart';
import 'package:concieltalk/pages/chat_list/search_title.dart';
import 'package:concieltalk/pages/chat_list/space_view.dart';
import 'package:concieltalk/pages/chat_list/stories_header.dart';
import 'package:concieltalk/utils/adaptive_bottom_sheet.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/client_stories_extension.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:concieltalk/utils/stream_extension.dart';
import 'package:concieltalk/widgets/avatar.dart';
import 'package:concieltalk/widgets/profile_bottom_sheet.dart';
import 'package:concieltalk/widgets/public_room_bottom_sheet.dart';
import '../../config/themes.dart';
import 'package:concieltalk/widgets/connection_status_header.dart';
import 'package:concieltalk/widgets/matrix.dart';

class ChatListViewBody extends StatelessWidget {
  final ChatListController controller;
  final ScrollController scrollController;
  final bool priority;

  const ChatListViewBody(
    this.controller,
    this.scrollController,
    this.priority, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roomSearchResult = controller.roomSearchResult;
    final userSearchResult = controller.userSearchResult;
    final client = Matrix.of(context).client;
    const dummyChatCount = 4;
    final titleColor = personalColorScheme.outline;
    final subtitleColor = personalColorScheme.outline;

    return SizedBox(
/*                          top: controller.isSearching || controller.isSearchMode
                              ? AppConfig.chatItemHeight
                              : 156.h,*/
      height: 1.sh - 306.h,
      width: 1.sw,
      child: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> primaryAnimation,
          Animation<double> secondaryAnimation,
        ) {
          return SharedAxisTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.vertical,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            child: child,
          );
        },
        child: StreamBuilder(
          key: ValueKey(
            client.userID.toString() +
                controller.activeFilter.toString() +
                controller.activeSpaceId.toString(),
          ),
          stream: client.onSync.stream
              .where((s) => s.hasRoomUpdate)
              .rateLimit(const Duration(seconds: 1)),
          builder: (context, _) {
            if (controller.activeFilter == ActiveFilter.spaces &&
                !controller.isSearchMode) {
              return SpaceView(
                controller,
                scrollController: scrollController,
                key: Key(controller.activeSpaceId ?? 'Spaces'),
              );
            }
            final rooms =
                priority ? controller.pfilteredRooms : controller.filteredRooms;
            final displayStoriesHeader = {
                  ActiveFilter.allChats,
                  ActiveFilter.messages,
                }.contains(controller.activeFilter) &&
                client.storiesRooms.isNotEmpty;
            return ValueListenableBuilder(
              valueListenable: controller.searchNotifier,
              builder: (context, isSearchMode, child) {
                return CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  controller: scrollController,
                  slivers: [
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppConfig.chatItemHeight),
                    ),

                    if (controller.isSearching ||
                        controller.isSearchMode ||
                        controller.selectMode == SelectMode.select)
                      ChatListHeader(controller: controller),

                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          if (controller.isSearchMode) ...[
                            SearchTitle(
                              title: L10n.of(context)!.publicRooms,
                              icon: const Icon(Icons.explore_outlined),
                            ),
                            AnimatedContainer(
                              clipBehavior: Clip.hardEdge,
                              decoration: const BoxDecoration(),
                              height: roomSearchResult == null ||
                                      roomSearchResult.chunk.isEmpty
                                  ? 0
                                  : 106,
                              duration: ConcielThemes.animationDuration,
                              curve: ConcielThemes.animationCurve,
                              child: roomSearchResult == null
                                  ? null
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: roomSearchResult.chunk.length,
                                      itemBuilder: (context, i) => _SearchItem(
                                        title: roomSearchResult.chunk[i].name ??
                                            roomSearchResult.chunk[i]
                                                .canonicalAlias?.localpart ??
                                            L10n.of(context)!.group,
                                        avatar:
                                            roomSearchResult.chunk[i].avatarUrl,
                                        onPressed: () =>
                                            showAdaptiveBottomSheet(
                                          context: context,
                                          builder: (c) => PublicRoomBottomSheet(
                                            roomAlias: roomSearchResult
                                                    .chunk[i].canonicalAlias ??
                                                roomSearchResult
                                                    .chunk[i].roomId,
                                            outerContext: context,
                                            chunk: roomSearchResult.chunk[i],
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            SearchTitle(
                              title: L10n.of(context)!.users,
                              icon: const Icon(Icons.group_outlined),
                            ),
                            AnimatedContainer(
                              clipBehavior: Clip.hardEdge,
                              decoration: const BoxDecoration(),
                              height: userSearchResult == null ||
                                      userSearchResult.results.isEmpty
                                  ? 0
                                  : 106,
                              duration: ConcielThemes.animationDuration,
                              curve: ConcielThemes.animationCurve,
                              child: userSearchResult == null
                                  ? null
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          userSearchResult.results.length,
                                      itemBuilder: (context, i) => _SearchItem(
                                        title: userSearchResult
                                                .results[i].displayName ??
                                            userSearchResult
                                                .results[i].userId.localpart ??
                                            L10n.of(context)!.unknownDevice,
                                        avatar: userSearchResult
                                            .results[i].avatarUrl,
                                        onPressed: () =>
                                            showAdaptiveBottomSheet(
                                          context: context,
                                          builder: (c) => ProfileBottomSheet(
                                            userId: userSearchResult
                                                .results[i].userId,
                                            outerContext: context,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            SearchTitle(
                              title: L10n.of(context)!.stories,
                              icon: const Icon(Icons.camera_alt_outlined),
                            ),
                          ],
                          if (displayStoriesHeader)
                            StoriesHeader(
                              key: const Key('stories_header'),
                              filter: controller.searchController.text,
                            ),
                          const ConnectionStatusHeader(),
                          if (controller.isSearchMode)
                            SearchTitle(
                              title: L10n.of(context)!.chats,
                              icon: const Icon(Icons.forum_outlined),
                            ),
                          if (client.prevBatch != null &&
                              rooms.isEmpty &&
                              !controller.isSearchMode) ...[
                            Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Icon(
                                CupertinoIcons.chat_bubble_2,
                                size: 128,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onInverseSurface,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (client.prevBatch == null)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => Opacity(
                            opacity: (dummyChatCount - i) / dummyChatCount,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: titleColor,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 14.h,
                                      decoration: BoxDecoration(
                                        color: titleColor,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 36.w),
                                  Container(
                                    height: 14.h,
                                    width: 14.w,
                                    decoration: BoxDecoration(
                                      color: subtitleColor,
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Container(
                                    height: 14.h,
                                    width: 14.w,
                                    decoration: BoxDecoration(
                                      color: subtitleColor,
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Container(
                                decoration: BoxDecoration(
                                  color: subtitleColor,
                                  borderRadius: BorderRadius.circular(3.r),
                                ),
                                height: 12.h,
                                margin: EdgeInsets.only(right: 22.w),
                              ),
                            ),
                          ),
                          childCount: dummyChatCount,
                        ),
                      ),
                    if (client.prevBatch != null)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            int i = index;
                            if (i > rooms.length) i = rooms.length;
                            if (!rooms[i]
                                .getLocalizedDisplayname(
                                  MatrixLocals(L10n.of(context)!),
                                )
                                .toLowerCase()
                                .contains(
                                  controller.searchController.text
                                      .toLowerCase(),
                                )) {
                              return const SizedBox.shrink();
                            }
                            return priority
                                ? !rooms[i].isFavourite
                                    ? Container(
                                        alignment: Alignment.centerLeft,
                                        height: AppConfig.chatItemHeight,
                                        child: ChatListItem(
                                          rooms[i],
                                          controller: controller,
                                          key: Key(
                                            'chat_list_item_${rooms[i].id}',
                                          ),
                                          selected: controller.selectedRoomIds
                                              .contains(rooms[i].id),
                                          onTap: controller.selectMode ==
                                                  SelectMode.select
                                              ? () =>
                                                  controller.toggleSelection(
                                                    rooms[i].id,
                                                  )
                                              : () {
                                                  controller.splineIndex;
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                          (_) {
                                                    scrollController.animateTo(
                                                      controller.splineIndex *
                                                          (AppConfig
                                                              .chatItemHeight),
                                                      duration: const Duration(
                                                        milliseconds: 100,
                                                      ),
                                                      curve: Curves.ease,
                                                    );
                                                  });
                                                },
                                          onLongPress: () {
                                            controller
                                                .toggleSelection(rooms[i].id);
                                          },
                                          activeChat: controller.activeChat ==
                                              rooms[i].id,
                                        ),
                                      )
                                    : const SizedBox.shrink()
                                : SizedBox(
                                    height: AppConfig.chatItemHeight,
                                    child: ChatListItem(
                                      rooms[i],
                                      controller: controller,
                                      key: Key(
                                        'chat_list_item_${rooms[i].id}',
                                      ),
                                      selected: controller.selectedRoomIds
                                          .contains(rooms[i].id),
                                      onTap: controller.selectMode ==
                                              SelectMode.select
                                          ? () => controller.toggleSelection(
                                                rooms[i].id,
                                              )
                                          : () {
                                              controller.splineIndex = i;
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                scrollController.animateTo(
                                                  controller.splineIndex *
                                                      (AppConfig
                                                          .chatItemHeight),
                                                  duration: const Duration(
                                                    milliseconds: 100,
                                                  ),
                                                  curve: Curves.ease,
                                                );
                                              });
                                            },
                                      onLongPress: () {
                                        controller.toggleSelection(rooms[i].id);
                                      },
                                      activeChat:
                                          controller.activeChat == rooms[i].id,
                                    ),
                                  );
                          },
                          childCount: rooms.length,
                        ),
                      ),
                    // DUMMY entry allows full scroll to bottom of list
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppConfig.chatItemHeight * 5.5),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

void makeCall(context, room, callType) async {
  final success = await showFutureLoadingDialog(
    context: context,
    future: () =>
        Matrix.of(context).voipPlugin!.voip.requestTurnServerCredentials(),
  );
  if (success.result != null) {
    final voipPlugin = Matrix.of(context).voipPlugin;
    try {
      await voipPlugin!.voip.inviteToCall(room.id, callType);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toLocalizedString(context))),
      );
    }
  } else {
    await showOkAlertDialog(
      context: context,
      title: L10n.of(context)!.unavailable,
      okLabel: L10n.of(context)!.next,
      useRootNavigator: false,
    );
  }
}

void onPhoneButtonTap(
  context,
  room, {
  bool? direct,
  bool? voice,
}) async {
  direct = direct ?? false;
  voice = voice ?? true;

  if (!direct) {
    final callType = await showModalActionSheet<CallType>(
      context: context,
      cancelLabel: L10n.of(context)!.cancel,
      actions: [
        SheetAction(
          label: L10n.of(context)!.voiceCall,
          icon: Icons.phone_outlined,
          key: CallType.kVoice,
        ),
        SheetAction(
          label: L10n.of(context)!.videoCall,
          icon: Icons.video_call_outlined,
          key: CallType.kVideo,
        ),
      ],
    );
    if (callType == null) return;
    makeCall(
      context,
      room,
      callType,
    );
  } else {
    makeCall(
      context,
      room,
      voice ? CallType.kVoice : CallType.kVideo,
    );
  }
}

class _SearchItem extends StatelessWidget {
  final String title;
  final Uri? avatar;
  final void Function() onPressed;

  const _SearchItem({
    required this.title,
    this.avatar,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 84,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Avatar(
                mxContent: avatar,
                name: title,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
