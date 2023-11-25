import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:matrix/matrix.dart';

import 'package:concieltalk/pages/chat/events/map_bubble.dart';
import 'package:concieltalk/utils/platform_infos.dart';

class SendLocationDialog extends StatefulWidget {
  final Room room;

  const SendLocationDialog({
    required this.room,
    Key? key,
  }) : super(key: key);

  @override
  SendLocationDialogState createState() => SendLocationDialogState();
}

class SendLocationDialogState extends State<SendLocationDialog> {
  bool disabled = false;
  bool denied = false;
  bool isSending = false;
  Position? position;
  Object? error;

  @override
  void initState() {
    super.initState();
    requestLocation();
  }

  Future<void> requestLocation() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      setState(() => disabled = true);
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => denied = true);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => denied = true);
      return;
    }
    try {
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 30),
        );
      } on TimeoutException {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 30),
        );
      }
      setState(() => this.position = position);
    } catch (e) {
      setState(() => error = e);
    }
  }

  void sendAction() async {
    setState(() => isSending = true);
    final body =
        'https://www.openstreetmap.org/?mlat=${position!.latitude}&mlon=${position!.longitude}#map=16/${position!.latitude}/${position!.longitude}';
    final uri =
        'geo:${position!.latitude},${position!.longitude};u=${position!.accuracy}';
    await showFutureLoadingDialog(
      context: context,
      future: () => widget.room.sendLocation(body, uri),
    );
    Navigator.of(context, rootNavigator: false).pop();
  }

  @override
  Widget build(BuildContext context) {
    Widget contentWidget;
    if (position != null) {
      contentWidget = MapBubble(
        latitude: position!.latitude,
        longitude: position!.longitude,
      );
    } else if (disabled) {
      contentWidget = Text(L10n.of(context)!.locationDisabledNotice);
    } else if (denied) {
      contentWidget = Text(L10n.of(context)!.locationPermissionDeniedNotice);
    } else if (error != null) {
      contentWidget =
          Text(L10n.of(context)!.errorObtainingLocation(error.toString()));
    } else {
      contentWidget = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(),
          const SizedBox(width: 12),
          Text(L10n.of(context)!.obtainingLocation),
        ],
      );
    }
    if (PlatformInfos.isCupertinoStyle) {
      return CupertinoAlertDialog(
        title: Text(L10n.of(context)!.shareLocation),
        content: contentWidget,
        actions: [
          CupertinoDialogAction(
            onPressed: Navigator.of(context, rootNavigator: false).pop,
            child: Text(L10n.of(context)!.cancel),
          ),
          CupertinoDialogAction(
            onPressed: isSending ? null : sendAction,
            child: Text(L10n.of(context)!.send),
          ),
        ],
      );
    }
    return AlertDialog(
      title: Text(L10n.of(context)!.shareLocation),
      content: contentWidget,
      actions: [
        TextButton(
          onPressed: Navigator.of(context, rootNavigator: false).pop,
          child: Text(L10n.of(context)!.cancel),
        ),
        if (position != null)
          TextButton(
            onPressed: isSending ? null : sendAction,
            child: Text(L10n.of(context)!.send),
          ),
      ],
    );
  }
}

/*

TO BE IMPLEMENTED - FUTURE - LIVE LOCATION FOR MAPS

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: MapSample(),
      ),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late latLng.LatLng _center;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _getUserLocation() async {
    var location = new Location();
    location.onLocationChanged.listen((l) {
      setState(() {
        _center = latLng.LatLng(l.latitude!, l.longitude!);
        _mapController.move(_center, 15.0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: _center,
        zoom: 13.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c']
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: _center,
              builder: (ctx) =>
              Container(
                child: Icon(Icons.location_on),
              ),
            ),
          ],
        ),
      ],
    );
  }
}



*/