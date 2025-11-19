import 'package:equatable/equatable.dart';

abstract class AvailableRidesEvent extends Equatable {
  const AvailableRidesEvent();

  @override
  List<Object?> get props => [];
}

class LoadAvailableRides extends AvailableRidesEvent {
  final double latitude;
  final double longitude;
  final double radius;

  const LoadAvailableRides({
    required this.latitude,
    required this.longitude,
    this.radius = 10.0, // 10km radius by default
  });

  @override
  List<Object?> get props => [latitude, longitude, radius];
}

class RefreshAvailableRides extends AvailableRidesEvent {
  const RefreshAvailableRides();
}

class AcceptRideRequested extends AvailableRidesEvent {
  final int rideId;

  const AcceptRideRequested(this.rideId);

  @override
  List<Object?> get props => [rideId];
}

class ClearAvailableRides extends AvailableRidesEvent {
  const ClearAvailableRides();
}
