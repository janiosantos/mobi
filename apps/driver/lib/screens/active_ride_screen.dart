import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobi_core/mobi_core.dart';
import '../bloc/active_ride/active_ride_bloc.dart';
import '../bloc/active_ride/active_ride_event.dart';
import '../bloc/active_ride/active_ride_state.dart';
import '../core/service_locator.dart';

class ActiveRideScreen extends StatefulWidget {
  final Ride ride;

  const ActiveRideScreen({
    super.key,
    required this.ride,
  });

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _updateMarkers(widget.ride);
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startLocationUpdates() {
    // Update driver location every 5 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final locationService = getIt<LocationService>();
        final position = await locationService.getCurrentPosition();

        if (!mounted) return;

        context.read<ActiveRideBloc>().add(
              UpdateDriverLocation(
                rideId: widget.ride.id,
                latitude: position.latitude,
                longitude: position.longitude,
              ),
            );
      } catch (e) {
        // Silent fail
      }
    });
  }

  void _updateMarkers(Ride ride) {
    _markers.clear();

    // Pickup marker
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(
          ride.pickupLatitude,
          ride.pickupLongitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Origem',
          snippet: ride.pickupAddress,
        ),
      ),
    );

    // Dropoff marker
    _markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(
          ride.dropoffLatitude,
          ride.dropoffLongitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Destino',
          snippet: ride.dropoffAddress,
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, Ride ride) async {
    if (ride.status == 'accepted') {
      // Mark arrival
      context.read<ActiveRideBloc>().add(MarkArrival(ride.id));
    } else if (ride.status == 'arrived') {
      // Start ride
      context.read<ActiveRideBloc>().add(StartRide(ride.id));
    } else if (ride.status == 'in_progress') {
      // Complete ride
      _showCompleteDialog(context, ride);
    }
  }

  void _showCompleteDialog(BuildContext context, Ride ride) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Corrida'),
        content: const Text('Confirma que a corrida foi finalizada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Get current location for final position
              try {
                final locationService = getIt<LocationService>();
                final position = await locationService.getCurrentPosition();

                // Calculate actual duration (mock for now)
                final duration = ride.estimatedDurationSeconds ?? 0;
                final distance = ride.estimatedDistanceMeters ?? 0;

                if (!context.mounted) return;

                context.read<ActiveRideBloc>().add(
                      CompleteRide(
                        rideId: ride.id,
                        finalLatitude: position.latitude,
                        finalLongitude: position.longitude,
                        actualDistanceMeters: distance,
                        actualDurationSeconds: duration,
                      ),
                    );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao obter localização: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancel(BuildContext context, Ride ride) async {
    final reasons = [
      'Passageiro não apareceu',
      'Endereço incorreto',
      'Passageiro cancelou',
      'Outro motivo',
    ];

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Corrida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons
              .map(
                (r) => ListTile(
                  title: Text(r),
                  onTap: () => Navigator.pop(context, r),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (reason != null && context.mounted) {
      context.read<ActiveRideBloc>().add(
            CancelRide(rideId: ride.id, reason: reason),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActiveRideBloc(
        rideRepository: getIt<RideRepository>(),
      )..add(const LoadActiveRide()),
      child: BlocConsumer<ActiveRideBloc, ActiveRideState>(
        listener: (context, state) {
          if (state is ActiveRideError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is RideCompleted || state is RideCancelled) {
            _locationTimer?.cancel();
            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state is RideCompleted
                      ? 'Corrida finalizada com sucesso!'
                      : 'Corrida cancelada',
                ),
                backgroundColor: state is RideCompleted
                    ? AppConstants.successColor
                    : AppConstants.warningColor,
              ),
            );
          }
        },
        builder: (context, state) {
          final ride = state is ActiveRideLoaded
              ? state.ride
              : state is RideActionInProgress
                  ? state.ride
                  : widget.ride;

          final isActionInProgress = state is RideActionInProgress;

          return Scaffold(
            body: Stack(
              children: [
                _buildMap(ride),
                _buildStatusBar(ride),
                _buildPassengerInfo(ride),
              ],
            ),
            bottomNavigationBar: _buildActionBar(context, ride, state, isActionInProgress),
          );
        },
      ),
    );
  }

  Widget _buildMap(Ride ride) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          ride.pickupLatitude,
          ride.pickupLongitude,
        ),
        zoom: 15,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        _fitBounds(ride);
      },
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      compassEnabled: true,
    );
  }

  void _fitBounds(Ride ride) {
    if (_mapController == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        ride.pickupLatitude < ride.dropoffLatitude
            ? ride.pickupLatitude
            : ride.dropoffLatitude,
        ride.pickupLongitude < ride.dropoffLongitude
            ? ride.pickupLongitude
            : ride.dropoffLongitude,
      ),
      northeast: LatLng(
        ride.pickupLatitude > ride.dropoffLatitude
            ? ride.pickupLatitude
            : ride.dropoffLatitude,
        ride.pickupLongitude > ride.dropoffLongitude
            ? ride.pickupLongitude
            : ride.dropoffLongitude,
      ),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  Widget _buildStatusBar(Ride ride) {
    final statusConfig = _getStatusConfig(ride.status);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusConfig['color'] as Color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                statusConfig['icon'] as IconData,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusConfig['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (statusConfig['subtitle'] != null)
                      Text(
                        statusConfig['subtitle'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'accepted':
        return {
          'title': 'Indo buscar passageiro',
          'subtitle': 'Dirija até o local de origem',
          'icon': Icons.directions_car,
          'color': AppConstants.infoColor,
        };
      case 'arrived':
        return {
          'title': 'Você chegou!',
          'subtitle': 'Aguarde o passageiro entrar no veículo',
          'icon': Icons.location_on,
          'color': AppConstants.warningColor,
        };
      case 'in_progress':
        return {
          'title': 'Corrida em andamento',
          'subtitle': 'Dirija com segurança até o destino',
          'icon': Icons.navigation,
          'color': AppConstants.successColor,
        };
      default:
        return {
          'title': 'Status desconhecido',
          'icon': Icons.help,
          'color': Colors.grey,
        };
    }
  }

  Widget _buildPassengerInfo(Ride ride) {
    if (ride.passenger == null) return const SizedBox.shrink();

    final passenger = ride.passenger!;

    return Positioned(
      bottom: 140,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: passenger.profilePhotoUrl != null
                  ? NetworkImage(passenger.profilePhotoUrl!)
                  : null,
              child: passenger.profilePhotoUrl == null
                  ? Text(
                      passenger.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    passenger.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: AppConstants.warningColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        passenger.rating?.toStringAsFixed(1) ?? '5.0',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.phone, color: AppConstants.primaryColor),
              onPressed: () {
                // TODO: Call passenger
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tel: ${passenger.phone ?? "N/A"}')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, Ride ride, ActiveRideState state, bool isLoading) {
    final statusConfig = _getStatusConfig(ride.status);
    String buttonText;
    IconData buttonIcon;

    if (ride.status == 'accepted') {
      buttonText = 'Cheguei ao Local';
      buttonIcon = Icons.location_on;
    } else if (ride.status == 'arrived') {
      buttonText = 'Iniciar Corrida';
      buttonIcon = Icons.play_arrow;
    } else if (ride.status == 'in_progress') {
      buttonText = 'Finalizar Corrida';
      buttonIcon = Icons.check_circle;
    } else {
      buttonText = 'Ação não disponível';
      buttonIcon = Icons.help;
    }

    final canCancel = ride.status == 'accepted' || ride.status == 'arrived';

    return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              text: buttonText,
              icon: buttonIcon,
              isLoading: isLoading,
              onPressed: () => _handleAction(context, ride),
            ),
            if (canCancel) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: isLoading ? null : () => _handleCancel(context, ride),
                icon: const Icon(Icons.cancel_outlined, color: AppConstants.errorColor),
                label: const Text(
                  'Cancelar Corrida',
                  style: TextStyle(color: AppConstants.errorColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppConstants.errorColor),
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
