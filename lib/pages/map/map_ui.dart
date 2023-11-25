import 'dart:async';

import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/drawers/rotating_drawer.dart';
import 'package:concieltalk/drawers/standard_drawer.dart';
import 'package:concieltalk/pages/map/map_page.dart';
import 'package:concieltalk/utils/search/map_search.dart';
import 'package:concieltalk/utils/ui/header_footer.dart';
import 'package:concieltalk/utils/voip/phone_direct_call.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vrouter/vrouter.dart';

final LatLngBounds mapBounds = LatLngBounds(
  southwest: const LatLng(-34.022631, 150.620685),
  northeast: const LatLng(-33.571835, 151.325952),
);

Future<Position> getCurrentLocation() async {
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

class MapUiPage extends MapPage {
  const MapUiPage({Key? key})
      : super(const Icon(Icons.map_outlined), 'Map UI', key: key);

  @override
  Widget build(BuildContext context) {
    final type = VRouter.of(context).queryParameters['type'] ?? '';
    final place = VRouter.of(context).queryParameters['place'] ?? '';
    final time = VRouter.of(context).queryParameters['time'] ?? '';
    final thisRoute = VRouter.of(context).path;
    final splitRoute = thisRoute.split('/');
    String resultRoute;
    if (splitRoute.length > 1) {
      resultRoute = splitRoute[1];
    } else {
      resultRoute = thisRoute.substring(1);
    }

    return VWidgetGuard(
      onSystemPop: (vRedirector) async {
        if (resultRoute == 'biometrics') {
          vRedirector.stopRedirection();
        } else {
          vRedirector.pop();
        }
      },
      child: Scaffold(
        drawerScrimColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          toolbarHeight: ScreenUtil().statusBarHeight + 32.h,
          foregroundColor: personalColorScheme.outline,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.6, 1.0],
                colors: [
                  personalColorScheme.background,
                  personalColorScheme.background,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          actions: <Widget>[Container()],
          clipBehavior: Clip.none,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DefaultHeaderWidget(
                route: '/$resultRoute',
                showSearch: false,
              ),
            ],
          ),
        ),
        body: MapUiBody(
          type: type,
          place: place,
          time: time,
        ),
      ),
    );
  }
}

class MapUiBody extends StatefulWidget {
  final String? type;
  final String? place;
  final String? time;
  const MapUiBody({
    this.type,
    this.place,
    this.time,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => MapUiBodyState();
}

class MapUiBodyState extends State<MapUiBody> {
  MapUiBodyState();
  late CameraPosition _position;
  Set<Marker> _markers = {};
  bool _isMapCreated = false;
  /*
  final bool _isMoving = false;
  bool _compassEnabled = true;
  bool _mapToolbarEnabled = true;
  CameraTargetBounds _cameraTargetBounds = CameraTargetBounds.unbounded;
  MinMaxZoomPreference _minMaxZoomPreference = MinMaxZoomPreference.unbounded;
  MapType _mapType = MapType.normal;
  bool _rotateGesturesEnabled = true;
  bool _scrollGesturesEnabled = true;
  bool _tiltGesturesEnabled = true;
  bool _zoomControlsEnabled = false;
  bool _zoomGesturesEnabled = true;
  bool _indoorViewEnabled = true;
  bool _myLocationEnabled = true;
  bool _myTrafficEnabled = false;
  bool _myLocationButtonEnabled = true;
  bool _nightMode = false;
  */
  late GoogleMapController mapController;
  late Future<Position> _myPosition;
  late Position _startPosition;

  @override
  void initState() {
    super.initState();
    _myPosition = getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /*
  Widget _compassToggler() {
    return TextButton(
      child: Text('${_compassEnabled ? 'disable' : 'enable'} compass'),
      onPressed: () {
        setState(() {
          _compassEnabled = !_compassEnabled;
        });
      },
    );
  }

  Widget _mapToolbarToggler() {
    return TextButton(
      child: Text('${_mapToolbarEnabled ? 'disable' : 'enable'} map toolbar'),
      onPressed: () {
        setState(() {
          _mapToolbarEnabled = !_mapToolbarEnabled;
        });
      },
    );
  }

  Widget _latLngBoundsToggler() {
    return TextButton(
      child: Text(
        _cameraTargetBounds.bounds == null
            ? 'bound camera target'
            : 'release camera target',
      ),
      onPressed: () {
        setState(() {
          _cameraTargetBounds = _cameraTargetBounds.bounds == null
              ? CameraTargetBounds(mapBounds)
              : CameraTargetBounds.unbounded;
        });
      },
    );
  }

  Widget _zoomBoundsToggler() {
    return TextButton(
      child: Text(
        _minMaxZoomPreference.minZoom == null ? 'bound zoom' : 'release zoom',
      ),
      onPressed: () {
        setState(() {
          _minMaxZoomPreference = _minMaxZoomPreference.minZoom == null
              ? const MinMaxZoomPreference(12.0, 16.0)
              : MinMaxZoomPreference.unbounded;
        });
      },
    );
  }

  Widget _mapTypeCycler() {
    final MapType nextType =
        MapType.values[(_mapType.index + 1) % MapType.values.length];
    return TextButton(
      child: Text('change map type to $nextType'),
      onPressed: () {
        setState(() {
          _mapType = nextType;
        });
      },
    );
  }

  Widget _rotateToggler() {
    return TextButton(
      child: Text('${_rotateGesturesEnabled ? 'disable' : 'enable'} rotate'),
      onPressed: () {
        setState(() {
          _rotateGesturesEnabled = !_rotateGesturesEnabled;
        });
      },
    );
  }

  Widget _scrollToggler() {
    return TextButton(
      child: Text('${_scrollGesturesEnabled ? 'disable' : 'enable'} scroll'),
      onPressed: () {
        setState(() {
          _scrollGesturesEnabled = !_scrollGesturesEnabled;
        });
      },
    );
  }

  Widget _tiltToggler() {
    return TextButton(
      child: Text('${_tiltGesturesEnabled ? 'disable' : 'enable'} tilt'),
      onPressed: () {
        setState(() {
          _tiltGesturesEnabled = !_tiltGesturesEnabled;
        });
      },
    );
  }

  Widget _zoomToggler() {
    return TextButton(
      child: Text('${_zoomGesturesEnabled ? 'disable' : 'enable'} zoom'),
      onPressed: () {
        setState(() {
          _zoomGesturesEnabled = !_zoomGesturesEnabled;
        });
      },
    );
  }

  Widget _zoomControlsToggler() {
    return TextButton(
      child:
          Text('${_zoomControlsEnabled ? 'disable' : 'enable'} zoom controls'),
      onPressed: () {
        setState(() {
          _zoomControlsEnabled = !_zoomControlsEnabled;
        });
      },
    );
  }

  Widget _indoorViewToggler() {
    return TextButton(
      child: Text('${_indoorViewEnabled ? 'disable' : 'enable'} indoor'),
      onPressed: () {
        setState(() {
          _indoorViewEnabled = !_indoorViewEnabled;
        });
      },
    );
  }

  Widget _myLocationToggler() {
    return TextButton(
      child: Text(
        '${_myLocationEnabled ? 'disable' : 'enable'} my location marker',
      ),
      onPressed: () {
        setState(() {
          _myLocationEnabled = !_myLocationEnabled;
        });
      },
    );
  }

  Widget _myLocationButtonToggler() {
    return TextButton(
      child: Text(
        '${_myLocationButtonEnabled ? 'disable' : 'enable'} my location button',
      ),
      onPressed: () {
        setState(() {
          _myLocationButtonEnabled = !_myLocationButtonEnabled;
        });
      },
    );
  }

  Widget _myTrafficToggler() {
    return TextButton(
      child: Text('${_myTrafficEnabled ? 'disable' : 'enable'} my traffic'),
      onPressed: () {
        setState(() {
          _myTrafficEnabled = !_myTrafficEnabled;
        });
      },
    );
  }

  Future<String> _getFileData(String path) async {
    return rootBundle.loadString(path);
  }

  
  void _setMapStyle(String mapStyle) {
    setState(() {
      _nightMode = true;
      _controller.setMapStyle(mapStyle);
    });
  }
  
  // Should only be called if _isMapCreated is true.
  Widget _nightModeToggler() {
    assert(_isMapCreated);
    return TextButton(
      child: Text('${_nightMode ? 'disable' : 'enable'} night mode'),
      onPressed: () {
        if (_nightMode) {
          setState(() {
            _nightMode = false;
            _controller.setMapStyle(null);
          });
        } else {
          _getFileData('assets/night_mode.json').then(_setMapStyle);
        }
      },
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: _myPosition,
      builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          _startPosition = snapshot.data!;
          final double latitude = _startPosition.latitude;
          final double longitude = _startPosition.longitude;
          final GoogleMap googleMap = GoogleMap(
            padding: EdgeInsets.only(
              top: 84.h,
            ),
            onCameraMove: _updateCameraPosition,
            onMapCreated: onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 13.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            trafficEnabled: false,
            markers: _markers,
          );
          final double mapHeight = 1.sh;
          final double mapWidth = 1.sw;
          final List<Widget> stackChildren = <Widget>[
            Center(
              child: SizedBox(
                width: mapWidth,
                height: mapHeight,
                child: googleMap,
              ),
            ),
          ];
          if (_isMapCreated) {
            stackChildren.add(
              Align(
                alignment: Alignment.centerRight,
                child: RotatingEndDrawer(
                  drawer: StandardDrawer(
                    showSplines: true,
                    context: context,
                    left: false,
                    borderColor: personalColorScheme.background,
                    splineColor: personalColorScheme.background,
                    iconColor: personalColorScheme.background,
                    color: personalColorScheme.background.withOpacity(0.25),
                    icons: const [
                      Icons.fitness_center_outlined,
                      Icons.hotel_outlined,
                      Icons.storefront_outlined,
                      Icons.restaurant_outlined,
                      Icons.train_outlined,
                      Icons.local_hospital_outlined,
                    ],
                    onTap: [
                      () async {
                        final LatLng currentPosition = _position.target;
                        final zoom = _position.zoom;
                        _markers = await searchFitness(
                          currentPosition.latitude,
                          currentPosition.longitude,
                          zoom,
                        );
                        setState(() {});
                      },
                      () async {
                        final LatLng currentPosition = _position.target;
                        final zoom = _position.zoom;
                        _markers = await searchHotels(
                          currentPosition.latitude,
                          currentPosition.longitude,
                          zoom,
                        );
                        setState(() {});
                      },
                      () async {
                        final LatLng currentPosition = _position.target;
                        final zoom = _position.zoom;
                        _markers = await searchShops(
                          currentPosition.latitude,
                          currentPosition.longitude,
                          zoom,
                        );
                        setState(() {});
                      },
                      () async {
                        final LatLng currentPosition = _position.target;
                        final zoom = _position.zoom;
                        _markers = await searcRestaurants(
                          currentPosition.latitude,
                          currentPosition.longitude,
                          zoom,
                        );
                        setState(() {});
                      },
                      () async {
                        final LatLng currentPosition = _position.target;
                        final zoom = _position.zoom;
                        _markers = await searchTransport(
                          currentPosition.latitude,
                          currentPosition.longitude,
                          zoom,
                        );
                        setState(() {});
                      },
                      () async {
                        final LatLng currentPosition = _position.target;
                        final zoom = _position.zoom;
                        _markers = await searchHealth(
                          currentPosition.latitude,
                          currentPosition.longitude,
                          zoom,
                        );
                        setState(() {});
                      },
                    ],
                  ),
                ),
              ),
            );
          }
          return Stack(
            children: stackChildren,
          );
        }
      },
    );
  }

  void processSearch({String? type, String? place, String? time}) async {
    String mapsDetail = '';
    String mapsType = '';
    type = type ?? '';
    place = place ?? 'HERE';
    time = time ?? '';
    if (type.length > 1) {
      mapsType = type.split('.').first;
      mapsDetail = type.split('.').last;
    }
    final IconData icon;
    switch (mapsType) {
      case 'HOTEL':
        mapsType = 'lodging';
        icon = Icons.local_hotel_outlined;
        break;
      case 'TRAVEL':
        mapsType = 'airport';
        icon = Icons.local_airport_outlined;
        break;
      case 'RESTAURANT':
        mapsType = 'restaurant';
        icon = Icons.restaurant_outlined;
        break;
      case 'MUSEUM':
        mapsType = 'museum';
        icon = Icons.museum_outlined;
        break;
      case 'SPORT':
        mapsType = 'gym';
        icon = Icons.fitness_center_outlined;
        break;
      case 'BAR':
        mapsType = 'bar';
        icon = Icons.local_bar_outlined;
        break;
      default:
        mapsType = '';
        icon = Icons.location_on_outlined;
    }
    CameraPosition location = _position;
    if (place == 'HERE' || place == 'MAP') {
    } else {
      try {
        final List<Location> locations = await locationFromAddress(place);
        if (locations.isNotEmpty) {
          location = CameraPosition(
            target: LatLng(
              locations.first.latitude,
              locations.first.longitude,
            ),
          );
        }
      } catch (e) {
        debugPrint('Failed to get locations from address: $e');
      }
    }

    _markers = await searchNearby(
      location.target.latitude,
      location.target.longitude,
      mapsType,
      icon,
      _position.zoom,
      keyword: mapsDetail,
    );
    setState(() {});
  }

  void _updateCameraPosition(CameraPosition position) {
    setState(() {
      _position = position;
    });
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    setState(() {
      _isMapCreated = true;
      _position = CameraPosition(
        target: LatLng(
          _startPosition.latitude,
          _startPosition.longitude,
        ),
        zoom: 13.0,
      );
      Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );
      processSearch(
        type: widget.type,
        place: widget.place,
        time: widget.time,
      );
    });
  }

  Future<void> openLocationDetail(outlet) async {
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



/*
    if (_isMapCreated) {
      stackChildren.add(
        Expanded(
          child: ListView(
            children: <Widget>[
              Text(
                'camera bearing: ${_position.bearing}',
                style: TextStyle(
                  fontFamily: 'Exo',
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: personalColorScheme.primary,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                'camera target: ${_position.target.latitude.toStringAsFixed(4)},'
                '${_position.target.longitude.toStringAsFixed(4)}',
                style: TextStyle(
                  fontFamily: 'Exo',
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: personalColorScheme.primary,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                'camera zoom: ${_position.zoom}',
                style: TextStyle(
                  fontFamily: 'Exo',
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: personalColorScheme.primary,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                'camera tilt: ${_position.tilt}',
                style: TextStyle(
                  fontFamily: 'Exo',
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: personalColorScheme.primary,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                _isMoving ? '(Camera moving)' : '(Camera idle)',
                style: TextStyle(
                  fontFamily: 'Exo',
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: personalColorScheme.primary,
                  decoration: TextDecoration.none,
                ),
              ),
              _compassToggler(),
              _mapToolbarToggler(),
              _latLngBoundsToggler(),
              _mapTypeCycler(),
              _zoomBoundsToggler(),
              _rotateToggler(),
              _scrollToggler(),
              _tiltToggler(),
              _zoomToggler(),
              _zoomControlsToggler(),
              _indoorViewToggler(),
              _myLocationToggler(),
              _myLocationButtonToggler(),
              _myTrafficToggler(),
              _nightModeToggler(),
            ],
          ),
        ),
      );
    }
*/