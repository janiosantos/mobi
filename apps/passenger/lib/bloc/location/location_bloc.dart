import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobi_core/mobi_core.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService locationService;

  LocationBloc({required this.locationService}) : super(const LocationInitial()) {
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<UpdateCurrentLocation>(_onUpdateCurrentLocation);
    on<SelectPickupLocation>(_onSelectPickupLocation);
    on<SelectDropoffLocation>(_onSelectDropoffLocation);
    on<ClearLocations>(_onClearLocations);
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());

    try {
      final hasPermission = await locationService.requestLocationPermission();

      if (!hasPermission) {
        emit(const LocationPermissionDenied());
        return;
      }

      final location = await locationService.getCurrentLocationWithAddress();

      if (location != null) {
        emit(LocationLoaded(currentLocation: location));
      } else {
        emit(const LocationError('Não foi possível obter sua localização'));
      }
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  void _onUpdateCurrentLocation(
    UpdateCurrentLocation event,
    Emitter<LocationState> emit,
  ) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      emit(currentState.copyWith(currentLocation: event.location));
    } else {
      emit(LocationLoaded(currentLocation: event.location));
    }
  }

  void _onSelectPickupLocation(
    SelectPickupLocation event,
    Emitter<LocationState> emit,
  ) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      emit(currentState.copyWith(pickupLocation: event.location));
    }
  }

  void _onSelectDropoffLocation(
    SelectDropoffLocation event,
    Emitter<LocationState> emit,
  ) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      emit(currentState.copyWith(dropoffLocation: event.location));
    }
  }

  void _onClearLocations(
    ClearLocations event,
    Emitter<LocationState> emit,
  ) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      emit(LocationLoaded(
        currentLocation: currentState.currentLocation,
      ));
    }
  }
}
