import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:matrix/matrix.dart';
import 'package:concieltalk/widgets/debouncer.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

abstract class AppConfig {
// Items that are set by Conciel UI - require translation into other
// languages - default is US English and is set in intl_en.arb
  static List<String> whenItems = [
    ConcielTalkBase.instance!.callKeepBaseConfig.week,
    ConcielTalkBase.instance!.callKeepBaseConfig.month,
    ConcielTalkBase.instance!.callKeepBaseConfig.year,
    ConcielTalkBase.instance!.callKeepBaseConfig.date,
    ConcielTalkBase.instance!.callKeepBaseConfig.today,
    ConcielTalkBase.instance!.callKeepBaseConfig.tomorrow,
  ];
  static List<String> whereItems = [
    ConcielTalkBase.instance!.callKeepBaseConfig.here,
    ConcielTalkBase.instance!.callKeepBaseConfig.address,
    ConcielTalkBase.instance!.callKeepBaseConfig.online,
    ConcielTalkBase.instance!.callKeepBaseConfig.map,
    ConcielTalkBase.instance!.callKeepBaseConfig.country,
    ConcielTalkBase.instance!.callKeepBaseConfig.city,
  ];
  static List<String> socialItems = [
    ConcielTalkBase.instance!.callKeepBaseConfig.favorites,
    ConcielTalkBase.instance!.callKeepBaseConfig.space,
    ConcielTalkBase.instance!.callKeepBaseConfig.community,
    ConcielTalkBase.instance!.callKeepBaseConfig.voting,
  ];
  static List<String> planItems = [
    ConcielTalkBase.instance!.callKeepBaseConfig.desktop,
    ConcielTalkBase.instance!.callKeepBaseConfig.schedule,
    ConcielTalkBase.instance!.callKeepBaseConfig.projects,
    ConcielTalkBase.instance!.callKeepBaseConfig.clients,
  ];
  static List<String> cloudItems = [
    ConcielTalkBase.instance!.callKeepBaseConfig.ccloud,
    ConcielTalkBase.instance!.callKeepBaseConfig.photos,
    ConcielTalkBase.instance!.callKeepBaseConfig.share,
    ConcielTalkBase.instance!.callKeepBaseConfig.files,
  ];
  static List<String> emailSelect = [
    ConcielTalkBase.instance!.callKeepBaseConfig.email,
    ConcielTalkBase.instance!.callKeepBaseConfig.cmail,
    ConcielTalkBase.instance!.callKeepBaseConfig.inbox,
    ConcielTalkBase.instance!.callKeepBaseConfig.priority,
  ];

  // Items configurable by operator - currently set here as static items
  // TO DO - transfer to local Hive database and create settings pages for
  // each of the UI components
  // Settings to be context specific for each page
  static List<String> whatItems = [
    'MUSEUM',
    'SPORT',
    'HOTEL',
    'TRAVEL',
    'RESTAURANT',
    'BAR',
  ];
  static List<List<String>> whatDetailItems = [
    [],
    [],
    [],
    [],
    [
      'ARABIC',
      'BREAKFAST',
      'FRENCH',
      'ITALIAN',
      'JAPANESE',
      'KOREAN',
    ],
    [''],
  ];

  static List<String> payItems = [
    'STATUS',
    'HISTORY',
    'REFUND',
    'TRANSFER',
  ];
  static List<String> memberItems = [
    'SUBSCRIPTIONS',
    'MEMBERSHIPS',
    'POINTS',
    'CASHBACK',
  ];
  static List<String> retailItems = [
    'FIND',
    'HOLD',
    'CONTACT',
    'BUY',
  ];
  static List<String> healthItems = [
    'WELLNESS',
    'SPORT',
    'TREATMENT',
    'MEDICAL',
  ];
  static List<String> travelItems = [
    'AIR',
    'SEA',
    'LAND',
    'MOBILITY',
  ];
  static List<String> sleepItems = [
    'HOTELS',
    'B & B',
    'HOSTELS',
    'HOMES',
  ];
  static List<String> shopSelect = [
    'SHOPS',
    'MARKETS',
    'SHIPPING',
    'SEARCH',
  ];
  static List<String> bookSelect = [
    'GROCERIES',
    'DELIVERY',
    'RESTAURANTS',
    'BARS',
  ];

//  static String _appFCMToken = 'AIzaSyBYIEQnV1qraO7u-pinOVGQVCBpblEveWc';
  static String _applicationName = 'ConcielTalk';
  static String get applicationName => _applicationName;
  static String? _applicationWelcomeMessage;
  static String? get applicationWelcomeMessage => _applicationWelcomeMessage;
  static String _defaultPort = '8448';
  static String get defaultPort => _defaultPort;
  static String _defaultDomain = 'conciel.space';
  static String get defaultDomain => _defaultDomain;
  static String _defaultHomeserver = 'https://$_defaultDomain:$_defaultPort';
  static String get defaultHomeserver => _defaultHomeserver;
  static double bubbleSizeFactor = 1;
  static double fontSizeFactor = 1;
  static double cubeRingScale = 0.8;
  static bool showBadge = true;
  static bool showCount = true;
  static bool showTile = false;
  static const Color chatColor = primaryColor;
  static Color? colorSchemeSeed = primaryColor;
  static const double messageFontSize = 15.75;
  static const bool allowOtherHomeservers = false;
  static const bool enableRegistration = false;
  static const Color primaryColor = Color(0xDD12a3f5);
  static const Color primaryColorLight = Color(0xFF12A3F5);
  static const Color secondaryColor = Color(0xFF85e527);
  static const Color backgroundColor = Color(0xFF534F5C);
  static String _privacyUrl = 'https://www.conciel.ch/impressum';
  static String get privacyUrl => _privacyUrl;
  static const String enablePushTutorial = 'https://www.conciel.ch/';
  static const String encryptionTutorial =
      'https://www.conciel.ch/auratech-technologies';
  static const String appId = 'chat.conciel.concieltalk';
  static const String appOpenUrlScheme = 'im.concieltalk';
  static String _webBaseUrl = 'https://conciel.ch';
  static String get webBaseUrl => _webBaseUrl;
  static const String sourceCodeUrl =
      'https://www.conciel.ch/auratech-technologies';
  static const String supportUrl = 'https://www.conciel.ch/contact';
  static final Uri newIssueUrl = Uri(
    scheme: 'https',
    host: 'gitlab.com',
    path: '/conciel/talk/-/issues/new',
  );
  static const bool enableSentry = false;
  static const String sentryDns =
      'https://a5dbe391251c4701a3b8809bd38e56ec@o4505560968003584.ingest.sentry.io/4505560976588800';
  static bool renderHtml = true;
  static bool hideRedactedEvents = true;
  static bool hideUnknownEvents = false;
  static bool hideUnimportantStateEvents = true;
  static bool showDirectChatsInSpaces = true;
  static bool separateChatTypes = false;
  static bool autoplayImages = true;
  static bool sendOnEnter = false;
  static bool experimentalVoip = false;
  static const bool hideTypingUsernames = false;
  static const bool hideAllStateEvents = false;
  static const String inviteLinkPrefix = 'https://matrix.to/#/';
  static const String deepLinkPrefix = 'im.concieltalk://chat/';
  static const String schemePrefix = 'matrix:';
  static const String pushNotificationsChannelId =
      'chat.conciel.concieltalk.push';
  static const String pushNotificationsChannelName = 'Conciel Talk';
  static const String pushNotificationsChannelDescription =
      'Talk notifications for Conciel';
  static const String pushNotificationsAppId = 'chat.conciel.concieltalk';
  static const String pushNotificationsGatewayUrl =
      'http://push.conciel.space:5000/_matrix/push/v1/notify';
  static const String pushNotificationsPusherFormat = 'event_id_only';
  static const String emojiFontName = 'Noto Emoji';
  static const String emojiFontUrl =
      'https://github.com/googlefonts/noto-emoji/';
  static const double borderRadius = 10.0;
  static const double columnWidth = 360.0;
  static const double chatItemHeight = 60;

  static void loadFromJson(Map<String, dynamic> json) {
    if (json['chat_color'] != null) {
      try {
        colorSchemeSeed = Color(json['chat_color']);
      } catch (e) {
        Logs().w(
          'Invalid color in config.json! Please make sure to define the color in this format: "0xffdd0000"',
          e,
        );
      }
    }
    if (json['application_name'] is String) {
      _applicationName = json['application_name'];
    }
    if (json['application_welcome_message'] is String) {
      _applicationWelcomeMessage = json['application_welcome_message'];
    }
    if (json['default_domain'] is String) {
      _defaultDomain = json['default_domain'];
    }
    if (json['default_port'] is String) {
      _defaultPort = json['default_port'];
    }
    if (json['default_homeserver'] is String) {
      _defaultHomeserver = json['default_homeserver'];
    }
    if (json['privacy_url'] is String) {
      _webBaseUrl = json['privacy_url'];
    }
    if (json['web_base_url'] is String) {
      _privacyUrl = json['web_base_url'];
    }
    if (json['render_html'] is bool) {
      renderHtml = json['render_html'];
    }
    if (json['hide_redacted_events'] is bool) {
      hideRedactedEvents = json['hide_redacted_events'];
    }
    if (json['hide_unknown_events'] is bool) {
      hideUnknownEvents = json['hide_unknown_events'];
    }
  }
}

const concielPlatform = MethodChannel('chat.conciel.concieltalk/permissions');

// Define ConcielTalkBase items from language as set by the Mobile device
// TO DO - extract the Shop and Book items into
// ConcielShopBase and ConcieBookBase
class ConcielTalkBase {
  static ConcielTalkBase? instance;
  final ConcielTalkBaseConfig callKeepBaseConfig;
  ConcielTalkBase._(this.callKeepBaseConfig);
  static void initialize(BuildContext context) {
    if (instance == null) {
      final concielTalkBaseConfig = ConcielTalkBaseConfig(
        favorites: L10n.of(context)!.favorites,
        space: L10n.of(context)!.space,
        community: L10n.of(context)!.community,
        voting: L10n.of(context)!.voting,
        desktop: L10n.of(context)!.desktop,
        schedule: L10n.of(context)!.schedule,
        projects: L10n.of(context)!.projects,
        clients: L10n.of(context)!.clients,
        ccloud: L10n.of(context)!.cloud,
        photos: L10n.of(context)!.photos,
        share: L10n.of(context)!.socialShare,
        files: L10n.of(context)!.files,
        email: L10n.of(context)!.email,
        cmail: L10n.of(context)!.cmail,
        inbox: L10n.of(context)!.inbox,
        priority: L10n.of(context)!.priority,
        where: L10n.of(context)!.where,
        here: L10n.of(context)!.here,
        address: L10n.of(context)!.address,
        online: L10n.of(context)!.online,
        map: L10n.of(context)!.map,
        country: L10n.of(context)!.country,
        city: L10n.of(context)!.city,
        when: L10n.of(context)!.when,
        week: L10n.of(context)!.week,
        month: L10n.of(context)!.month,
        year: L10n.of(context)!.year,
        date: L10n.of(context)!.date,
        today: L10n.of(context)!.today,
        tomorrow: L10n.of(context)!.tomorrow,
        what: L10n.of(context)!.what,
        social: L10n.of(context)!.social,
        cloud: L10n.of(context)!.cloud,
        plan: L10n.of(context)!.plan,
        payments: L10n.of(context)!.payments,
        retail: L10n.of(context)!.retail,
        member: L10n.of(context)!.member,
        travel: L10n.of(context)!.travel,
        health: L10n.of(context)!.health,
        sleep: L10n.of(context)!.sleep,
      );
      instance = ConcielTalkBase._(concielTalkBaseConfig);
    }
  }
}

class ConcielTalkBaseConfig {
  final String favorites;
  final String space;
  final String community;
  final String voting;
  final String desktop;
  final String schedule;
  final String projects;
  final String clients;
  final String ccloud;
  final String photos;
  final String share;
  final String files;
  final String email;
  final String cmail;
  final String inbox;
  final String priority;
  final String where;
  final String here;
  final String address;
  final String online;
  final String map;
  final String country;
  final String city;
  final String when;
  final String week;
  final String month;
  final String year;
  final String date;
  final String today;
  final String tomorrow;
  final String what;
  final String social;
  final String cloud;
  final String plan;
  final String payments;
  final String retail;
  final String member;
  final String travel;
  final String health;
  final String sleep;
  ConcielTalkBaseConfig({
    required this.favorites,
    required this.space,
    required this.community,
    required this.voting,
    required this.desktop,
    required this.schedule,
    required this.projects,
    required this.clients,
    required this.ccloud,
    required this.photos,
    required this.share,
    required this.files,
    required this.email,
    required this.cmail,
    required this.inbox,
    required this.priority,
    required this.where,
    required this.here,
    required this.address,
    required this.online,
    required this.map,
    required this.country,
    required this.city,
    required this.when,
    required this.week,
    required this.month,
    required this.year,
    required this.date,
    required this.today,
    required this.tomorrow,
    required this.what,
    required this.social,
    required this.cloud,
    required this.plan,
    required this.payments,
    required this.retail,
    required this.member,
    required this.travel,
    required this.health,
    required this.sleep,
  });
}

class CallKeepBase {
  static late final CallKeepBase instance;
  final CallKeepBaseConfig callKeepBaseConfig;

  CallKeepBase._(this.callKeepBaseConfig);

  static void initialize(BuildContext context) {
    final callKeepBaseConfig = CallKeepBaseConfig(
      appName: AppConfig._applicationName,
      acceptText: L10n.of(context)!.accept,
      declineText: L10n.of(context)!.deny,
      missedCallText: L10n.of(context)!.missed,
      callBackText: 'Call back',
      headers: <String, dynamic>{
        'apiKey': 'thisisthehookitscatchyyoulikeit',
        'platform': 'flutter',
      },
      androidConfig: CallKeepAndroidConfig(
        logo: "ic_launcher",
        showCallBackAction: true,
        showMissedCallNotification: true,
        ringtoneFileName: 'call.ogg',
        accentColor: '#12a3f5',
        backgroundUrl: 'assets/banner_dark.png',
        incomingCallNotificationChannelName: 'Incoming Calls',
        missedCallNotificationChannelName: 'Missed Calls',
      ),
      iosConfig: CallKeepIosConfig(
        iconName: 'Icon-App-40x40@2x',
        handleType: CallKitHandleType.generic,
        isVideoSupported: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 4,
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: true,
        supportsUngrouping: true,
        ringtoneFileName: 'call.ogg',
      ),
    );
    instance = CallKeepBase._(callKeepBaseConfig);
  }
}

class Conciel {
  static const appTitle = "Conciel Chat";
  static const loginTitle = "Login Page";
  static const homeTitle = "Home Page";
  static const profileTitle = "Profile Page";
  static const fullPhotoTitle = "Image Full Size";
  static const fileDB = "conciel_files";
  static const settingsDB = "conciel_settings";
  static const fileLocation = "storage";
  static const iconFamily = "ConcielIcons";
  static const mIconFamily = "MaterialIcons";
  static Debouncer debouncer = Debouncer(isExecuting: false, milliseconds: 500);
  static double bottomBarHeight = ScreenUtil().bottomBarHeight;
  static const cubeRingScale = 0.8;
}

const concielAvatarThumb = ResizeImage(
  AssetImage('assets/conciel-avatar.jpg'),
  width: 162,
);

enum Cube { talk, book, shop, what, where, when, none }

enum ConcielApp { talk, book, shop }

reset(List<double> list, double value) {
  for (int i = 0; i < list.length; i++) {
    list[i] = value;
  }
}

List<double> whereProgress = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
List<double> whenProgress = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
List<double> whatProgress = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
int whereIndex = 99;
int whenIndex = 99;
int whatIndex = 99;
List<int> whatDetailIndices = [
  99,
  99,
  99,
  99,
  99,
  99,
];
List<List<double>> whatDetailProgress = [
  [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
  ],
  [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
  ],
  [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
  ],
  [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
  ],
  [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
  ],
  [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
  ],
];
List<double> socialProgress = [0.0, 0.0, 0.0, 0.0, 0.0];
List<double> planProgress = [0.0, 0.0, 0.0, 0.0];
List<double> cloudProgress = [0.0, 0.0, 0.0, 0.0];
int socialIndex = 99;
int planIndex = 99;
int cloudIndex = 99;
List<double> payProgress = [0.0, 0.0, 0.0, 0.0];
List<double> retailProgress = [0.0, 0.0, 0.0, 0.0];
List<double> memberProgress = [0.0, 0.0, 0.0, 0.0];
int payIndex = 99;
int retailIndex = 99;
int memberIndex = 99;
List<double> healthProgress = [0.0, 0.0, 0.0, 0.0];
List<double> travelProgress = [0.0, 0.0, 0.0, 0.0];
List<double> sleepProgress = [0.0, 0.0, 0.0, 0.0];
int healthIndex = 99;
int travelIndex = 99;
int sleepIndex = 99;

String whenText = ConcielTalkBase.instance!.callKeepBaseConfig.when;
String whereText = ConcielTalkBase.instance!.callKeepBaseConfig.where;
String whatText = ConcielTalkBase.instance!.callKeepBaseConfig.what;
List<DateTime> whenDateTime = [DateTime.now(), DateTime.now(), DateTime.now()];

void updateData(Map<String, bool> newData) {
  wwwState.value = newData;
}

ValueNotifier<Map<String, bool>> wwwState = ValueNotifier({
  'where': false,
  'when': false,
  'what': false,
});

void resetAllWWW() {
  wwwState.value['where'] = false;
  wwwState.value['when'] = false;
  wwwState.value['what'] = false;
  whereProgress = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  whenProgress = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  whatProgress = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  whatDetailProgress = [
    [
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    [
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    [
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    [
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    [
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    [
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
  ];
  whatDetailIndices = [
    99,
    99,
    99,
    99,
    99,
    99,
  ];
  whereIndex = 99;
  whenIndex = 99;
  whatIndex = 99;
  whenText = ConcielTalkBase.instance!.callKeepBaseConfig.when;
  whereText = ConcielTalkBase.instance!.callKeepBaseConfig.where;
  whatText = ConcielTalkBase.instance!.callKeepBaseConfig.what;
}

bool pusherLogDone = false;
