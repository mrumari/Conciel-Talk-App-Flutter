import 'dart:io';

import 'package:concieltalk/pages/chat_list/chat_share_view.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matrix/matrix.dart';
import 'package:record/record.dart';
import 'package:concieltalk/pages/chat/recording_dialog.dart';
import 'package:concieltalk/utils/adaptive_bottom_sheet.dart';
import 'package:concieltalk/utils/platform_infos.dart';
import 'package:vrouter/vrouter.dart';

import 'package:concieltalk/utils/localized_exception_extension.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/matrix_file_extension.dart';
import 'send_file_dialog.dart';
import 'send_location_dialog.dart';
import 'sticker_picker_dialog.dart';

void sendFileAction(
  BuildContext context, [
  Room? room,
]) async {
  Room? selectedRoom;
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    withData: room == null ? false : true,
  );
  if (result == null || result.files.isEmpty) return;
  if (room == null) {
    final List<String?> filePaths =
        result.files.map((file) => file.path).toList();
    VRouter.of(context).to(
      'fileshare',
      queryParameters: {'files': filePaths.join(',')},
    );
    return;
  } else {
    selectedRoom = room;
  }
  await showDialog(
    context: context,
    useRootNavigator: false,
    builder: (c) => SendFileDialog(
      files: result.files
          .map(
            (xfile) => MatrixFile(
              bytes: xfile.bytes!,
              name: xfile.name,
            ).detectFileType,
          )
          .toList(),
      room: selectedRoom!,
    ),
  );
  VRouter.of(context).toSegments(
    [
      'rooms',
      selectedRoom.id,
    ],
    queryParameters: {
      'share': 'no-file',
    },
  );
}

Future<Room?> roomSelect(
  BuildContext context,
) async {
  return await showDialog<Room>(
    context: context,
    builder: (context) {
      return const ChatShare();
    },
  );
}

void sendImageAction(BuildContext context, Room room) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
    allowMultiple: true,
  );
  if (result == null || result.files.isEmpty) return;
  await showDialog(
    context: context,
    useRootNavigator: false,
    builder: (c) => SendFileDialog(
      files: result.files
          .map(
            (xfile) => MatrixFile(
              bytes: xfile.bytes!,
              name: xfile.name,
            ).detectFileType,
          )
          .toList(),
      room: room,
    ),
  );
}

void openCameraAction(BuildContext context, Room room) async {
  // Make sure the textfield is unfocused before opening the camera
  FocusScope.of(context).requestFocus(FocusNode());
  final file = await ImagePicker().pickImage(source: ImageSource.camera);
  if (file == null) return;
  final bytes = await file.readAsBytes();
  await showDialog(
    context: context,
    useRootNavigator: false,
    builder: (c) => SendFileDialog(
      files: [
        MatrixImageFile(
          bytes: bytes,
          name: file.path,
        ),
      ],
      room: room,
    ),
  );
}

void openVideoCameraAction(BuildContext context, Room room) async {
  // Make sure the textfield is unfocused before opening the camera
  FocusScope.of(context).requestFocus(FocusNode());
  final file = await ImagePicker().pickVideo(source: ImageSource.camera);
  if (file == null) return;
  final bytes = await file.readAsBytes();
  await showDialog(
    context: context,
    useRootNavigator: false,
    builder: (c) => SendFileDialog(
      files: [
        MatrixVideoFile(
          bytes: bytes,
          name: file.path,
        ),
      ],
      room: room,
    ),
  );
}

void sendStickerAction(BuildContext context, Room room) async {
  final sticker = await showAdaptiveBottomSheet<ImagePackImageContent>(
    context: context,
    builder: (c) => StickerPickerDialog(room: room),
  );
  if (sticker == null) return;
  final eventContent = <String, dynamic>{
    'body': sticker.body,
    if (sticker.info != null) 'info': sticker.info,
    'url': sticker.url.toString(),
  };
  // send the sticker
  await room.sendEvent(
    eventContent,
    type: EventTypes.Sticker,
  );
}

void voiceMessageAction(
  BuildContext context,
  Room room,
  Event replyEvent,
  VoidCallback onDone,
) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  if (PlatformInfos.isAndroid) {
    final info = await DeviceInfoPlugin().androidInfo;
    if (info.version.sdkInt < 19) {
      showOkAlertDialog(
        context: context,
        title: L10n.of(context)!.unsupportedAndroidVersion,
        message: L10n.of(context)!.unsupportedAndroidVersionLong,
        okLabel: L10n.of(context)!.close,
      );
      return;
    }
  }

  if (await Record().hasPermission() == false) return;
  final result = await showDialog<RecordingResult>(
    context: context,
    useRootNavigator: false,
    barrierDismissible: false,
    builder: (c) => const RecordingDialog(),
  );
  if (result == null) return;
  final audioFile = File(result.path);
  final file = MatrixAudioFile(
    bytes: audioFile.readAsBytesSync(),
    name: audioFile.path,
  );
  await room.sendFileEvent(
    file,
    inReplyTo: replyEvent,
    extraContent: {
      'info': {
        ...file.info,
        'duration': result.duration,
      },
      'org.matrix.msc3245.voice': {},
      'org.matrix.msc1767.audio': {
        'duration': result.duration,
        'waveform': result.waveform,
      },
    },
  ).catchError((e) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          (e as Object).toLocalizedString(context),
        ),
      ),
    );
    return null;
  });
  onDone();
}

void sendLocationAction(BuildContext context, Room room) async {
  await showDialog(
    context: context,
    useRootNavigator: false,
    builder: (c) => SendLocationDialog(room: room),
  );
}
