// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatLng _$LatLngFromJson(Map<String, dynamic> json) => LatLng(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$LatLngToJson(LatLng instance) => <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };

Neighborhood _$NeighborhoodFromJson(Map<String, dynamic> json) => Neighborhood(
      coords: LatLng.fromJson(json['coords'] as Map<String, dynamic>),
      placeId: json['placeId'] as String,
      title: json['title'] as String,
      zoom: (json['zoom'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$NeighborhoodToJson(Neighborhood instance) =>
    <String, dynamic>{
      'coords': instance.coords,
      'placeId': instance.placeId,
      'title': instance.title,
      'zoom': instance.zoom,
    };

Outlets _$OutletsFromJson(Map<String, dynamic> json) => Outlets(
      address: json['address'] as String? ?? '',
      placeId: json['placeId'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      title: json['title'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
    );

Map<String, dynamic> _$OutletsToJson(Outlets instance) => <String, dynamic>{
      'address': instance.address,
      'placeId': instance.placeId,
      'lat': instance.lat,
      'lng': instance.lng,
      'title': instance.title,
      'phone': instance.phone,
      'neighborhood': instance.neighborhood,
    };

// ignore: unused_element
Locations _$LocationsFromJson(Map<String, dynamic> json) => Locations(
      outlets: (json['outlets'] as List<dynamic>)
          .map((e) => Outlets.fromJson(e as Map<String, dynamic>))
          .toList(),
      neighborhoods: (json['neighborhoods'] as List<dynamic>)
          .map((e) => Neighborhood.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LocationsToJson(Locations instance) => <String, dynamic>{
      'outlets': instance.outlets,
      'neighborhoods': instance.neighborhoods,
    };
