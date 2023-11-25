import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/utils/ui/conciel_ring.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';

import 'package:concieltalk/utils/localized_exception_extension.dart';
import 'package:concieltalk/utils/size_string.dart';
import 'package:concieltalk/utils/resize_image.dart';

class SendFileDialog extends StatefulWidget {
  final Room room;
  final List<MatrixFile> files;

  const SendFileDialog({
    required this.room,
    required this.files,
    Key? key,
  }) : super(key: key);

  @override
  SendFileDialogState createState() => SendFileDialogState();
}

class SendFileDialogState extends State<SendFileDialog> {
  bool origImage = false;
  bool _isLoading = false;

  /// Images smaller than 20kb don't need compression.
  static const int minSizeToCompress = 20 * 1024;

  Future<void> _send() async {
    setState(() {
      _isLoading = true;
    });
    for (var file in widget.files) {
      MatrixImageFile? thumbnail;
      if (file is MatrixVideoFile && file.bytes.length > minSizeToCompress) {
        await showFutureLoadingDialog(
          context: context,
          future: () async {
            file = await file.resizeVideo();
            thumbnail = await file.getVideoThumbnail();
          },
        );
      }
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      await widget.room
          .sendFileEvent(
        file,
        thumbnail: thumbnail,
        shrinkImageMaxDimension: origImage ? null : 1600,
      )
          .catchError((e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text((e as Object).toLocalizedString(context))),
        );
        return null;
      });
    }
    Navigator.of(context, rootNavigator: false).pop();
    setState(() {
      _isLoading = false;
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    var sendStr = L10n.of(context)!.sendFile;
    final bool allFilesAreImages =
        widget.files.every((file) => file is MatrixImageFile);
    final sizeString = widget.files
        .fold<double>(0, (p, file) => p + file.bytes.length)
        .sizeString;
    final fileName = widget.files.length == 1
        ? widget.files.single.name
        : L10n.of(context)!.countFiles(widget.files.length.toString());

    if (allFilesAreImages) {
      sendStr = L10n.of(context)!.sendImage;
    } else if (widget.files.every((file) => file is MatrixAudioFile)) {
      sendStr = L10n.of(context)!.sendAudio;
    } else if (widget.files.every((file) => file is MatrixVideoFile)) {
      sendStr = L10n.of(context)!.sendVideo;
    }
    Widget contentWidget;
    if (allFilesAreImages) {
      contentWidget = Stack(
        children: [
          if (!_isLoading)
            ListView.builder(
              itemCount: widget.files.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Image.memory(
                        widget.files[index].bytes,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: origImage,
                          onChanged: (v) =>
                              setState(() => origImage = v ?? false),
                        ),
                        Flexible(
                          child: InkWell(
                            onTap: () => setState(() => origImage = !origImage),
                            child: Text(
                              '${L10n.of(context)!.sendOriginal} ($sizeString)',
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          if (_isLoading)
            Align(
              alignment: Alignment.center,
              child: ConcielRingDraw(
                animDurationMillis: 500,
                barWidth: 25,
                strokeCap: StrokeCap.butt,
                dashWidth: 0.5,
                dashGap: 1,
                startAngle: 0,
                sweepAngle: 360,
                width: 100,
                height: 100,
                progress: 100,
                interactive: false,
                trackColor: personalColorScheme.surfaceTint,
                progressColor: personalColorScheme.primary,
              ),
            ),
        ],
      );
    } else {
      contentWidget = Text(
        '$fileName ($sizeString)',
        overflow: TextOverflow.clip,
      );
    }
    return AlertDialog(
      title: Text(sendStr),
      content: contentWidget,
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // just close the dialog
            Navigator.of(context, rootNavigator: false).pop();
          },
          child: Text(L10n.of(context)!.cancel),
        ),
        TextButton(
          onPressed: _send,
          child: Text(L10n.of(context)!.send),
        ),
      ],
    );
  }
}