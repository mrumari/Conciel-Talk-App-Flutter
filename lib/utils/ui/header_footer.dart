import 'dart:math';
import 'package:collection/collection.dart';
import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/widgets/base_ring_state.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:concieltalk/widgets/unread_rooms_badge.dart';
import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

class DefaultHeaderWidget extends StatelessWidget {
  final String route;
  final bool showConciel;
  final bool showSearch;
  final bool showBack;
  final VoidCallback? onSearchPress;
  final VoidCallback? onConcielPress;
  final VoidCallback? onBackPress;
  final VoidCallback? onSearchLongPress;
  final VoidCallback? onConcielLongPress;
  final VoidCallback? onBackLongPress;
  final VoidCallback? onSearchDoubleTap;
  final VoidCallback? onConcielDoubleTap;
  final VoidCallback? onBackDoubleTap;

  const DefaultHeaderWidget({
    super.key,
    this.route = '',
    this.showConciel = true,
    this.showSearch = true,
    this.showBack = true,
    this.onSearchPress,
    this.onConcielPress,
    this.onBackPress,
    this.onSearchLongPress,
    this.onConcielLongPress,
    this.onBackLongPress,
    this.onSearchDoubleTap,
    this.onConcielDoubleTap,
    this.onBackDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final pathData = context.vRouter.path;
    final path = pathData.split('/').slice(1)[0];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 26,
                bottom: 2,
              ),
              child: showBack
                  ? GestureDetector(
                      onLongPress: () {
                        if (onBackLongPress != null) onBackLongPress!();
                      },
                      onTap: () {
                        if (onBackPress == null) {
                          switch (path) {
                            case '':
                              VRouter.of(context).pop();
                              break;
                            default:
                              VRouter.of(context).to('/$path');
                              break;
                          }
                        } else {
                          onBackPress!();
                        }
                      },
                      child: const Icon(ConcielIcons.back),
                    )
                  : const SizedBox(
                      width: 24,
                    ),
            ),
          ],
        ),
        if (showConciel)
          GestureDetector(
            onTap: () {
              if (onConcielPress != null) {
                onConcielPress!();
              } else {
                if (path == 'rooms') {
                  VRouter.of(context).to('/talk');
                }
                VRouter.of(context).to('/$path');
              }
            },
            onLongPress: () {
              if (onConcielLongPress != null) {
                onConcielLongPress!();
              } else {
                VRouter.of(context).to('/biometrics');
              }
            },
            onDoubleTap: () {
              if (onConcielDoubleTap != null) {
                onConcielDoubleTap!();
              } else {
                VRouter.of(context).to('settings');
              }
            },
            child: Image.asset(
              cacheHeight: 121,
              cacheWidth: 121,
              'assets/conciel-icon.png',
              width: 36,
              height: 36,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(
            right: 26,
            bottom: 2,
          ),
          child: showSearch
              ? GestureDetector(
                  onTap: () {
                    if (onSearchPress != null) onSearchPress!();
                  },
                  child: const Icon(ConcielIcons.search),
                )
              : GestureDetector(
                  onTap: () {
                    if (onSearchPress != null) onSearchPress!();
                  },
                  child: Icon(
                    Icons.menu,
                    color: personalColorScheme.outline,
                    size: 24,
                  ),
                ),
        ),
      ],
    );
  }
}

class PrimaryHeaderWidget extends StatefulWidget {
  final BuildContext inboundContext;
  final VoidCallback onSearchPressed;
  final VoidCallback onConcielPressed;
  final GlobalKey<BaseRingState> ringKey;

  const PrimaryHeaderWidget({
    Key? key,
    required this.inboundContext,
    required this.onSearchPressed,
    required this.ringKey,
    required this.onConcielPressed,
  }) : super(key: key);
  @override
  PrimaryHeaderWidgetState createState() => PrimaryHeaderWidgetState();
}

class PrimaryHeaderWidgetState extends State<PrimaryHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
//            var settingsDB = Hive.box(Conciel.settingsDB);
//            if (!settingsDB.get(stayLoggedIn)) {
//              AuthProvider authProvider =
//                  Provider.of<AuthProvider>(context, listen: false);
//              authProvider.isLoggedIn().then((value) {
//                VRouter.of(context).to('/biometrics');
//              });
//            }
            VRouter.of(context).to('/biometrics');
          },
          icon: const Icon(ConcielIcons.back),
        ),
        IconButton(
          onPressed: widget.onConcielPressed,
          icon: Image.asset(
            cacheHeight: 121,
            cacheWidth: 121,
            'assets/conciel-icon.png',
            width: 36,
            height: 36,
          ),
        ),
        IconButton(
          onPressed: widget.onSearchPressed,
          icon: const Icon(ConcielIcons.search),
        ),
      ],
    );
  }
}

class PrimaryBottomBar extends StatelessWidget {
  final Function(int) onTap;
  final ConcielApp concielApp;

  const PrimaryBottomBar({
    super.key,
    required this.onTap,
    required this.concielApp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(
            width: 0,
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () => onTap(0),
              icon: Icon(
                ConcielIcons.share,
                color: personalColorScheme.outline,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 26,
                  bottom: 8,
                  child: UnreadIcon(
                    type: concielApp == ConcielApp.shop
                        ? ConcielApp.talk
                        : ConcielApp.shop,
                    badge: false,
                    color: concielApp == ConcielApp.shop
                        ? personalColorScheme.primary
                        : personalColorScheme.secondary,
                    child: IconButton(
                      onPressed: () => onTap(1),
                      icon: Transform.rotate(
                        angle: 90 * pi / 180,
                        child: const Icon(
                          Icons.play_arrow,
                          size: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                UnreadIcon(
                  type: concielApp,
                  color: personalColorScheme.outline,
                  badge: false,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => onTap(2),
                    icon: Icon(
                      switch (concielApp) {
                        ConcielApp.talk => ConcielIcons.msg_notifier,
                        ConcielApp.shop => ConcielIcons.shop,
                        ConcielApp.book => ConcielIcons.book,
                      },
                      size: 26,
                    ),
                  ),
                ),
                Positioned(
                  right: 26,
                  bottom: 8,
                  child: UnreadIcon(
                    type: concielApp == ConcielApp.book
                        ? ConcielApp.talk
                        : ConcielApp.book,
                    badge: false,
                    color: concielApp == ConcielApp.book
                        ? personalColorScheme.primary
                        : personalColorScheme.tertiary,
                    child: IconButton(
                      onPressed: () => onTap(3),
                      icon: Transform.rotate(
                        angle: 90 * pi / 180,
                        child: const Icon(
                          Icons.play_arrow,
                          size: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () => onTap(4),
              icon: Icon(
                ConcielIcons.users,
                color: personalColorScheme.outline,
              ),
            ),
          ),
          const SizedBox(
            width: 0,
          ),
        ],
      ),
    );
  }
}

class CallFooterWidget extends StatelessWidget {
  const CallFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          color: Theme.of(context).colorScheme.outline,
          icon: const Icon(Icons.history_outlined),
          onPressed: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('History')));
          },
        ),
        IconButton(
          color: Theme.of(context).colorScheme.outline,
          icon: const Icon(ConcielIcons.msg_notifier),
          onPressed: () {
            VRouter.of(context).pop;
          },
        ),
        IconButton(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          icon: const Icon(Icons.star_border),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Favorites button pressed')),
            );
          },
        ),
      ],
    );
  }
}

class NumberButton extends StatelessWidget {
  const NumberButton({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 36, fontFamily: 'Exo'),
        foregroundColor: Theme.of(context).colorScheme.outlineVariant,
      ),
      onPressed: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(title)));
      },
      child: Text(title),
    );
  }
}

class FloatingButtonLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return Offset(
      scaffoldGeometry.scaffoldSize.width * .76, //customize here
      scaffoldGeometry.scaffoldSize.height * .93,
    );
  }
}

class NoScalingAnimation extends FloatingActionButtonAnimator {
  @override
  Offset getOffset({Offset? begin, Offset? end, double? progress}) {
    return end!;
  }

  @override
  Animation<double> getRotationAnimation({Animation<double>? parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent!);
  }

  @override
  Animation<double> getScaleAnimation({Animation<double>? parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent!);
  }
}
