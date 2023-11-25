import 'package:concieltalk/widgets/avatar.dart';
import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:matrix/matrix.dart';

class MapBubble extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final double width;
  final double height;
  final double radius;
  final Event? event;
  const MapBubble({
    required this.latitude,
    required this.longitude,
    this.zoom = 14.0,
    this.width = 400,
    this.height = 400,
    this.radius = 10.0,
    Key? key,
    this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        constraints: BoxConstraints.loose(Size(width, height)),
        child: AspectRatio(
          aspectRatio: width / height,
          child: Stack(
            children: <Widget>[
              FlutterMap(
                options: MapOptions(
                  center: LatLng(latitude, longitude),
                  zoom: zoom,
                  rotationWinGestures: MultiFingerGesture.all,
                  interactiveFlags: InteractiveFlag.pinchZoom,
                ),
                children: [
                  TileLayer(
                    maxZoom: 20,
                    minZoom: 0,
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    rotate: true,
                    markers: [
                      Marker(
                        point: LatLng(latitude, longitude),
                        width: 30,
                        height: 30,
                        builder: (_) => Transform.translate(
                          // No idea why the offset has to be like this, instead of -15
                          // It has been determined by trying out, though, that this yields
                          // the tip of the location pin to be static when zooming.
                          // Might have to do with psychological perception of where the tip exactly is
                          offset: const Offset(0, -12.5),
                          child: event == null
                              ? const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 30,
                                )
                              : FutureBuilder<User?>(
                                  future: event!.fetchSenderUser(),
                                  builder: (context, snapshot) {
                                    bool hasdata = true;
                                    if (snapshot.data == null) hasdata = false;
                                    return hasdata
                                        ? Avatar(
                                            mxContent: snapshot.data!.avatarUrl,
                                            name: snapshot.data!
                                                .calcDisplayname(),
                                          )
                                        : Container();
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                alignment: Alignment.bottomRight,
                child: Text(
                  ' © OpenStreetMap contributors ',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    backgroundColor:
                        Theme.of(context).appBarTheme.backgroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
