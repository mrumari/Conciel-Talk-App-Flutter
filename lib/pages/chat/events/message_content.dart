import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:matrix/matrix.dart';

import 'package:concieltalk/pages/chat/events/video_player.dart';
import 'package:concieltalk/utils/adaptive_bottom_sheet.dart';
import 'package:concieltalk/utils/date_time_extension.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:concieltalk/widgets/avatar.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'package:vrouter/vrouter.dart';
import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/utils/platform_infos.dart';
import 'package:concieltalk/utils/url_launcher.dart';
import 'package:concieltalk/pages/bootstrap/bootstrap_dialog.dart';
import 'audio_player.dart';
import 'cute_events.dart';
import 'html_message.dart';
import 'image_bubble.dart';
import 'map_bubble.dart';
import 'message_download_content.dart';
import 'sticker.dart';

class MessageContent extends StatelessWidget {
  final Event event;
  final Color textColor;
  final void Function(Event)? onInfoTab;

  const MessageContent(
    this.event, {
    this.onInfoTab,
    Key? key,
    required this.textColor,
  }) : super(key: key);

  void _verifyOrRequestKey(BuildContext context) async {
    final l10n = L10n.of(context)!;
    if (event.content['can_request_session'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            event.type == EventTypes.Encrypted
                ? l10n.needPantalaimonWarning
                : event.calcLocalizedBodyFallback(
                    MatrixLocals(l10n),
                  ),
          ),
        ),
      );
      return;
    }
    final client = Matrix.of(context).client;
    if (client.isUnknownSession && client.encryption!.crossSigning.enabled) {
      final success = await BootstrapDialog(
        client: Matrix.of(context).client,
      ).show(context);
      if (success != true) return;
    }
    event.requestKey();
    final sender = event.senderFromMemoryOrFallback;
    await showAdaptiveBottomSheet(
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          leading: CloseButton(onPressed: Navigator.of(context).pop),
          title: Text(
            l10n.whyIsThisMessageEncrypted,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Avatar(
                  mxContent: sender.avatarUrl,
                  name: sender.calcDisplayname(),
                ),
                title: Text(sender.calcDisplayname()),
                subtitle: Text(event.originServerTs.localizedTime(context)),
                trailing: const Icon(Icons.lock_outlined),
              ),
              const Divider(),
              Text(
                event.calcLocalizedBodyFallback(
                  MatrixLocals(l10n),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = AppConfig.messageFontSize * AppConfig.fontSizeFactor;
    final buttonTextColor =
        event.senderId == Matrix.of(context).client.userID ? textColor : null;
    switch (event.type) {
      case 'm.call.reject':
        return FutureBuilder<User?>(
          future: event.fetchSenderUser(),
          builder: (context, snapshot) {
            return snapshot.data == null
                ? Container()
                : GestureDetector(
                    child: Row(
                      children: [
                        const Text(
                          'Call declined  ',
                        ),
                        rotatedIcon(
                          ConcielIcons.phone,
                          color: personalColorScheme.tertiary,
                          angle: 135,
                        ),
                        Text(
                          '  - ${event.originServerTs.localizedTimeShort(context)}',
                        ),
                      ],
                    ),
                    onTap: () => onInfoTab!(event),
                  );
          },
        );
      case EventTypes.Message:
      case EventTypes.Encrypted:
      case EventTypes.Sticker:
        switch (event.messageType) {
          case MessageTypes.Image:
            return ImageBubble(
              event,
              width: 200,
              height: 150,
              fit: BoxFit.cover,
            );
          case MessageTypes.Sticker:
            if (event.redacted) continue textmessage;
            return Sticker(event);
          case CuteEventContent.eventType:
            return CuteContent(event);
          case MessageTypes.Audio:
            if (PlatformInfos.isMobile ||
                    PlatformInfos.isMacOS ||
                    PlatformInfos.isWeb
                // Disabled until https://github.com/bleonard252/just_audio_mpv/issues/3
                // is fixed
                //   || PlatformInfos.isLinux
                ) {
              return AudioPlayerWidget(
                event,
                color: textColor,
              );
            }
            return MessageDownloadContent(event, textColor);
          case MessageTypes.Video:
            if (PlatformInfos.isMobile || PlatformInfos.isWeb) {
              return EventVideoPlayer(event);
            }
            return MessageDownloadContent(event, textColor);
          case MessageTypes.File:
            return MessageDownloadContent(event, textColor);

          case MessageTypes.Text:
            switch (event.body) {
              case EventTypes.CallAnswer:
                return GestureDetector(
                  child: Row(
                    children: [
                      Text(
                        '${event.room.getLocalizedDisplayname()}  ',
                      ),
                      rotatedIcon(
                        ConcielIcons.phone,
                        color: Colors.green,
                      ),
                      Text(
                        '  - ${event.originServerTs.localizedTimeShort(context)}',
                      ),
                    ],
                  ),
                  onTap: () => onInfoTab!(event),
                );
              case EventTypes.CallReject:
                return FutureBuilder<User?>(
                  future: event.fetchSenderUser(),
                  builder: (context, snapshot) {
                    return snapshot.data == null
                        ? Container()
                        : GestureDetector(
                            child: Row(
                              children: [
                                const Text(
                                  'Call declined  ',
                                ),
                                rotatedIcon(
                                  ConcielIcons.phone,
                                  color: personalColorScheme.tertiary,
                                  angle: 135,
                                ),
                                Text(
                                  '  - ${event.originServerTs.localizedTimeShort(context)}',
                                ),
                              ],
                            ),
                            onTap: () => onInfoTab!(event),
                          );
                  },
                );
              case EventTypes.CallHangup:
                return GestureDetector(
                  child: Row(
                    children: [
                      Text(
                        'Missed call - ${event.room.getLocalizedDisplayname()}  ',
                      ),
                      rotatedIcon(
                        ConcielIcons.phone,
                        color: personalColorScheme.primary,
                        angle: 270,
                      ),
                      Text(
                        '  - ${event.originServerTs.localizedTimeShort(context)}',
                      ),
                    ],
                  ),
                  onTap: () => onInfoTab!(event),
                );
            }
            continue textmessage;
          case MessageTypes.Notice:
          case MessageTypes.Emote:
            if (AppConfig.renderHtml &&
                !event.redacted &&
                event.isRichMessage) {
              var html = event.formattedText;
              if (event.messageType == MessageTypes.Emote) {
                html = '* $html';
              }
              return HtmlMessage(
                html: html,
                textColor: textColor,
                room: event.room,
              );
            }
            // else we fall through to the normal message rendering
            continue textmessage;
          case MessageTypes.BadEncrypted:
          case EventTypes.Encrypted:
            return _ButtonContent(
              textColor: buttonTextColor,
              onPressed: () => _verifyOrRequestKey(context),
              icon: const Icon(Icons.lock_outline),
              label: L10n.of(context)!.encrypted,
            );
          case MessageTypes.Location:
            final geoUri =
                Uri.tryParse(event.content.tryGet<String>('geo_uri')!);
            if (geoUri != null && geoUri.scheme == 'geo') {
              final latlong = geoUri.path
                  .split(';')
                  .first
                  .split(',')
                  .map((s) => double.tryParse(s))
                  .toList();
              if (latlong.length == 2 &&
                  latlong.first != null &&
                  latlong.last != null) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MapBubble(
                      latitude: latlong.first!,
                      longitude: latlong.last!,
                      event: event,
                      height: 150,
                      width: 250,
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      icon: Icon(Icons.location_on_outlined, color: textColor),
                      onPressed: () {
                        VRouter.of(context).to(
                          'maps',
                          queryParameters: {
                            'address': geoUri.toString(),
                            'user': event.senderId,
                          },
                        );
                      },
                      label: Text(
                        L10n.of(context)!.openInMaps,
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  ],
                );
              }
            }
            continue textmessage;
          case MessageTypes.None:
          textmessage:
          default:
            if (event.redacted) {
              return FutureBuilder<User?>(
                future: event.redactedBecause?.fetchSenderUser(),
                builder: (context, snapshot) {
                  return _ButtonContent(
                    label: L10n.of(context)!.redactedAnEvent(
                      snapshot.data?.calcDisplayname() ??
                          event.senderFromMemoryOrFallback.calcDisplayname(),
                    ),
                    icon: const Icon(Icons.delete_outlined),
                    textColor: buttonTextColor,
                    onPressed: () => onInfoTab!(event),
                  );
                },
              );
            }
            final bigEmotes = event.onlyEmotes &&
                event.numberEmotes > 0 &&
                event.numberEmotes <= 10;
            return FutureBuilder<String>(
              future: event.calcLocalizedBody(
                MatrixLocals(L10n.of(context)!),
                hideReply: true,
              ),
              builder: (context, snapshot) {
                return Linkify(
                  text: snapshot.data ??
                      event.calcLocalizedBodyFallback(
                        MatrixLocals(L10n.of(context)!),
                        hideReply: true,
                      ),
                  style: TextStyle(
                    color: textColor,
                    fontSize: bigEmotes ? fontSize * 3 : fontSize,
                    decoration:
                        event.redacted ? TextDecoration.lineThrough : null,
                  ),
                  options: const LinkifyOptions(humanize: false),
                  linkStyle: TextStyle(
                    color: textColor.withAlpha(150),
                    fontSize: bigEmotes ? fontSize * 3 : fontSize,
                    decoration: TextDecoration.underline,
                    decorationColor: textColor.withAlpha(150),
                  ),
                  onOpen: (url) => UrlLauncher(context, url.url).launchUrl(),
                );
              },
            );
        }
      default:
        return FutureBuilder<User?>(
          future: event.fetchSenderUser(),
          builder: (context, snapshot) {
            return _ButtonContent(
              label: L10n.of(context)!.userSentUnknownEvent(
                snapshot.data?.calcDisplayname() ??
                    event.senderFromMemoryOrFallback.calcDisplayname(),
                'is this really the ... ${event.type}',
              ),
              icon: const Icon(Icons.info_outlined),
              textColor: buttonTextColor,
              onPressed: () => onInfoTab!(event),
            );
          },
        );
    }
  }
}

class _ButtonContent extends StatelessWidget {
  final void Function() onPressed;
  final String label;
  final Icon icon;
  final Color? textColor;

  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.textColor,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: personalColorScheme.background,
      ),
    );
  }
}
