import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobi_core/mobi_core.dart';
import 'active_ride_event.dart';
import 'active_ride_state.dart';

class ActiveRideBloc extends Bloc<ActiveRideEvent, ActiveRideState> {
  final RideRepository rideRepository;

  ActiveRideBloc({required this.rideRepository}) : super(const ActiveRideInitial()) {
    on<LoadActiveRide>(_onLoadActiveRide);
    on<MarkArrival>(_onMarkArrival);
    on<StartRide>(_onStartRide);
    on<CompleteRide>(_onCompleteRide);
    on<CancelRide>(_onCancelRide);
    on<UpdateDriverLocation>(_onUpdateDriverLocation);
    on<ClearActiveRide>(_onClearActiveRide);
  }

  Future<void> _onLoadActiveRide(
    LoadActiveRide event,
    Emitter<ActiveRideState> emit,
  ) async {
    emit(const ActiveRideLoading());

    try {
      final result = await rideRepository.getActiveRide();

      if (result['success'] == true) {
        final ride = Ride.fromJson(result['data']);
        emit(ActiveRideLoaded(ride));
      } else {
        emit(const NoActiveRide());
      }
    } catch (e) {
      emit(const NoActiveRide());
    }
  }

  Future<void> _onMarkArrival(
    MarkArrival event,
    Emitter<ActiveRideState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ActiveRideLoaded) return;

    emit(RideActionInProgress(action: 'arriving', ride: currentState.ride));

    try {
      final result = await rideRepository.markArrival(event.rideId);

      if (result['success'] == true) {
        final ride = Ride.fromJson(result['data']);
        emit(ActiveRideLoaded(ride));
      } else {
        emit(ActiveRideError(result['message'] ?? 'Erro ao marcar chegada'));
        emit(currentState);
      }
    } catch (e) {
      emit(ActiveRideError(e.toString()));
      emit(currentState);
    }
  }

  Future<void> _onStartRide(
    StartRide event,
    Emitter<ActiveRideState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ActiveRideLoaded) return;

    emit(RideActionInProgress(action: 'starting', ride: currentState.ride));

    try {
      final result = await rideRepository.startRide(event.rideId);

      if (result['success'] == true) {
        final ride = Ride.fromJson(result['data']);
        emit(ActiveRideLoaded(ride));
      } else {
        emit(ActiveRideError(result['message'] ?? 'Erro ao iniciar corrida'));
        emit(currentState);
      }
    } catch (e) {
      emit(ActiveRideError(e.toString()));
      emit(currentState);
    }
  }

  Future<void> _onCompleteRide(
    CompleteRide event,
    Emitter<ActiveRideState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ActiveRideLoaded) return;

    emit(RideActionInProgress(action: 'completing', ride: currentState.ride));

    try {
      final result = await rideRepository.completeRide(event.rideId, {
        'final_latitude': event.finalLatitude,
        'final_longitude': event.finalLongitude,
        'actual_distance_meters': event.actualDistanceMeters,
        'actual_duration_seconds': event.actualDurationSeconds,
      });

      if (result['success'] == true) {
        final ride = Ride.fromJson(result['data']);
        emit(RideCompleted(ride));
      } else {
        emit(ActiveRideError(result['message'] ?? 'Erro ao completar corrida'));
        emit(currentState);
      }
    } catch (e) {
      emit(ActiveRideError(e.toString()));
      emit(currentState);
    }
  }

  Future<void> _onCancelRide(
    CancelRide event,
    Emitter<ActiveRideState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ActiveRideLoaded) return;

    emit(RideActionInProgress(action: 'cancelling', ride: currentState.ride));

    try {
      final result = await rideRepository.driverCancelRide(event.rideId, event.reason);

      if (result['success'] == true) {
        final ride = Ride.fromJson(result['data']);
        emit(RideCancelled(ride));
      } else {
        emit(ActiveRideError(result['message'] ?? 'Erro ao cancelar corrida'));
        emit(currentState);
      }
    } catch (e) {
      emit(ActiveRideError(e.toString()));
      emit(currentState);
    }
  }

  Future<void> _onUpdateDriverLocation(
    UpdateDriverLocation event,
    Emitter<ActiveRideState> emit,
  ) async {
    // This would typically update the driver's location via API
    // For now, we'll just keep the current state
    // In Fase 2.5 with WebSocket, this will broadcast the location

    // Silent update - no state change needed
  }

  Future<void> _onClearActiveRide(
    ClearActiveRide event,
    Emitter<ActiveRideState> emit,
  ) async {
    emit(const NoActiveRide());
  }
}
