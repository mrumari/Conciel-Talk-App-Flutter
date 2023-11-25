import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:concieltalk/utils/platform_infos.dart';

class UserMediaManager {
  factory UserMediaManager() {
    return _instance;
  }

  UserMediaManager._internal();

  static final UserMediaManager _instance = UserMediaManager._internal();

  AudioPlayer? _assetsAudioPlayer;

  Future<void> startRingingTone() async {
    if (PlatformInfos.isMobile) {
      await FlutterRingtonePlayer.play(
        fromAsset: 'assets/minimal_techno.mp3',
        looping: true,
      );
    }
    return;
  }

  Future<void> stopRingingTone() async {
    if (PlatformInfos.isMobile) {
      await FlutterRingtonePlayer.stop();
    }
    await _assetsAudioPlayer?.stop();
    _assetsAudioPlayer = null;
    return;
  }
}
