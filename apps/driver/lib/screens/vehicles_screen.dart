import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final ApiService _apiService = getIt<ApiService>();
  bool _isLoading = true;
  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load vehicles and categories in parallel
      final results = await Future.wait([
        _apiService.getVehicles(),
        _apiService.getVehicleCategories(),
      ]);

      final vehiclesResponse = results[0];
      final categoriesResponse = results[1];

      setState(() {
        if (vehiclesResponse.response.statusCode == 200) {
          _vehicles = List<Map<String, dynamic>>.from(
            vehiclesResponse.data['data'] ?? [],
          );
        }

        if (categoriesResponse.response.statusCode == 200) {
          _categories = List<Map<String, dynamic>>.from(
            categoriesResponse.data['data'] ?? [],
          );
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        CustomSnackbar.showError(
          context,
          'Erro ao carregar veículos: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _activateVehicle(int vehicleId) async {
    try {
      final response = await _apiService.activateVehicle(vehicleId);

      if (response.response.statusCode == 200) {
        // Reload to get updated list
        await _loadData();

        if (mounted) {
          CustomSnackbar.showSuccess(context, 'Veículo ativado com sucesso!');
        }
      } else {
        throw Exception('Failed to activate vehicle');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          'Erro ao ativar veículo: ${e.toString()}',
        );
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
      try {
        await _apiService.deleteVehicle(vehicleId);

        // Reload to get updated list
        await _loadData();

        if (mounted) {
          CustomSnackbar.showSuccess(context, 'Veículo removido com sucesso!');
        }
      } catch (e) {
        if (mounted) {
          CustomSnackbar.showError(
            context,
            'Erro ao remover veículo: ${e.toString()}',
          );
        }
      }
    }
  }

  void _showAddVehicleDialog() {
    final formKey = GlobalKey<FormState>();
    final makeController = TextEditingController();
    final modelController = TextEditingController();
    final yearController = TextEditingController();
    final colorController = TextEditingController();
    final plateController = TextEditingController();
    int? selectedCategoryId;

    if (_categories.isEmpty) {
      CustomSnackbar.showError(
        context,
        'Carregue as categorias primeiro',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Adicionar Veículo'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: makeController,
                  decoration: const InputDecoration(
                    labelText: 'Marca',
                    hintText: 'Ex: Toyota',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Marca é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: modelController,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    hintText: 'Ex: Corolla',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Modelo é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: yearController,
                  decoration: const InputDecoration(
                    labelText: 'Ano',
                    hintText: 'Ex: 2022',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ano é obrigatório';
                    }
                    final year = int.tryParse(value);
                    if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                      return 'Ano inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: colorController,
                  decoration: const InputDecoration(
                    labelText: 'Cor',
                    hintText: 'Ex: Prata',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Cor é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: plateController,
                  decoration: const InputDecoration(
                    labelText: 'Placa',
                    hintText: 'Ex: ABC-1234 ou ABC1D23',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Placa é obrigatória';
                    }
                    final cleaned = value.replaceAll(RegExp(r'[^A-Z0-9]'), '');
                    if (cleaned.length != 7) {
                      return 'Placa inválida (7 caracteres)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category['id'],
                      child: Text(category['name'] ?? 'Desconhecido'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCategoryId = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Categoria é obrigatória';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              Navigator.pop(dialogContext);

              try {
                final vehicleData = {
                  'make': makeController.text.trim(),
                  'model': modelController.text.trim(),
                  'year': int.parse(yearController.text.trim()),
                  'color': colorController.text.trim(),
                  'license_plate': plateController.text.trim().toUpperCase(),
                  'vehicle_category_id': selectedCategoryId,
                };

                final response = await _apiService.createVehicle(vehicleData);

                if (response.response.statusCode == 201 ||
                    response.response.statusCode == 200) {
                  await _loadData();

                  if (mounted) {
                    CustomSnackbar.showSuccess(
                      context,
                      'Veículo adicionado! Aguarde aprovação.',
                    );
                  }
                } else {
                  throw Exception('Failed to create vehicle');
                }
              } catch (e) {
                if (mounted) {
                  CustomSnackbar.showError(
                    context,
                    'Erro ao adicionar veículo: ${e.toString()}',
                  );
                }
              }
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
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddVehicleDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _vehicles.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Nenhum veículo cadastrado',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Adicione um veículo para começar\na aceitar corridas',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: _showAddVehicleDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Adicionar Veículo'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
            ),
      floatingActionButton: !_isLoading && _vehicles.isNotEmpty
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
    final isActive = vehicle['is_active'] == true || vehicle['isActive'] == true;
    final make = vehicle['make'] ?? '';
    final model = vehicle['model'] ?? '';
    final year = vehicle['year'] ?? '';
    final color = vehicle['color'] ?? '';
    final plate =
        vehicle['license_plate'] ?? vehicle['plate'] ?? '';
    final categoryName =
        vehicle['category']?['name'] ?? vehicle['category'] ?? 'N/A';

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
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: (isActive
                            ? AppConstants.primaryColor
                            : Colors.grey)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    size: 32,
                    color: isActive ? AppConstants.primaryColor : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$make $model',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$year • $color',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              plate,
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              categoryName,
                              style: TextStyle(
                                color: AppConstants.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'ATIVO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: onActivate,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Ativar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: onDelete,
                  tooltip: 'Remover veículo',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
