import 'dart:async';

import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:concieltalk/drawers/drawer_components.dart';
import 'package:concieltalk/drawers/rotating_drawer.dart';
import 'package:concieltalk/drawers/standard_drawer.dart';
import 'package:concieltalk/pages/chat/chat_send_actions.dart';
import 'package:concieltalk/pages/chat_list/chat_list_body.dart';
import 'package:concieltalk/pages/chat_list/chat_peek_view.dart';
import 'package:concieltalk/utils/id_share.dart';
import 'package:concieltalk/utils/ui/header_footer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import 'package:new_keyboard_shortcuts/keyboard_shortcuts.dart';
import 'package:vrouter/vrouter.dart';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/themes.dart';
import 'package:concieltalk/pages/chat_list/chat_list_view.dart';
import 'package:concieltalk/pages/settings/settings_security/settings_security.dart';
import 'package:concieltalk/utils/local_storage.dart';
import 'package:concieltalk/utils/localized_exception_extension.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/client_stories_extension.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:concieltalk/utils/account_bundles.dart';
import 'package:concieltalk/utils/voip/callkeep_manager.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'package:concieltalk/pages/bootstrap/bootstrap_dialog.dart';

import 'package:concieltalk/utils/tor_stub.dart'
    if (dart.library.html) 'package:tor_detector_web/tor_detector_web.dart';

enum SelectMode {
  normal,
  share,
  select,
}

enum PopupMenuAction {
  settings,
  invite,
  newGroup,
  newSpace,
  setStatus,
  archive,
}

enum ActiveFilter {
  allChats,
  groups,
  messages,
  spaces,
}

class ChatList extends StatefulWidget {
  static BuildContext? contextForVoip;

  const ChatList({Key? key}) : super(key: key);

  @override
  ChatListController createState() => ChatListController();
}

class ChatListController extends State<ChatList>
    with TickerProviderStateMixin, RouteAware {
  StreamSubscription? _intentDataStreamSubscription;

  StreamSubscription? _intentFileStreamSubscription;

  StreamSubscription? _intentUriStreamSubscription;

  bool get displayNavigationBar =>
      !ConcielThemes.isColumnMode(context) &&
      (spaces.isNotEmpty || AppConfig.separateChatTypes);

  String? activeSpaceId;

  bool? endDrawerOpen = false;
  bool navigation = false;

  void resetActiveSpaceId() {
    setState(() {
      activeSpaceId = null;
    });
  }

  void setActiveSpace(String? spaceId) {
    setState(() {
      activeSpaceId = spaceId;
      activeFilter = ActiveFilter.spaces;
    });
  }

  int get selectedIndex {
    switch (activeFilter) {
      case ActiveFilter.allChats:
        return 0;
      case ActiveFilter.messages:
        return 1;
      case ActiveFilter.groups:
        return AppConfig.separateChatTypes ? 2 : 1;
      case ActiveFilter.spaces:
        return AppConfig.separateChatTypes ? 3 : 2;
    }
  }

  ActiveFilter getActiveFilterByDestination(int? i) {
    navigation = true;
    switch (i) {
      case 0:
        scaffoldKey.currentState!.openEndDrawer();
        // VRouter.of(context).to('fileshare');
        return ActiveFilter.allChats;
      case 1:
        if (AppConfig.separateChatTypes) {
          return ActiveFilter.messages;
        } else {
          return ActiveFilter.allChats;
        }
      case 2:
        if (AppConfig.separateChatTypes) {
          return ActiveFilter.groups;
        } else {
          if (spaces.isNotEmpty) {
            return ActiveFilter.spaces;
          } else {
            setState(() {});
            VRouter.of(context)
                .to('/localcontacts', queryParameters: {'route': 'rooms'});
            return ActiveFilter.allChats;
          }
        }
      case 3:
        if (AppConfig.separateChatTypes) {
          if (spaces.isNotEmpty) {
            return ActiveFilter.spaces;
          } else {
            VRouter.of(context)
                .to('/localcontacts', queryParameters: {'route': 'rooms'});
            return ActiveFilter.allChats;
          }
        } else {
          VRouter.of(context)
              .to('/localcontacts', queryParameters: {'route': 'rooms'});
          return ActiveFilter.allChats;
        }
      case 4:
        VRouter.of(context)
            .to('/localcontacts', queryParameters: {'route': 'rooms'});
        return ActiveFilter.allChats;
      default:
        return ActiveFilter.allChats;
    }
  }

  void onDestinationSelected(int? i) async {
    final ActiveFilter filter = getActiveFilterByDestination(i);
    setState(() {
      activeFilter = filter;
    });
  }

  ActiveFilter activeFilter = AppConfig.separateChatTypes
      ? ActiveFilter.messages
      : ActiveFilter.allChats;

  bool Function(Room) getRoomFilterByActiveFilter(ActiveFilter activeFilter) {
    switch (activeFilter) {
      case ActiveFilter.allChats:
        return (room) => !room.isSpace && !room.isStoryRoom;
      case ActiveFilter.groups:
        return (room) =>
            !room.isSpace && !room.isDirectChat && !room.isStoryRoom;
      case ActiveFilter.messages:
        return (room) =>
            !room.isSpace && room.isDirectChat && !room.isStoryRoom;
      case ActiveFilter.spaces:
        return (r) => r.isSpace;
    }
  }

  List<Room> get filteredRooms {
    final List<Room> rooms = Matrix.of(context)
        .client
        .rooms
        .where(
          (room) => getRoomFilterByActiveFilter(activeFilter)(room),
        )
        .toList();

    _sortRooms(rooms);

    return rooms;
  }

  bool _sortLock = false;

  void _sortRooms(List<Room> rooms) {
    if (_sortLock || rooms.length < 2) return;
    _sortLock = true;
    rooms.sort(sortRoomsBy);
    _sortLock = false;
  }

  RoomSorter get sortRoomsBy => (a, b) {
        if (a.isFavourite != b.isFavourite) {
          return a.isFavourite ? -1 : 1;
        } else if (a.notificationCount != b.notificationCount) {
          return b.notificationCount.compareTo(a.notificationCount);
        } else if (a.lastEvent != null && b.lastEvent != null) {
          return b.lastEvent!.originServerTs
              .compareTo(a.lastEvent!.originServerTs);
        } else if (a.lastEvent != null && b.lastEvent == null) {
          return -1;
        } else if (a.lastEvent == null && b.lastEvent != null) {
          return 1;
        } else {
          return a.name.compareTo(b.name);
        }
      };

  List<Room> get pfilteredRooms => Matrix.of(context)
      .client
      .rooms
      .where(
        (room) =>
            !room.isFavourite &&
            getRoomFilterByActiveFilter(activeFilter)(room),
      )
      .toList();

  List<Room> get priorityRooms => Matrix.of(context)
      .client
      .rooms
      .where((room) => room.isFavourite)
      .toList();

  bool isSearchMode = false;
  Future<QueryPublicRoomsResponse>? publicRoomsResponse;
  String? searchServer;
  Timer? _coolDown;
  SearchUserDirectoryResponse? userSearchResult;
  QueryPublicRoomsResponse? roomSearchResult;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool isSearching = false;
  static const String _serverStoreNamespace = 'im.concieltalk.search.server';

  void setServer() async {
    final newServer = await showTextInputDialog(
      useRootNavigator: false,
      title: L10n.of(context)!.changeTheHomeserver,
      context: context,
      okLabel: L10n.of(context)!.ok,
      cancelLabel: L10n.of(context)!.cancel,
      textFields: [
        DialogTextField(
          prefixText: 'https://',
          hintText: Matrix.of(context).client.homeserver?.host,
          initialText: searchServer,
          keyboardType: TextInputType.url,
          autocorrect: false,
        ),
      ],
    );
    if (newServer == null) return;
    Store().setItem(_serverStoreNamespace, newServer.single);
    setState(() {
      searchServer = newServer.single;
    });
    onSearchEnter(searchController.text);
  }

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  late ValueNotifier searchNotifier = ValueNotifier<bool>(false);

  void _search() async {
    final client = Matrix.of(context).client;
    if (!isSearching) {
      setState(() {
        isSearching = true;
      });
    }
    SearchUserDirectoryResponse? userSearchResult;
    QueryPublicRoomsResponse? roomSearchResult;
    try {
      roomSearchResult = await client.queryPublicRooms(
        server: searchServer,
        filter: PublicRoomQueryFilter(genericSearchTerm: searchController.text),
        limit: 20,
      );
      userSearchResult = await client.searchUserDirectory(
        searchController.text,
        limit: 20,
      );
    } catch (e, s) {
      Logs().w('Searching has crashed', e, s);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toLocalizedString(context),
          ),
        ),
      );
    }
    if (!isSearchMode) return;
    setState(() {
      isSearching = false;
      this.roomSearchResult = roomSearchResult;
      this.userSearchResult = userSearchResult;
    });
  }

  void onSearchEnter(String text) {
    if (text.isEmpty) {
      cancelSearch(unfocus: false);
      return;
    }

    setState(() {
      isSearchMode = true;
    });
    _coolDown?.cancel();
    _coolDown = Timer(const Duration(milliseconds: 500), _search);
  }

  void cancelSearch({bool unfocus = true}) {
    setState(() {
      searchController.clear();
      searchNotifier.value = false;
      isSearchMode = false;
      roomSearchResult = userSearchResult = null;
      isSearching = false;
    });
    if (unfocus) FocusManager.instance.primaryFocus?.unfocus();
  }

  bool isTorBrowser = false;

  BoxConstraints? snappingSheetContainerSize;

  final ScrollController scrollController = ScrollController();
  final ScrollController priorityScrollController = ScrollController();
  final ValueNotifier<bool> scrolledToTop = ValueNotifier(true);
  int splineIndex = 0;

  final StreamController<Client> _clientStream = StreamController.broadcast();
  AnimationController? slidePage;
  Animation<Offset>? slideAnimation;

  Stream<Client> get clientStream => _clientStream.stream;

  void addAccountAction() => VRouter.of(context).to('/settings/account');

  void _onScroll() {
    final newScrolledToTop = scrollController.position.pixels <= 0;
    if (newScrolledToTop != scrolledToTop.value) {
      scrolledToTop.value = newScrolledToTop;
    }
    scrollController.position.isScrollingNotifier.addListener(() {
      if (!scrollController.position.isScrollingNotifier.value) {
        setState(() {
          splineIndex =
              ((scrollController.offset / AppConfig.chatItemHeight).round());
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollController.animateTo(
              splineIndex * AppConfig.chatItemHeight,
              duration: const Duration(milliseconds: 50),
              curve: Curves.ease,
            );
          });
        });
      }
    });
  }

  void editSpace(BuildContext context, String spaceId) async {
    await Matrix.of(context).client.getRoomById(spaceId)!.postLoad();
    if (mounted) {
      VRouter.of(context).toSegments(['spaces', spaceId]);
    }
  }

  // Needs to match GroupsSpacesEntry for 'separate group' checking.
  List<Room> get spaces =>
      Matrix.of(context).client.rooms.where((r) => r.isSpace).toList();

  final selectedRoomIds = <String>{};

  String? get activeChat => VRouter.of(context).pathParameters['roomid'];

  SelectMode get selectMode => Matrix.of(context).shareContent != null
      ? SelectMode.share
      : selectedRoomIds.isEmpty
          ? SelectMode.normal
          : SelectMode.select;

  /*
  void _processIncomingSharedFiles(List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    final file = File(files.first.path.replaceFirst('file://', ''));

    Matrix.of(context).shareContent = {
      'msgtype': 'conciel.talk.shared_file',
      'file': MatrixFile(
        bytes: file.readAsBytesSync(),
        name: file.path,
      ).detectFileType,
    };
    VRouter.of(context).to('/rooms');
  }

  void _processIncomingSharedFiles(List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    //final file = File(files.first.path.replaceFirst('file://', ''));

    final List<String?> filePaths = files.map((file) => file.path).toList();
    VRouter.of(context).to(
      'fileshare',
      queryParameters: {'files': filePaths.join(',')},
    );
    return;
  }

  void _processIncomingSharedText(String? text) {
    if (text == null) return;
    if (text.toLowerCase().startsWith(AppConfig.deepLinkPrefix) ||
        text.toLowerCase().startsWith(AppConfig.inviteLinkPrefix) ||
        (text.toLowerCase().startsWith(AppConfig.schemePrefix) &&
            !RegExp(r'\s').hasMatch(text))) {
      return _processIncomingUris(text);
    }
    Matrix.of(context).shareContent = {
      'msgtype': 'm.text',
      'body': text,
    };
    VRouter.of(context).to('/rooms');
  }

  void _processIncomingUris(String? text) async {
    if (text == null) return;
    VRouter.of(context).to('/rooms');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UrlLauncher(context, text).openMatrixToUrl();
    });
  }
  
  void _initReceiveSharingIntent() {
    if (!PlatformInfos.isMobile) return;

    // For sharing images coming from outside the app while the app is in the memory
    _intentFileStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen(_processIncomingSharedFiles, onError: print);

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then(_processIncomingSharedFiles);

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream()
        .listen(_processIncomingSharedText, onError: print);

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then(_processIncomingSharedText);

    // For receiving shared Uris
    _intentUriStreamSubscription = linkStream.listen(_processIncomingUris);
    if (ConcielTalkApp.gotInitialLink == false) {
      ConcielTalkApp.gotInitialLink = true;
      getInitialLink().then(_processIncomingUris);
    }
  }
  */

  @override
  void initState() {
//    _initReceiveSharingIntent();

    _waitForFirstSync();
    _hackyWebRTCFixForWeb();
    CallKeepManager().initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      scrollController.addListener(_onScroll);
      priorityScrollController.addListener(_onScroll);
      if (mounted) {
        searchServer = await Store().getItem(_serverStoreNamespace);
//        if (!pusherLogDone) Matrix.of(context).backgroundPush?.setupPush();
      }
    });

    _checkTorBrowser();

    super.initState();
    slidePage = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.5, 0),
    ).animate(slidePage!);
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    _intentFileStreamSubscription?.cancel();
    _intentUriStreamSubscription?.cancel();
    scrollController.removeListener(_onScroll);
    priorityScrollController.removeListener(_onScroll);
    slidePage!.dispose();
    super.dispose();
  }

  void toggleSelection(String roomId) {
    setState(
      () => selectedRoomIds.contains(roomId)
          ? selectedRoomIds.remove(roomId)
          : selectedRoomIds.add(roomId),
    );
  }

  Future<void> toggleUnread() async {
    await showFutureLoadingDialog(
      context: context,
      future: () async {
        final markUnread = anySelectedRoomNotMarkedUnread;
        final client = Matrix.of(context).client;
        for (final roomId in selectedRoomIds) {
          final room = client.getRoomById(roomId)!;
          if (room.markedUnread == markUnread) continue;
          await client.getRoomById(roomId)!.markUnread(markUnread);
        }
      },
    );
    cancelAction();
  }

  Future<void> toggleFavouriteRoom() async {
    await showFutureLoadingDialog(
      context: context,
      future: () async {
        final makeFavorite = anySelectedRoomNotFavorite;
        final client = Matrix.of(context).client;
        for (final roomId in selectedRoomIds) {
          final room = client.getRoomById(roomId)!;
          if (room.isFavourite == makeFavorite) continue;
          await client.getRoomById(roomId)!.setFavourite(makeFavorite);
        }
      },
    );
    cancelAction();
  }

  Future<void> toggleMuted() async {
    await showFutureLoadingDialog(
      context: context,
      future: () async {
        final newState = anySelectedRoomNotMuted
            ? PushRuleState.mentionsOnly
            : PushRuleState.notify;
        final client = Matrix.of(context).client;
        for (final roomId in selectedRoomIds) {
          final room = client.getRoomById(roomId)!;
          if (room.pushRuleState == newState) continue;
          await client.getRoomById(roomId)!.setPushRuleState(newState);
        }
      },
    );
    cancelAction();
  }

  Future<void> archiveAction() async {
    final confirmed = await showOkCancelAlertDialog(
          useRootNavigator: false,
          context: context,
          title: L10n.of(context)!.areYouSure,
          okLabel: L10n.of(context)!.yes,
          cancelLabel: L10n.of(context)!.cancel,
        ) ==
        OkCancelResult.ok;
    if (!confirmed) return;
    await showFutureLoadingDialog(
      context: context,
      future: () => _archiveSelectedRooms(),
    );
    setState(() {});
  }

  void setStatus() async {
    final input = await showTextInputDialog(
      useRootNavigator: false,
      context: context,
      title: L10n.of(context)!.setStatus,
      okLabel: L10n.of(context)!.ok,
      cancelLabel: L10n.of(context)!.cancel,
      textFields: [
        DialogTextField(
          hintText: L10n.of(context)!.statusExampleMessage,
        ),
      ],
    );
    if (input == null) return;
    await showFutureLoadingDialog(
      context: context,
      future: () => Matrix.of(context).client.setPresence(
            Matrix.of(context).client.userID!,
            PresenceType.online,
            statusMsg: input.single,
          ),
    );
  }

  Future<void> _archiveSelectedRooms() async {
    final client = Matrix.of(context).client;
    while (selectedRoomIds.isNotEmpty) {
      final roomId = selectedRoomIds.first;
      try {
        await client.getRoomById(roomId)!.leave();
      } finally {
        toggleSelection(roomId);
      }
    }
  }

  Future<void> addToSpace() async {
    final selectedSpace = await showConfirmationDialog<String>(
      context: context,
      title: L10n.of(context)!.addToSpace,
      message: L10n.of(context)!.addToSpaceDescription,
      fullyCapitalizedForMaterial: false,
      actions: Matrix.of(context)
          .client
          .rooms
          .where((r) => r.isSpace)
          .map(
            (space) => AlertDialogAction(
              key: space.id,
              label: space
                  .getLocalizedDisplayname(MatrixLocals(L10n.of(context)!)),
            ),
          )
          .toList(),
    );
    if (selectedSpace == null) return;
    final result = await showFutureLoadingDialog(
      context: context,
      future: () async {
        final space = Matrix.of(context).client.getRoomById(selectedSpace)!;
        if (space.canSendDefaultStates) {
          for (final roomId in selectedRoomIds) {
            await space.setSpaceChild(roomId);
          }
        }
      },
    );
    if (result.error == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.chatHasBeenAddedToThisSpace),
        ),
      );
    }

    setState(() => selectedRoomIds.clear());
  }

  bool get anySelectedRoomNotMarkedUnread => selectedRoomIds.any(
        (roomId) =>
            !Matrix.of(context).client.getRoomById(roomId)!.markedUnread,
      );

  bool get anySelectedRoomNotFavorite => selectedRoomIds.any(
        (roomId) => !Matrix.of(context).client.getRoomById(roomId)!.isFavourite,
      );

  bool get anySelectedRoomNotMuted => selectedRoomIds.any(
        (roomId) =>
            Matrix.of(context).client.getRoomById(roomId)!.pushRuleState ==
            PushRuleState.notify,
      );

  bool waitForFirstSync = false;

  Future<void> _waitForFirstSync() async {
    final client = Matrix.of(context).client;
    await client.roomsLoading;
    await client.accountDataLoading;
    if (client.prevBatch == null) {
      await client.onSync.stream.first;

      // Display first login bootstrap if enabled
      if (client.encryption?.keyManager.enabled == true) {
        if (await client.encryption?.keyManager.isCached() == false ||
            await client.encryption?.crossSigning.isCached() == false ||
            client.isUnknownSession && !mounted) {
          await BootstrapDialog(client: client).show(context);
        }
      }
    }
    if (!mounted) return;
    setState(() {
      waitForFirstSync = true;
    });
  }

  void cancelAction() {
    if (selectMode == SelectMode.share) {
      setState(() => Matrix.of(context).shareContent = null);
    } else {
      setState(() => selectedRoomIds.clear());
    }
  }

  void setActiveClient(Client client) {
    VRouter.of(context).to('/rooms');
    setState(() {
      activeFilter = AppConfig.separateChatTypes
          ? ActiveFilter.messages
          : ActiveFilter.allChats;
      activeSpaceId = null;
      selectedRoomIds.clear();
      Matrix.of(context).setActiveClient(client);
    });
    _clientStream.add(client);
  }

  void setActiveBundle(String bundle) {
    VRouter.of(context).to('/rooms');
    setState(() {
      selectedRoomIds.clear();
      Matrix.of(context).activeBundle = bundle;
      if (!Matrix.of(context)
          .currentBundle!
          .any((client) => client == Matrix.of(context).client)) {
        Matrix.of(context)
            .setActiveClient(Matrix.of(context).currentBundle!.first);
      }
    });
  }

  void editBundlesForAccount(String? userId, String? activeBundle) async {
    final l10n = L10n.of(context)!;
    final client = Matrix.of(context)
        .widget
        .clients[Matrix.of(context).getClientIndexByMatrixId(userId!)];
    final action = await showConfirmationDialog<EditBundleAction>(
      context: context,
      title: L10n.of(context)!.editBundlesForAccount,
      actions: [
        AlertDialogAction(
          key: EditBundleAction.addToBundle,
          label: L10n.of(context)!.addToBundle,
        ),
        if (activeBundle != client.userID)
          AlertDialogAction(
            key: EditBundleAction.removeFromBundle,
            label: L10n.of(context)!.removeFromBundle,
          ),
      ],
    );
    if (action == null) return;
    switch (action) {
      case EditBundleAction.addToBundle:
        final bundle = await showTextInputDialog(
          context: context,
          title: l10n.bundleName,
          textFields: [DialogTextField(hintText: l10n.bundleName)],
        );
        if (bundle == null || bundle.isEmpty || bundle.single.isEmpty) return;
        await showFutureLoadingDialog(
          context: context,
          future: () => client.setAccountBundle(bundle.single),
        );
        break;
      case EditBundleAction.removeFromBundle:
        await showFutureLoadingDialog(
          context: context,
          future: () => client.removeFromAccountBundle(activeBundle!),
        );
    }
  }

  bool get displayBundles =>
      Matrix.of(context).hasComplexBundles &&
      Matrix.of(context).accountBundles.keys.length > 1;

  String? get secureActiveBundle {
    if (Matrix.of(context).activeBundle == null ||
        !Matrix.of(context)
            .accountBundles
            .keys
            .contains(Matrix.of(context).activeBundle)) {
      return Matrix.of(context).accountBundles.keys.first;
    }
    return Matrix.of(context).activeBundle;
  }

  void resetActiveBundle() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        Matrix.of(context).activeBundle = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Matrix.of(context).navigatorContext = context;
    final String share =
        VRouter.of(context).queryParameters['share'] ?? 'no-file';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: personalColorScheme.background,
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
                onBackPress: () async {
                  for (int i = 0; i < filteredRooms.length; i++) {
                    filteredRooms[i].stopStaleCallsChecker(
                      filteredRooms[i].id,
                    );
                  }
                  await slidePage!.forward();
                  VRouter.of(context).to('/talk');
                },
                onBackLongPress: () => VRouter.of(context).to('/talk'),
                onSearchPress: () {
                  if (isSearching || isSearchMode) {
                    cancelSearch();
                    searchNotifier.value = false;
                  } else {
                    onSearchEnter('');
                    isSearchMode = true;
                    searchNotifier.value = true;
                    searchFocusNode.requestFocus();
                  }
                },
              ),
            ),
          ],
        ),
      ),
      key: scaffoldKey,
      endDrawer: Padding(
        padding: EdgeInsets.zero,
        child: RotatingEndDrawer(
          drawer: StandardDrawer(
            showSplines: false,
            context: context,
            left: false,
            color: personalColorScheme.background,
            borderColor: personalColorScheme.primary,
            splineColor: Colors.transparent,
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
                scaffoldKey.currentState?.closeEndDrawer();
                sendStickerAction(
                  context,
                  filteredRooms[splineIndex],
                );
              },
              () {
                scaffoldKey.currentState?.closeEndDrawer();
                sendLocationAction(
                  context,
                  filteredRooms[splineIndex],
                );
              },
              () {
                scaffoldKey.currentState?.closeEndDrawer();
                sendFileAction(
                  context,
                  filteredRooms[splineIndex],
                );
              },
              () {
                scaffoldKey.currentState?.closeEndDrawer();
                sendImageAction(
                  context,
                  filteredRooms[splineIndex],
                );
              },
              () {
                scaffoldKey.currentState?.closeEndDrawer();
                openCameraAction(
                  context,
                  filteredRooms[splineIndex],
                );
              },
              () {
                scaffoldKey.currentState?.closeEndDrawer();
                openVideoCameraAction(
                  context,
                  filteredRooms[splineIndex],
                );
              },
            ],
          ),
        ),
      ),
      body: SizedBox(
        height: 1.sh,
        width: 1.sw,
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 99.h,
                ),
                if (!isSearching &&
                    !isSearchMode &&
                    !(selectMode != SelectMode.normal))
                  // Peek of the selected room in the blue lines
                  // Only visible if not in select more or searching
                  ChatPeekView(
                    share: share,
                    controller: this,
                  ),
                // primary list of available chat rooms
                ChatListView(this),
              ],
            ),
            if (!isSearching &&
                !isSearchMode &&
                !(selectMode != SelectMode.normal))
              // Conciel DNA - splines
              LinesSplines(
                context: context,
                height: 1.sh,
                width: 1.sw,
                itemHeight: AppConfig.chatItemHeight,
                color: personalColorScheme.primary,
              ),
            if (!isSearching &&
                !isSearchMode &&
                !(selectMode != SelectMode.normal))
              // Conciel DNA - UI rotating rings - right side
              ConcielStaticUI(
                slideAnimation: slideAnimation,
                share: share,
                filteredRooms: filteredRooms,
                splineIndex: splineIndex,
              ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: personalColorScheme.background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 40,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: getNavigationDestinations(context, this),
      ),
      floatingActionButton: KeyBoardShortcuts(
        keysToPress: {
          LogicalKeyboardKey.controlLeft,
          LogicalKeyboardKey.keyN,
        },
        onKeysPressed: () => VRouter.of(context).to('/newprivatechat'),
        helpLabel: L10n.of(context)!.newChat,
        child: selectMode == SelectMode.normal && !isSearchMode
            ? Container()
            : const SizedBox.shrink(),
      ),
    );
  }

  void _hackyWebRTCFixForWeb() {
    ChatList.contextForVoip = context;
  }

  Future<void> _checkTorBrowser() async {
    if (!kIsWeb) return;
    final isTor = await TorBrowserDetector.isTorBrowser;
    isTorBrowser = isTor;
  }

  Future<void> dehydrate() =>
      SettingsSecurityController.dehydrateDevice(context);
}

class ConcielStaticUI extends StatelessWidget {
  const ConcielStaticUI({
    super.key,
    required this.slideAnimation,
    required this.share,
    required this.filteredRooms,
    required this.splineIndex,
  });

  final Animation<Offset>? slideAnimation;
  final String share;
  final List<Room> filteredRooms;
  final int splineIndex;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation!,
      child: Align(
        alignment: Alignment.centerRight,
        child: RotatingEndDrawer(
          drawer: share == 'make-call'
              ? StandardDrawer(
                  showSplines: false,
                  context: context,
                  left: false,
                  borderColor: personalColorScheme.primary,
                  splineColor: Colors.transparent,
                  icons: const [
                    ConcielIcons.phone,
                    ConcielIcons.video_camera,
                    ConcielIcons.chat,
                    ConcielIcons.phone,
                    ConcielIcons.video_camera,
                    ConcielIcons.chat,
                  ],
                  onTap: [
                    () => onPhoneButtonTap(
                          context,
                          filteredRooms[splineIndex],
                          direct: true,
                          voice: true,
                        ),
                    () => onPhoneButtonTap(
                          context,
                          filteredRooms[splineIndex],
                          direct: true,
                          voice: false,
                        ),
                    () => chatTap(
                          context,
                          filteredRooms[splineIndex],
                        ),
                    () => onPhoneButtonTap(
                          context,
                          filteredRooms[splineIndex],
                          direct: true,
                          voice: true,
                        ),
                    () => onPhoneButtonTap(
                          context,
                          filteredRooms[splineIndex],
                          direct: true,
                          voice: false,
                        ),
                    () => chatTap(
                          context,
                          filteredRooms[splineIndex],
                        ),
                  ],
                )
              : StandardDrawer(
                  showSplines: false,
                  context: context,
                  left: false,
                  borderColor: personalColorScheme.primary,
                  splineColor: Colors.transparent,
                  icons: const [
                    Icons.workspaces_outlined,
                    Icons.event,
                    ConcielIcons.mail,
                    ConcielIcons.chat,
                    ConcielIcons.phone,
                    Icons.cloud_outlined,
                  ],
                  onTap: [
                    () => VRouter.of(context).to('/newspace'),
                    () => IdentityShare.share(
                          L10n.of(context)!.inviteText(
                            Matrix.of(context).client.userID!,
                            'https://matrix.to/#/${Matrix.of(context).client.userID}?client=im.concieltalk',
                          ),
                          context,
                        ),
                    () {},
                    () => chatTap(
                          context,
                          filteredRooms[splineIndex],
                        ),
                    () => onPhoneButtonTap(
                          context,
                          filteredRooms[splineIndex],
                        ),
                    () => VRouter.of(context).to('/archive'),
                  ],
                ),
        ),
      ),
    );
  }
}

enum EditBundleAction { addToBundle, removeFromBundle }

class CustomScrollPhysics extends ScrollPhysics {
  const CustomScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    return 0.0;
  }
}

class CustomBouncingScrollPhysics extends BouncingScrollPhysics {
  const CustomBouncingScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  double frictionFactor(double overscrollFraction) => 0;
  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    return 0.0;
  }
}
