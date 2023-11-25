import 'dart:async';

import 'package:concieltalk/config/app_config.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';

Future<void> displayIncomingCall(
  String uuid,
  String callerName,
  String avatar,
  String handle,
  bool video,
  Map<String, dynamic> extra,
) async {
  final config = CallKeepIncomingConfig.fromBaseConfig(
// the following will be updated when a call is received
//    callerName:
//    avatar:
//    handle:
//    hasVideo:
//    extra: <String, dynamic>{'userId': '1a2b3c4d'},
    config: CallKeepBase.instance.callKeepBaseConfig,
    uuid: uuid,
    callerName: callerName,
    avatar: avatar,
    handle: handle,
    hasVideo: video,
    extra: extra,
    duration: 30000,
  );
  await CallKeep.instance.displayIncomingCall(config);
}
