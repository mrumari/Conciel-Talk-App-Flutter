import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/drawers/rotating_drawer.dart';
import 'package:concieltalk/drawers/search_drawer.dart';
import 'package:concieltalk/utils/ui/central_buttons.dart';
import 'package:concieltalk/utils/ui/header_footer.dart';
import 'package:concieltalk/utils/ui/page_template.dart';
import 'package:concieltalk/utils/ui/ring_widgets.dart';
import 'package:concieltalk/widgets/base_ring_state.dart';
import 'package:concieltalk/widgets/debouncer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vrouter/vrouter.dart';

class CubeSelect extends StatefulWidget {
  const CubeSelect({Key? key}) : super(key: key);

  @override
  RingController createState() => RingController();
}

class RingController extends State<CubeSelect> with TickerProviderStateMixin {
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double width = 1.sw;
    final double height = 1.sh;
    final talkshopbook = VRouter.of(context).queryParameters['bookshop'];

    return Scaffold(
      body: SizedBox(
        width: width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            HomePageDevice(
              route: '/$talkshopbook',
              appBar: (context) => DefaultHeaderWidget(
                route: '/$talkshopbook',
                onSearchPress: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
              ringKey: ringWidgetKey,
              drawer: Container(),
              endDrawer: RotatingEndDrawer(
                drawer: SearchDrawer(
                  context: context,
                  route: 'cubeview',
                ),
              ),
              children: [
                Transform.scale(
                  scale: AppConfig.cubeRingScale,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: const Stack(
                      alignment: AlignmentDirectional.center,
                      children: <Widget>[
                        CubeSelectView(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            PrimaryBottomBar(
              concielApp: switch (talkshopbook) {
                'talk' => ConcielApp.talk,
                'shop' => ConcielApp.shop,
                'book' => ConcielApp.book,
                _ => ConcielApp.talk,
              },
              onTap: (value) {
                switch (value) {
                  case 0:
                    // Share pressed
                    VRouter.of(context).to('fileshare');
                    break;
                  case 1:
                    // Book notifier pressed
                    break;
                  case 2:
                    // Message notifier pressed

                    break;
                  case 3:
                    // Talk notifier pressed
                    break;
                  case 4:
                    // Contacts pressed
                    VRouter.of(context).to(
                      '/localcontacts',
                      queryParameters: {'route': 'cubeview'},
                    );
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CubeSelectView extends StatefulWidget {
  const CubeSelectView({Key? key}) : super(key: key);

  @override
  CubeSelectViewState createState() => CubeSelectViewState();
}

class CubeSelectViewState extends State<CubeSelectView>
    with TickerProviderStateMixin {
  bool animateNow = false;
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double width = 1.sw;
    final double height = 1.sh;
    int book = 0;
    switch (context.vRouter.queryParameters['bookshop']) {
      case 'talk':
        book = 0;
        break;
      case 'book':
        book = 1;
        break;
      case 'shop':
        book = 2;
        break;
      default:
        break;
    }
    final items = book == 0
        ? AppConfig.emailSelect.length
        : book == 1
            ? AppConfig.bookSelect.length
            : AppConfig.shopSelect.length;
    final color = book == 0
        ? personalColorScheme.primary
        : book == 1
            ? personalColorScheme.tertiary
            : personalColorScheme.secondary;
    final List<double> progressList = [];
    for (var i = 0; i < (items); i++) {
      progressList.add(0.0);
    }
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          IgnorePointer(
            ignoring: true,
            child: Opacity(
              opacity: 1.0,
              child: wwwRings(
                1,
                context,
                color,
                personalColorScheme.surfaceTint,
                progressList,
                99,
                360 / items,
              ),
            ),
          ),
          for (var index = 0; index < items; index++)
            ArcButton(
              startAngle: 0 + index * 360 / items,
              sweepAngle: 360 / items,
              radius: 105.w,
              strokeWidth: 35.r,
              onTap: () {
                debounce(Conciel.debouncer, () {
                  setState(() {});
                });
              },
              child: IgnorePointer(
                ignoring: true,
                child: Opacity(
                  opacity: 1.0,
                  child: ConcielArcText(
                    color: personalColorScheme.outline,
                    fontSize: 14,
                    radius: 105.w,
                    sweep: 360 / items,
                    start: 180 + (360 / items / 2) + index * 360 / items,
                    text: book == 0
                        ? AppConfig.emailSelect[index]
                        : book == 1
                            ? AppConfig.bookSelect[index]
                            : AppConfig.shopSelect[index],
                  ),
                ),
              ),
            ),
          Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                width: 96.r,
                decoration: ShapeDecoration(
                  shape: StarBorder.polygon(
                    side: BorderSide(
                      color: color,
                    ),
                    sides: 6,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {});
                    VRouter.of(context).to(
                      '/talk',
                    );
                  },
                  child: Text(
                    book == 0
                        ? 'MAIL'
                        : book == 1
                            ? 'FOOD'
                            : 'ONLINE',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 16,
                      letterSpacing: 2,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
