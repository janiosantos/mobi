import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contatos de Emergência')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(context),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('João Silva'),
            subtitle: const Text('(11) 99999-9999'),
            trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
          )),
        ],
      ),
    );
  }

  static void _showAddContactDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar Contato'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome')),
            const SizedBox(height: 8),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Telefone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(onPressed: () { Navigator.pop(ctx); CustomSnackbar.showSuccess(context, 'Contato adicionado!'); }, child: const Text('Adicionar')),
        ],
      ),
    );
  }
}
