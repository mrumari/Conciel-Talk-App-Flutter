import 'dart:async';
import 'dart:convert';
import 'package:concieltalk/drawers/standard_drawer.dart';
import 'package:concieltalk/drawers/rotating_drawer.dart';

import 'package:concieltalk/utils/voip/phone_direct_call.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/utils/map_locations.dart' as locations;
import 'package:concieltalk/utils/ui/header_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vrouter/vrouter.dart';

class MapSearch extends StatefulWidget {
  final String? address;
  final String? contact;

  const MapSearch({Key? key, this.address, this.contact}) : super(key: key);

  @override
  MapSearchState createState() => MapSearchState();
}

class MapSearchState extends State<MapSearch>
    with SingleTickerProviderStateMixin {
  MapController mapController = MapController();
  late AnimationController _animController;
  late Animation<Color?> _animation;
  String? address;
  String? contact;
  String? route;
  List<Location>? location;
  late locations.Locations outletLocations;
  late MapOptions mapOptions;
  List<Map<String, Marker>> markerMap = [];
  List<Marker> markers = [];
  String overpassApiUrl = "https://overpass-api.de/api/interpreter";

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..repeat();
    _animation = ColorTween(
      begin: personalColorScheme.secondary,
      end: personalColorScheme.tertiary,
    ).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> queryOverpassApi(String query) async {
    final response = await http
        .get(Uri.parse("$overpassApiUrl?data=${Uri.encodeComponent(query)}"));
    if (response.statusCode == 200) {
      // parse the response and create markers for each location
      final data = jsonDecode(response.body);
      for (final element in data["elements"]) {
        final marker = Marker(
          width: 40.0,
          height: 40.0,
          point: LatLng(element["lat"], element["lon"]),
          builder: (ctx) => const Icon(Icons.location_on),
        );
        markers.add(marker);
      }
      setState(() {});
    } else {}
  }

  Future<List<Location>> getLocation() async {
    address = VRouter.of(context).queryParameters['address'] ?? widget.address;
    contact = VRouter.of(context).queryParameters['contact'] ?? widget.contact;
    double latitude;
    double longitude;
    Position position;
    final LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      if (mounted) {
        VRouter.of(context).to('/$route');
      }
      return [];
    } else {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    }
    latitude = position.latitude;
    longitude = position.longitude;

    if (address == '') {
      outletLocations = await locations.getMapMarkers();
      for (final outlet in outletLocations.outlets) {
        final marker = Marker(
          point: LatLng(outlet.lat, outlet.lng),
          builder: (ctx) => GestureDetector(
            child: Icon(
              Icons.location_pin,
              size: 36,
              color: personalColorScheme.tertiary.withAlpha(200),
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => SizedBox(
                  width: double.infinity,
                  height: 140.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        outlet.title,
                        style: TextStyle(
                          color: personalColorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(outlet.address),
                      const SizedBox(height: 10),
                      InkWell(
                        splashColor: personalColorScheme.secondary,
                        onTap: () {
                          openDialog(outlet);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              outlet.phone,
                              style: TextStyle(
                                color: personalColorScheme.primary,
                              ),
                            ),
                            Icon(
                              Icons.phone_android_sharp,
                              color: personalColorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
        markerMap.add({outlet.placeId: marker});
        markers.add(marker);
      }
      return [
        Location(
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
        ),
      ];
    } else {
      if (address!.substring(0, 3) == 'geo') {
        final List<String> parts = address!.split(':');
        final List<String> coords = parts[1].split(';')[0].split(',');
        latitude = double.parse(coords[0]);
        longitude = double.parse(coords[1]);
      } else if (address == 'home') {
      } else {
        final location = await locationFromAddress(address!);
        latitude = location.first.latitude;
        longitude = location.first.longitude;
      }
      final List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      final marker = Marker(
        width: 80,
        height: 80,
        point: LatLng(latitude, longitude),
        builder: (ctx) => GestureDetector(
          child: Icon(
            Icons.person_pin_circle_outlined,
            color: personalColorScheme.tertiary,
          ),
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => SizedBox(
                width: double.infinity,
                height: 140.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'My Location',
                      style: TextStyle(
                        color: personalColorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(placemarks.first.street!),
                    Text(placemarks.first.locality!),
                    Text(placemarks.first.postalCode!),
                    const SizedBox(height: 10),
                    InkWell(
                      splashColor: personalColorScheme.secondary,
                      onTap: () {},
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.phone_android_sharp,
                            color: personalColorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
      markers.add(marker);
      return [
        Location(
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    route = VRouter.of(context).queryParameters['route'] ?? 'none';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: DefaultHeaderWidget(
          route: route == 'none'
              ? '/localcontacts?contact=${VRouter.of(context).queryParameters['contact']}'
              : '/$route',
          onSearchPress: () {
            Scaffold.of(context).openEndDrawer();
          },
        ),
      ),
      body: FutureBuilder<List<Location>>(
        future: getLocation(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final locations = snapshot.data!;
            final lat = locations.first.latitude;
            final lng = locations.first.longitude;
            mapOptions = MapOptions(
              onPositionChanged: (position, hasGesture) {
                if (position.zoom! > 18.44) {
                  mapController.move(position.center!, 18.45);
                } else if (position.zoom! < 1.25) {
                  mapController.move(position.center!, 1.25);
                }
              },
              center: LatLng(lat, lng),
              zoom: 14,
              maxZoom: 19,
            );
            if (locations.isEmpty) {
              return CircularProgressIndicator(
                valueColor: _animation,
              );
            } else {
              return Stack(
                alignment: Alignment.center,
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: mapOptions,
                    nonRotatedChildren: [
                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            'OpenStreetMap',
                            onTap: () => launchUrl(
                              Uri.parse(
                                'https://openstreetmap.org/copyright',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'talk.conciel.concieltalk',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: markers,
                      ),
                    ],
                  ),
                  RotatingEndDrawer(
                    drawer: StandardDrawer(
                      showSplines: true,
                      context: context,
                      left: false,
                      borderColor: personalColorScheme.primary,
                      splineColor: personalColorScheme.surfaceTint,
                      icons: const [
                        Icons.fitness_center_outlined,
                        Icons.local_bar_outlined,
                        Icons.storefront_outlined,
                        Icons.restaurant_outlined,
                        Icons.train_outlined,
                        Icons.local_hospital_outlined,
                      ],
                      onTap: [
                        () {
                          const String query = """
[out:json][timeout:25];
{{geocodeArea:Zurich}}->.searchArea;
(
  node["sport"](area.searchArea);
  way["sport"](area.searchArea);
  relation["sport"](area.searchArea);
);
out body;
>;
out skel qt;
          """;
                          queryOverpassApi(query);
                        },
                        () {
                          const String query = """
[out:json][timeout:25];
{{geocodeArea:Zurich}}->.searchArea;
(
  node["amenity"="bar"](area.searchArea);
  way["amenity"="bar"](area.searchArea);
  relation["amenity"="bar"](area.searchArea);
);
out body;
>;
out skel qt;
          """;
                          queryOverpassApi(query);
                        },
                        () {
                          const String query = """
[out:json][timeout:25];
{{geocodeArea:Zurich}}->.searchArea;
(
  node["amenity"="shop"](area.searchArea);
  way["amenity"="shop"](area.searchArea);
  relation["amenity"="shop"](area.searchArea);
);
out body;
>;
out skel qt;
          """;
                          queryOverpassApi(query);
                        },
                        () {
                          const String query = """
[out:json][timeout:25];
{{geocodeArea:Zurich}}->.searchArea;
(
  // query part for: “amenity=restaurant”
  node["amenity"="restaurant"](area.searchArea);
  way["amenity"="restaurant"](area.searchArea);
  relation["amenity"="restaurant"](area.searchArea);
);
out body;
>;
out skel qt;
          """;
                          queryOverpassApi(query);
                        },
                        () {
                          const String query = """
            [out:json][timeout:25];
{{geocodeArea:Zurich}}->.searchArea;
(
  node["amenity"="shelter"]["shelter_type"="public_transport"](area.searchArea);
  way["amenity"="shelter"]["shelter_type"="public_transport"](area.searchArea);
  relation["amenity"="shelter"]["shelter_type"="public_transport"](area.searchArea);
  node["railway"="station"](area.searchArea);
  way["railway"="station"](area.searchArea);
  relation["railway"="station"](area.searchArea);
);
out body;
>;
out skel qt;
          """;
                          queryOverpassApi(query);
                        },
                        () {
                          const String query = """
[out:json][timeout:25];
{{geocodeArea:Zurich}}->.searchArea;
(
  node["amenity"="hospital"](area.searchArea);
  way["amenity"="hospital"](area.searchArea);
  relation["amenity"="hospital"](area.searchArea);
  node["amenity"="clinic"](area.searchArea);
  way["amenity"="clinic"](area.searchArea);
  relation["amenity"="clinic"](area.searchArea);
  node["amenity"="pharmacy"](area.searchArea);
  way["amenity"="pharmacy"](area.searchArea);
  relation["amenity"="pharmacy"](area.searchArea);
);
out body;
>;
out skel qt;
          """;
                          queryOverpassApi(query);
                        },
                      ],
                    ),
                  ),
                ],
              );
            }
          } else {
            return const Center(
              child: Text('Location data not available'),
            );
          }
        },
      ),
    );
  }

  Future<void> openDialog(outlet) async {
    switch (await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return SimpleDialog(
          surfaceTintColor: personalColorScheme.onSurfaceVariant,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(color: personalColorScheme.primary),
                "Call",
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          children: [
            Text(
              outlet.title,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Text(
              outlet.phone,
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 0);
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 1);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: personalColorScheme.secondary,
                      ),
                      'YES',
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    )) {
      case 0:
        return;
      case 1:
        callPhoneNumber(outlet.phone);
    }
  }
}
