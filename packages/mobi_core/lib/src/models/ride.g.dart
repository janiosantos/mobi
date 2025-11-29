// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ride _$RideFromJson(Map<String, dynamic> json) => Ride(
      id: (json['id'] as num).toInt(),
      rideNumber: json['ride_number'] as String,
      passengerId: (json['passenger_id'] as num).toInt(),
      driverId: (json['driver_id'] as num?)?.toInt(),
      vehicleId: (json['vehicle_id'] as num?)?.toInt(),
      vehicleCategoryId: (json['vehicle_category_id'] as num).toInt(),
      status: json['status'] as String,
      pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
      pickupAddress: json['pickup_address'] as String,
      dropoffLatitude: (json['dropoff_latitude'] as num).toDouble(),
      dropoffLongitude: (json['dropoff_longitude'] as num).toDouble(),
      dropoffAddress: json['dropoff_address'] as String,
      estimatedDistanceMeters:
          (json['estimated_distance_meters'] as num?)?.toInt(),
      estimatedDurationSeconds:
          (json['estimated_duration_seconds'] as num?)?.toInt(),
      estimatedPrice: (json['estimated_price'] as num).toDouble(),
      finalPrice: (json['final_price'] as num?)?.toDouble(),
      surgeMultiplier: (json['surge_multiplier'] as num?)?.toDouble(),
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String?,
      passenger: json['passenger'] == null
          ? null
          : User.fromJson(json['passenger'] as Map<String, dynamic>),
      driver: json['driver'] == null
          ? null
          : User.fromJson(json['driver'] as Map<String, dynamic>),
      vehicle: json['vehicle'] == null
          ? null
          : Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      acceptedAt: json['accepted_at'] == null
          ? null
          : DateTime.parse(json['accepted_at'] as String),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
      cancellationReason: json['cancellation_reason'] as String?,
    );

Map<String, dynamic> _$RideToJson(Ride instance) => <String, dynamic>{
      'id': instance.id,
      'ride_number': instance.rideNumber,
      'passenger_id': instance.passengerId,
      'driver_id': instance.driverId,
      'vehicle_id': instance.vehicleId,
      'vehicle_category_id': instance.vehicleCategoryId,
      'status': instance.status,
      'pickup_latitude': instance.pickupLatitude,
      'pickup_longitude': instance.pickupLongitude,
      'pickup_address': instance.pickupAddress,
      'dropoff_latitude': instance.dropoffLatitude,
      'dropoff_longitude': instance.dropoffLongitude,
      'dropoff_address': instance.dropoffAddress,
      'estimated_distance_meters': instance.estimatedDistanceMeters,
      'estimated_duration_seconds': instance.estimatedDurationSeconds,
      'estimated_price': instance.estimatedPrice,
      'final_price': instance.finalPrice,
      'surge_multiplier': instance.surgeMultiplier,
      'payment_method': instance.paymentMethod,
      'payment_status': instance.paymentStatus,
      'passenger': instance.passenger,
      'driver': instance.driver,
      'vehicle': instance.vehicle,
      'created_at': instance.createdAt?.toIso8601String(),
      'accepted_at': instance.acceptedAt?.toIso8601String(),
      'started_at': instance.startedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'cancelled_at': instance.cancelledAt?.toIso8601String(),
      'cancellation_reason': instance.cancellationReason,
    };
