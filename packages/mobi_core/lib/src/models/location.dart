import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'location.g.dart';

@JsonSerializable()
class Location extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final String? placeId;

  const Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.placeId,
  });

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);

  @override
  List<Object?> get props => [latitude, longitude, address, placeId];

  Location copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? placeId,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      placeId: placeId ?? this.placeId,
    );
  }
}
