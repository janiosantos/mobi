import 'package:equatable/equatable.dart';
import 'package:mobi_core/mobi_core.dart';

abstract class AvailableRidesState extends Equatable {
  const AvailableRidesState();

  @override
  List<Object?> get props => [];
}

class AvailableRidesInitial extends AvailableRidesState {
  const AvailableRidesInitial();
}

class AvailableRidesLoading extends AvailableRidesState {
  const AvailableRidesLoading();
}

class AvailableRidesLoaded extends AvailableRidesState {
  final List<Ride> rides;

  const AvailableRidesLoaded(this.rides);

  @override
  List<Object?> get props => [rides];
}

class AvailableRidesError extends AvailableRidesState {
  final String message;

  const AvailableRidesError(this.message);

  @override
  List<Object?> get props => [message];
}

class RideAccepting extends AvailableRidesState {
  final int rideId;

  const RideAccepting(this.rideId);

  @override
  List<Object?> get props => [rideId];
}

class RideAccepted extends AvailableRidesState {
  final Ride ride;

  const RideAccepted(this.ride);

  @override
  List<Object?> get props => [ride];
}

class RideAcceptError extends AvailableRidesState {
  final String message;

  const RideAcceptError(this.message);

  @override
  List<Object?> get props => [message];
}
