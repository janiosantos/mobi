import 'package:equatable/equatable.dart';
import 'package:mobi_core/mobi_core.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class GetCurrentLocation extends LocationEvent {
  const GetCurrentLocation();
}

class UpdateCurrentLocation extends LocationEvent {
  final Location location;

  const UpdateCurrentLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class SearchAddress extends LocationEvent {
  final String query;

  const SearchAddress(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectPickupLocation extends LocationEvent {
  final Location location;

  const SelectPickupLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class SelectDropoffLocation extends LocationEvent {
  final Location location;

  const SelectDropoffLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class ClearLocations extends LocationEvent {
  const ClearLocations();
}
