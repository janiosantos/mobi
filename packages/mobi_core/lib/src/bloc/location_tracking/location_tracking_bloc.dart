import 'dart:async';
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'location_tracking_event.dart';
import 'location_tracking_state.dart';

class LocationTrackingBloc
    extends Bloc<LocationTrackingEvent, LocationTrackingState> {
  StreamSubscription? _locationSubscription;
  Timer? _sendLocationTimer;
  final List<LocationPoint> _routePoints = [];
  double _totalDistance = 0.0;

  LocationTrackingBloc() : super(const LocationTrackingInitial()) {
    on<StartLocationTracking>(_onStartLocationTracking);
    on<StopLocationTracking>(_onStopLocationTracking);
    on<UpdateLocation>(_onUpdateLocation);
    on<SendLocationToBackend>(_onSendLocationToBackend);
    on<RequestLocationPermission>(_onRequestLocationPermission);
    on<LocationPermissionChanged>(_onLocationPermissionChanged);
    on<CheckLocationServices>(_onCheckLocationServices);
    on<LocationServicesChanged>(_onLocationServicesChanged);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<CalculateDistance>(_onCalculateDistance);
    on<AddRoutePoint>(_onAddRoutePoint);
    on<ClearRoute>(_onClearRoute);
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _sendLocationTimer?.cancel();
    return super.close();
  }

  Future<void> _onStartLocationTracking(
    StartLocationTracking event,
    Emitter<LocationTrackingState> emit,
  ) async {
    emit(const LocationTrackingLoading());

    try {
      // TODO: Initialize actual location service
      // This would typically use geolocator package
      // For now, we'll set up the state

      _routePoints.clear();
      _totalDistance = 0.0;

      // Start periodic location updates to backend (if rideId provided)
      if (event.rideId != null) {
        _sendLocationTimer?.cancel();
        _sendLocationTimer = Timer.periodic(
          const Duration(seconds: 10),
          (timer) {
            // Send location update every 10 seconds during active ride
            final currentState = state;
            if (currentState is LocationTrackingActive) {
              add(SendLocationToBackend(
                rideId: event.rideId!,
                latitude: currentState.currentLocation.latitude,
                longitude: currentState.currentLocation.longitude,
                accuracy: currentState.currentLocation.accuracy,
                heading: currentState.currentLocation.heading,
                speed: currentState.currentLocation.speed,
              ));
            }
          },
        );
      }

      // Emit initial tracking state (will be updated by location updates)
      emit(LocationTrackingActive(
        currentLocation: LocationPoint(
          latitude: 0,
          longitude: 0,
          timestamp: DateTime.now(),
        ),
        rideId: event.rideId,
      ));
    } catch (e) {
      emit(LocationTrackingError('Erro ao iniciar tracking: ${e.toString()}'));
    }
  }

  Future<void> _onStopLocationTracking(
    StopLocationTracking event,
    Emitter<LocationTrackingState> emit,
  ) async {
    _locationSubscription?.cancel();
    _sendLocationTimer?.cancel();

    emit(LocationTrackingStopped(
      totalDistance: _totalDistance,
      totalPoints: _routePoints.length,
    ));

    _routePoints.clear();
    _totalDistance = 0.0;
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationTrackingState> emit,
  ) async {
    final newLocation = LocationPoint(
      latitude: event.latitude,
      longitude: event.longitude,
      accuracy: event.accuracy,
      heading: event.heading,
      speed: event.speed,
      timestamp: event.timestamp,
    );

    final currentState = state;
    if (currentState is LocationTrackingActive) {
      // Calculate distance from last point
      if (_routePoints.isNotEmpty) {
        final lastPoint = _routePoints.last;
        final distance = _calculateDistanceInMeters(
          lastPoint.latitude,
          lastPoint.longitude,
          newLocation.latitude,
          newLocation.longitude,
        );

        // Only add point if moved more than 5 meters (avoid GPS drift)
        if (distance > 5) {
          _totalDistance += distance;
          _routePoints.add(newLocation);

          emit(currentState.copyWith(
            currentLocation: newLocation,
            route: List.from(_routePoints),
            totalDistance: _totalDistance,
          ));
        } else {
          // Update current location without adding to route
          emit(currentState.copyWith(currentLocation: newLocation));
        }
      } else {
        _routePoints.add(newLocation);
        emit(currentState.copyWith(
          currentLocation: newLocation,
          route: List.from(_routePoints),
        ));
      }
    } else {
      emit(LocationUpdated(newLocation));
    }
  }

  Future<void> _onSendLocationToBackend(
    SendLocationToBackend event,
    Emitter<LocationTrackingState> emit,
  ) async {
    try {
      // TODO: Implement actual API call to send location to backend
      // This would use the ride repository or location service
      // For now, we'll just emit success state

      final location = LocationPoint(
        latitude: event.latitude,
        longitude: event.longitude,
        accuracy: event.accuracy,
        heading: event.heading,
        speed: event.speed,
        timestamp: DateTime.now(),
      );

      emit(LocationSentToBackend(
        rideId: event.rideId,
        location: location,
      ));

      // Return to tracking active state
      final currentState = state;
      if (currentState is LocationTrackingActive) {
        emit(currentState);
      }
    } catch (e) {
      // Silent fail - location updates should not break the app
    }
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermission event,
    Emitter<LocationTrackingState> emit,
  ) async {
    emit(const LocationTrackingLoading());

    try {
      // TODO: Request actual location permission using permission_handler
      // For now, we'll simulate permission granted
      emit(const LocationPermissionGranted());
    } catch (e) {
      emit(const LocationPermissionDenied());
    }
  }

  Future<void> _onLocationPermissionChanged(
    LocationPermissionChanged event,
    Emitter<LocationTrackingState> emit,
  ) async {
    if (event.granted) {
      emit(const LocationPermissionGranted());
    } else {
      emit(const LocationPermissionDenied());
    }
  }

  Future<void> _onCheckLocationServices(
    CheckLocationServices event,
    Emitter<LocationTrackingState> emit,
  ) async {
    try {
      // TODO: Check actual location services using geolocator
      // For now, we'll assume enabled
      emit(const LocationServicesEnabled());
    } catch (e) {
      emit(const LocationServicesDisabled());
    }
  }

  Future<void> _onLocationServicesChanged(
    LocationServicesChanged event,
    Emitter<LocationTrackingState> emit,
  ) async {
    if (event.enabled) {
      emit(const LocationServicesEnabled());
    } else {
      emit(const LocationServicesDisabled());
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<LocationTrackingState> emit,
  ) async {
    emit(const LocationTrackingLoading());

    try {
      // TODO: Get actual current location using geolocator
      // For now, we'll emit a placeholder
      final location = LocationPoint(
        latitude: 0,
        longitude: 0,
        timestamp: DateTime.now(),
      );

      emit(CurrentLocationObtained(location));
    } catch (e) {
      emit(LocationTrackingError(
          'Erro ao obter localização: ${e.toString()}'));
    }
  }

  Future<void> _onCalculateDistance(
    CalculateDistance event,
    Emitter<LocationTrackingState> emit,
  ) async {
    final distanceMeters = _calculateDistanceInMeters(
      event.startLat,
      event.startLng,
      event.endLat,
      event.endLng,
    );

    emit(DistanceCalculated(
      distanceInMeters: distanceMeters,
      distanceInKilometers: distanceMeters / 1000,
    ));
  }

  Future<void> _onAddRoutePoint(
    AddRoutePoint event,
    Emitter<LocationTrackingState> emit,
  ) async {
    final point = LocationPoint(
      latitude: event.latitude,
      longitude: event.longitude,
      timestamp: DateTime.now(),
    );

    _routePoints.add(point);

    final currentState = state;
    if (currentState is LocationTrackingActive) {
      emit(currentState.copyWith(route: List.from(_routePoints)));
    }
  }

  Future<void> _onClearRoute(
    ClearRoute event,
    Emitter<LocationTrackingState> emit,
  ) async {
    _routePoints.clear();
    _totalDistance = 0.0;

    final currentState = state;
    if (currentState is LocationTrackingActive) {
      emit(currentState.copyWith(
        route: [],
        totalDistance: 0.0,
      ));
    }
  }

  /// Calculate distance between two points using Haversine formula
  /// Returns distance in meters
  double _calculateDistanceInMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000; // meters

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = (dLat / 2).abs() * (dLat / 2).abs() +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            (dLon / 2).abs() *
            (dLon / 2).abs();

    final c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }
}
