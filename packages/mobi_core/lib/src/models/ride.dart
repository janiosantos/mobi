import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'user.dart';
import 'vehicle.dart';

part 'ride.g.dart';

@JsonSerializable()
class Ride extends Equatable {
  final int id;
  @JsonKey(name: 'ride_number')
  final String rideNumber;
  @JsonKey(name: 'passenger_id')
  final int passengerId;
  @JsonKey(name: 'driver_id')
  final int? driverId;
  @JsonKey(name: 'vehicle_id')
  final int? vehicleId;
  @JsonKey(name: 'vehicle_category_id')
  final int vehicleCategoryId;
  final String status;
  @JsonKey(name: 'pickup_latitude')
  final double pickupLatitude;
  @JsonKey(name: 'pickup_longitude')
  final double pickupLongitude;
  @JsonKey(name: 'pickup_address')
  final String pickupAddress;
  @JsonKey(name: 'dropoff_latitude')
  final double dropoffLatitude;
  @JsonKey(name: 'dropoff_longitude')
  final double dropoffLongitude;
  @JsonKey(name: 'dropoff_address')
  final String dropoffAddress;
  @JsonKey(name: 'estimated_distance_meters')
  final int? estimatedDistanceMeters;
  @JsonKey(name: 'estimated_duration_seconds')
  final int? estimatedDurationSeconds;
  @JsonKey(name: 'estimated_price')
  final double estimatedPrice;
  @JsonKey(name: 'final_price')
  final double? finalPrice;
  @JsonKey(name: 'surge_multiplier')
  final double? surgeMultiplier;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @JsonKey(name: 'payment_status')
  final String? paymentStatus;
  final User? passenger;
  final User? driver;
  final Vehicle? vehicle;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'accepted_at')
  final DateTime? acceptedAt;
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt;
  @JsonKey(name: 'cancellation_reason')
  final String? cancellationReason;

  const Ride({
    required this.id,
    required this.rideNumber,
    required this.passengerId,
    this.driverId,
    this.vehicleId,
    required this.vehicleCategoryId,
    required this.status,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.dropoffAddress,
    this.estimatedDistanceMeters,
    this.estimatedDurationSeconds,
    required this.estimatedPrice,
    this.finalPrice,
    this.surgeMultiplier,
    required this.paymentMethod,
    this.paymentStatus,
    this.passenger,
    this.driver,
    this.vehicle,
    this.createdAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  factory Ride.fromJson(Map<String, dynamic> json) => _$RideFromJson(json);
  Map<String, dynamic> toJson() => _$RideToJson(this);

  bool get isSearching => status == 'searching';
  bool get isAccepted => status == 'accepted';
  bool get isArrived => status == 'arrived';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  @override
  List<Object?> get props => [
        id,
        rideNumber,
        passengerId,
        driverId,
        vehicleId,
        vehicleCategoryId,
        status,
        pickupLatitude,
        pickupLongitude,
        pickupAddress,
        dropoffLatitude,
        dropoffLongitude,
        dropoffAddress,
        estimatedDistanceMeters,
        estimatedDurationSeconds,
        estimatedPrice,
        finalPrice,
        surgeMultiplier,
        paymentMethod,
        paymentStatus,
        passenger,
        driver,
        vehicle,
        createdAt,
        acceptedAt,
        startedAt,
        completedAt,
        cancelledAt,
        cancellationReason,
      ];
}
