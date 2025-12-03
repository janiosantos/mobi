import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_core/mobi_core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/service_locator.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
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
      final response = await apiService.get('/emergency-contacts');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> contactsData = data['data'] ?? [];

        setState(() {
          _contacts = contactsData.map((json) => json as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Erro ao carregar contatos');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteContact(int id) async {
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.delete('/emergency-contacts/$id');

      if (response.statusCode == 200) {
        CustomSnackbar.showSuccess(context, 'Contato removido!');
        _loadContacts();
      } else {
        throw Exception('Erro ao remover contato');
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Erro: ${e.toString()}');
    }
  }

  Future<void> _setPrimary(int id) async {
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.post('/emergency-contacts/$id/set-primary');

      if (response.statusCode == 200) {
        CustomSnackbar.showSuccess(context, 'Contato principal atualizado!');
        _loadContacts();
      } else {
        throw Exception('Erro ao definir contato principal');
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Erro: ${e.toString()}');
    }
  }

  void _showAddContactDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddContactBottomSheet(
        onContactAdded: _loadContacts,
      ),
    );
  }

  void _showEditContactDialog(Map<String, dynamic> contact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddContactBottomSheet(
        contact: contact,
        onContactAdded: _loadContacts,
      ),
    );
  }

  Future<void> _callContact(String phone) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          CustomSnackbar.showError(context, 'Não foi possível realizar a chamada');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Erro ao iniciar chamada: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos de Emergência'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContacts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddContactDialog,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Contato'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorWidget()
              : _contacts.isEmpty
                  ? _buildEmptyWidget()
                  : _buildContactsList(),
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
            'Erro ao carregar contatos',
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
            onPressed: _loadContacts,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contact_emergency,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum contato de emergência',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione contatos que serão notificados em caso de emergência durante suas viagens',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddContactDialog,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Primeiro Contato'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Estes contatos serão notificados quando você ativar o SOS durante uma viagem.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              final contact = _contacts[index];
              final name = contact['name'] ?? 'Sem nome';
              final phone = contact['phone'] ?? '';
              final relationship = contact['relationship'] ?? '';
              final isPrimary = contact['is_primary'] == true || contact['is_primary'] == 1;
              final id = contact['id'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: isPrimary ? 4 : 1,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPrimary ? Colors.red.shade100 : Colors.blue.shade100,
                    child: Icon(
                      isPrimary ? Icons.favorite : Icons.person,
                      color: isPrimary ? Colors.red : Colors.blue,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (isPrimary)
                        const Chip(
                          label: Text('Principal', style: TextStyle(fontSize: 10)),
                          backgroundColor: Colors.red,
                          labelStyle: TextStyle(color: Colors.white),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(phone, style: const TextStyle(color: Colors.blue)),
                      if (relationship.isNotEmpty)
                        Text(relationship, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  isThreeLine: relationship.isNotEmpty,
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'call',
                        child: Row(
                          children: [
                            Icon(Icons.phone, size: 20, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Ligar'),
                          ],
                        ),
                      ),
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
                      if (!isPrimary)
                        const PopupMenuItem(
                          value: 'primary',
                          child: Row(
                            children: [
                              Icon(Icons.favorite, size: 20),
                              SizedBox(width: 8),
                              Text('Definir como Principal'),
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
                        case 'call':
                          _callContact(phone);
                          break;
                        case 'edit':
                          _showEditContactDialog(contact);
                          break;
                        case 'primary':
                          _setPrimary(id);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(id, name);
                          break;
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o contato "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteContact(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Contatos de Emergência'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Como funciona:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Ao ativar o SOS durante uma viagem, todos os seus contatos de emergência receberão uma notificação.'),
              SizedBox(height: 8),
              Text('• A notificação incluirá sua localização em tempo real e informações da viagem.'),
              SizedBox(height: 8),
              Text('• O contato principal receberá notificações prioritárias.'),
              SizedBox(height: 16),
              Text(
                'Dica de segurança:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              SizedBox(height: 8),
              Text('Adicione pelo menos 2 contatos de confiança para maior segurança.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}

class _AddContactBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? contact;
  final VoidCallback onContactAdded;

  const _AddContactBottomSheet({
    this.contact,
    required this.onContactAdded,
  });

  @override
  State<_AddContactBottomSheet> createState() => _AddContactBottomSheetState();
}

class _AddContactBottomSheetState extends State<_AddContactBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _relationshipController;
  bool _isPrimary = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?['name']);
    _phoneController = TextEditingController(text: widget.contact?['phone']);
    _relationshipController = TextEditingController(text: widget.contact?['relationship']);
    _isPrimary = widget.contact?['is_primary'] == true || widget.contact?['is_primary'] == 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    // Remove non-digits
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      return 'Telefone inválido';
    }
    return null;
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final apiService = getIt<ApiService>();
      final data = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'relationship': _relationshipController.text,
        'is_primary': _isPrimary,
      };

      final response = widget.contact == null
          ? await apiService.post('/emergency-contacts', data: data)
          : await apiService.put('/emergency-contacts/${widget.contact!['id']}', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          CustomSnackbar.showSuccess(
            context,
            widget.contact == null ? 'Contato adicionado!' : 'Contato atualizado!',
          );
          Navigator.pop(context);
          widget.onContactAdded();
        }
      } else {
        throw Exception('Erro ao salvar contato');
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
                widget.contact == null ? 'Adicionar Contato' : 'Editar Contato',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Nome é obrigatório' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: '(11) 99999-9999',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _relationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relacionamento (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                  hintText: 'Ex: Mãe, Pai, Irmão, Amigo...',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: const Text('Definir como contato principal'),
                  subtitle: const Text('Receberá notificações prioritárias'),
                  value: _isPrimary,
                  onChanged: (value) => setState(() => _isPrimary = value),
                  secondary: const Icon(Icons.favorite),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveContact,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.contact == null ? 'Adicionar' : 'Salvar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
