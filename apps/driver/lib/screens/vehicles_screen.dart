import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  bool _isLoading = false;

  // TODO: Load from API
  final List<Map<String, dynamic>> _vehicles = [
    {
      'id': 1,
      'make': 'Toyota',
      'model': 'Corolla',
      'year': 2022,
      'color': 'Prata',
      'plate': 'ABC-1234',
      'category': 'Conforto',
      'isActive': true,
    },
    {
      'id': 2,
      'make': 'Honda',
      'model': 'Civic',
      'year': 2021,
      'color': 'Preto',
      'plate': 'XYZ-9876',
      'category': 'Econômico',
      'isActive': false,
    },
  ];

  Future<void> _activateVehicle(int vehicleId) async {
    setState(() => _isLoading = true);

    try {
      // TODO: Call API to activate vehicle
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        for (var vehicle in _vehicles) {
          vehicle['isActive'] = vehicle['id'] == vehicleId;
        }
        _isLoading = false;
      });

      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Veículo ativado com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackbar.showError(context, 'Erro ao ativar veículo');
      }
    }
  }

  Future<void> _deleteVehicle(int vehicleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Veículo'),
        content: const Text(
          'Tem certeza que deseja remover este veículo? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        // TODO: Call API to delete vehicle
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _vehicles.removeWhere((v) => v['id'] == vehicleId);
          _isLoading = false;
        });

        if (mounted) {
          CustomSnackbar.showSuccess(context, 'Veículo removido com sucesso!');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          CustomSnackbar.showError(context, 'Erro ao remover veículo');
        }
      }
    }
  }

  void _showAddVehicleDialog() {
    final makeController = TextEditingController();
    final modelController = TextEditingController();
    final yearController = TextEditingController();
    final colorController = TextEditingController();
    final plateController = TextEditingController();
    String selectedCategory = 'Econômico';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Veículo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: makeController,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  hintText: 'Ex: Toyota',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  hintText: 'Ex: Corolla',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(
                  labelText: 'Ano',
                  hintText: 'Ex: 2022',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(
                  labelText: 'Cor',
                  hintText: 'Ex: Prata',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: plateController,
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  hintText: 'Ex: ABC-1234',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Econômico', child: Text('Econômico')),
                  DropdownMenuItem(value: 'Conforto', child: Text('Conforto')),
                  DropdownMenuItem(value: 'Premium', child: Text('Premium')),
                  DropdownMenuItem(value: 'XL', child: Text('XL')),
                ],
                onChanged: (value) {
                  if (value != null) selectedCategory = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Validate and call API
              Navigator.pop(context);
              CustomSnackbar.showSuccess(
                this.context,
                'Veículo adicionado! Aguarde aprovação.',
              );
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Veículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddVehicleDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_car, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum veículo cadastrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showAddVehicleDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Veículo'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = _vehicles[index];
                    return _VehicleCard(
                      vehicle: vehicle,
                      onActivate: () => _activateVehicle(vehicle['id']),
                      onDelete: () => _deleteVehicle(vehicle['id']),
                    );
                  },
                ),
      floatingActionButton: _vehicles.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddVehicleDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final VoidCallback onActivate;
  final VoidCallback onDelete;

  const _VehicleCard({
    required this.vehicle,
    required this.onActivate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = vehicle['isActive'] as bool;

    return Card(
      elevation: isActive ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_car,
                  size: 48,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle['make']} ${vehicle['model']}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vehicle['year']} • ${vehicle['color']} • ${vehicle['plate']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(vehicle['category']),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (isActive)
                  const Chip(
                    label: Text('ATIVO'),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: onActivate,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Ativar'),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
