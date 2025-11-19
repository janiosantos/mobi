import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'vehicle.g.dart';

@JsonSerializable()
class Vehicle extends Equatable {
  final int id;
  @JsonKey(name: 'driver_id')
  final int driverId;
  @JsonKey(name: 'category_id')
  final int categoryId;
  final String make;
  final String model;
  final int year;
  final String color;
  @JsonKey(name: 'license_plate')
  final String licensePlate;
  final String? renavam;
  @JsonKey(name: 'vehicle_photo_url')
  final String? vehiclePhotoUrl;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const Vehicle({
    required this.id,
    required this.driverId,
    required this.categoryId,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    this.renavam,
    this.vehiclePhotoUrl,
    required this.isActive,
    this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleToJson(this);

  String get displayName => '$make $model $year';

  @override
  List<Object?> get props => [
        id,
        driverId,
        categoryId,
        make,
        model,
        year,
        color,
        licensePlate,
        renavam,
        vehiclePhotoUrl,
        isActive,
        createdAt,
      ];
}
