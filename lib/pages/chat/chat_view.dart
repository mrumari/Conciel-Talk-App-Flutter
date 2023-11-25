import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:concieltalk/drawers/standard_drawer.dart';
import 'package:concieltalk/drawers/rotating_drawer.dart';

import 'package:concieltalk/pages/chat/chat_send_actions.dart';
import 'package:concieltalk/utils/ui/header_footer.dart';
import 'package:flutter/material.dart';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/themes.dart';
import 'package:concieltalk/pages/chat/chat.dart';
import 'package:concieltalk/pages/chat/chat_app_bar_title.dart';
import 'package:concieltalk/pages/chat/chat_event_list.dart';
import 'package:concieltalk/pages/chat/encryption_button.dart';
import 'package:concieltalk/pages/chat/pinned_events.dart';
import 'package:concieltalk/pages/chat/reactions_picker.dart';
import 'package:concieltalk/pages/chat/reply_display.dart';
import 'package:concieltalk/pages/chat/tombstone_display.dart';
import 'package:concieltalk/widgets/chat_settings_popup_menu.dart';
import 'package:concieltalk/widgets/connection_status_header.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'package:concieltalk/utils/stream_extension.dart';
import 'chat_emoji_picker.dart';
import 'chat_input_row.dart';

enum _EventContextAction { info, report }

class ChatView extends StatelessWidget {
  final ChatController controller;

  const ChatView(this.controller, {Key? key}) : super(key: key);

  List<Widget> _appBarActions(BuildContext context) {
    if (controller.selectMode) {
      return [
        if (controller.canEditSelectedEvents)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: L10n.of(context)!.edit,
            onPressed: controller.editSelectedEventAction,
          ),
        IconButton(
          icon: const Icon(Icons.copy_outlined),
          tooltip: L10n.of(context)!.copy,
          onPressed: controller.copyEventsAction,
        ),
        if (controller.canSaveSelectedEvent)
          // Use builder context to correctly position the share dialog on iPad
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.adaptive.share),
              tooltip: L10n.of(context)!.share,
              onPressed: () => controller.saveSelectedEvent(context),
            ),
          ),
        if (controller.canRedactSelectedEvents)
          IconButton(
            icon: const Icon(Icons.delete_outlined),
            tooltip: L10n.of(context)!.redactMessage,
            onPressed: controller.redactEventsAction,
          ),
        IconButton(
          icon: const Icon(Icons.push_pin_outlined),
          onPressed: controller.pinEvent,
          tooltip: L10n.of(context)!.pinMessage,
        ),
        if (controller.selectedEvents.length == 1)
          PopupMenuButton<_EventContextAction>(
            onSelected: (action) {
              switch (action) {
                case _EventContextAction.info:
                  controller.showEventInfo();
                  controller.clearSelectedEvents();
                  break;
                case _EventContextAction.report:
                  controller.reportEventAction();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _EventContextAction.info,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outlined),
                    const SizedBox(width: 12),
                    Text(L10n.of(context)!.messageInfo),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _EventContextAction.report,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Text(L10n.of(context)!.reportMessage),
                  ],
                ),
              ),
            ],
          ),
      ];
    } else if (controller.isArchived) {
      return [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton.icon(
            onPressed: controller.forgetRoom,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            icon: const Icon(Icons.delete_forever_outlined),
            label: Text(L10n.of(context)!.delete),
          ),
        ),
      ];
    } else {
      return [
        if (Matrix.of(context).voipPlugin != null &&
            controller.room.isDirectChat)
          IconButton(
            onPressed: controller.onVoiceButtonTap,
            icon: const Icon(
              ConcielIcons.phone,
              size: 18,
            ),
            tooltip: L10n.of(context)!.placeCall,
          ),
        IconButton(
          onPressed: controller.onVideoButtonTap,
          icon: const Icon(
            ConcielIcons.video_camera,
            size: 18,
          ),
          tooltip: L10n.of(context)!.placeCall,
        ),
        if (controller.room.isDirectChat) EncryptionButton(controller.room),
        ChatSettingsPopupMenu(controller.room, !controller.room.isDirectChat),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.room.membership == Membership.invite) {
      showFutureLoadingDialog(
        context: context,
        future: () => controller.room.join(),
      );
    }
    final bottomSheetPadding = ConcielThemes.isColumnMode(context) ? 16.0 : 8.0;
    final String share =
        VRouter.of(context).queryParameters['share'] ?? 'no-file';
    return VWidgetGuard(
      onSystemPop: (redirector) async {
        VRouter.of(context).to('/rooms', queryParameters: {'share': share});
        redirector.stopRedirection();
      },
      child: GestureDetector(
        onTapDown: (_) => controller.setReadMarker(),
        behavior: HitTestBehavior.opaque,
        child: StreamBuilder(
          stream: controller.room.onUpdate.stream
              .rateLimit(const Duration(seconds: 1)),
          builder: (context, snapshot) => FutureBuilder(
            future: controller.loadTimelineFuture,
            builder: (BuildContext context, snapshot) {
              return Scaffold(
                appBar: AppBar(
                  toolbarHeight: ScreenUtil().statusBarHeight + 32.h,
                  foregroundColor: personalColorScheme.outline,
                  titleSpacing: 0,
                  automaticallyImplyLeading: false,
                  actions: <Widget>[Container()],
                  clipBehavior: Clip.none,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Builder(
                        builder: (context) => DefaultHeaderWidget(
                          route: '/rooms',
                          onBackPress: () {
                            controller.room.stopStaleCallsChecker(
                              controller.room.id,
                            );
                            VRouter.of(context).to(
                              '/rooms',
                              queryParameters: {'share': share},
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                onEndDrawerChanged: (isOpened) {
                  controller.endDrawerOpen = isOpened;
                  controller.isEndDrawerOpen(isOpened);
                },
                endDrawer: Padding(
                  padding: const EdgeInsets.only(top: 16).r,
                  child: RotatingEndDrawer(
                    drawer: StandardDrawer(
                      showSplines: true,
                      context: context,
                      left: false,
                      borderColor: personalColorScheme.primary,
                      splineColor: personalColorScheme.surfaceTint,
                      icons: const [
                        Icons.emoji_emotions_outlined,
                        Icons.gps_fixed_outlined,
                        Icons.attachment_outlined,
                        Icons.image_outlined,
                        Icons.camera_alt_outlined,
                        Icons.videocam_outlined,
                      ],
                      onTap: [
                        () {
                          sendStickerAction(context, controller.room);
                        },
                        () {
                          sendLocationAction(context, controller.room);
                        },
                        () {
                          sendFileAction(context, controller.room);
                        },
                        () {
                          sendImageAction(context, controller.room);
                        },
                        () {
                          openCameraAction(context, controller.room);
                        },
                        () {
                          openVideoCameraAction(context, controller.room);
                        },
                      ],
                    ),
                  ),
                ),
                floatingActionButton: controller.showScrollDownButton &&
                        controller.selectedEvents.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 56.0),
                        child: FloatingActionButton(
                          onPressed: controller.scrollDown,
                          heroTag: null,
                          mini: true,
                          child: const Icon(Icons.arrow_downward_outlined),
                        ),
                      )
                    : null,
                body: Builder(
                  builder: (context) {
                    return DropTarget(
                      onDragDone: controller.onDragDone,
                      onDragEntered: controller.onDragEntered,
                      onDragExited: controller.onDragExited,
                      child: Stack(
                        children: <Widget>[
                          if (Matrix.of(context).wallpaper != null)
                            Image.file(
                              Matrix.of(context).wallpaper!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                gradient: ConcielThemes.backgroundGradient(
                                  context,
                                  64,
                                ),
                              ),
                            ),
                          SafeArea(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  children: <Widget>[
                                    AppBar(
                                      automaticallyImplyLeading: false,
                                      elevation: 3,
                                      actionsIconTheme: IconThemeData(
                                        color: controller.selectedEvents.isEmpty
                                            ? null
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                      ),
                                      leading: controller.selectMode
                                          ? IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: controller
                                                  .clearSelectedEvents,
                                              tooltip: L10n.of(context)!.close,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            )
                                          : null,
                                      titleSpacing: 0,
                                      title: ChatAppBarTitle(controller),
                                      actions: _appBarActions(context),
                                    ),
                                    TombstoneDisplay(controller),
                                    PinnedEvents(controller),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap:
                                            controller.clearSingleSelectedEvent,
                                        child: Builder(
                                          builder: (context) {
                                            if (controller.timeline == null) {
                                              return const Center(
                                                child: CircularProgressIndicator
                                                    .adaptive(
                                                  strokeWidth: 2,
                                                ),
                                              );
                                            }

                                            return ChatEventList(
                                              controller: controller,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    if (controller
                                            .room.canSendDefaultMessages &&
                                        controller.room.membership ==
                                            Membership.join)
                                      Container(
                                        margin: EdgeInsets.only(
                                          bottom: bottomSheetPadding,
                                          left: bottomSheetPadding,
                                          right: bottomSheetPadding,
                                        ),
                                        constraints: const BoxConstraints(
                                          maxWidth:
                                              ConcielThemes.columnWidth * 2.5,
                                        ),
                                        alignment: Alignment.center,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceTint, // Set the border color here
                                              width:
                                                  1, // Set the border width here
                                            ),
                                            borderRadius:
                                                const BorderRadius.only(
                                              bottomLeft: Radius.circular(
                                                AppConfig.borderRadius,
                                              ),
                                              bottomRight: Radius.circular(
                                                AppConfig.borderRadius,
                                              ),
                                            ),
                                          ),
                                          child: Material(
                                            borderRadius:
                                                const BorderRadius.only(
                                              bottomLeft: Radius.circular(
                                                AppConfig.borderRadius,
                                              ),
                                              bottomRight: Radius.circular(
                                                AppConfig.borderRadius,
                                              ),
                                            ),
                                            elevation: 4,
                                            shadowColor:
                                                Colors.black.withAlpha(64),
                                            clipBehavior: Clip.hardEdge,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.white
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .background,
                                            child: controller.room
                                                        .isAbandonedDMRoom ==
                                                    true
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      TextButton.icon(
                                                        style: TextButton
                                                            .styleFrom(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(
                                                            16,
                                                          ),
                                                          foregroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .error,
                                                        ),
                                                        icon: const Icon(
                                                          Icons
                                                              .archive_outlined,
                                                        ),
                                                        onPressed: controller
                                                            .leaveChat,
                                                        label: Text(
                                                          L10n.of(context)!
                                                              .leave,
                                                        ),
                                                      ),
                                                      TextButton.icon(
                                                        style: TextButton
                                                            .styleFrom(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(
                                                            16,
                                                          ),
                                                        ),
                                                        icon: const Icon(
                                                          Icons.forum_outlined,
                                                        ),
                                                        onPressed: controller
                                                            .recreateChat,
                                                        label: Text(
                                                          L10n.of(context)!
                                                              .reopenChat,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const ConnectionStatusHeader(),
                                                      ReactionsPicker(
                                                        controller,
                                                      ),
                                                      ReplyDisplay(controller),
                                                      ChatInputRow(controller),
                                                      ChatEmojiPicker(
                                                        controller,
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (controller.dragging)
                            Container(
                              color: Theme.of(context)
                                  .scaffoldBackgroundColor
                                  .withOpacity(0.9),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.upload_outlined,
                                size: 100,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
