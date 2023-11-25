import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/drawers/rotating_drawer.dart';
import 'package:concieltalk/drawers/search_drawer.dart';
import 'package:concieltalk/pages/conciel_primary/what_home.dart';
import 'package:concieltalk/pages/conciel_primary/when_home.dart';
import 'package:concieltalk/pages/conciel_primary/where_home.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/client_stories_extension.dart';
import 'package:concieltalk/utils/ui/header_footer.dart';
import 'package:concieltalk/utils/ui/page_template.dart';
import 'package:concieltalk/widgets/base_ring_state.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:vrouter/vrouter.dart';

class WhereWhenWhat extends StatefulWidget {
  const WhereWhenWhat({Key? key}) : super(key: key);

  @override
  RingController createState() => RingController();
}

class RingController extends State<WhereWhenWhat>
    with TickerProviderStateMixin {
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final wwwRoute = VRouter.of(context).queryParameters['route'];
    final thisRoute = VRouter.of(context).path;
    final splitRoute = thisRoute.split('/');
    String resultRoute;
    if (splitRoute.length > 1) {
      resultRoute = splitRoute[1];
    } else {
      resultRoute = thisRoute.substring(1);
    }

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          HomePageDevice(
            route: '/$resultRoute',
            appBar: (context) => DefaultHeaderWidget(
              route: '/$resultRoute',
              onBackPress: () {
                switch (wwwRoute) {
                  case 'where':
                    setState(() {
                      if (whereIndex == 99) {
                        VRouter.of(context).to('/$resultRoute');
                      } else {
                        wwwState.value['where']!
                            ? reset(whereProgress, 0)
                            : whereIndex = 99;
                        whenText = 'WHERE';
                      }
                    });
                  case 'when':
                    setState(() {
                      if (whenIndex == 99) {
                        VRouter.of(context).to('/$resultRoute');
                      } else {
                        wwwState.value['when']!
                            ? reset(whenProgress, 0)
                            : whenIndex = 99;
                        whenText = 'WHEN';
                      }
                    });
                  case 'what':
                    setState(() {
                      if (whatIndex == 99) {
                        VRouter.of(context).to('/$resultRoute');
                      } else {
                        wwwState.value['what']!
                            ? reset(whatProgress, 0)
                            : whatIndex = 99;
                        whatText = 'WHAT';
                      }
                    });

                  default:
                    break;
                }
              },
              onSearchPress: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
            ringKey: ringWidgetKey,
            drawer: Container(),
            endDrawer: RotatingEndDrawer(
              drawer: SearchDrawer(
                context: context,
                route: 'wherewhenwhat',
              ),
            ),
            children: [
              Transform.scale(
                scale: AppConfig.cubeRingScale,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    switch (wwwRoute) {
                      'where' => WhereView(this),
                      'when' => WhenView(this),
                      'what' => WhatView(this),
                      _ => WhatView(this),
                    },
                  ],
                ),
              ),
            ],
          ),
          PrimaryBottomBar(
            concielApp: switch (resultRoute) {
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
                  switch (resultRoute) {
                    case 'talk' || 'book':
                      VRouter.of(context).to('/shop');
                    case 'shop':
                      VRouter.of(context).to('/talk');
                  }
                  break;
                case 2:
                  // Message notifier pressed
                  final unreadCount = Matrix.of(context)
                      .client
                      .rooms
                      .where((r) => (r.isStoryRoom))
                      .where(
                        (r) =>
                            (r.isUnread || r.membership == Membership.invite),
                      )
                      .length;
                  unreadCount != 0 ? VRouter.of(context).to('/rooms') : null;
                  break;
                case 3:
                  switch (resultRoute) {
                    case 'talk' || 'shop':
                      VRouter.of(context).to('/book');
                    case 'book':
                      VRouter.of(context).to('/talk');
                  }
                  break;
                case 4:
                  // Contacts pressed
                  VRouter.of(context).to(
                    '/localcontacts',
                    queryParameters: {'route': 'wherewhenwhat'},
                  );
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}
