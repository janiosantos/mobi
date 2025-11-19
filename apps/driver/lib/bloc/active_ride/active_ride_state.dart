import 'package:equatable/equatable.dart';
import 'package:mobi_core/mobi_core.dart';

abstract class ActiveRideState extends Equatable {
  const ActiveRideState();

  @override
  List<Object?> get props => [];
}

class ActiveRideInitial extends ActiveRideState {
  const ActiveRideInitial();
}

class ActiveRideLoading extends ActiveRideState {
  const ActiveRideLoading();
}

class ActiveRideLoaded extends ActiveRideState {
  final Ride ride;

  const ActiveRideLoaded(this.ride);

  bool get canMarkArrival => ride.status == 'accepted';
  bool get canStartRide => ride.status == 'arrived';
  bool get canCompleteRide => ride.status == 'in_progress';
  bool get canCancelRide => ride.status == 'accepted' || ride.status == 'arrived';

  @override
  List<Object?> get props => [ride];
}

class NoActiveRide extends ActiveRideState {
  const NoActiveRide();
}

class ActiveRideError extends ActiveRideState {
  final String message;

  const ActiveRideError(this.message);

  @override
  List<Object?> get props => [message];
}

class RideActionInProgress extends ActiveRideState {
  final String action; // 'arriving', 'starting', 'completing', 'cancelling'
  final Ride ride;

  const RideActionInProgress({
    required this.action,
    required this.ride,
  });

  @override
  List<Object?> get props => [action, ride];
}

class RideCompleted extends ActiveRideState {
  final Ride ride;

  const RideCompleted(this.ride);

  @override
  List<Object?> get props => [ride];
}

class RideCancelled extends ActiveRideState {
  final Ride ride;

  const RideCancelled(this.ride);

  @override
  List<Object?> get props => [ride];
}
