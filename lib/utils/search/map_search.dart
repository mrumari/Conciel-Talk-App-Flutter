import 'dart:math';
import 'dart:ui' as ui;
import 'package:concieltalk/config/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

final places =
    GoogleMapsPlaces(apiKey: 'AIzaSyBYIEQnV1qraO7u-pinOVGQVCBpblEveWc');

Future<Set<Marker>> searcRestaurants(
  double latitude,
  double longitude,
  num zoom,
) async {
  final restaurant = await searchNearby(
    latitude,
    longitude,
    'restaurant',
    Icons.restaurant,
    zoom,
  );
  final cafe = await searchNearby(
    latitude,
    longitude,
    'cafe',
    Icons.local_cafe_outlined,
    zoom,
  );
  final bar = await searchNearby(
    latitude,
    longitude,
    'bar',
    Icons.local_bar_outlined,
    zoom,
  );
  final Set<Marker> combinedSet = Set<Marker>.from(restaurant)
    ..addAll(cafe)
    ..addAll(bar);
  return combinedSet;
}

Future<Set<Marker>> searchHotels(
  double latitude,
  double longitude,
  num zoom,
) async {
  return await searchNearby(
    latitude,
    longitude,
    'lodging',
    Icons.local_hotel_outlined,
    zoom,
  );
}

Future<Set<Marker>> searchTransport(
  double latitude,
  double longitude,
  num zoom,
) async {
  final transit = await searchNearby(
    latitude,
    longitude,
    'subway_station',
    Icons.subway_outlined,
    zoom,
  );
  final bus = await searchNearby(
    latitude,
    longitude,
    'bus_station',
    Icons.directions_bus_outlined,
    zoom,
  );
  final train = await searchNearby(
    latitude,
    longitude,
    'train_station',
    Icons.directions_train_outlined,
    zoom,
  );
  final lightrail = await searchNearby(
    latitude,
    longitude,
    'light_rail_station',
    Icons.tram_outlined,
    zoom,
  );
  final airport = await searchNearby(
    latitude,
    longitude,
    'airport',
    Icons.local_airport_outlined,
    zoom,
  );
  final Set<Marker> combinedSet = Set<Marker>.from(transit)
    ..addAll(bus)
    ..addAll(lightrail)
    ..addAll(airport)
    ..addAll(train);
  return combinedSet;
}

Future<Set<Marker>> searchHealth(
  double latitude,
  double longitude,
  num zoom,
) async {
  final hospital = await searchNearby(
    latitude,
    longitude,
    'hospital',
    Icons.emergency_outlined,
    zoom,
  );
  final pharmacy = await searchNearby(
    latitude,
    longitude,
    'pharmacy',
    Icons.local_pharmacy_outlined,
    zoom,
  );
  final Set<Marker> combinedSet = Set<Marker>.from(hospital)..addAll(pharmacy);
  return combinedSet;
}

Future<Set<Marker>> searchFitness(
  double latitude,
  double longitude,
  num zoom,
) async {
  return await searchNearby(
    latitude,
    longitude,
    'gym',
    Icons.fitness_center_outlined,
    zoom,
  );
}

Future<Set<Marker>> searchShops(
  double latitude,
  double longitude,
  num zoom,
) async {
  final store = await searchNearby(
    latitude,
    longitude,
    'store',
    Icons.store_outlined,
    zoom,
  );
  final mall = await searchNearby(
    latitude,
    longitude,
    'shopping_mall',
    Icons.local_mall_outlined,
    zoom,
  );
  final market = await searchNearby(
    latitude,
    longitude,
    'supermarket',
    Icons.storefront_outlined,
    zoom,
  );
  final Set<Marker> combinedSet = Set<Marker>.from(store)
    ..addAll(mall)
    ..addAll(market);
  return combinedSet;
}

Future<Set<Marker>> searchNearby(
  double latitude,
  double longitude,
  String type,
  IconData icon,
  num zoom, {
  String? keyword,
}) async {
  final location = Location(
    lat: latitude,
    lng: longitude,
  );
  final Set<Marker> markers = {};
  final metersPerPixel = 156543.03392 * cos(latitude * pi / 180) / pow(2, zoom);
  final searchRadius = 320 * metersPerPixel;

  final result = await places.searchNearbyWithRadius(
    location,
    searchRadius,
    type: type,
    keyword: keyword,
  );
  final thisIcon =
      await getMarkerIcon(personalColorScheme.background, icon, 40);
  if (result.status == 'OK') {
    // ignore: prefer_final_in_for_each
    for (var res in result.results) {
      markers.add(
        Marker(
          icon: thisIcon,
          markerId: MarkerId(res.placeId),
          position:
              LatLng(res.geometry!.location.lat, res.geometry!.location.lng),
          infoWindow: InfoWindow(title: res.name, snippet: res.vicinity),
        ),
      );
    }
  }
  return markers;
}

Future<BitmapDescriptor> getMarkerIcon(
  Color color,
  IconData icon,
  double size,
) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint = Paint()..color = Colors.blue;
  final double radius = size;

  canvas.drawCircle(Offset(radius, radius), radius, paint);

  final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  textPainter.text = TextSpan(
    text: String.fromCharCode(icon.codePoint),
    style: TextStyle(
      letterSpacing: 0.0,
      fontSize: 2.0 * radius - 10.0,
      fontFamily: icon.fontFamily,
      color: color,
    ),
  );

  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
  );

  final img = await pictureRecorder
      .endRecording()
      .toImage(radius.toInt() * 2, radius.toInt() * 2);
  final data = await img.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
}
