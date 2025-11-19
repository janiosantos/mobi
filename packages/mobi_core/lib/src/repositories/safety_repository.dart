import '../models/emergency_contact.dart';
import '../models/shared_trip_info.dart';
import '../services/api_service.dart';

/// Repository for managing safety features
class SafetyRepository {
  final ApiService _apiService;

  SafetyRepository(this._apiService);

  /*
  |--------------------------------------------------------------------------
  | Emergency Contacts
  |--------------------------------------------------------------------------
  */

  /// Get all emergency contacts
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      final response = await _apiService.get('/emergency-contacts');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => EmergencyContact.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get emergency contacts: $e');
    }
  }

  /// Create a new emergency contact
  Future<EmergencyContact> createEmergencyContact({
    required String name,
    required String phone,
    String? relationship,
    bool isPrimary = false,
  }) async {
    try {
      final response = await _apiService.post(
        '/emergency-contacts',
        data: {
          'name': name,
          'phone': phone,
          'relationship': relationship,
          'is_primary': isPrimary,
        },
      );

      return EmergencyContact.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create emergency contact: $e');
    }
  }

  /// Update an emergency contact
  Future<EmergencyContact> updateEmergencyContact({
    required int id,
    String? name,
    String? phone,
    String? relationship,
    bool? isPrimary,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (relationship != null) data['relationship'] = relationship;
      if (isPrimary != null) data['is_primary'] = isPrimary;

      final response = await _apiService.put(
        '/emergency-contacts/$id',
        data: data,
      );

      return EmergencyContact.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update emergency contact: $e');
    }
  }

  /// Delete an emergency contact
  Future<void> deleteEmergencyContact(int id) async {
    try {
      await _apiService.delete('/emergency-contacts/$id');
    } catch (e) {
      throw Exception('Failed to delete emergency contact: $e');
    }
  }

  /*
  |--------------------------------------------------------------------------
  | Trip Sharing
  |--------------------------------------------------------------------------
  */

  /// Share a trip and get share code and URL
  Future<Map<String, dynamic>> shareTrip(int rideId) async {
    try {
      final response = await _apiService.post('/rides/$rideId/share');
      return {
        'code': response.data['data']['share_code'],
        'url': response.data['data']['share_url'],
        'expires_at': DateTime.parse(response.data['data']['expires_at']),
      };
    } catch (e) {
      throw Exception('Failed to share trip: $e');
    }
  }

  /// Get shared trip information (public, no auth required)
  Future<SharedTripInfo> getSharedTrip(String code) async {
    try {
      final response = await _apiService.get('/shared-trip/$code');
      return SharedTripInfo.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get shared trip: $e');
    }
  }

  /*
  |--------------------------------------------------------------------------
  | SOS Emergency
  |--------------------------------------------------------------------------
  */

  /// Trigger SOS emergency alert
  Future<void> triggerSOS({
    required int rideId,
    String? note,
  }) async {
    try {
      await _apiService.post(
        '/rides/$rideId/sos',
        data: {
          if (note != null) 'note': note,
        },
      );
    } catch (e) {
      throw Exception('Failed to trigger SOS: $e');
    }
  }

  /// Cancel SOS emergency alert
  Future<void> cancelSOS(int rideId) async {
    try {
      await _apiService.delete('/rides/$rideId/sos');
    } catch (e) {
      throw Exception('Failed to cancel SOS: $e');
    }
  }
}
