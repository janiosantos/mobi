import 'package:equatable/equatable.dart';

abstract class ActiveRideEvent extends Equatable {
  const ActiveRideEvent();

  @override
  List<Object?> get props => [];
}

class LoadActiveRide extends ActiveRideEvent {
  const LoadActiveRide();
}

class MarkArrival extends ActiveRideEvent {
  final int rideId;

  const MarkArrival(this.rideId);

  @override
  List<Object?> get props => [rideId];
}

class StartRide extends ActiveRideEvent {
  final int rideId;

  const StartRide(this.rideId);

  @override
  List<Object?> get props => [rideId];
}

class CompleteRide extends ActiveRideEvent {
  final int rideId;
  final double finalLatitude;
  final double finalLongitude;
  final int actualDistanceMeters;
  final int actualDurationSeconds;

  const CompleteRide({
    required this.rideId,
    required this.finalLatitude,
    required this.finalLongitude,
    required this.actualDistanceMeters,
    required this.actualDurationSeconds,
  });

  @override
  List<Object?> get props => [
        rideId,
        finalLatitude,
        finalLongitude,
        actualDistanceMeters,
        actualDurationSeconds,
      ];
}

class CancelRide extends ActiveRideEvent {
  final int rideId;
  final String reason;

  const CancelRide({
    required this.rideId,
    required this.reason,
  });

  @override
  List<Object?> get props => [rideId, reason];
}

class UpdateDriverLocation extends ActiveRideEvent {
  final int rideId;
  final double latitude;
  final double longitude;

  const UpdateDriverLocation({
    required this.rideId,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [rideId, latitude, longitude];
}

class ClearActiveRide extends ActiveRideEvent {
  const ClearActiveRide();
}
