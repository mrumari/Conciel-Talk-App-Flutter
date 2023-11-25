import 'dart:math';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:concieltalk/drawers/contacts_drawer.dart';
import 'package:concieltalk/drawers/drawer_components.dart';
import 'package:concieltalk/drawers/standard_drawer.dart';
import 'package:concieltalk/utils/ui/header_footer.dart';
import 'package:concieltalk/drawers/rotating_drawer.dart';
import 'package:concieltalk/utils/ui/text_items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vrouter/vrouter.dart';

class LocalContactsPage extends StatefulWidget {
  const LocalContactsPage({super.key});

  @override
  LocalContactsPageState createState() => LocalContactsPageState();
}

class LocalContactsPageState extends State<LocalContactsPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _listViewKey = GlobalKey();
  late List<GlobalKey> _tileKeys;
  final ScrollController _scrollController = ScrollController();
  final double _itemHeight = 60;

  int _contactIndex = 0;
  List<Contact>? _contacts;
  Future<List<Contact>>? _contactsFuture;
  List<Contact>? _filteredContacts;
  AnimationController? _slidePage;
  Animation<Offset>? _slideAnimation;
  String? _contactID;
  double _top = 0;
  int _centerIndex = 0;

  bool _searchOpen = false;
  bool _permissionDenied = false;
  bool _isInitialized = false;
  bool _peep = true;
  bool _isAnimating = false;
  String _route = 'talk';
  final Map<String, int> _letterToIndexMap = {};
  String _currentLetter = 'A';
  bool _letterScroll = false;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    // Get local contacts list
    _contactsFuture = _fetchContacts();
    // Listen for search events
    _searchController.addListener(_onSearchChanged);
    // Listen for scroll events
    _scrollController.addListener(() {
      setState(() {
        _scrollController.position.isScrollingNotifier.addListener(() {
          if (!_scrollController.position.isScrollingNotifier.value) {
            // when scrolling stops adjust position to align centre tile
            if (!_isAnimating) {
            } else {
              VRouter.of(context).to(
                '/localcontacts',
                queryParameters: {'contact': _contacts![_contactIndex].id},
              );
            }
          } else {}
        });
        // Calculate the index of the ListTile in the center of the screen
        if (_listViewKey.currentContext != null) {
          final listViewBox =
              _listViewKey.currentContext!.findRenderObject() as RenderBox;
          final listViewHeight = listViewBox.size.height;
          final listViewTop = listViewBox.localToGlobal(Offset.zero).dy;
          final centerPosition = listViewTop + listViewHeight / 2 - _top;
          double minDistance = double.infinity;
          for (int i = 0; i < _contacts!.length; i++) {
            if (_tileKeys[i].currentContext != null) {
              final tileBox =
                  _tileKeys[i].currentContext!.findRenderObject() as RenderBox;
              final tileTop = tileBox.localToGlobal(Offset.zero).dy;
              final tileBottom = tileTop + tileBox.size.height;
              final distance = min(
                (tileTop - centerPosition).abs(),
                (tileBottom - centerPosition).abs(),
              );
              if (distance < minDistance) {
                minDistance = distance;
                _centerIndex = i;
                _contactIndex = i;
                if (!_letterScroll) {
                  setState(() {
                    _currentLetter = _filteredContacts![_contactIndex]
                        .displayName
                        .substring(0, 1)
                        .toUpperCase();
                  });
                }
              }
            }
          }
        }
      });
    });
    _slidePage = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.5, 0),
    ).animate(_slidePage!);
  }

  @override
  void dispose() {
    _slidePage!.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredContacts = _contacts!.where((contact) {
        // Filter the contacts based on the search text
        return contact.displayName
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  Future _chatUser(Contact localUser) async {}

  Future<List<Contact>> _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
      return [];
    } else {
      final contacts = await FlutterContacts.getContacts(
        withThumbnail: true,
        withProperties: true,
        withPhoto: true,
      );
      setState(() => _contacts = contacts);
      setState(() => _filteredContacts = _contacts);
      // Initialize the list of tile keys
      if (_contacts != null) {
        _tileKeys =
            List.generate(_filteredContacts!.length, (_) => GlobalKey());
        _contactID = _contacts![0].id;
        VRouter.of(context).to(
          '/localcontacts',
          queryParameters: {'contact': '$_contactID'},
        );
      }
      return contacts;
    }
  }

  void onTileTap(int i) {
    setState(() {
      _peep = _centerIndex != i;
      var index = 0;
      i == 0 ? index = 0 : index = i + 1;
      _contactIndex = index;
      _centerIndex = index;
    });

    double targetOffset = (_centerIndex * _itemHeight) - 60;
    targetOffset = max(0, targetOffset);

    _isAnimating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _isAnimating = false,
      );
    });
  }

  // ignore: unused_element
  _leavePage(BuildContext context) async {
    if (_route == 'talk' || _route == 'wherewhenwhat') {
      await _slidePage!.forward();
      VRouter.of(context).to(
        '/talk',
        queryParameters: {
          'context': _route == 'wherewhenwhat' ? 'true' : 'false',
        },
      );
    } else {
      VRouter.of(context).to('/$_route');
    }
  }

  @override
  Widget build(BuildContext context) {
    _route = VRouter.of(context).queryParameters['route'] ?? _route;
    final double width = 1.sw;
    final double height = 1.sh;
    return VWidgetGuard(
      onSystemPop: (vRedirector) async {
        if (_route == 'talk' || _route == 'wherewhenwhat') {
          await _slidePage!.forward();
          VRouter.of(context).to(
            '/talk',
            queryParameters: {
              'context': _route == 'wherewhenwhat' ? 'true' : 'false',
            },
          );
          vRedirector.stopRedirection();
          return;
        } else {
          VRouter.of(context).to('/$_route');
          vRedirector.stopRedirection();
          return;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: ScreenUtil().statusBarHeight + 32.h,
          foregroundColor: personalColorScheme.outline,
          backgroundColor: Colors.transparent,
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
                  onBackPress: () async {
                    if (_route == 'talk' || _route == 'wherewhenwhat') {
                      await _slidePage!.forward();
                      VRouter.of(context).to(
                        '/talk',
                        queryParameters: {
                          'context':
                              _route == 'wherewhenwhat' ? 'true' : 'false',
                        },
                      );
                    } else {
                      VRouter.of(context).to('/$_route');
                    }
                  },
                  route: '/$_route',
                  showConciel: false,
                  onSearchPress: () {
                    setState(() {
                      _searchOpen = !_searchOpen;
                      if (!_searchOpen) {
                        _searchController.clear();
                        _filteredContacts = _contacts;
                      }
                      _searchFocusNode.requestFocus();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        body: Builder(
          builder: (context) {
            return Stack(
              children: [
                FutureBuilder<List<Contact>>(
                  future: _contactsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData) {
                      _chatUser(snapshot.data![_contactIndex]);
                      if (!_isInitialized) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollController.jumpTo(0);
                          setState(() => _top = 240.h);
                        });
                        _isInitialized = true;
                      }
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ContactPeep(
                            context,
                            contact: _filteredContacts![_contactIndex],
                          ),
                          _body(),
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                if (_contacts == null)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 58,
                    ).r,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: RotatingEndDrawer(
                        drawer: StandardDrawer(
                          showSplines: false,
                          context: context,
                          left: false,
                          borderColor: Colors.deepPurple,
                          splineColor: Colors.transparent,
                          icons: const [
                            ConcielIcons.doc_file,
                            ConcielIcons.share,
                            ConcielIcons.mail,
                            ConcielIcons.chat,
                            ConcielIcons.phone,
                            ConcielIcons.map_marker,
                          ],
                          onTap: const [],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: -50.h,
                  child: LinesSplines(
                    context: context,
                    itemHeight: _itemHeight,
                    height: height,
                    width: width,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButtonAnimator: NoScalingAnimation(),
        floatingActionButtonLocation: FloatingButtonLocation(),
        floatingActionButton: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              height: 48.w,
              width: 48.w,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  VRouter.of(context).to(
                    '/newprivatechat',
                    queryParameters: {'route': '/localcontacts'},
                  );
                },
                icon: Icon(
                  ConcielIcons.users,
                  color: personalColorScheme.outline,
                ),
              ),
            ),
            const Icon(Icons.add),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_permissionDenied) {
      return const Center(child: Text('Permission denied'));
    }
    if (_contacts == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      for (int i = 0; i < _filteredContacts!.length - 1; i++) {
        final contact = _filteredContacts![i];
        final String firstLetter =
            contact.displayName.substring(0, 1).toUpperCase();
        if (firstLetter.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
            firstLetter.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) {
          if (!_letterToIndexMap.containsKey(firstLetter)) {
            _letterToIndexMap[firstLetter] = i;
          }
        }
      }
    }
    final double width = 1.sw;
    final double height = 1.sh;
    final String previousLetter = _currentLetter == 'A'
        ? ''
        : String.fromCharCode(_currentLetter.codeUnitAt(0) - 1);
    final String nextLetter = _currentLetter == 'Z'
        ? ''
        : String.fromCharCode(_currentLetter.codeUnitAt(0) + 1);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: _top,
          child: SizedBox(
            height: height,
            width: width,
            child: ListView.builder(
              key: _listViewKey,
              controller: _scrollController,
              itemCount: _filteredContacts!.length + 5,
              itemBuilder: (context, i) {
                if (i >= _filteredContacts!.length - 6) {
                  return const SizedBox(
                    height: AppConfig.chatItemHeight,
                    child: ListTile(
                      title: Text(''),
                    ),
                  );
                } else {
                  final contact = _filteredContacts![i];
                  return SizedBox(
                    height: 60,
                    key: _tileKeys[i],
                    child: ListTile(
                      leading: contact.photoOrThumbnail != null
                          ? HexAvatarImage(
                              image: MemoryImage(contact.photoOrThumbnail!),
                              size: 48,
                            )
                          : HexAvatarLetters(
                              name: contact.displayName,
                              size: 48,
                            ),
                      title: Text(
                        contact.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () async {
                        setState(() {
                          _contactID = contact.id;
                          _peep = i == _centerIndex;
                        });
                        !_peep
                            ? onTileTap(i)
                            : VRouter.of(context).to(
                                'contact',
                                queryParameters: {
                                  'contact': '$_contactID',
                                  'peep': 'false',
                                },
                              );
                        if (mounted && _peep) {
                          ContactPeep(
                            context,
                            contact: contact,
                          );
                        } else {
                          _peep = !_peep;
                        }
                      },
                      onLongPress: () async {
                        setState(() {
                          _contactID = contact.id;
                        });
                        VRouter.of(context).to(
                          'contact',
                          queryParameters: {
                            'contact': '$_contactID',
                            'peep': 'false',
                          },
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 60,
          ).r,
          child: Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position: _slideAnimation!,
              child: RotatingEndDrawer(
                drawer: ContactsDrawer(
                  context: context,
                  chat: false,
                  contactId: _contacts![_contactIndex].id,
                ),
              ),
            ),
          ),
        ),
        _searchOpen
            ? Align(
                alignment: Alignment.topCenter,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    fillColor:
                        personalColorScheme.surfaceTint.withOpacity(0.75),
                    focusColor: personalColorScheme.surfaceTint,
                  ),
                ),
              )
            : Container(),
        Positioned(
          left: 20,
          top: 120.h,
          child: GestureDetector(
            onVerticalDragUpdate: _dragUpdate,
            onVerticalDragEnd: _dragEnd,
            onVerticalDragCancel: _dragCancel,
            onPanEnd: _dragEnd,
            child: SizedBox(
              height: 216.h,
              width: 240.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _letterScroll
                      ? Container(
                          margin: EdgeInsets.zero,
                          color:
                              personalColorScheme.background.withOpacity(0.75),
                          height: 45.h,
                          width: 80.w,
                          child: Text(
                            previousLetter,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 28,
                            ),
                          ),
                        )
                      : Container(height: 45.h),
                  SizedBox(
                    width: 240.w,
                    child: Text(
                      _currentLetter,
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 60,
                      ),
                    ),
                  ),
                  _letterScroll
                      ? Container(
                          margin: EdgeInsets.zero,
                          color:
                              personalColorScheme.background.withOpacity(0.75),
                          height: 45.h,
                          width: 80.w,
                          child: Text(
                            nextLetter,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 28,
                            ),
                          ),
                        )
                      : Container(height: 45.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _dragEnd(DragEndDetails details) {
    setState(() {
      _letterScroll = false;
    });
  }

  void _dragCancel() {
    setState(() {
      _letterScroll = false;
    });
  }

  void _dragUpdate(DragUpdateDetails details) {
    setState(() {
      _letterScroll = true;
      _dragDistance += details.delta.dy;
      if (_dragDistance.abs() >= 15) {
        // threshold reached
        if (_dragDistance < 0) {
          // drag up
          _currentLetter = String.fromCharCode(
            min(_currentLetter.codeUnitAt(0) + 1, 'Z'.codeUnitAt(0)),
          );
        } else if (_dragDistance > 0) {
          // drag down
          _currentLetter = String.fromCharCode(
            max(_currentLetter.codeUnitAt(0) - 1, 'A'.codeUnitAt(0)),
          );
        }

        final int? letterIndex = _letterToIndexMap[_currentLetter];
        if (letterIndex != null) {
          _scrollController.jumpTo(letterIndex * _itemHeight - 30);
        }
        _dragDistance = 0;
      }
    });
  }
}

class ContactDetailsPage extends StatelessWidget {
  final Contact? contact;
  final bool? inpeep;
  const ContactDetailsPage({
    super.key,
    this.inpeep,
    this.contact,
  });
  @override
  Widget build(BuildContext context) {
    final String? contactId = VRouter.of(context).queryParameters['contact'];
    // final int events = Random().nextInt(10);
    return FutureBuilder<Contact?>(
      future: FlutterContacts.getContact(
        contactId!,
        withGroups: true,
        withAccounts: true,
        withPhoto: true,
        withProperties: true,
        withThumbnail: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final contact = snapshot.data;
          final height = 1.sh;
          final width = 1.sw;
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
//              toolbarOpacity: 0.0,
              backgroundColor: Colors.transparent,
              titleSpacing: 0,
              automaticallyImplyLeading: false,
              actions: <Widget>[Container()],
              toolbarHeight: ScreenUtil().statusBarHeight + 32.h,
              clipBehavior: Clip.none,
              title: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Builder(
                    builder: (context) => DefaultHeaderWidget(
                      route: '/localcontacts',
                      showConciel: false,
                      showSearch: false,
                      onSearchPress: () {},
                    ),
                  ),
                ],
              ),
            ),
            body: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 60,
                  ).r,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: RotatingEndDrawer(
                      drawer: StandardDrawer(
                        showSplines: false,
                        context: context,
                        left: false,
                        borderColor: Colors.deepPurple,
                        splineColor: Colors.transparent,
                        icons: const [
                          ConcielIcons.doc_file,
                          ConcielIcons.share,
                          ConcielIcons.mail,
                          ConcielIcons.chat,
                          ConcielIcons.phone,
                          ConcielIcons.map_marker,
                        ],
                        onTap: const [],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -52,
                  child: LinesSplines(
                    context: context,
                    itemHeight: 60,
                    height: height,
                    width: width,
                    color: Colors.deepPurple,
                  ),
                ),
                ContactPeep(context, contact: contact!),
                Positioned(
                  left: 20,
                  top: 1767.h,
                  child: Text(
                    contact.displayName.substring(0, 1).toUpperCase(),
                    style:
                        const TextStyle(color: Colors.deepPurple, fontSize: 60),
                  ),
                ),
                Positioned(
                  top: 234.h,
                  left: 20,
                  child: SizedBox(
                    height: 287.55.h,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                contact.phones.isNotEmpty
                                    ? '${describeEnum(contact.phones.first.label).toUpperCase()} '
                                    : 'PHONES ',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: personalColorScheme.onSurface,
                                ),
                              ),
                              Text(
                                contact.phones.isNotEmpty
                                    ? contact.phones.first.number
                                    : ' (none)',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: personalColorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'EMAIL',
                            textAlign: TextAlign.left,
                            style:
                                TextStyle(color: personalColorScheme.onSurface),
                          ),
                          Text(
                            contact.emails.isNotEmpty ? 'PRIVATE EMAIL' : ' ',
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'ADDRESS',
                            textAlign: TextAlign.left,
                            style:
                                TextStyle(color: personalColorScheme.onSurface),
                          ),
                          Text(
                            contact.addresses.isNotEmpty
                                ? contact.addresses.first.address
                                    .split(',')
                                    .map((part) => part.trim())
                                    .join('\n')
                                : ' ',
                            maxLines: 3,
                            textAlign: TextAlign.left,
                            style:
                                TextStyle(color: personalColorScheme.outline),
                          ),
                          /*
                          const SizedBox(height: 5),
                          Text(
                            'CALENDAR',
                            style:
                                TextStyle(color: personalColorScheme.primary),
                          ),
                          const SizedBox(height: 5),
                          RandomDateTimeList(events: events),
                          */
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 272.w,
                  bottom: 0,
                  child: IconButton(
                    onPressed: () {
                      VRouter.of(context).to('/talk/fileshare');
                    },
                    icon: Icon(
                      ConcielIcons.share,
                      color: personalColorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class ContactPeep extends StatelessWidget {
  final BuildContext context;
  final Contact contact;

  const ContactPeep(this.context, {super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -10.h,
      height: 278.h,
      width: 1.sw,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              icon: (contact.photoOrThumbnail != null)
                  ? HexAvatarImage(
                      image: MemoryImage(contact.photoOrThumbnail!),
                      size: 72,
                    )
                  : const HexAvatarImage(
                      image: concielAvatarThumb,
                      size: 72,
                    ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  top: 10.0,
                ).r,
                child: Text(
                  contact.displayName.toUpperCase(),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: personalColorScheme.outline,
                    overflow: TextOverflow.fade,
                    fontFamily: 'Exo',
                    fontSize: 20,
                    letterSpacing: 2,
                    fontWeight: FontWeight.normal,
                    height: 1.0909090909090908,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                IconButtonWithText(
                  icon: Icons.fiber_manual_record,
                  size: 12,
                  text: 'INVITE',
                  color: personalColorScheme.primary,
                ),
                IconButtonWithText(
                  icon: Icons.fiber_manual_record,
                  size: 12,
                  text: 'PRIORITY',
                  color: contact.isStarred
                      ? personalColorScheme.tertiary
                      : personalColorScheme.surfaceTint,
                ),
                IconButtonWithText(
                  icon: Icons.fiber_manual_record,
                  size: 12,
                  text: 'SECURITY',
                  color: personalColorScheme.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
