import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';
import 'package:intl/intl.dart';

class SharedRidesSearchScreen extends StatefulWidget {
  const SharedRidesSearchScreen({super.key});

  @override
  State<SharedRidesSearchScreen> createState() => _SharedRidesSearchScreenState();
}

class _SharedRidesSearchScreenState extends State<SharedRidesSearchScreen> {
  final SharedRideRepository _repository = getIt<SharedRideRepository>();
  List<SharedRide> _rides = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  // Search parameters
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  DateTime? _departureTime;

  // Mock locations for demo
  double? _pickupLat;
  double? _pickupLng;
  double? _dropoffLat;
  double? _dropoffLng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Corridas Compartilhadas'),
      ),
      body: Column(
        children: [
          // Search Form
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _pickupController,
                    decoration: const InputDecoration(
                      labelText: 'Origem',
                      hintText: 'Digite o endereço de origem',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    onTap: () {
                      // TODO: Implement location picker
                      _pickupController.text = 'Av. Paulista, 1000 - São Paulo, SP';
                      _pickupLat = -23.5505;
                      _pickupLng = -46.6333;
                    },
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dropoffController,
                    decoration: const InputDecoration(
                      labelText: 'Destino',
                      hintText: 'Digite o endereço de destino',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    onTap: () {
                      // TODO: Implement location picker
                      _dropoffController.text = 'Centro - São Paulo, SP';
                      _dropoffLat = -23.5489;
                      _dropoffLng = -46.6388;
                    },
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      _departureTime == null
                          ? 'Selecionar horário de partida'
                          : DateFormat('dd/MM/yyyy HH:mm').format(_departureTime!),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _selectDepartureTime,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _search,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar Corridas'),
                  ),
                ],
              ),
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasSearched && _rides.isEmpty
                    ? Center(
                        child: EmptyState(
                          icon: Icons.car_rental,
                          title: 'Nenhuma corrida encontrada',
                          message:
                              'Não há corridas disponíveis para esta rota. Tente outro horário ou destino.',
                        ),
                      )
                    : !_hasSearched
                        ? Center(
                            child: EmptyState(
                              icon: Icons.search,
                              title: 'Buscar corridas compartilhadas',
                              message:
                                  'Economize dividindo o custo da viagem com outros passageiros!',
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _rides.length,
                            itemBuilder: (context, index) {
                              final ride = _rides[index];
                              return _SharedRideCard(
                                ride: ride,
                                onTap: () => _showRideDetails(ride),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDepartureTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _departureTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _search() async {
    if (_pickupLat == null || _pickupLng == null || _dropoffLat == null || _dropoffLng == null) {
      CustomSnackbar.showError(context, 'Selecione origem e destino');
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final rides = await _repository.searchSharedRides(
        pickupLat: _pickupLat!,
        pickupLng: _pickupLng!,
        dropoffLat: _dropoffLat!,
        dropoffLng: _dropoffLng!,
        departureTime: _departureTime,
      );

      setState(() {
        _rides = rides;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        CustomSnackbar.showError(context, 'Erro ao buscar corridas');
      }
    }
  }

  void _showRideDetails(SharedRide ride) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _RideDetailsSheet(ride: ride),
    );
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }
}

class _SharedRideCard extends StatelessWidget {
  final SharedRide ride;
  final VoidCallback onTap;

  const _SharedRideCard({
    required this.ride,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Motorista',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          DateFormat('dd/MM - HH:mm').format(ride.departureTime),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'R\$ ${ride.pricePerSeat.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${ride.maxPassengers - ride.currentPassengers} vagas',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.circle, size: 12, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride.pickupAddress,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.circle, size: 12, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride.dropoffAddress,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RideDetailsSheet extends StatelessWidget {
  final SharedRide ride;

  const _RideDetailsSheet({required this.ride});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Detalhes da Corrida',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Horário de Partida'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy - HH:mm').format(ride.departureTime),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Vagas Disponíveis'),
                subtitle: Text(
                  '${ride.maxPassengers - ride.currentPassengers} de ${ride.maxPassengers}',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Preço por Assento'),
                subtitle: Text('R\$ ${ride.pricePerSeat.toStringAsFixed(2)}'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: ride.hasAvailableSeats
                    ? () {
                        // TODO: Join ride
                        Navigator.pop(context);
                        CustomSnackbar.showSuccess(
                          context,
                          'Solicitação de entrada enviada!',
                        );
                      }
                    : null,
                child: const Text('Entrar na Corrida'),
              ),
            ],
          ),
        );
      },
    );
  }
}
