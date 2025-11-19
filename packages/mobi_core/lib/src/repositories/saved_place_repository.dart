import '../models/saved_place.dart';
import '../services/api_service.dart';

/// Repository for managing saved places
class SavedPlaceRepository {
  final ApiService _apiService;

  SavedPlaceRepository(this._apiService);

  /// Get all saved places
  Future<List<SavedPlace>> getSavedPlaces() async {
    try {
      final response = await _apiService.get('/saved-places');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => SavedPlace.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get saved places: $e');
    }
  }

  /// Get saved places by type
  Future<List<SavedPlace>> getSavedPlacesByType(SavedPlaceType type) async {
    try {
      final typeString = type.toString().split('.').last;
      final response = await _apiService.get('/saved-places/type/$typeString');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => SavedPlace.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get saved places by type: $e');
    }
  }

  /// Create a new saved place
  Future<SavedPlace> createSavedPlace({
    required SavedPlaceType type,
    required String label,
    required String address,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) async {
    try {
      final response = await _apiService.post(
        '/saved-places',
        data: {
          'type': type.toString().split('.').last,
          'label': label,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'is_default': isDefault,
        },
      );

      return SavedPlace.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create saved place: $e');
    }
  }

  /// Update a saved place
  Future<SavedPlace> updateSavedPlace({
    required int id,
    SavedPlaceType? type,
    String? label,
    String? address,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (type != null) data['type'] = type.toString().split('.').last;
      if (label != null) data['label'] = label;
      if (address != null) data['address'] = address;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (isDefault != null) data['is_default'] = isDefault;

      final response = await _apiService.put(
        '/saved-places/$id',
        data: data,
      );

      return SavedPlace.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update saved place: $e');
    }
  }

  /// Delete a saved place
  Future<void> deleteSavedPlace(int id) async {
    try {
      await _apiService.delete('/saved-places/$id');
    } catch (e) {
      throw Exception('Failed to delete saved place: $e');
    }
  }

  /// Set a saved place as default
  Future<SavedPlace> setAsDefault(int id) async {
    try {
      final response = await _apiService.post('/saved-places/$id/set-default');
      return SavedPlace.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to set as default: $e');
    }
  }

  /// Quick create home address
  Future<SavedPlace> saveHome({
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    return createSavedPlace(
      type: SavedPlaceType.home,
      label: 'Casa',
      address: address,
      latitude: latitude,
      longitude: longitude,
      isDefault: true,
    );
  }

  /// Quick create work address
  Future<SavedPlace> saveWork({
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    return createSavedPlace(
      type: SavedPlaceType.work,
      label: 'Trabalho',
      address: address,
      latitude: latitude,
      longitude: longitude,
      isDefault: true,
    );
  }
}
