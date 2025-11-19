import 'package:equatable/equatable.dart';
import 'package:mobi_core/mobi_core.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationLoaded extends LocationState {
  final Location currentLocation;
  final Location? pickupLocation;
  final Location? dropoffLocation;

  const LocationLoaded({
    required this.currentLocation,
    this.pickupLocation,
    this.dropoffLocation,
  });

  @override
  List<Object?> get props => [currentLocation, pickupLocation, dropoffLocation];

  LocationLoaded copyWith({
    Location? currentLocation,
    Location? pickupLocation,
    Location? dropoffLocation,
  }) {
    return LocationLoaded(
      currentLocation: currentLocation ?? this.currentLocation,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
    );
  }

  bool get hasPickup => pickupLocation != null;
  bool get hasDropoff => dropoffLocation != null;
  bool get canRequestRide => hasPickup && hasDropoff;
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
}

class LocationPermissionDenied extends LocationState {
  const LocationPermissionDenied();
}
