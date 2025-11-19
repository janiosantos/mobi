import 'package:equatable/equatable.dart';
import '../../models/ride.dart';

abstract class RideState extends Equatable {
  const RideState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class RideInitial extends RideState {
  const RideInitial();
}

/// Loading state
class RideLoading extends RideState {
  const RideLoading();
}

/// Ride request in progress
class RideRequesting extends RideState {
  const RideRequesting();
}

/// Ride requested successfully (waiting for driver)
class RideRequested extends RideState {
  final Ride ride;

  const RideRequested(this.ride);

  @override
  List<Object> get props => [ride];
}

/// Driver found and accepted
class RideAccepted extends RideState {
  final Ride ride;

  const RideAccepted(this.ride);

  @override
  List<Object> get props => [ride];
}

/// Driver is on the way
class DriverEnRoute extends RideState {
  final Ride ride;
  final double? driverLatitude;
  final double? driverLongitude;
  final int? estimatedArrivalSeconds;

  const DriverEnRoute({
    required this.ride,
    this.driverLatitude,
    this.driverLongitude,
    this.estimatedArrivalSeconds,
  });

  @override
  List<Object?> get props => [
        ride,
        driverLatitude,
        driverLongitude,
        estimatedArrivalSeconds,
      ];
}

/// Driver arrived
class DriverArrived extends RideState {
  final Ride ride;

  const DriverArrived(this.ride);

  @override
  List<Object> get props => [ride];
}

/// Ride in progress
class RideInProgress extends RideState {
  final Ride ride;
  final double? currentLatitude;
  final double? currentLongitude;
  final int? elapsedSeconds;

  const RideInProgress({
    required this.ride,
    this.currentLatitude,
    this.currentLongitude,
    this.elapsedSeconds,
  });

  @override
  List<Object?> get props => [
        ride,
        currentLatitude,
        currentLongitude,
        elapsedSeconds,
      ];
}

/// Ride completed
class RideCompleted extends RideState {
  final Ride ride;

  const RideCompleted(this.ride);

  @override
  List<Object> get props => [ride];
}

/// Ride cancelled
class RideCancelled extends RideState {
  final Ride ride;
  final String? reason;

  const RideCancelled({
    required this.ride,
    this.reason,
  });

  @override
  List<Object?> get props => [ride, reason];
}

/// Ride rated successfully
class RideRated extends RideState {
  final Ride ride;

  const RideRated(this.ride);

  @override
  List<Object> get props => [ride];
}

/// Tip added successfully
class TipAdded extends RideState {
  final Ride ride;

  const TipAdded(this.ride);

  @override
  List<Object> get props => [ride];
}

/// Ride history loaded
class RideHistoryLoaded extends RideState {
  final List<Ride> rides;
  final int currentPage;
  final int? totalPages;
  final bool hasMore;

  const RideHistoryLoaded({
    required this.rides,
    required this.currentPage,
    this.totalPages,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [rides, currentPage, totalPages, hasMore];
}

/// Ride details loaded
class RideDetailsLoaded extends RideState {
  final Ride ride;

  const RideDetailsLoaded(this.ride);

  @override
  List<Object> get props => [ride];
}

/// No active ride
class NoActiveRide extends RideState {
  const NoActiveRide();
}

/// Error state
class RideError extends RideState {
  final String message;

  const RideError(this.message);

  @override
  List<Object> get props => [message];
}
