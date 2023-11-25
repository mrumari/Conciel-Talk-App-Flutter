import 'dart:io';
import 'dart:typed_data';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mime/mime.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thumbnailer/thumbnailer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:vrouter/vrouter.dart';

class FilePage extends StatefulWidget {
  const FilePage({Key? key}) : super(key: key);

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  final FileManagerController controller = FileManagerController();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.request().isGranted) {
        // Permission already granted
      } else {
        // Permission not yet granted
        // ignore: unused_local_variable
        final extstatus = await Permission.manageExternalStorage.request();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ControlBackButton(
      controller: controller,
      child: Scaffold(
        drawerScrimColor: Colors.transparent,
        appBar: appBar(context),
        body: SafeArea(
          child: Stack(
            children: [
              FileManager(
                loadingScreen: const CircularProgressIndicator(),
                controller: controller,
                builder: (context, snapshot) {
                  final List<FileSystemEntity> entities = snapshot;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0.5,
                      vertical: 0,
                    ),
                    itemCount: entities.length,
                    itemBuilder: (context, index) {
                      final FileSystemEntity entity = entities[index];
                      final String mimeType = lookupMimeType(entity.path) ??
                          'application/octet-stream';
                      return Card(
                        child: ListTile(
                          dense: true,
                          visualDensity:
                              const VisualDensity(horizontal: 1, vertical: -3),
                          leading: FileManager.isFile(entity)
                              ? mimeType.contains('video')
                                  ? VideoThumb(videoPath: entity.path)
                                  : Thumbnail(
                                      dataResolver: () async {
                                        if (mimeType ==
                                            'application/octet-stream') {
                                          return Uint8List(0);
                                        } else {
                                          return (await (entity as File)
                                              .readAsBytes());
                                        }
                                      },
                                      mimeType: mimeType,
                                      widgetSize: 36,
                                      decoration: WidgetDecoration(
                                        backgroundColor:
                                            personalColorScheme.surfaceTint,
                                      ),
                                    )
                              : const Icon(Icons.folder_outlined),
                          title: Text(
                            FileManager.basename(
                              entity,
                              showFileExtension: true,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: subtitle(entity),
                          onTap: () async {
                            if (FileManager.isDirectory(entity)) {
                              controller.openDirectory(entity);
                            } else {
                              VRouter.of(context).to(
                                '/rooms',
                                queryParameters: {'share': entity.path},
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
/*              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Center(child: FileDrawer(fileController: controller))
                ],
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  bool isMedia(String? mimeType) {
/*                        if (FileManager.isDirectory(entity)) {
                          controller.openDirectory(entity);
                          // delete a folder
                          // await entity.delete(recursive: true);
                          // rename a folder
                          // await entity.rename("newPath");
                          // Check weather folder exists
                          // entity.exists();
                          // get date of file
                          // DateTime date = (await entity.stat()).modified;
                        } else {
                          // delete a file
                          // await entity.delete();
                          // rename a file
                          // await entity.rename("newPath");
                          // Check whether file exists
                          // entity.exists();
                          // get date of file
                          // DateTime date = (await entity.stat()).modified;
                          // get the size of the file
                          // int size = (await entity.stat()).size;
                        }
*/

    if (mimeType == null) {
      return false;
    }
    return mimeType.startsWith('image/') || mimeType.startsWith('video/');
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      toolbarHeight: ScreenUtil().statusBarHeight + 32.h,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 2),
                child: InkWell(
                  child: const Icon(ConcielIcons.back),
                  onLongPress: () {
                    Navigator.pop(context);
                  },
                  onTap: () async {
                    await controller.isRootDirectory()
                        ? Navigator.pop(context)
                        : await controller.goToParentDirectory();
                  },
                ),
              ),
              IconButton(
                padding: const EdgeInsets.only(left: 20),
                onPressed: () {},
                icon: Image.asset(
                  'assets/conciel-icon.png',
                  width: 36,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(ConcielIcons.search),
              ),
            ],
          ),
          ValueListenableBuilder<String>(
            valueListenable: controller.titleNotifier,
            builder: (context, title, _) => Align(
              alignment: Alignment.centerLeft,
              child: title == '0' || title == ''
                  ? const Text('/')
                  : Text('../$title'),
            ),
          ),
        ],
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
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(FileManager.formatBytes(size)),
                Text('.${(FileManager.basename(entity)).split('.').last}'),
              ],
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

  Future<void> selectStorage(BuildContext context) async {
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
                            controller.openDirectory(e);
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

  sort(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Name"),
                onTap: () {
                  controller.sortBy(SortBy.name);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Size"),
                onTap: () {
                  controller.sortBy(SortBy.size);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Date"),
                onTap: () {
                  controller.sortBy(SortBy.date);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("type"),
                onTap: () {
                  controller.sortBy(SortBy.type);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  createFolder(BuildContext context) async {
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
                        controller.getCurrentPath,
                        folderName.text,
                      );
                      // Open Created Folder
                      controller.setCurrentPath =
                          "${controller.getCurrentPath}/${folderName.text}";
                    } catch (e) {
                      return;
                    }
//                    Navigator.pop(context);
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

class VideoThumb extends StatelessWidget {
  final String videoPath;

  const VideoThumb({super.key, required this.videoPath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 36,
        maxHeight: 36,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Icon(Icons.video_file);
        } else if (snapshot.hasData) {
          return Image.memory(snapshot.data!);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
