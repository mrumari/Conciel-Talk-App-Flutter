import 'dart:io';

import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/utils/ui/conciel_ring.dart';
import 'package:flutter/material.dart';
import 'package:file_manager/file_manager.dart';
import 'package:matrix/matrix.dart';

class FileDrawer extends StatefulWidget {
  final FileManagerController fileController;
  const FileDrawer({Key? key, required this.fileController}) : super(key: key);
  @override
  State<FileDrawer> createState() => _FileDrawerState();
}

class _FileDrawerState extends State<FileDrawer> {
  Color outerRingColor = personalColorScheme.primaryContainer;
  Color innerRingColor = primaryColorOff;
  _pulseOuterRing() {
    setState(() {
      if (outerRingColor == personalColorScheme.primary) {
        outerRingColor = personalColorScheme.primaryContainer;
        innerRingColor = primaryColorOff;
      } else {
        outerRingColor = personalColorScheme.primary;
        innerRingColor = personalColorScheme.primary;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final FileManagerController fileControl = widget.fileController;
    return SizedBox(
      width: MediaQuery.sizeOf(context).width / 2.8,
      child: ClipRRect(
        child: Stack(
          children: [
            OverflowBox(
              alignment: Alignment.centerLeft,
              maxWidth: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ConcielRingDraw(
                  width: 275,
                  height: 275,
                  progress: 0,
                  barWidth: 35,
                  startAngle: 0,
                  sweepAngle: 180,
                  strokeCap: StrokeCap.butt,
                  trackColor: outerRingColor,
                  progressGradientColors: [
                    personalColorScheme.primary,
                    personalColorScheme.secondary,
                    personalColorScheme.primary,
                  ],
                  dashWidth: 0.5,
                  dashGap: 1,
                  animDurationMillis: 1000,
                  animation: true,
                ),
              ),
            ),
            OverflowBox(
              alignment: Alignment.centerLeft,
              maxWidth: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 60),
                child: ConcielRingDraw(
                  width: 210,
                  height: 210,
                  progress: 0,
                  barWidth: 4,
                  startAngle: 12.5,
                  sweepAngle: 270,
                  strokeCap: StrokeCap.butt,
                  trackColor: innerRingColor,
                  progressGradientColors: [
                    personalColorScheme.primary,
                    personalColorScheme.secondary,
                    personalColorScheme.primary,
                  ],
                  dashWidth: 52.5,
                  dashGap: 1,
                  animDurationMillis: 1000,
                  animation: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 85),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  IconButton(
                    onPressed: () {
                      _pulseOuterRing();
                      sort(context, fileControl);
                    },
                    icon: const Icon(Icons.sort_rounded),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
//                  IconButton(
//                      icon: const Icon(Icons.arrow_upward),
//                      onPressed: () async {
//                        await fileControl.goToParentDirectory();
//                      }),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: IconButton(
                    onPressed: () => createFolder(context, fileControl),
                    icon: const Icon(Icons.create_new_folder_outlined),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget subtitle(FileSystemEntity entity) {
    return FutureBuilder<FileStat>(
      future: entity.stat(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (entity is File) {
            final int size = snapshot.data!.size;

            return Text(
              FileManager.formatBytes(size),
            );
          }
          return Text(
            "${snapshot.data!.modified}".substring(0, 10),
          );
        } else {
          return const Text("");
        }
      },
    );
  }

  Future<void> selectStorage(
    BuildContext context,
    FileManagerController fileControl,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: FutureBuilder<List<Directory>>(
          future: FileManager.getStorageList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<FileSystemEntity> storageList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: storageList
                      .map(
                        (e) => ListTile(
                          title: Text(
                            FileManager.basename(e),
                          ),
                          onTap: () {
                            fileControl.openDirectory(e);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
                ),
              );
            }
            return const Dialog(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  sort(BuildContext context, FileManagerController fileControl) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Name"),
                onTap: () {
                  fileControl.sortBy(SortBy.name);
                  _pulseOuterRing();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Size"),
                onTap: () {
                  fileControl.sortBy(SortBy.size);
                  _pulseOuterRing();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Date"),
                onTap: () {
                  fileControl.sortBy(SortBy.date);
                  _pulseOuterRing();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Type"),
                onTap: () {
                  fileControl.sortBy(SortBy.type);
                  _pulseOuterRing();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  createFolder(BuildContext context, FileManagerController fileControl) async {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController folderName = TextEditingController();
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: TextField(
                    controller: folderName,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Create Folder
                      await FileManager.createFolder(
                        fileControl.getCurrentPath,
                        folderName.text,
                      );
                      // Open Created Folder
                      fileControl.setCurrentPath =
                          "${fileControl.getCurrentPath}/${folderName.text}";
                    } catch (e) {
                      Logs().e('Folder create error: $e');
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Create Folder'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
