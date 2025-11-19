import 'package:equatable/equatable.dart';

abstract class RideEvent extends Equatable {
  const RideEvent();

  @override
  List<Object?> get props => [];
}

/// Request a new ride
class RequestRide extends RideEvent {
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupAddress;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final String dropoffAddress;
  final int vehicleCategoryId;
  final String? passengerNotes;
  final String? paymentMethodId;

  const RequestRide({
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.dropoffAddress,
    required this.vehicleCategoryId,
    this.passengerNotes,
    this.paymentMethodId,
  });

  @override
  List<Object?> get props => [
        pickupLatitude,
        pickupLongitude,
        pickupAddress,
        dropoffLatitude,
        dropoffLongitude,
        dropoffAddress,
        vehicleCategoryId,
        passengerNotes,
        paymentMethodId,
      ];
}

/// Load current active ride
class LoadCurrentRide extends RideEvent {
  const LoadCurrentRide();
}

/// Track ride in real-time
class TrackRide extends RideEvent {
  final int rideId;

  const TrackRide(this.rideId);

  @override
  List<Object> get props => [rideId];
}

/// Cancel ride
class CancelRideByPassenger extends RideEvent {
  final int rideId;
  final String? reason;

  const CancelRideByPassenger({
    required this.rideId,
    this.reason,
  });

  @override
  List<Object?> get props => [rideId, reason];
}

/// Rate completed ride
class RateRide extends RideEvent {
  final int rideId;
  final int rating;
  final String? comment;
  final List<String>? tags;

  const RateRide({
    required this.rideId,
    required this.rating,
    this.comment,
    this.tags,
  });

  @override
  List<Object?> get props => [rideId, rating, comment, tags];
}

/// Add tip to ride
class AddTip extends RideEvent {
  final int rideId;
  final double amount;

  const AddTip({
    required this.rideId,
    required this.amount,
  });

  @override
  List<Object> get props => [rideId, amount];
}

/// Load ride history
class LoadRideHistory extends RideEvent {
  final int page;
  final String? status;

  const LoadRideHistory({
    this.page = 1,
    this.status,
  });

  @override
  List<Object?> get props => [page, status];
}

/// Get ride details
class GetRideDetails extends RideEvent {
  final int rideId;

  const GetRideDetails(this.rideId);

  @override
  List<Object> get props => [rideId];
}

/// Clear current ride
class ClearCurrentRide extends RideEvent {
  const ClearCurrentRide();
}

/// Refresh ride status
class RefreshRideStatus extends RideEvent {
  final int rideId;

  const RefreshRideStatus(this.rideId);

  @override
  List<Object> get props => [rideId];
}
