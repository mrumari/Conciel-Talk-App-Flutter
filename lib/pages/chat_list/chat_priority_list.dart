                            // Priority chats - row at top of primary list
/*                             Positioned(
                              top: mSize.height / 3,
                              height: 60,
                              child: SizedBox(
                                width: mSize.width,
                                child: ListView.builder(
                                  controller:
                                      controller.priorityScrollController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      Matrix.of(context).client.rooms.length,
                                  itemBuilder: (context, index) {
                                    final room =
                                        Matrix.of(context).client.rooms[index];
                                    final unread = room.isUnread ||
                                        room.membership == Membership.invite;
                                    final unreadBubbleSize =
                                        unread || room.hasNewMessages
                                            ? room.notificationCount > 0
                                                ? 20.0
                                                : 14.0
                                            : 0.0;
                                    return Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        room.isFavourite
                                            ? SizedBox(
                                                height: Avatar.defaultSize,
                                                width: Avatar.defaultSize + 8,
                                                child: ListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  title: Container(
                                                    padding: EdgeInsets.zero,
                                                    clipBehavior: Clip.hardEdge,
                                                    decoration: ShapeDecoration(
                                                      color: personalColorScheme
                                                          .tertiary,
                                                      shape: StarBorder.polygon(
                                                        sides: 6,
                                                        side: BorderSide(
                                                          strokeAlign: BorderSide
                                                              .strokeAlignOutside,
                                                          color:
                                                              personalColorScheme
                                                                  .tertiary,
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Avatar(
                                                      size: 60,
                                                      mxContent: room.avatar,
                                                      name: room.name,
                                                      onTap: () {
                                                        controller.splineIndex =
                                                            index;
                                                        WidgetsBinding.instance
                                                            .addPostFrameCallback(
                                                                (_) {
                                                          controller
                                                              .scrollController
                                                              .animateTo(
                                                            controller
                                                                    .splineIndex *
                                                                60,
                                                            duration:
                                                                const Duration(
                                                              milliseconds: 100,
                                                            ),
                                                            curve: Curves.ease,
                                                          );
                                                        });
                                                        chatTap(context, room);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                        room.isFavourite
                                            ? AnimatedContainer(
                                                duration: ConcielThemes
                                                    .animationDuration,
                                                curve: ConcielThemes
                                                    .animationCurve,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 7,
                                                ),
                                                height: unreadBubbleSize,
                                                width: room.notificationCount ==
                                                            0 &&
                                                        !unread &&
                                                        !room.hasNewMessages
                                                    ? 0
                                                    : (unreadBubbleSize - 9) *
                                                            room.notificationCount
                                                                .toString()
                                                                .length +
                                                        9,
                                                decoration: BoxDecoration(
                                                  color: room.highlightCount >
                                                              0 ||
                                                          room.membership ==
                                                              Membership.invite
                                                      ? Colors.amber
                                                      : room.notificationCount >
                                                                  0 ||
                                                              room.markedUnread
                                                          ? room.isFavourite
                                                              ? Theme.of(
                                                                  context,
                                                                )
                                                                  .colorScheme
                                                                  .tertiary
                                                              : Theme.of(
                                                                  context,
                                                                )
                                                                  .colorScheme
                                                                  .primary
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .primaryContainer,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    AppConfig.borderRadius,
                                                  ),
                                                ),
                                                child: Center(
                                                  child:
                                                      room.notificationCount > 0
                                                          ? Text(
                                                              room.notificationCount
                                                                  .toString(),
                                                              style: TextStyle(
                                                                color: room.highlightCount >
                                                                        0
                                                                    ? Colors
                                                                        .white
                                                                    : room.notificationCount >
                                                                            0
                                                                        ? Theme.of(context)
                                                                            .colorScheme
                                                                            .outline
                                                                        : Theme.of(context)
                                                                            .colorScheme
                                                                            .onPrimaryContainer,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            )
                                                          : const SizedBox
                                                              .shrink(),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),*/