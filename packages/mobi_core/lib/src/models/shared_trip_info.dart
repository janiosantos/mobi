import 'package:equatable/equatable.dart';

/// Shared trip information model (for public sharing)
class SharedTripInfo extends Equatable {
  final int rideId;
  final String passengerName;
  final String? driverName;
  final String? driverPhone;
  final String? vehiclePlate;
  final String? vehicleModel;
  final String? vehicleColor;
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String dropoffAddress;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final double? currentLatitude;
  final double? currentLongitude;
  final String status;
  final DateTime? startedAt;
  final DateTime? estimatedArrival;
  final DateTime shareExpiresAt;

  const SharedTripInfo({
    required this.rideId,
    required this.passengerName,
    this.driverName,
    this.driverPhone,
    this.vehiclePlate,
    this.vehicleModel,
    this.vehicleColor,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropoffAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    this.currentLatitude,
    this.currentLongitude,
    required this.status,
    this.startedAt,
    this.estimatedArrival,
    required this.shareExpiresAt,
  });

  factory SharedTripInfo.fromJson(Map<String, dynamic> json) {
    return SharedTripInfo(
      rideId: json['ride_id'] as int,
      passengerName: json['passenger_name'] as String,
      driverName: json['driver_name'] as String?,
      driverPhone: json['driver_phone'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      vehicleModel: json['vehicle_model'] as String?,
      vehicleColor: json['vehicle_color'] as String?,
      pickupAddress: json['pickup_address'] as String,
      pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
      dropoffAddress: json['dropoff_address'] as String,
      dropoffLatitude: (json['dropoff_latitude'] as num).toDouble(),
      dropoffLongitude: (json['dropoff_longitude'] as num).toDouble(),
      currentLatitude: json['current_latitude'] != null
          ? (json['current_latitude'] as num).toDouble()
          : null,
      currentLongitude: json['current_longitude'] != null
          ? (json['current_longitude'] as num).toDouble()
          : null,
      status: json['status'] as String,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      estimatedArrival: json['estimated_arrival'] != null
          ? DateTime.parse(json['estimated_arrival'] as String)
          : null,
      shareExpiresAt: DateTime.parse(json['share_expires_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ride_id': rideId,
      'passenger_name': passengerName,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'vehicle_plate': vehiclePlate,
      'vehicle_model': vehicleModel,
      'vehicle_color': vehicleColor,
      'pickup_address': pickupAddress,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'dropoff_address': dropoffAddress,
      'dropoff_latitude': dropoffLatitude,
      'dropoff_longitude': dropoffLongitude,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'status': status,
      'started_at': startedAt?.toIso8601String(),
      'estimated_arrival': estimatedArrival?.toIso8601String(),
      'share_expires_at': shareExpiresAt.toIso8601String(),
    };
  }

  /// Check if sharing is still active (not expired)
  bool get isActive => DateTime.now().isBefore(shareExpiresAt);

  /// Check if ride is in progress
  bool get isInProgress => status == 'in_progress';

  /// Get status display text
  String get statusDisplay {
    switch (status) {
      case 'requested':
        return 'Solicitada';
      case 'accepted':
        return 'Aceita';
      case 'driver_arrived':
        return 'Motorista chegou';
      case 'in_progress':
        return 'Em andamento';
      case 'completed':
        return 'Concluída';
      case 'cancelled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  @override
  List<Object?> get props => [
        rideId,
        passengerName,
        driverName,
        driverPhone,
        vehiclePlate,
        vehicleModel,
        vehicleColor,
        pickupAddress,
        pickupLatitude,
        pickupLongitude,
        dropoffAddress,
        dropoffLatitude,
        dropoffLongitude,
        currentLatitude,
        currentLongitude,
        status,
        startedAt,
        estimatedArrival,
        shareExpiresAt,
      ];
}
