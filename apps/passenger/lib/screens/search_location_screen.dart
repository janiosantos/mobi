import 'package:flutter/material.dart';
import 'package:mobi_core/mobi_core.dart';

class SearchLocationScreen extends StatefulWidget {
  final bool isPickup;

  const SearchLocationScreen({
    super.key,
    required this.isPickup,
  });

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Location> _suggestions = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPickup ? 'Selecionar Origem' : 'Selecionar Destino'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscar endereço...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _suggestions.clear());
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlinedInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_suggestions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      itemCount: _suggestions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return ListTile(
          leading: const Icon(Icons.location_on, color: AppConstants.primaryColor),
          title: Text(
            suggestion.address ?? 'Endereço desconhecido',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${suggestion.latitude.toStringAsFixed(4)}, ${suggestion.longitude.toStringAsFixed(4)}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          onTap: () => _selectLocation(suggestion),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.isPickup ? Icons.my_location : Icons.location_on,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Digite um endereço',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Busque por rua, número ou ponto de referência',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _suggestions.clear();
        _isLoading = false;
      });
      return;
    }

    if (query.length < 3) return;

    setState(() => _isLoading = true);

    // Simular busca de endereços
    // TODO: Integrar com Google Places API ou Geocoding API
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() {
        _suggestions.clear();

        // Mock suggestions - Em produção, usar Google Places API
        if (query.toLowerCase().contains('paulista')) {
          _suggestions.addAll([
            const Location(
              latitude: -23.5617,
              longitude: -46.6565,
              address: 'Avenida Paulista, 1000 - Bela Vista, São Paulo',
            ),
            const Location(
              latitude: -23.5628,
              longitude: -46.6544,
              address: 'Avenida Paulista, 1500 - Bela Vista, São Paulo',
            ),
          ]);
        } else if (query.toLowerCase().contains('augusta')) {
          _suggestions.addAll([
            const Location(
              latitude: -23.5505,
              longitude: -46.6333,
              address: 'Rua Augusta, 500 - Consolação, São Paulo',
            ),
            const Location(
              latitude: -23.5550,
              longitude: -46.6370,
              address: 'Rua Augusta, 1000 - Consolação, São Paulo',
            ),
          ]);
        } else {
          // Sugestões genéricas
          _suggestions.add(
            Location(
              latitude: -23.5505 + (query.length * 0.001),
              longitude: -46.6333 - (query.length * 0.001),
              address: '$query - São Paulo, SP',
            ),
          );
        }

        _isLoading = false;
      });
    });
  }

  void _selectLocation(Location location) {
    Navigator.of(context).pop(location);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
