import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobi_core/mobi_core.dart';
import '../bloc/location/location_bloc.dart';
import '../bloc/location/location_event.dart';
import '../bloc/location/location_state.dart';
import '../core/service_locator.dart';
import 'search_location_screen.dart';
import 'ride_estimate_screen.dart';

class RequestRideScreen extends StatefulWidget {
  const RequestRideScreen({super.key});

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationBloc(
        locationService: getIt<LocationService>(),
      )..add(const GetCurrentLocation()),
      child: Scaffold(
        body: BlocConsumer<LocationBloc, LocationState>(
          listener: (context, state) {
            if (state is LocationPermissionDenied) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permissão de localização negada'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is LocationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is LocationLoaded) {
              _updateMarkers(state);
              _animateToLocation(state.currentLocation);
            }
          },
          builder: (context, state) {
            if (state is LocationLoading || state is LocationInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LocationPermissionDenied) {
              return _buildPermissionDenied(context);
            }

            if (state is LocationLoaded) {
              return _buildMapView(context, state);
            }

            return const Center(child: Text('Erro ao carregar localização'));
          },
        ),
      ),
    );
  }

  Widget _buildPermissionDenied(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Permissão de localização necessária',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Para solicitar corridas, precisamos acessar sua localização',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Permitir Localização',
              onPressed: () {
                context.read<LocationBloc>().add(const GetCurrentLocation());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView(BuildContext context, LocationLoaded state) {
    return Stack(
      children: [
        // Google Maps
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              state.currentLocation.latitude,
              state.currentLocation.longitude,
            ),
            zoom: AppConstants.defaultMapZoom,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
          },
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),

        // Top card with addresses
        SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildAddressField(
                      context,
                      icon: Icons.my_location,
                      label: 'Origem',
                      address: state.pickupLocation?.address ?? 'Onde você está?',
                      color: AppConstants.successColor,
                      onTap: () => _searchLocation(context, isPickup: true),
                    ),
                    const Divider(height: 1),
                    _buildAddressField(
                      context,
                      icon: Icons.location_on,
                      label: 'Destino',
                      address: state.dropoffLocation?.address ?? 'Para onde vai?',
                      color: AppConstants.errorColor,
                      onTap: () => _searchLocation(context, isPickup: false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom button
        if (state.canRequestRide)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: CustomButton(
                  text: 'Ver Preços e Solicitar',
                  icon: Icons.local_taxi,
                  onPressed: () => _showRideEstimate(context, state),
                ),
              ),
            ),
          ),

        // My location button
        Positioned(
          bottom: state.canRequestRide ? 100 : 32,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => _animateToLocation(state.currentLocation),
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: AppConstants.primaryColor),
          ),
        ),

        // Back button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String address,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.search, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _updateMarkers(LocationLoaded state) {
    _markers.clear();

    if (state.hasPickup) {
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(
            state.pickupLocation!.latitude,
            state.pickupLocation!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'Origem', snippet: state.pickupLocation!.address),
        ),
      );
    }

    if (state.hasDropoff) {
      _markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(
            state.dropoffLocation!.latitude,
            state.dropoffLocation!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'Destino', snippet: state.dropoffLocation!.address),
        ),
      );
    }

    setState(() {});
  }

  void _animateToLocation(Location location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        AppConstants.defaultMapZoom,
      ),
    );
  }

  Future<void> _searchLocation(BuildContext context, {required bool isPickup}) async {
    final location = await Navigator.of(context).push<Location>(
      MaterialPageRoute(
        builder: (_) => SearchLocationScreen(isPickup: isPickup),
      ),
    );

    if (location != null && mounted) {
      if (isPickup) {
        context.read<LocationBloc>().add(SelectPickupLocation(location));
      } else {
        context.read<LocationBloc>().add(SelectDropoffLocation(location));
      }
    }
  }

  void _showRideEstimate(BuildContext context, LocationLoaded state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RideEstimateScreen(
          pickupLocation: state.pickupLocation!,
          dropoffLocation: state.dropoffLocation!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
