import 'package:flutter/material.dart';

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Locais Salvos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Casa'),
            subtitle: const Text('Av. Paulista, 1000'),
            trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
          ),
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text('Trabalho'),
            subtitle: const Text('Av. Faria Lima, 2000'),
            trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
          ),
        ],
      ),
    );
  }
}
