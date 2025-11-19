import 'package:equatable/equatable.dart';

abstract class LocationTrackingEvent extends Equatable {
  const LocationTrackingEvent();

  @override
  List<Object?> get props => [];
}

/// Start tracking location
class StartLocationTracking extends LocationTrackingEvent {
  final int? rideId;
  final bool highAccuracy;

  const StartLocationTracking({
    this.rideId,
    this.highAccuracy = true,
  });

  @override
  List<Object?> get props => [rideId, highAccuracy];
}

/// Stop tracking location
class StopLocationTracking extends LocationTrackingEvent {
  const StopLocationTracking();
}

/// Update current location
class UpdateLocation extends LocationTrackingEvent {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? heading;
  final double? speed;
  final DateTime timestamp;

  const UpdateLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.heading,
    this.speed,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        accuracy,
        heading,
        speed,
        timestamp,
      ];
}

/// Send location to backend (for active ride)
class SendLocationToBackend extends LocationTrackingEvent {
  final int rideId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? heading;
  final double? speed;

  const SendLocationToBackend({
    required this.rideId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.heading,
    this.speed,
  });

  @override
  List<Object?> get props => [
        rideId,
        latitude,
        longitude,
        accuracy,
        heading,
        speed,
      ];
}

/// Request permission
class RequestLocationPermission extends LocationTrackingEvent {
  const RequestLocationPermission();
}

/// Permission status changed
class LocationPermissionChanged extends LocationTrackingEvent {
  final bool granted;

  const LocationPermissionChanged(this.granted);

  @override
  List<Object> get props => [granted];
}

/// Check if location services are enabled
class CheckLocationServices extends LocationTrackingEvent {
  const CheckLocationServices();
}

/// Location services status changed
class LocationServicesChanged extends LocationTrackingEvent {
  final bool enabled;

  const LocationServicesChanged(this.enabled);

  @override
  List<Object> get props => [enabled];
}

/// Get current location (one-time)
class GetCurrentLocation extends LocationTrackingEvent {
  const GetCurrentLocation();
}

/// Calculate distance between two points
class CalculateDistance extends LocationTrackingEvent {
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;

  const CalculateDistance({
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
  });

  @override
  List<Object> get props => [startLat, startLng, endLat, endLng];
}

/// Track route polyline
class AddRoutePoint extends LocationTrackingEvent {
  final double latitude;
  final double longitude;

  const AddRoutePoint({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}

/// Clear route
class ClearRoute extends LocationTrackingEvent {
  const ClearRoute();
}
