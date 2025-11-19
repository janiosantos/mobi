import 'package:equatable/equatable.dart';

class LocationPoint {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? heading;
  final double? speed;
  final DateTime timestamp;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.heading,
    this.speed,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (accuracy != null) 'accuracy': accuracy,
        if (heading != null) 'heading': heading,
        if (speed != null) 'speed': speed,
        'timestamp': timestamp.toIso8601String(),
      };
}

abstract class LocationTrackingState extends Equatable {
  const LocationTrackingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class LocationTrackingInitial extends LocationTrackingState {
  const LocationTrackingInitial();
}

/// Loading/Initializing
class LocationTrackingLoading extends LocationTrackingState {
  const LocationTrackingLoading();
}

/// Permission denied
class LocationPermissionDenied extends LocationTrackingState {
  final String message;

  const LocationPermissionDenied(
      {this.message = 'Permissão de localização negada'});

  @override
  List<Object> get props => [message];
}

/// Permission granted
class LocationPermissionGranted extends LocationTrackingState {
  const LocationPermissionGranted();
}

/// Location services disabled
class LocationServicesDisabled extends LocationTrackingState {
  final String message;

  const LocationServicesDisabled({
    this.message = 'Serviços de localização desabilitados',
  });

  @override
  List<Object> get props => [message];
}

/// Location services enabled
class LocationServicesEnabled extends LocationTrackingState {
  const LocationServicesEnabled();
}

/// Tracking active
class LocationTrackingActive extends LocationTrackingState {
  final LocationPoint currentLocation;
  final List<LocationPoint> route;
  final int? rideId;
  final double? totalDistance;

  const LocationTrackingActive({
    required this.currentLocation,
    this.route = const [],
    this.rideId,
    this.totalDistance,
  });

  @override
  List<Object?> get props => [
        currentLocation,
        route,
        rideId,
        totalDistance,
      ];

  LocationTrackingActive copyWith({
    LocationPoint? currentLocation,
    List<LocationPoint>? route,
    int? rideId,
    double? totalDistance,
  }) {
    return LocationTrackingActive(
      currentLocation: currentLocation ?? this.currentLocation,
      route: route ?? this.route,
      rideId: rideId ?? this.rideId,
      totalDistance: totalDistance ?? this.totalDistance,
    );
  }
}

/// Location updated
class LocationUpdated extends LocationTrackingState {
  final LocationPoint location;

  const LocationUpdated(this.location);

  @override
  List<Object> get props => [location];
}

/// Location sent to backend
class LocationSentToBackend extends LocationTrackingState {
  final int rideId;
  final LocationPoint location;

  const LocationSentToBackend({
    required this.rideId,
    required this.location,
  });

  @override
  List<Object> get props => [rideId, location];
}

/// Current location obtained (one-time)
class CurrentLocationObtained extends LocationTrackingState {
  final LocationPoint location;

  const CurrentLocationObtained(this.location);

  @override
  List<Object> get props => [location];
}

/// Distance calculated
class DistanceCalculated extends LocationTrackingState {
  final double distanceInMeters;
  final double distanceInKilometers;

  const DistanceCalculated({
    required this.distanceInMeters,
    required this.distanceInKilometers,
  });

  @override
  List<Object> get props => [distanceInMeters, distanceInKilometers];
}

/// Tracking stopped
class LocationTrackingStopped extends LocationTrackingState {
  final double? totalDistance;
  final int? totalPoints;

  const LocationTrackingStopped({
    this.totalDistance,
    this.totalPoints,
  });

  @override
  List<Object?> get props => [totalDistance, totalPoints];
}

/// Error state
class LocationTrackingError extends LocationTrackingState {
  final String message;

  const LocationTrackingError(this.message);

  @override
  List<Object> get props => [message];
}
