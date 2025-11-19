import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';

class RideDetailScreen extends StatelessWidget {
  final Ride ride;

  const RideDetailScreen({
    super.key,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Corrida #${ride.rideNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildRouteCard(),
            const SizedBox(height: 16),
            if (ride.driver != null) _buildDriverCard(),
            if (ride.driver != null) const SizedBox(height: 16),
            if (ride.vehicle != null) _buildVehicleCard(),
            if (ride.vehicle != null) const SizedBox(height: 16),
            _buildPriceCard(),
            const SizedBox(height: 16),
            _buildTimestampsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusColor = _getStatusColor(ride.status);
    final statusText = Formatters.formatStatus(ride.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(ride.status),
                size: 48,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            if (ride.cancellationReason != null) ...[
              const SizedBox(height: 8),
              Text(
                ride.cancellationReason!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rota',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildLocationRow(
              Icons.my_location,
              'Origem',
              ride.pickupAddress ?? 'N/A',
              AppConstants.successColor,
            ),
            const SizedBox(height: 16),
            _buildLocationRow(
              Icons.location_on,
              'Destino',
              ride.dropoffAddress ?? 'N/A',
              AppConstants.errorColor,
            ),
            if (ride.estimatedDistanceMeters != null ||
                ride.estimatedDurationSeconds != null) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (ride.estimatedDistanceMeters != null)
                    _buildInfoChip(
                      Icons.straighten,
                      Formatters.formatDistance(ride.estimatedDistanceMeters!),
                      'Distância',
                    ),
                  if (ride.estimatedDurationSeconds != null)
                    _buildInfoChip(
                      Icons.access_time,
                      Formatters.formatDuration(ride.estimatedDurationSeconds!),
                      'Duração',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard() {
    final driver = ride.driver!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Motorista',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: driver.profilePhotoUrl != null
                      ? NetworkImage(driver.profilePhotoUrl!)
                      : null,
                  child: driver.profilePhotoUrl == null
                      ? Text(
                          driver.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 24),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (driver.rating != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: AppConstants.warningColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              driver.rating!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard() {
    final vehicle = ride.vehicle!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Veículo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildVehicleInfo(Icons.directions_car, '${vehicle.brand} ${vehicle.model}'),
                _buildVehicleInfo(Icons.palette, vehicle.color),
                _buildVehicleInfo(Icons.pin, vehicle.plate),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pagamento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Corrida'),
                Text(Formatters.formatCurrency(ride.estimatedPrice)),
              ],
            ),
            if (ride.surgeMultiplier != null && ride.surgeMultiplier! > 1.0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tarifa dinâmica (${ride.surgeMultiplier!.toStringAsFixed(1)}x)',
                    style: const TextStyle(color: AppConstants.warningColor),
                  ),
                  Text(
                    Formatters.formatCurrency(
                      ride.estimatedPrice * (ride.surgeMultiplier! - 1),
                    ),
                    style: const TextStyle(color: AppConstants.warningColor),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getPaymentIcon(ride.paymentMethod),
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _getPaymentMethodText(ride.paymentMethod),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                if (ride.paymentStatus != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ride.paymentStatus == 'completed'
                          ? AppConstants.successColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ride.paymentStatus == 'completed' ? 'Pago' : ride.paymentStatus!,
                      style: TextStyle(
                        fontSize: 12,
                        color: ride.paymentStatus == 'completed'
                            ? AppConstants.successColor
                            : Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Linha do Tempo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (ride.createdAt != null)
              _buildTimestamp('Solicitada', ride.createdAt!),
            if (ride.acceptedAt != null)
              _buildTimestamp('Aceita pelo motorista', ride.acceptedAt!),
            if (ride.startedAt != null)
              _buildTimestamp('Iniciada', ride.startedAt!),
            if (ride.completedAt != null)
              _buildTimestamp('Concluída', ride.completedAt!),
            if (ride.cancelledAt != null)
              _buildTimestamp('Cancelada', ride.cancelledAt!),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String label, String address, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                address,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleInfo(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTimestamp(String label, DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppConstants.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            Formatters.formatDateTime(timestamp),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'in_progress':
        return Icons.navigation;
      case 'searching':
        return Icons.search;
      case 'accepted':
        return Icons.directions_car;
      case 'arrived':
        return Icons.location_on;
      default:
        return Icons.help;
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'pix':
        return Icons.qr_code;
      case 'credit_card':
      case 'card':
        return Icons.credit_card;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method.toLowerCase()) {
      case 'pix':
        return 'PIX';
      case 'credit_card':
      case 'card':
        return 'Cartão de Crédito';
      case 'cash':
        return 'Dinheiro';
      default:
        return method;
    }
  }
}
