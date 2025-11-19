import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobi_core/mobi_core.dart';
import 'available_rides_event.dart';
import 'available_rides_state.dart';

class AvailableRidesBloc extends Bloc<AvailableRidesEvent, AvailableRidesState> {
  final RideRepository rideRepository;

  AvailableRidesBloc({required this.rideRepository}) : super(const AvailableRidesInitial()) {
    on<LoadAvailableRides>(_onLoadAvailableRides);
    on<RefreshAvailableRides>(_onRefreshAvailableRides);
    on<AcceptRideRequested>(_onAcceptRideRequested);
    on<ClearAvailableRides>(_onClearAvailableRides);
  }

  Future<void> _onLoadAvailableRides(
    LoadAvailableRides event,
    Emitter<AvailableRidesState> emit,
  ) async {
    emit(const AvailableRidesLoading());

    try {
      final result = await rideRepository.getAvailableRides(
        latitude: event.latitude,
        longitude: event.longitude,
        radius: event.radius,
      );

      if (result['success'] == true) {
        final List<dynamic> ridesData = result['data']['data'] ?? [];
        final rides = ridesData.map((json) => Ride.fromJson(json)).toList();

        emit(AvailableRidesLoaded(rides));
      } else {
        emit(AvailableRidesError(result['message'] ?? 'Erro ao carregar corridas'));
      }
    } catch (e) {
      emit(AvailableRidesError(e.toString()));
    }
  }

  Future<void> _onRefreshAvailableRides(
    RefreshAvailableRides event,
    Emitter<AvailableRidesState> emit,
  ) async {
    // Keep the current rides while refreshing
    final currentState = state;

    try {
      // This will use the last known location
      // In a real app, we would get the current location from LocationService
      // For now, we just emit an error if we can't refresh

      emit(const AvailableRidesError('Refresh not implemented - need current location'));
    } catch (e) {
      // If refresh fails, restore previous state
      if (currentState is AvailableRidesLoaded) {
        emit(currentState);
      } else {
        emit(AvailableRidesError(e.toString()));
      }
    }
  }

  Future<void> _onAcceptRideRequested(
    AcceptRideRequested event,
    Emitter<AvailableRidesState> emit,
  ) async {
    emit(RideAccepting(event.rideId));

    try {
      final result = await rideRepository.acceptRide(event.rideId);

      if (result['success'] == true) {
        final ride = Ride.fromJson(result['data']);
        emit(RideAccepted(ride));
      } else {
        emit(RideAcceptError(result['message'] ?? 'Erro ao aceitar corrida'));
      }
    } catch (e) {
      emit(RideAcceptError(e.toString()));
    }
  }

  Future<void> _onClearAvailableRides(
    ClearAvailableRides event,
    Emitter<AvailableRidesState> emit,
  ) async {
    emit(const AvailableRidesInitial());
  }
}
