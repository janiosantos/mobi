import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';
import '../core/service_locator.dart';
import 'ride_tracking_screen.dart';

class RideEstimateScreen extends StatefulWidget {
  final Location pickupLocation;
  final Location dropoffLocation;

  const RideEstimateScreen({
    super.key,
    required this.pickupLocation,
    required this.dropoffLocation,
  });

  @override
  State<RideEstimateScreen> createState() => _RideEstimateScreenState();
}

class _RideEstimateScreenState extends State<RideEstimateScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _estimateData;
  String? _selectedCategory;
  String _selectedPaymentMethod = 'pix';
  bool _isRequestingRide = false;

  @override
  void initState() {
    super.initState();
    _loadEstimate();
  }

  Future<void> _loadEstimate() async {
    setState(() => _isLoading = true);

    try {
      final rideRepository = getIt<RideRepository>();

      final result = await rideRepository.estimateRide({
        'pickup_latitude': widget.pickupLocation.latitude,
        'pickup_longitude': widget.pickupLocation.longitude,
        'dropoff_latitude': widget.dropoffLocation.latitude,
        'dropoff_longitude': widget.dropoffLocation.longitude,
      });

      if (result['success'] == true && mounted) {
        setState(() {
          _estimateData = result['data'];
          _isLoading = false;
        });
      } else {
        throw Exception(result['message'] ?? 'Erro ao estimar corrida');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Corrida'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRouteInfo(),
                  const SizedBox(height: 16),
                  _buildVehicleCategories(),
                  const SizedBox(height: 16),
                  _buildPaymentMethods(),
                  const SizedBox(height: 16),
                  _buildEstimateDetails(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildRouteInfo() {
    final distance = _estimateData?['estimated_distance_meters'] ?? 0;
    final duration = _estimateData?['estimated_duration_seconds'] ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.my_location, color: AppConstants.successColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.pickupLocation.address ?? 'Origem',
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppConstants.errorColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.dropoffLocation.address ?? 'Destino',
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.straighten, color: Colors.grey.shade600, size: 16),
              const SizedBox(width: 4),
              Text(
                Formatters.formatDistance(distance),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, color: Colors.grey.shade600, size: 16),
              const SizedBox(width: 4),
              Text(
                Formatters.formatDuration(duration),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCategories() {
    // Mock categories - Em produção, vem da API
    final categories = [
      {'id': '1', 'name': 'MOBI X', 'description': 'Econômico', 'price': 15.50, 'icon': '🚗'},
      {'id': '2', 'name': 'MOBI Confort', 'description': 'Conforto', 'price': 22.00, 'icon': '🚙'},
      {'id': '3', 'name': 'MOBI Black', 'description': 'Premium', 'price': 35.00, 'icon': '🚘'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Escolha o veículo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _selectedCategory == category['id'];

            return InkWell(
              onTap: () => setState(() => _selectedCategory = category['id'] as String),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppConstants.primaryColor : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected ? AppConstants.primaryColor.withOpacity(0.05) : null,
                ),
                child: Row(
                  children: [
                    Text(category['icon'] as String, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category['name'] as String,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            category['description'] as String,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(category['price'] as double),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      {'value': 'pix', 'name': 'PIX', 'icon': Icons.pix},
      {'value': 'credit_card', 'name': 'Cartão de Crédito', 'icon': Icons.credit_card},
      {'value': 'cash', 'name': 'Dinheiro', 'icon': Icons.money},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Forma de pagamento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: methods.length,
            itemBuilder: (context, index) {
              final method = methods[index];
              final isSelected = _selectedPaymentMethod == method['value'];

              return InkWell(
                onTap: () => setState(() => _selectedPaymentMethod = method['value'] as String),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? AppConstants.primaryColor : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected ? AppConstants.primaryColor.withOpacity(0.05) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        method['icon'] as IconData,
                        size: 32,
                        color: isSelected ? AppConstants.primaryColor : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        method['name'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEstimateDetails() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Corrida', style: TextStyle(fontSize: 14)),
              Text(
                'R\$ 15,50',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tarifa dinâmica', style: TextStyle(fontSize: 14)),
              Text(
                'R\$ 0,00',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total estimado',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'R\$ 15,50',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
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
        child: CustomButton(
          text: 'Solicitar MOBI X',
          icon: Icons.local_taxi,
          isLoading: _isRequestingRide,
          onPressed: _selectedCategory != null ? _requestRide : null,
        ),
      ),
    );
  }

  Future<void> _requestRide() async {
    setState(() => _isRequestingRide = true);

    try {
      final rideRepository = getIt<RideRepository>();

      final result = await rideRepository.requestRide({
        'pickup_latitude': widget.pickupLocation.latitude,
        'pickup_longitude': widget.pickupLocation.longitude,
        'pickup_address': widget.pickupLocation.address,
        'dropoff_latitude': widget.dropoffLocation.latitude,
        'dropoff_longitude': widget.dropoffLocation.longitude,
        'dropoff_address': widget.dropoffLocation.address,
        'vehicle_category_id': _selectedCategory,
        'payment_method': _selectedPaymentMethod,
      });

      if (result['success'] == true && mounted) {
        final ride = Ride.fromJson(result['data']);

        // Navegar para tela de tracking
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => RideTrackingScreen(ride: ride),
          ),
          (route) => route.isFirst,
        );
      } else {
        throw Exception(result['message'] ?? 'Erro ao solicitar corrida');
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
        setState(() => _isRequestingRide = false);
      }
    }
  }
}
