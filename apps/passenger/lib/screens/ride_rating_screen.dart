import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';
import '../core/service_locator.dart';

class RideRatingScreen extends StatefulWidget {
  final Ride ride;

  const RideRatingScreen({
    super.key,
    required this.ride,
  });

  @override
  State<RideRatingScreen> createState() => _RideRatingScreenState();
}

class _RideRatingScreenState extends State<RideRatingScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma avaliação'),
          backgroundColor: AppConstants.warningColor,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final rideRepository = getIt<RideRepository>();

      final result = await rideRepository.rateRide(
        widget.ride.id,
        _rating,
        _commentController.text.trim(),
      );

      if (result['success'] == true && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avaliação enviada com sucesso!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      } else {
        throw Exception(result['message'] ?? 'Erro ao enviar avaliação');
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
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _skipRating() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliar Corrida'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _skipRating,
            child: const Text('Pular'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRideSummary(),
            const SizedBox(height: 24),
            _buildDriverInfo(),
            const SizedBox(height: 32),
            _buildRatingSection(),
            const SizedBox(height: 24),
            _buildCommentSection(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRideSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.successColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppConstants.successColor,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Corrida Concluída!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.successColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            Icons.my_location,
            'Origem',
            widget.ride.pickupAddress ?? 'N/A',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            Icons.location_on,
            'Destino',
            widget.ride.dropoffAddress ?? 'N/A',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            Icons.attach_money,
            'Valor',
            Formatters.formatCurrency(widget.ride.finalPrice ?? widget.ride.estimatedPrice),
          ),
          if (widget.ride.startedAt != null && widget.ride.completedAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildSummaryRow(
                Icons.access_time,
                'Duração',
                Formatters.formatDuration(
                  widget.ride.completedAt!.difference(widget.ride.startedAt!).inSeconds,
                ),
              ),
            )
          else if (widget.ride.estimatedDurationSeconds != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildSummaryRow(
                Icons.access_time,
                'Duração estimada',
                Formatters.formatDuration(widget.ride.estimatedDurationSeconds!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    if (widget.ride.driver == null) {
      return const SizedBox.shrink();
    }

    final driver = widget.ride.driver!;

    return Row(
      children: [
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
              if (widget.ride.vehicle != null)
                Text(
                  '${widget.ride.vehicle!.brand} ${widget.ride.vehicle!.model} - ${widget.ride.vehicle!.plate}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      children: [
        const Text(
          'Como foi sua experiência?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            return IconButton(
              icon: Icon(
                starValue <= _rating ? Icons.star : Icons.star_border,
                size: 48,
              ),
              color: AppConstants.warningColor,
              onPressed: _isSubmitting
                  ? null
                  : () {
                      setState(() => _rating = starValue);
                    },
            );
          }),
        ),
        if (_rating > 0)
          Text(
            _getRatingText(_rating),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Muito ruim';
      case 2:
        return 'Ruim';
      case 3:
        return 'Regular';
      case 4:
        return 'Bom';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comentário (opcional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          enabled: !_isSubmitting,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Conte-nos mais sobre sua experiência...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      text: 'Enviar Avaliação',
      icon: Icons.send,
      isLoading: _isSubmitting,
      onPressed: _rating > 0 ? _submitRating : null,
    );
  }
}
