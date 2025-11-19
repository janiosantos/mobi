import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';
import '../core/service_locator.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  String _selectedFilter = 'completed';
  List<Ride> _rides = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  double _totalEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _loadRides() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final rideRepository = getIt<RideRepository>();
      final result = await rideRepository.getRides(
        status: _selectedFilter == 'all' ? null : _selectedFilter,
      );

      if (result['success'] == true) {
        final List<dynamic> ridesData = result['data']['data'] ?? [];
        final rides = ridesData.map((json) => Ride.fromJson(json)).toList();

        // Calculate total earnings from completed rides
        double earnings = 0.0;
        for (var ride in rides) {
          if (ride.status == 'completed') {
            // Driver gets 80% (platform keeps 20%)
            final driverShare = (ride.finalPrice ?? ride.estimatedPrice) * 0.8;
            earnings += driverShare;
          }
        }

        setState(() {
          _rides = rides;
          _totalEarnings = earnings;
          _isLoading = false;
        });
      } else {
        throw Exception(result['message'] ?? 'Erro ao carregar corridas');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Corridas'),
      ),
      body: Column(
        children: [
          if (_selectedFilter == 'completed' && !_isLoading)
            _buildEarningsCard(),
          _buildFilterChips(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryColor, AppConstants.infoColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total de Ganhos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCurrency(_totalEarnings),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_rides.length} corridas concluídas',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Concluídas', 'completed'),
            const SizedBox(width: 8),
            _buildFilterChip('Canceladas', 'cancelled'),
            const SizedBox(width: 8),
            _buildFilterChip('Todas', 'all'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = value);
          _loadRides();
        }
      },
      selectedColor: AppConstants.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRides,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_rides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma corrida encontrada',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRides,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rides.length,
        itemBuilder: (context, index) {
          final ride = _rides[index];
          return _buildRideCard(ride);
        },
      ),
    );
  }

  Widget _buildRideCard(Ride ride) {
    final statusColor = _getStatusColor(ride.status);
    final statusText = Formatters.formatStatus(ride.status);
    final driverEarning = ride.status == 'completed'
        ? (ride.finalPrice ?? ride.estimatedPrice) * 0.8
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${ride.rideNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLocationRow(
              Icons.my_location,
              ride.pickupAddress ?? 'Endereço não disponível',
              AppConstants.successColor,
            ),
            const SizedBox(height: 8),
            _buildLocationRow(
              Icons.location_on,
              ride.dropoffAddress ?? 'Endereço não disponível',
              AppConstants.errorColor,
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (ride.createdAt != null)
                  Text(
                    Formatters.formatDate(ride.createdAt!),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (ride.status == 'completed')
                      Text(
                        Formatters.formatCurrency(driverEarning),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.successColor,
                        ),
                      )
                    else
                      Text(
                        Formatters.formatCurrency(ride.finalPrice ?? ride.estimatedPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    if (ride.status == 'completed')
                      Text(
                        'Seu ganho (80%)',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (ride.passenger != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: ride.passenger!.profilePhotoUrl != null
                        ? NetworkImage(ride.passenger!.profilePhotoUrl!)
                        : null,
                    child: ride.passenger!.profilePhotoUrl == null
                        ? Text(
                            ride.passenger!.name[0].toUpperCase(),
                            style: const TextStyle(fontSize: 14),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride.passenger!.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String address, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppConstants.successColor;
      case 'cancelled':
        return AppConstants.errorColor;
      case 'in_progress':
        return AppConstants.infoColor;
      case 'searching':
      case 'accepted':
      case 'arrived':
        return AppConstants.warningColor;
      default:
        return Colors.grey;
    }
  }
}
