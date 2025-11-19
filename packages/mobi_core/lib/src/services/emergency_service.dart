import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';
import '../models/location.dart';
import '../models/emergency_contact.dart';

/// Emergency service for handling SOS situations
class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  final ApiService _apiService = ApiService();
  StreamSubscription<Position>? _locationSubscription;
  Timer? _heartbeatTimer;

  bool _isSOSActive = false;
  Position? _lastPosition;
  List<EmergencyContact> _emergencyContacts = [];

  final _sosStatusController = StreamController<bool>.broadcast();
  final _locationUpdatesController = StreamController<Position>.broadcast();

  /// Stream of SOS status changes
  Stream<bool> get sosStatusStream => _sosStatusController.stream;

  /// Stream of location updates during SOS
  Stream<Position> get locationUpdatesStream => _locationUpdatesController.stream;

  /// Check if SOS is currently active
  bool get isSOSActive => _isSOSActive;

  /// Get last known position
  Position? get lastPosition => _lastPosition;

  /// Initialize emergency service
  Future<void> initialize() async {
    try {
      // Load emergency contacts
      await loadEmergencyContacts();
    } catch (e) {
      print('Error initializing emergency service: $e');
    }
  }

  /// Load emergency contacts from API
  Future<void> loadEmergencyContacts() async {
    try {
      final response = await _apiService.getEmergencyContacts();
      _emergencyContacts = (response.data['data'] as List<dynamic>)
          .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading emergency contacts: $e');
      _emergencyContacts = [];
    }
  }

  /// Activate SOS mode
  Future<bool> activateSOS({
    String? note,
    String? rideId,
  }) async {
    if (_isSOSActive) {
      return true; // Already active
    }

    try {
      // Get current location
      final position = await _getCurrentLocation();
      if (position == null) {
        throw Exception('Could not get current location');
      }

      _lastPosition = position;

      // Notify backend
      final response = await _apiService.activateSOS({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        if (note != null) 'note': note,
        if (rideId != null) 'ride_id': rideId,
      });

      if (response.statusCode == 200) {
        _isSOSActive = true;
        _sosStatusController.add(true);

        // Start continuous location tracking
        _startLocationTracking();

        // Start heartbeat to keep SOS active
        _startHeartbeat();

        // Notify emergency contacts
        await _notifyEmergencyContacts(position);

        return true;
      }

      return false;
    } catch (e) {
      print('Error activating SOS: $e');
      return false;
    }
  }

  /// Deactivate SOS mode
  Future<bool> deactivateSOS({String? resolution}) async {
    if (!_isSOSActive) {
      return true; // Already inactive
    }

    try {
      // Notify backend
      final response = await _apiService.deactivateSOS({
        if (resolution != null) 'resolution': resolution,
      });

      if (response.statusCode == 200) {
        _isSOSActive = false;
        _sosStatusController.add(false);

        // Stop location tracking
        await _stopLocationTracking();

        // Stop heartbeat
        _stopHeartbeat();

        return true;
      }

      return false;
    } catch (e) {
      print('Error deactivating SOS: $e');
      return false;
    }
  }

  /// Get current location
  Future<Position?> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.denied ||
            newPermission == LocationPermission.deniedForever) {
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Start continuous location tracking
  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _lastPosition = position;
        _locationUpdatesController.add(position);

        // Send location update to backend
        _sendLocationUpdate(position);
      },
      onError: (error) {
        print('Error in location stream: $error');
      },
    );
  }

  /// Stop location tracking
  Future<void> _stopLocationTracking() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  /// Send location update to backend
  Future<void> _sendLocationUpdate(Position position) async {
    try {
      await _apiService.updateSOSLocation({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error sending location update: $e');
    }
  }

  /// Start heartbeat to keep SOS active
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        await _apiService.sendSOSHeartbeat();
      } catch (e) {
        print('Error sending heartbeat: $e');
      }
    });
  }

  /// Stop heartbeat
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Notify emergency contacts
  Future<void> _notifyEmergencyContacts(Position position) async {
    try {
      await _apiService.notifyEmergencyContacts({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'contacts': _emergencyContacts.map((c) => c.id).toList(),
      });
    } catch (e) {
      print('Error notifying emergency contacts: $e');
    }
  }

  /// Get tracking link for sharing
  Future<String?> getTrackingLink() async {
    if (!_isSOSActive) {
      return null;
    }

    try {
      final response = await _apiService.getSOSTrackingLink();
      return response.data['link'] as String?;
    } catch (e) {
      print('Error getting tracking link: $e');
      return null;
    }
  }

  /// Send alert to monitoring center
  Future<bool> alertMonitoringCenter({
    required String reason,
    String? details,
  }) async {
    try {
      final response = await _apiService.alertMonitoringCenter({
        'reason': reason,
        if (details != null) 'details': details,
        if (_lastPosition != null) ...{
          'latitude': _lastPosition!.latitude,
          'longitude': _lastPosition!.longitude,
        },
      });

      return response.statusCode == 200;
    } catch (e) {
      print('Error alerting monitoring center: $e');
      return false;
    }
  }

  /// Record audio evidence (for last 30 seconds)
  Future<bool> recordAudioEvidence() async {
    try {
      // This would integrate with audio recording service
      // For now, just notify backend to start recording
      final response = await _apiService.startAudioRecording();
      return response.statusCode == 200;
    } catch (e) {
      print('Error recording audio: $e');
      return false;
    }
  }

  /// Share location with specific contact
  Future<bool> shareLocationWithContact(EmergencyContact contact) async {
    if (_lastPosition == null) {
      return false;
    }

    try {
      final response = await _apiService.shareSOSLocation({
        'contact_id': contact.id,
        'latitude': _lastPosition!.latitude,
        'longitude': _lastPosition!.longitude,
      });

      return response.statusCode == 200;
    } catch (e) {
      print('Error sharing location: $e');
      return false;
    }
  }

  /// Get distance to nearest police station or hospital
  Future<Map<String, dynamic>?> getNearestEmergencyServices() async {
    if (_lastPosition == null) {
      return null;
    }

    try {
      final response = await _apiService.getNearestEmergencyServices({
        'latitude': _lastPosition!.latitude,
        'longitude': _lastPosition!.longitude,
      });

      return response.data['data'] as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting nearest emergency services: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _stopLocationTracking();
    _stopHeartbeat();
    _sosStatusController.close();
    _locationUpdatesController.close();
  }
}

// Extension methods on ApiService for SOS endpoints
extension SOSApiExtension on ApiService {
  Future<dynamic> activateSOS(Map<String, dynamic> data) async {
    // This would be implemented in the actual ApiService
    throw UnimplementedError('activateSOS not implemented in ApiService');
  }

  Future<dynamic> deactivateSOS(Map<String, dynamic> data) async {
    throw UnimplementedError('deactivateSOS not implemented in ApiService');
  }

  Future<dynamic> updateSOSLocation(Map<String, dynamic> data) async {
    throw UnimplementedError('updateSOSLocation not implemented in ApiService');
  }

  Future<dynamic> sendSOSHeartbeat() async {
    throw UnimplementedError('sendSOSHeartbeat not implemented in ApiService');
  }

  Future<dynamic> notifyEmergencyContacts(Map<String, dynamic> data) async {
    throw UnimplementedError('notifyEmergencyContacts not implemented in ApiService');
  }

  Future<dynamic> getSOSTrackingLink() async {
    throw UnimplementedError('getSOSTrackingLink not implemented in ApiService');
  }

  Future<dynamic> alertMonitoringCenter(Map<String, dynamic> data) async {
    throw UnimplementedError('alertMonitoringCenter not implemented in ApiService');
  }

  Future<dynamic> startAudioRecording() async {
    throw UnimplementedError('startAudioRecording not implemented in ApiService');
  }

  Future<dynamic> shareSOSLocation(Map<String, dynamic> data) async {
    throw UnimplementedError('shareSOSLocation not implemented in ApiService');
  }

  Future<dynamic> getNearestEmergencyServices(Map<String, dynamic> query) async {
    throw UnimplementedError('getNearestEmergencyServices not implemented in ApiService');
  }

  Future<dynamic> getEmergencyContacts() async {
    throw UnimplementedError('getEmergencyContacts not implemented in ApiService');
  }
}
