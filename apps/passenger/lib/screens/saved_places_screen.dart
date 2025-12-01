import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobi_core/mobi_core.dart';
import '../core/service_locator.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  List<Map<String, dynamic>> _places = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final authService = getIt<AuthService>();
      final token = await authService.getToken();

      if (token == null) {
        throw Exception('Usuário não autenticado');
      }

      final apiService = getIt<ApiService>();
      final response = await apiService.get('/saved-places');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> placesData = data['data'] ?? [];

        setState(() {
          _places = placesData.map((json) => json as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Erro ao carregar locais salvos');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePlace(int id) async {
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.delete('/saved-places/$id');

      if (response.statusCode == 200) {
        CustomSnackbar.showSuccess(context, 'Local removido com sucesso!');
        _loadPlaces();
      } else {
        throw Exception('Erro ao remover local');
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Erro ao remover local: ${e.toString()}');
    }
  }

  Future<void> _setAsDefault(int id) async {
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.post('/saved-places/$id/set-default');

      if (response.statusCode == 200) {
        CustomSnackbar.showSuccess(context, 'Local padrão atualizado!');
        _loadPlaces();
      } else {
        throw Exception('Erro ao definir local padrão');
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Erro: ${e.toString()}');
    }
  }

  void _showAddPlaceDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddPlaceBottomSheet(
        onPlaceAdded: _loadPlaces,
      ),
    );
  }

  void _showEditPlaceDialog(Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddPlaceBottomSheet(
        place: place,
        onPlaceAdded: _loadPlaces,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locais Salvos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlaces,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPlaceDialog,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Local'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorWidget()
              : _places.isEmpty
                  ? _buildEmptyWidget()
                  : _buildPlacesList(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Erro ao carregar locais',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadPlaces,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum local salvo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione locais para acesso rápido',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddPlaceDialog,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Primeiro Local'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _places.length,
      itemBuilder: (context, index) {
        final place = _places[index];
        final type = place['type'] ?? 'favorite';
        final label = place['label'] ?? 'Local ${index + 1}';
        final address = place['address'] ?? 'Endereço não disponível';
        final isDefault = place['is_default'] == true || place['is_default'] == 1;
        final id = place['id'];

        IconData icon;
        Color iconColor;
        switch (type) {
          case 'home':
            icon = Icons.home;
            iconColor = Colors.blue;
            break;
          case 'work':
            icon = Icons.work;
            iconColor = Colors.orange;
            break;
          default:
            icon = Icons.star;
            iconColor = Colors.amber;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isDefault ? 4 : 1,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.2),
              child: Icon(icon, color: iconColor),
            ),
            title: Row(
              children: [
                Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
                if (isDefault)
                  const Chip(
                    label: Text('Padrão', style: TextStyle(fontSize: 10)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            subtitle: Text(address, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                if (!isDefault)
                  const PopupMenuItem(
                    value: 'default',
                    child: Row(
                      children: [
                        Icon(Icons.push_pin, size: 20),
                        SizedBox(width: 8),
                        Text('Definir como Padrão'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Excluir', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditPlaceDialog(place);
                    break;
                  case 'default':
                    _setAsDefault(id);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(id);
                    break;
                }
              },
            ),
            onTap: () => _showEditPlaceDialog(place),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir este local?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePlace(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _AddPlaceBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? place;
  final VoidCallback onPlaceAdded;

  const _AddPlaceBottomSheet({
    this.place,
    required this.onPlaceAdded,
  });

  @override
  State<_AddPlaceBottomSheet> createState() => _AddPlaceBottomSheetState();
}

class _AddPlaceBottomSheetState extends State<_AddPlaceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  String _selectedType = 'favorite';
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.place?['label']);
    _addressController = TextEditingController(text: widget.place?['address']);
    _latitudeController = TextEditingController(
      text: widget.place?['latitude']?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.place?['longitude']?.toString() ?? '',
    );
    _selectedType = widget.place?['type'] ?? 'favorite';
    _isDefault = widget.place?['is_default'] == true || widget.place?['is_default'] == 1;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _savePlace() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final apiService = getIt<ApiService>();
      final data = {
        'type': _selectedType,
        'label': _labelController.text,
        'address': _addressController.text,
        'latitude': double.parse(_latitudeController.text),
        'longitude': double.parse(_longitudeController.text),
        'is_default': _isDefault,
      };

      final response = widget.place == null
          ? await apiService.post('/saved-places', data: data)
          : await apiService.put('/saved-places/${widget.place!['id']}', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          CustomSnackbar.showSuccess(
            context,
            widget.place == null ? 'Local adicionado!' : 'Local atualizado!',
          );
          Navigator.pop(context);
          widget.onPlaceAdded();
        }
      } else {
        throw Exception('Erro ao salvar local');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Erro: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.place == null ? 'Adicionar Local' : 'Editar Local',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'home', child: Text('🏠 Casa')),
                  DropdownMenuItem(value: 'work', child: Text('💼 Trabalho')),
                  DropdownMenuItem(value: 'favorite', child: Text('⭐ Favorito')),
                ],
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Local',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Endereço é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Obrigatório';
                        if (double.tryParse(value!) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Obrigatório';
                        if (double.tryParse(value!) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Definir como padrão'),
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _savePlace,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.place == null ? 'Adicionar' : 'Salvar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
