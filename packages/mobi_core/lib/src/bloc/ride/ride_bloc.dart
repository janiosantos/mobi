import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/ride_repository.dart';
import '../../models/ride.dart';
import 'ride_event.dart';
import 'ride_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  final RideRepository rideRepository;

  RideBloc({required this.rideRepository}) : super(const RideInitial()) {
    on<RequestRide>(_onRequestRide);
    on<LoadCurrentRide>(_onLoadCurrentRide);
    on<TrackRide>(_onTrackRide);
    on<CancelRideByPassenger>(_onCancelRide);
    on<RateRide>(_onRateRide);
    on<AddTip>(_onAddTip);
    on<LoadRideHistory>(_onLoadRideHistory);
    on<GetRideDetails>(_onGetRideDetails);
    on<ClearCurrentRide>(_onClearCurrentRide);
    on<RefreshRideStatus>(_onRefreshRideStatus);
  }

  Future<void> _onRequestRide(
    RequestRide event,
    Emitter<RideState> emit,
  ) async {
    emit(const RideRequesting());

    try {
      final data = {
        'pickup_latitude': event.pickupLatitude,
        'pickup_longitude': event.pickupLongitude,
        'pickup_address': event.pickupAddress,
        'dropoff_latitude': event.dropoffLatitude,
        'dropoff_longitude': event.dropoffLongitude,
        'dropoff_address': event.dropoffAddress,
        'vehicle_category_id': event.vehicleCategoryId,
        if (event.passengerNotes != null)
          'passenger_notes': event.passengerNotes,
        if (event.paymentMethodId != null)
          'payment_method_id': event.paymentMethodId,
      };

      final result = await rideRepository.requestRide(data);

      if (result['success'] == true) {
        final ride = Ride.fromJson(result['data']);
        emit(RideRequested(ride));
      } else {
        emit(RideError(result['message'] ?? 'Erro ao solicitar corrida'));
      }
    } catch (e) {
      emit(RideError('Erro ao solicitar corrida: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCurrentRide(
    LoadCurrentRide event,
    Emitter<RideState> emit,
  ) async {
    emit(const RideLoading());

    try {
      final result = await rideRepository.getCurrentRide();

      if (result['success'] == true && result['data'] != null) {
        final ride = Ride.fromJson(result['data']);
        _emitRideStateByStatus(ride, emit);
      } else {
        emit(const NoActiveRide());
      }
    } catch (e) {
      emit(const NoActiveRide());
    }
  }

  Future<void> _onTrackRide(
    TrackRide event,
    Emitter<RideState> emit,
  ) async {
    try {
      final result = await rideRepository.getRide(event.rideId);

      if (result['success'] == true) {
        final ride = Ride.fromJson(result['data']);
        _emitRideStateByStatus(ride, emit);
      } else {
        emit(RideError(result['message'] ?? 'Erro ao rastrear corrida'));
      }
    } catch (e) {
      emit(RideError('Erro ao rastrear corrida: ${e.toString()}'));
    }
  }

  Future<void> _onCancelRide(
    CancelRideByPassenger event,
    Emitter<RideState> emit,
  ) async {
    final currentState = state;

    try {
      final result = await rideRepository.passengerCancelRide(
        event.rideId,
        event.reason ?? 'Cancelado pelo passageiro',
      );

      if (result['success'] == true) {
        final ride = Ride.fromJson(result['data']);
        emit(RideCancelled(ride: ride, reason: event.reason));
      } else {
        emit(RideError(result['message'] ?? 'Erro ao cancelar corrida'));
        if (currentState is! RideError) {
          emit(currentState);
        }
      }
    } catch (e) {
      emit(RideError('Erro ao cancelar corrida: ${e.toString()}'));
      if (currentState is! RideError) {
        emit(currentState);
      }
    }
  }

  Future<void> _onRateRide(
    RateRide event,
    Emitter<RideState> emit,
  ) async {
    final currentState = state;

    try {
      final data = {
        'rating': event.rating,
        if (event.comment != null) 'comment': event.comment,
        if (event.tags != null && event.tags!.isNotEmpty) 'tags': event.tags,
      };

      final result = await rideRepository.rateRide(event.rideId, data);

      if (result['success'] == true) {
        final ride = Ride.fromJson(result['data']);
        emit(RideRated(ride));
      } else {
        emit(RideError(result['message'] ?? 'Erro ao avaliar corrida'));
        if (currentState is! RideError) {
          emit(currentState);
        }
      }
    } catch (e) {
      emit(RideError('Erro ao avaliar corrida: ${e.toString()}'));
      if (currentState is! RideError) {
        emit(currentState);
      }
    }
  }

  Future<void> _onAddTip(
    AddTip event,
    Emitter<RideState> emit,
  ) async {
    final currentState = state;

    try {
      final result = await rideRepository.addTip(
        event.rideId,
        event.amount,
      );

      if (result['success'] == true) {
        final ride = Ride.fromJson(result['data']);
        emit(TipAdded(ride));
      } else {
        emit(RideError(result['message'] ?? 'Erro ao adicionar gorjeta'));
        if (currentState is! RideError) {
          emit(currentState);
        }
      }
    } catch (e) {
      emit(RideError('Erro ao adicionar gorjeta: ${e.toString()}'));
      if (currentState is! RideError) {
        emit(currentState);
      }
    }
  }

  Future<void> _onLoadRideHistory(
    LoadRideHistory event,
    Emitter<RideState> emit,
  ) async {
    emit(const RideLoading());

    try {
      final queryParams = <String, dynamic>{
        'page': event.page,
        if (event.status != null) 'status': event.status,
      };

      final result = await rideRepository.getRideHistory(queryParams);

      if (result['success'] == true) {
        final data = result['data'];
        final ridesData = data['data'] as List<dynamic>;
        final rides = ridesData.map((json) => Ride.fromJson(json)).toList();

        emit(RideHistoryLoaded(
          rides: rides,
          currentPage: data['current_page'] ?? event.page,
          totalPages: data['last_page'],
          hasMore: data['current_page'] < (data['last_page'] ?? 0),
        ));
      } else {
        emit(RideError(result['message'] ?? 'Erro ao carregar histórico'));
      }
    } catch (e) {
      emit(RideError('Erro ao carregar histórico: ${e.toString()}'));
    }
  }

  Future<void> _onGetRideDetails(
    GetRideDetails event,
    Emitter<RideState> emit,
  ) async {
    emit(const RideLoading());

    try {
      final result = await rideRepository.getRide(event.rideId);

      if (result['success'] == true) {
        final ride = Ride.fromJson(result['data']);
        emit(RideDetailsLoaded(ride));
      } else {
        emit(RideError(result['message'] ?? 'Erro ao carregar detalhes'));
      }
    } catch (e) {
      emit(RideError('Erro ao carregar detalhes: ${e.toString()}'));
    }
  }

  Future<void> _onClearCurrentRide(
    ClearCurrentRide event,
    Emitter<RideState> emit,
  ) async {
    emit(const NoActiveRide());
  }

  Future<void> _onRefreshRideStatus(
    RefreshRideStatus event,
    Emitter<RideState> emit,
  ) async {
    try {
      final result = await rideRepository.getRide(event.rideId);

      if (result['success'] == true) {
        final ride = Ride.fromJson(result['data']);
        _emitRideStateByStatus(ride, emit);
      }
    } catch (e) {
      // Silent fail - keep current state
    }
  }

  /// Helper method to emit the correct state based on ride status
  void _emitRideStateByStatus(Ride ride, Emitter<RideState> emit) {
    switch (ride.status) {
      case 'pending':
      case 'searching_driver':
        emit(RideRequested(ride));
        break;
      case 'accepted':
      case 'driver_assigned':
        emit(RideAccepted(ride));
        break;
      case 'driver_en_route':
        emit(DriverEnRoute(
          ride: ride,
          driverLatitude: ride.driverCurrentLatitude,
          driverLongitude: ride.driverCurrentLongitude,
        ));
        break;
      case 'driver_arrived':
        emit(DriverArrived(ride));
        break;
      case 'in_progress':
      case 'started':
        emit(RideInProgress(ride: ride));
        break;
      case 'completed':
        emit(RideCompleted(ride));
        break;
      case 'cancelled_by_passenger':
      case 'cancelled_by_driver':
      case 'cancelled':
        emit(RideCancelled(ride: ride));
        break;
      default:
        emit(RideDetailsLoaded(ride));
    }
  }
}
