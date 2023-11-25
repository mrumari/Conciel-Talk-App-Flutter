import 'dart:async';
import 'dart:math';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:matrix/matrix.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:concieltalk/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:concieltalk/utils/platform_infos.dart';
import 'package:concieltalk/widgets/avatar.dart';
import 'pip/pip_view.dart';

class _StreamView extends StatelessWidget {
  const _StreamView(
    this.wrappedStream, {
    Key? key,
    this.mainView = false,
    required this.matrixClient,
    this.videoOff = true,
  }) : super(key: key);

  final WrappedMediaStream wrappedStream;
  final Client matrixClient;
  final bool mainView;
  final bool videoOff;

  Uri? get avatarUrl => wrappedStream.room
      .unsafeGetUserFromMemoryOrFallback(wrappedStream.room.directChatMatrixID!)
      .avatarUrl;

  int? get startIndex => wrappedStream.room.directChatMatrixID?.indexOf('@');
  int? get endIndex => wrappedStream.room.directChatMatrixID?.indexOf(':');
  String? get displayName => wrappedStream.room.directChatMatrixID
      ?.substring(startIndex! + 1, endIndex);

  String get avatarName => wrappedStream.avatarName;

  bool get isLocal => wrappedStream.isLocal();
  String? get localName => wrappedStream.displayName;
  Uri? get localAvatarUrl => wrappedStream.getUser().avatarUrl;

  bool get mirrored =>
      wrappedStream.isLocal() &&
      wrappedStream.purpose == SDPStreamMetadataPurpose.Usermedia;

  bool get audioMuted => wrappedStream.audioMuted;

  bool get videoMuted => wrappedStream.videoMuted;

  bool get isScreenSharing =>
      wrappedStream.purpose == SDPStreamMetadataPurpose.Screenshare;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (videoOff)
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  const ClipOval(
                    child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child:
                          Image(image: concielAvatarThumb, fit: BoxFit.cover),
                    ),
                  ),
                  Icon(
                    Icons.block_outlined,
                    color: Colors.red.withOpacity(0.5),
                    size: 48,
                  ),
                ],
              ),
            ),
          if (!wrappedStream.videoMuted || !videoOff)
            RTCVideoView(
              // yes, it must explicitly be casted even though I do not feel
              // comfortable with it...
              wrappedStream.renderer as RTCVideoRenderer,
              mirror: mirrored,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
            ),
          if (videoOff && wrappedStream.videoMuted && mainView)
            Positioned(
              child: Avatar(
                mxContent: mainView ? avatarUrl : localAvatarUrl,
                name: mainView ? displayName : localName,
                size: mainView ? 200 : 48,
                client: matrixClient,
                // textSize: mainView ? 36 : 24,
                // matrixClient: matrixClient,
              ),
            ),
          if (!isScreenSharing)
            Positioned(
              left: 4.0,
              bottom: 4.0,
              child: Icon(
                audioMuted ? Icons.mic_off : Icons.mic,
                color: personalColorScheme.outline,
                size: 18.0,
              ),
            ),
        ],
      ),
    );
  }
}

class Calling extends StatefulWidget {
  final VoidCallback? onClear;
  final BuildContext context;
  final String callId;
  final CallSession call;
  final Client client;

  const Calling({
    required this.context,
    required this.call,
    required this.client,
    required this.callId,
    this.onClear,
    Key? key,
  }) : super(key: key);

  @override
  MyCallingPage createState() => MyCallingPage();
}

class MyCallingPage extends State<Calling> {
  Room? get room => call.room;

  String get displayName => call.room.getLocalizedDisplayname(
        MatrixLocals(L10n.of(widget.context)!),
      );

  String get callId => widget.callId;

  CallSession get call => widget.call;

  MediaStream? get localStream {
    if (call.localUserMediaStream != null) {
      return call.localUserMediaStream!.stream!;
    }
    return null;
  }

  MediaStream? get remoteStream {
    if (call.getRemoteStreams.isNotEmpty) {
      return call.getRemoteStreams[0].stream!;
    }
    return null;
  }

  bool get speakerOn => call.speakerOn;

  bool get isMicrophoneMuted => call.isMicrophoneMuted;

  bool get isLocalVideoMuted => call.isLocalVideoMuted;

  bool get isScreensharingEnabled => call.screensharingEnabled;

  bool get isRemoteOnHold => call.remoteOnHold;

  bool get voiceonly => call.type == CallType.kVoice;

  IconData get msgicon => call.type == CallType.kVideo
      ? ConcielIcons.video_camera
      : ConcielIcons.phone;

  bool get connecting => call.state == CallState.kConnecting;

  bool get connected => call.state == CallState.kConnected;

  bool get mirrored => call.facingMode == 'user';

  AudioPlayer player = AudioPlayer();

  List<WrappedMediaStream> get streams => call.streams;

  double? _localVideoHeight;
  double? _localVideoWidth;
  EdgeInsetsGeometry? _localVideoMargin;
  CallState? _state;
  late bool videoMute = true;
  String get callMessage => call.direction == CallDirection.kIncoming
      ? ' - missed call'
      : ' - call invite';

  void _playCallSound() async {
    const path = 'assets/sounds/call.ogg';
    await player.setAsset(path);
    player.setLoopMode(LoopMode.one);
    player.play();
  }

  @override
  void initState() {
    super.initState();
    initialize();
    _playCallSound();
  }

  void initialize() async {
    final call = this.call;
    call.onCallStateChanged.stream.listen(_handleCallState);
    call.onCallEventChanged.stream.listen((event) {
      if (event == CallEvent.kFeedsChanged) {
        setState(() {
          call.tryRemoveStopedStreams();
        });
      } else if (event == CallEvent.kLocalHoldUnhold ||
          event == CallEvent.kRemoteHoldUnhold) {
        setState(() {});
        Logs().i(
          'Call hold event: local ${call.localHold}, remote ${call.remoteOnHold}',
        );
      }
    });
    _state = call.state;

    if (call.type == CallType.kVideo) {
      videoMute = false;
      try {
        // Enable wakelock (keep screen on)
        unawaited(WakelockPlus.enable());
      } catch (_) {}
    }
  }

  void cleanUp() {
    Timer(
      const Duration(seconds: 2),
      () => widget.onClear?.call(),
    );
    if (call.type == CallType.kVideo) {
      try {
        unawaited(WakelockPlus.disable());
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    super.dispose();
    player.stop();
    call.cleanUp.call();
  }

  void _resizeLocalVideo(Orientation orientation) {
    final shortSide = min(
      1.sw,
      1.sh,
    );
    _localVideoMargin = remoteStream != null
        ? const EdgeInsets.only(top: 20.0, right: 20.0).r
        : EdgeInsets.zero;
    _localVideoWidth = remoteStream != null ? shortSide / 3 : 1.sw;
    _localVideoHeight = remoteStream != null ? shortSide / 4 : 1.sh;
  }

  void _handleCallState(CallState state) {
    Logs().v('CallingPage::handleCallState: ${state.toString()}');
    if ({CallState.kConnected, CallState.kEnded}.contains(state)) {
      try {
        player.stop();
        Vibration.vibrate(duration: 200);
      } catch (e) {
        Logs().e('[Dialer] could not stop audio player');
      }
    }
    if (mounted) {
      setState(() {
        _state = state;
        if (_state == CallState.kEnded) cleanUp();
      });
    }
  }

  void _answerCall() async {
    await player.stop();
    await call.answer();
  }

  void _hangUp() async {
    final callType = call.type == CallType.kVoice ? 'voice' : 'video';
    final direction = call.direction == CallDirection.kIncoming ? 'in' : 'out';
    final reason = '$callType-$direction';
    await player.stop();
    await call.hangup(reason);
  }

  void _rejectCall() async {
    final callType = call.type == CallType.kVoice ? 'voice' : 'video';
    final direction = call.direction == CallDirection.kIncoming ? 'in' : 'out';
    final reason = '$callType-$direction';
    await player.stop();
    await call.reject(reason: reason);
  }

  void _muteMic() {
    setState(() {
      call.setMicrophoneMuted(!call.isMicrophoneMuted);
    });
  }

  void _screenSharing() async {
    if (PlatformInfos.isAndroid) {
      if (!call.screensharingEnabled) {
        FlutterForegroundTask.init(
          androidNotificationOptions: AndroidNotificationOptions(
            channelId: 'notification_channel_id',
            channelName: 'Foreground Notification',
            channelDescription:
                L10n.of(widget.context)!.foregroundServiceRunning,
          ),
          iosNotificationOptions: const IOSNotificationOptions(),
          foregroundTaskOptions: const ForegroundTaskOptions(),
        );
        FlutterForegroundTask.startService(
          notificationTitle: L10n.of(widget.context)!.screenSharingTitle,
          notificationText: L10n.of(widget.context)!.screenSharingDetail,
        );
      } else {
        FlutterForegroundTask.stopService();
      }
    }

    setState(() {
      call.setScreensharingEnabled(!call.screensharingEnabled);
    });
  }

  void _remoteOnHold() {
    setState(() {
      call.setRemoteOnHold(!call.remoteOnHold);
    });
  }

  void _muteCamera() {
    setState(() {
      videoMute = call.isLocalVideoMuted;
      videoMute = !videoMute;
      call.setLocalVideoMuted(videoMute);
    });
  }

  void _switchCamera() async {
    if (call.localUserMediaStream != null) {
      await Helper.switchCamera(
        call.localUserMediaStream!.stream!.getVideoTracks()[0],
      );
      if (PlatformInfos.isMobile) {
        call.facingMode == 'user'
            ? call.facingMode = 'environment'
            : call.facingMode = 'user';
      }
    }
    setState(() {});
  }

  void _switchSpeaker() {
    setState(() {
      call.speakerOn = !call.speakerOn;
    });
  }

  List<Widget> _buildActionButtons(bool isFloating) {
    if (isFloating) {
      return [];
    }

    final switchCameraButton = FloatingActionButton(
      mini: true,
      heroTag: 'switchCamera',
      onPressed: _switchCamera,
      foregroundColor: personalColorScheme.outline,
      backgroundColor: personalColorScheme.surface,
      child: const Icon(
        Icons.flip_camera_android,
        weight: 100,
      ),
    );

    // ignore: unused_local_variable
    final switchSpeakerButton = FloatingActionButton(
      mini: true,
      heroTag: 'switchSpeaker',
      onPressed: _switchSpeaker,
      foregroundColor: personalColorScheme.outline,
      backgroundColor: personalColorScheme.surface,
      child: Icon(call.speakerOn ? Icons.volume_up : Icons.volume_off),
    );

    final hangupButton = FloatingActionButton(
      mini: true,
      heroTag: 'hangup',
      onPressed: _hangUp,
      tooltip: 'Hangup',
      backgroundColor: _state == CallState.kEnded
          ? personalColorScheme.surface
          : personalColorScheme.tertiary,
      child: const Icon(
        Icons.call_end_outlined,
        weight: 100,
      ),
    );

    final rejectButton = FloatingActionButton(
      mini: true,
      heroTag: 'rejectcall',
      onPressed: _rejectCall,
      tooltip: 'RejectCall',
      backgroundColor: _state == CallState.kEnded
          ? personalColorScheme.surface
          : personalColorScheme.tertiary,
      child: const Icon(
        Icons.call_end_outlined,
        weight: 100,
      ),
    );

    final answerButton = FloatingActionButton(
      mini: true,
      heroTag: 'answer',
      onPressed: _answerCall,
      tooltip: 'Answer',
      backgroundColor: Colors.green,
      child: const Icon(Icons.phone_outlined),
    );

    final muteMicButton = FloatingActionButton(
      mini: true,
      heroTag: 'muteMic',
      onPressed: _muteMic,
      foregroundColor:
          isMicrophoneMuted ? Colors.black26 : personalColorScheme.outline,
      backgroundColor: isMicrophoneMuted
          ? personalColorScheme.outline
          : personalColorScheme.surface,
      child: Icon(
        isMicrophoneMuted ? Icons.mic_off : ConcielIcons.microphone,
        weight: 100,
      ),
    );

    final screenSharingButton = FloatingActionButton(
      mini: true,
      heroTag: 'screenSharing',
      onPressed: _screenSharing,
      foregroundColor:
          isScreensharingEnabled ? Colors.black26 : personalColorScheme.outline,
      backgroundColor: isScreensharingEnabled
          ? personalColorScheme.outline
          : personalColorScheme.surface,
      child: const Icon(
        Icons.screen_share_outlined,
        weight: 100,
      ),
    );

    final holdButton = FloatingActionButton(
      mini: true,
      heroTag: 'hold',
      onPressed: _remoteOnHold,
      foregroundColor:
          isRemoteOnHold ? Colors.black26 : personalColorScheme.outline,
      backgroundColor: isRemoteOnHold
          ? personalColorScheme.outline
          : personalColorScheme.surface,
      child: const Icon(
        Icons.pause_outlined,
        weight: 100,
      ),
    );

    final muteCameraButton = FloatingActionButton(
      mini: true,
      heroTag: 'muteCam',
      onPressed: _muteCamera,
      foregroundColor: videoMute ? Colors.black26 : personalColorScheme.outline,
      backgroundColor:
          videoMute ? personalColorScheme.outline : personalColorScheme.surface,
      child: Icon(
        videoMute ? Icons.videocam_off : ConcielIcons.video_camera,
      ),
    );

    switch (_state) {
      case CallState.kRinging:
      case CallState.kInviteSent:
      case CallState.kCreateAnswer:
      case CallState.kConnecting:
        return call.isOutgoing
            ? <Widget>[hangupButton]
            : <Widget>[answerButton, rejectButton];
      case CallState.kConnected:
        return <Widget>[
          muteMicButton,
//          switchSpeakerButton,
          if (!voiceonly && !kIsWeb) switchCameraButton,
          if (!voiceonly) muteCameraButton,
          if (PlatformInfos.isMobile || PlatformInfos.isWeb)
            screenSharingButton,
          holdButton,
          hangupButton,
        ];
      case CallState.kEnded:
        return <Widget>[
          hangupButton,
        ];
      case CallState.kFledgling:
        // TODO: Handle this case.
        break;
      case CallState.kWaitLocalMedia:
        // TODO: Handle this case.
        break;
      case CallState.kCreateOffer:
        // TODO: Handle this case.
        break;
      case null:
        // TODO: Handle this case.
        break;
    }
    return <Widget>[];
  }

  List<Widget> _buildContent(Orientation orientation, bool isFloating) {
    final stackWidgets = <Widget>[];

    final call = this.call;
    if (call.callHasEnded) {
      return stackWidgets;
    }

    if (call.localHold || call.remoteOnHold) {
      var title = '';
      if (call.localHold) {
        title = '${call.room.getLocalizedDisplayname(
          MatrixLocals(L10n.of(widget.context)!),
        )} held the call.';
      } else if (call.remoteOnHold) {
        title = 'You held the call.';
      }
      stackWidgets.add(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pause,
                size: 48.0,
                color: personalColorScheme.outline,
              ),
              Text(
                title,
                style: TextStyle(
                  color: personalColorScheme.outline,
                  fontSize: 24.0,
                ),
              ),
            ],
          ),
        ),
      );
      return stackWidgets;
    }

    var primaryStream = call.remoteScreenSharingStream ??
        call.localScreenSharingStream ??
        call.remoteUserMediaStream ??
        call.localUserMediaStream;

    if (!connected) {
      primaryStream = call.localUserMediaStream;
    }

    if (primaryStream != null) {
      stackWidgets.add(
        Center(
          child: _StreamView(
            primaryStream,
            mainView: true,
            matrixClient: widget.client,
          ),
        ),
      );
    }

    if (isFloating || !connected) {
      return stackWidgets;
    }

    _resizeLocalVideo(orientation);

    if (call.getRemoteStreams.isEmpty) {
      return stackWidgets;
    }

    final secondaryStreamViews = <Widget>[];

    if (call.remoteScreenSharingStream != null) {
      final remoteUserMediaStream = call.remoteUserMediaStream;
      secondaryStreamViews.add(
        SizedBox(
          width: _localVideoWidth,
          height: _localVideoHeight,
          child: _StreamView(
            remoteUserMediaStream!,
            matrixClient: widget.client,
          ),
        ),
      );
      secondaryStreamViews.add(const SizedBox(height: 10));
    }

    final localStream =
        call.localUserMediaStream ?? call.localScreenSharingStream;
    if (localStream != null && !isFloating) {
      secondaryStreamViews.add(
        SizedBox(
          width: _localVideoWidth,
          height: _localVideoHeight,
          child: _StreamView(
            localStream,
            matrixClient: widget.client,
            videoOff: videoMute,
          ),
        ),
      );
      secondaryStreamViews.add(const SizedBox(height: 10));
    }

    if (call.localScreenSharingStream != null && !isFloating) {
      secondaryStreamViews.add(
        SizedBox(
          width: _localVideoWidth,
          height: _localVideoHeight,
          child: _StreamView(
            call.remoteUserMediaStream!,
            matrixClient: widget.client,
          ),
        ),
      );
      secondaryStreamViews.add(const SizedBox(height: 10));
    }

    if (secondaryStreamViews.isNotEmpty) {
      stackWidgets.add(
        Container(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 120),
          alignment: Alignment.bottomRight,
          child: Container(
            width: _localVideoWidth,
            margin: _localVideoMargin,
            child: Column(
              children: secondaryStreamViews,
            ),
          ),
        ),
      );
    }

    return stackWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return PIPView(
      builder: (context, isFloating) {
        return Scaffold(
          resizeToAvoidBottomInset: !isFloating,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: SizedBox(
            width: 320.0,
            height: 150.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildActionButtons(isFloating),
            ),
          ),
          body: OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.black87,
                ),
                child: Stack(
                  children: [
                    ..._buildContent(orientation, isFloating),
                    if (!isFloating)
                      Positioned(
                        top: 24.0,
                        left: 24.0,
                        child: IconButton(
                          color: personalColorScheme.surface,
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            PIPView.of(context)?.setFloating(true);
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
