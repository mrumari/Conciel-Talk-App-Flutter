import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

part 'map_locations.g.dart';

@JsonSerializable()
class LatLng {
  LatLng({
    required this.lat,
    required this.lng,
  });

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);
  Map<String, dynamic> toJson() => _$LatLngToJson(this);

  final double lat;
  final double lng;
}

@JsonSerializable()
class Neighborhood {
  Neighborhood({
    required this.coords,
    required this.placeId,
    required this.title,
    this.zoom = 0.0,
  });

  factory Neighborhood.fromJson(Map<String, dynamic> json) =>
      _$NeighborhoodFromJson(json);
  Map<String, dynamic> toJson() => _$NeighborhoodToJson(this);

  final LatLng coords;
  final String placeId;
  final String title;
  final double zoom;
}

@JsonSerializable()
class Outlets {
  Outlets({
    this.address = '',
    this.placeId = '',
    this.lat = 0.0,
    this.lng = 0.0,
    this.title = '',
    this.phone = '',
    this.neighborhood = '',
  });

  factory Outlets.fromJson(Map<String, dynamic> json) =>
      _$OutletsFromJson(json);
  Map<String, dynamic> toJson() => _$OutletsToJson(this);

  final String address;
  final String placeId;
  final double lat;
  final double lng;
  final String title;
  final String phone;
  final String neighborhood;
}

@JsonSerializable()
class Locations {
  Locations({
    required this.outlets,
    required this.neighborhoods,
  });

  factory Locations.fromJson(List<dynamic> jsonList) {
    final List<Outlets> outlets = jsonList
        .map(
          (json) => Outlets(
            address: json['address'] ?? '',
            placeId: json['placeId'] ?? '',
            lat: json['location']['lat'] ?? 0.0,
            lng: json['location']['lng'] ?? 0.0,
            title: json['title'] ?? '',
            phone: json['phone'] ?? '',
            neighborhood: json['neighborhood'] ?? '',
          ),
        )
        .toList();
    return Locations(outlets: outlets, neighborhoods: []);
  }

  Map<String, dynamic> toJson() => _$LocationsToJson(this);

  final List<Outlets> outlets;
  final List<Neighborhood> neighborhoods;
}

Future<Locations> getMapMarkers() async {
  Locations places;

  places = Locations.fromJson(
    List<dynamic>.from(
      json.decode(
        await rootBundle.loadString('assets/map_data/bars_munich_2023-05.json'),
      ),
    ),
  );

  return places;
//  }
}
