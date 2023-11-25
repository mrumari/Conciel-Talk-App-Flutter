import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:concieltalk/pages/chat/event_info_dialog.dart';
import 'package:concieltalk/pages/chat_list/chat_list_body.dart';
import 'package:concieltalk/utils/date_time_extension.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

import 'package:concieltalk/utils/matrix_sdk_extensions/matrix_locals.dart';
import '../../../config/app_config.dart';

class StateMessage extends StatelessWidget {
  final Event event;
  const StateMessage(this.event, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onInverseSurface,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
          ),
          child: FutureBuilder<String>(
            future: event.calcLocalizedBody(MatrixLocals(L10n.of(context)!)),
            builder: (context, snapshot) {
              final isCall = event.body.toString().startsWith('m.call');
              final String reason = event.content['reason'].toString();
              final String who = event.senderId;
              final CallType callType = reason.startsWith('video')
                  ? CallType.kVideo
                  : CallType.kVoice;
              final client = Matrix.of(context).client;
              final inbound = who == client.userID ? false : true;
              var stateMsgText = snapshot.data ??
                  event.calcLocalizedBodyFallback(
                    MatrixLocals(L10n.of(context)!),
                  );
              var angle = 0.0;
              var color = personalColorScheme.primary;
              if (inbound) {
                if (event.type == EventTypes.CallInvite) {
                  stateMsgText =
                      'Missed from ${event.senderFromMemoryOrFallback.displayName}:';
                  angle = 270;
                }
                if (event.type == EventTypes.CallReject) {
                  stateMsgText =
                      '${event.senderFromMemoryOrFallback.displayName} declined:';
                  angle = 135;
                  color = personalColorScheme.tertiary;
                }
              } else {
                if (event.type == EventTypes.CallInvite) {
                  stateMsgText = 'Unanswered:';
                }
                if (event.type == EventTypes.CallReject) {
                  stateMsgText = 'You declined:';

                  angle = 135;
                  color = personalColorScheme.tertiary;
                }
              }
              if (event.type == EventTypes.CallAnswer) {
                color = personalColorScheme.secondary;
                if (inbound) {
                  angle = 270;
                }
              }
              if (callType == CallType.kVideo) {
                angle = 0.0;
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      stateMsgText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14 * AppConfig.fontSizeFactor,
                        color: isCall
                            ? personalColorScheme.outline
                            : Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                        decoration:
                            event.redacted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  event.body.startsWith('m.call') ||
                          event.body == EventTypes.CallHangup
                      ? GestureDetector(
                          onTap: () async {
                            final voiceCall =
                                callType == CallType.kVoice ? true : false;
                            onPhoneButtonTap(
                              context,
                              event.room,
                              direct: true,
                              voice: voiceCall,
                            );
                          },
                          onDoubleTap: () => event.showInfoDialog(context),
                          child: rotatedIcon(
                            callType == CallType.kVoice
                                ? ConcielIcons.phone
                                : ConcielIcons.video_camera,
                            size: 20,
                            angle: angle,
                            color: color,
                          ),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    width: 4,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      event.originServerTs.localizedTime(context),
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
