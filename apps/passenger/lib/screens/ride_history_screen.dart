import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';
import '../core/service_locator.dart';
import 'ride_detail_screen.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  String _selectedFilter = 'all';
  List<Ride> _rides = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

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

        setState(() {
          _rides = rides;
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
        title: const Text('Minhas Corridas'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterChips(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Todas', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Concluídas', 'completed'),
            const SizedBox(width: 8),
            _buildFilterChip('Canceladas', 'cancelled'),
            const SizedBox(width: 8),
            _buildFilterChip('Em andamento', 'in_progress'),
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
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all'
                  ? 'Você ainda não fez nenhuma corrida'
                  : 'Nenhuma corrida ${_getFilterLabel()}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
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

  String _getFilterLabel() {
    switch (_selectedFilter) {
      case 'completed':
        return 'concluída';
      case 'cancelled':
        return 'cancelada';
      case 'in_progress':
        return 'em andamento';
      default:
        return '';
    }
  }

  Widget _buildRideCard(Ride ride) {
    final statusColor = _getStatusColor(ride.status);
    final statusText = Formatters.formatStatus(ride.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RideDetailScreen(ride: ride),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
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
                  Text(
                    Formatters.formatCurrency(ride.finalPrice ?? ride.estimatedPrice),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ],
              ),
              if (ride.driver != null) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: ride.driver!.profilePhotoUrl != null
                          ? NetworkImage(ride.driver!.profilePhotoUrl!)
                          : null,
                      child: ride.driver!.profilePhotoUrl == null
                          ? Text(
                              ride.driver!.name[0].toUpperCase(),
                              style: const TextStyle(fontSize: 14),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ride.driver!.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    if (ride.driver!.rating != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppConstants.warningColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ride.driver!.rating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ],
          ),
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
