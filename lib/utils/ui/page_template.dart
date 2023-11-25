import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/widgets/base_ring_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

class HomePageDevice extends StatefulWidget {
  final GlobalKey<BaseRingState> ringKey;
  final String route;
  final WidgetBuilder appBar;
  final Widget drawer;
  final Widget endDrawer;
  final List<Widget> children;
  const HomePageDevice({
    Key? key,
    required this.ringKey,
    required this.route,
    required this.appBar,
    required this.drawer,
    required this.endDrawer,
    required this.children,
  }) : super(key: key);

  @override
  State<HomePageDevice> createState() => _HomePageDeviceState();
}

class _HomePageDeviceState extends State<HomePageDevice>
    with TickerProviderStateMixin {
  AnimationController? _movePage;
  AnimationController? _moveEndPage;

  late UserProfile userProfile;

  @override
  void initState() {
    super.initState();
    _movePage = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _moveEndPage = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      widget.ringKey.currentState?.animateColors();
    });
  }

  @override
  void dispose() {
    // Dispose of the AnimationController to properly dispose of the Ticker
    super.dispose();
  }

  void movePage() {}

  @override
  Widget build(BuildContext context) {
    final drawerWidth = 1.sw;
    final drawerAnimation =
        Tween(begin: 0.0, end: drawerWidth / 2).animate(_movePage!);
    final endDrawerAnimation =
        Tween(begin: 0.0, end: -drawerWidth).animate(_moveEndPage!);
    return VWidgetGuard(
      onSystemPop: (vRedirector) async {
        if (widget.route == '/biometrics') {
          vRedirector.stopRedirection();
        } else {
          vRedirector.pop();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        drawerScrimColor: Colors.transparent,
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
              Builder(builder: widget.appBar),
            ],
          ),
        ),
        drawer: widget.drawer,
        drawerEnableOpenDragGesture: false,
        drawerDragStartBehavior: DragStartBehavior.down,
        onDrawerChanged: (isOpened) {
          if (isOpened) {
            widget.ringKey.currentState?.animateColors();
            _movePage!.forward();
          } else {
            widget.ringKey.currentState?.animateColors();
            _movePage!.reverse();
          }
        },
        endDrawer: widget.endDrawer,
        endDrawerEnableOpenDragGesture: false,
        onEndDrawerChanged: (isOpened) {
          if (isOpened) {
            widget.ringKey.currentState?.animateColors();
            _moveEndPage!.forward();
          } else {
            widget.ringKey.currentState?.animateColors();
            _moveEndPage!.reverse();
          }
        },
        body: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: drawerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(drawerAnimation.value, 0),
                  child: AnimatedBuilder(
                    animation: endDrawerAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(endDrawerAnimation.value, 0),
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: Conciel.bottomBarHeight,
                          ),
                          child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              ...widget.children,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AppBarDevice extends StatelessWidget implements PreferredSizeWidget {
  final WidgetBuilder builder;

  const AppBarDevice({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      actions: <Widget>[Container()],
      toolbarHeight: ScreenUtil().statusBarHeight + 32.h,
      clipBehavior: Clip.none,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Builder(builder: builder),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(ScreenUtil().statusBarHeight);
}
