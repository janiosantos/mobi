import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobi_core/mobi_core.dart';
import '../core/service_locator.dart';
import 'ride_rating_screen.dart';

class RideTrackingScreen extends StatefulWidget {
  final Ride ride;

  const RideTrackingScreen({
    super.key,
    required this.ride,
  });

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  GoogleMapController? _mapController;
  Timer? _statusTimer;
  Ride? _currentRide;
  final Set<Marker> _markers = {};
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _currentRide = widget.ride;
    _updateMarkers();
    _startStatusPolling();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startStatusPolling() {
    // Poll ride status every 5 seconds
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _refreshRideStatus();
    });
  }

  Future<void> _refreshRideStatus() async {
    try {
      final rideRepository = getIt<RideRepository>();
      final result = await rideRepository.getRideDetail(_currentRide!.id);

      if (result['success'] == true && mounted) {
        final updatedRide = Ride.fromJson(result['data']);

        setState(() {
          _currentRide = updatedRide;
          _updateMarkers();
        });

        // Navigate to rating if completed
        if (updatedRide.status == 'completed') {
          _statusTimer?.cancel();
          _navigateToRating();
        }
      }
    } catch (e) {
      // Silent fail - will retry on next poll
    }
  }

  void _updateMarkers() {
    _markers.clear();

    // Pickup marker
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(
          _currentRide!.pickupLatitude,
          _currentRide!.pickupLongitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Origem',
          snippet: _currentRide!.pickupAddress,
        ),
      ),
    );

    // Dropoff marker
    _markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(
          _currentRide!.dropoffLatitude,
          _currentRide!.dropoffLongitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Destino',
          snippet: _currentRide!.dropoffAddress,
        ),
      ),
    );

    // Driver marker (would need real-time location updates via WebSocket - Fase 2)
    // For now, we only show pickup and dropoff markers
  }

  Future<void> _cancelRide() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Corrida'),
        content: const Text('Tem certeza que deseja cancelar esta corrida?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);

    try {
      final rideRepository = getIt<RideRepository>();
      final result = await rideRepository.cancelRide(
        _currentRide!.id,
        'Cancelado pelo passageiro',
      );

      if (result['success'] == true && mounted) {
        _statusTimer?.cancel();
        Navigator.of(context).popUntil((route) => route.isFirst);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Corrida cancelada com sucesso'),
            backgroundColor: AppConstants.warningColor,
          ),
        );
      } else {
        throw Exception(result['message'] ?? 'Erro ao cancelar corrida');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  void _navigateToRating() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RideRatingScreen(ride: _currentRide!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildStatusBanner(),
          if (_currentRide!.status != 'searching')
            _buildDriverInfo(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          _currentRide!.pickupLatitude,
          _currentRide!.pickupLongitude,
        ),
        zoom: 15,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        _fitBounds();
      },
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      compassEnabled: true,
    );
  }

  void _fitBounds() {
    if (_mapController == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _currentRide!.pickupLatitude < _currentRide!.dropoffLatitude
            ? _currentRide!.pickupLatitude
            : _currentRide!.dropoffLatitude,
        _currentRide!.pickupLongitude < _currentRide!.dropoffLongitude
            ? _currentRide!.pickupLongitude
            : _currentRide!.dropoffLongitude,
      ),
      northeast: LatLng(
        _currentRide!.pickupLatitude > _currentRide!.dropoffLatitude
            ? _currentRide!.pickupLatitude
            : _currentRide!.dropoffLatitude,
        _currentRide!.pickupLongitude > _currentRide!.dropoffLongitude
            ? _currentRide!.pickupLongitude
            : _currentRide!.dropoffLongitude,
      ),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  Widget _buildStatusBanner() {
    final statusConfig = _getStatusConfig();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusConfig['color'],
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
              if (_currentRide!.status == 'searching' ||
                  _currentRide!.status == 'accepted')
                if (_isCancelling)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _cancelRide,
                    tooltip: 'Cancelar',
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig() {
    switch (_currentRide!.status) {
      case 'searching':
        return {
          'title': 'Procurando motorista...',
          'subtitle': 'Aguarde, estamos encontrando o melhor motorista',
          'icon': Icons.search,
          'color': AppConstants.primaryColor,
        };
      case 'accepted':
        return {
          'title': 'Motorista a caminho',
          'subtitle': 'Aguarde, o motorista está vindo buscar você',
          'icon': Icons.directions_car,
          'color': AppConstants.infoColor,
        };
      case 'arrived':
        return {
          'title': 'Motorista chegou!',
          'subtitle': 'Seu motorista está te esperando',
          'icon': Icons.location_on,
          'color': AppConstants.successColor,
        };
      case 'in_progress':
        return {
          'title': 'Viagem em andamento',
          'subtitle': _currentRide!.estimatedDurationSeconds != null
              ? 'Chegada prevista em ${Formatters.formatDuration(_currentRide!.estimatedDurationSeconds!)}'
              : null,
          'icon': Icons.navigation,
          'color': AppConstants.successColor,
        };
      case 'completed':
        return {
          'title': 'Viagem concluída',
          'subtitle': 'Obrigado por usar MOBI!',
          'icon': Icons.check_circle,
          'color': AppConstants.successColor,
        };
      case 'cancelled':
        return {
          'title': 'Corrida cancelada',
          'subtitle': _currentRide!.cancellationReason,
          'icon': Icons.cancel,
          'color': AppConstants.errorColor,
        };
      default:
        return {
          'title': 'Status desconhecido',
          'icon': Icons.help,
          'color': Colors.grey,
        };
    }
  }

  Widget _buildDriverInfo() {
    if (_currentRide!.driver == null) {
      return const SizedBox.shrink();
    }

    final driver = _currentRide!.driver!;

    return Positioned(
      bottom: 0,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Driver photo
                CircleAvatar(
                  radius: 30,
                  backgroundImage: driver.profilePhotoUrl != null
                      ? NetworkImage(driver.profilePhotoUrl!)
                      : null,
                  child: driver.profilePhotoUrl == null
                      ? Text(
                          driver.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Driver info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppConstants.warningColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            driver.rating?.toStringAsFixed(1) ?? '5.0',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Contact button
                IconButton(
                  icon: const Icon(Icons.phone),
                  color: AppConstants.primaryColor,
                  onPressed: () {
                    // TODO: Implement phone call
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Telefone: ${driver.phone ?? 'N/A'}'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Vehicle info
            if (_currentRide!.vehicle != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildVehicleDetail(
                    Icons.directions_car,
                    '${_currentRide!.vehicle!.brand} ${_currentRide!.vehicle!.model}',
                  ),
                  _buildVehicleDetail(
                    Icons.palette,
                    _currentRide!.vehicle!.color,
                  ),
                  _buildVehicleDetail(
                    Icons.pin,
                    _currentRide!.vehicle!.plate,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
