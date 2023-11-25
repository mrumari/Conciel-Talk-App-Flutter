import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/client_stories_extension.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as b;
import 'package:matrix/matrix.dart';

import 'matrix.dart';

class UnreadRoomsBadge extends StatelessWidget {
  final bool Function(Room) filter;
  final b.BadgePosition? badgePosition;
  final Widget? child;

  const UnreadRoomsBadge({
    Key? key,
    required this.filter,
    this.badgePosition,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Matrix.of(context)
          .client
          .onSync
          .stream
          .where((syncUpdate) => syncUpdate.hasRoomUpdate),
      builder: (context, _) {
        final unreadCount = Matrix.of(context)
            .client
            .rooms
            .where(filter)
            .where((r) => (r.isUnread || r.membership == Membership.invite))
            .length;
        return b.Badge(
          position: badgePosition,
          badgeStyle: b.BadgeStyle(
            badgeColor: Theme.of(context).colorScheme.primary,
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.background,
              width: 2,
            ),
            elevation: 4,
          ),
          badgeContent: Text(
            unreadCount.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 12,
            ),
          ),
          showBadge: unreadCount != 0,
          badgeAnimation: const b.BadgeAnimation.scale(),
          child: child,
        );
      },
    );
  }
}

class UnreadIcon extends StatefulWidget {
  final ConcielApp? type;
  final bool? badge;
  final Color color;
  final b.BadgePosition? badgePosition;
  final Widget? child;

  const UnreadIcon({
    Key? key,
    this.type,
    this.badge,
    required this.color,
    this.badgePosition,
    this.child,
  }) : super(key: key);

  @override
  UnreadIconState createState() => UnreadIconState();
}

class UnreadIconState extends State<UnreadIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    return StreamBuilder(
      stream: Matrix.of(context)
          .client
          .onSync
          .stream
          .where((syncUpdate) => syncUpdate.hasRoomUpdate),
      builder: (context, _) {
        int unreadCount;
        final ConcielApp appIs = widget.type ?? ConcielApp.talk;
        switch (appIs) {
          case ConcielApp.shop:
            unreadCount = Matrix.of(context)
                .client
                .rooms
                .where((r) => (r.isDirectChat != true))
                .where(
                  (r) => (r.isUnread || r.membership == Membership.invite),
                )
                .length;
            iconColor = personalColorScheme.secondary;
            break;
          case ConcielApp.book:
            unreadCount = Matrix.of(context)
                .client
                .rooms
                .where((r) => (r.isStoryRoom))
                .where(
                  (r) => (r.isUnread || r.membership == Membership.invite),
                )
                .length;
            iconColor = personalColorScheme.tertiary;
            break;
          case ConcielApp.talk:
            unreadCount = Matrix.of(context)
                .client
                .rooms
                .where(
                  (r) => (r.isUnread || r.membership == Membership.invite),
                )
                .length;
            iconColor = personalColorScheme.primary;
            break;
          default:
            unreadCount = Matrix.of(context)
                .client
                .rooms
                .where((r) => (r.isUnread || r.membership == Membership.invite))
                .length;
            iconColor = widget.color;
        }
        return b.Badge(
          badgeStyle: b.BadgeStyle(
            badgeColor: widget.badge ?? true
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            elevation: 4,
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.background,
              width: 2,
            ),
          ),
          badgeContent: Text(
            unreadCount.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 12,
            ),
          ),
          showBadge: unreadCount != 0,
          badgeAnimation: const b.BadgeAnimation.scale(),
          position: widget.badgePosition,
          child: unreadCount != 0
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcATop),
                  child: Opacity(
                    opacity: _animation.value,
                    child: widget.child,
                  ),
                )
              : Builder(
                  builder: (context) {
                    return ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        widget.color,
                        BlendMode.srcATop,
                      ),
                      child: widget.child,
                    );
                  },
                ),
        );
      },
    );
  }
}

/*
class UnreadBadge extends StatelessWidget {
  final String? type;
  final bool? badge;
  final Color? color;
  final b.BadgePosition? badgePosition;
  final Widget? child;

  const UnreadBadge({
    Key? key,
    this.type,
    this.badge,
    this.color,
    this.badgePosition,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Matrix.of(context)
          .client
          .onSync
          .stream
          .where((syncUpdate) => syncUpdate.hasRoomUpdate),
      builder: (context, _) {
        int unreadCount;
        final String appIs = type ?? 'talk';
        switch (appIs) {
          case 'shop':
            unreadCount = Matrix.of(context)
                .client
                .rooms
                .where((r) => (r.isDirectChat != true))
                .where((r) => (r.isUnread || r.membership == Membership.invite))
                .length;
            break;
          case 'book':
            unreadCount = Matrix.of(context)
                .client
                .rooms
                .where((r) => (r.isStoryRoom))
                .where((r) => (r.isUnread || r.membership == Membership.invite))
                .length;
            break;
          case 'talk':
            unreadCount = Matrix.of(context)
                .client
                .rooms
                .where((r) => (r.isUnread || r.membership == Membership.invite))
                .length;
            break;
          default:
            unreadCount = Matrix.of(context)
                .client
                .rooms
                .where((r) => (r.isUnread || r.membership == Membership.invite))
                .length;
        }
        return b.Badge(
          alignment: Alignment.bottomRight,
          badgeContent: Text(
            unreadCount.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 12,
            ),
          ),
          showBadge: unreadCount != 0,
          animationType: b.BadgeAnimationType.scale,
          badgeColor: badge ?? true
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          position: badgePosition,
          elevation: 4,
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.background,
            width: 2,
          ),
          child: unreadCount != 0
              ? TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0.1,
                    end: 1.0,
                  ),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, opacity, child) {
                    return ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          personalColorScheme.primary, BlendMode.srcATop),
                      child: Opacity(
                        opacity: opacity,
                        child: this.child,
                      ),
                    );
                  },
                )
              : Builder(
                  builder: (context) {
                    final childColor = personalColorScheme.surfaceTint;
                    return ColorFiltered(
                      colorFilter:
                          ColorFilter.mode(childColor, BlendMode.srcATop),
                      child: child,
                    );
                  },
                ),
        );
      },
    );
  }
}
*/