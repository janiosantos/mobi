import '../models/shared_ride.dart';
import '../services/api_service.dart';

/// Repository for managing shared rides (carpooling)
class SharedRideRepository {
  final ApiService _apiService;

  SharedRideRepository(this._apiService);

  /// Search for available shared rides
  Future<List<SharedRide>> searchSharedRides({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    DateTime? departureTime,
    int? maxResults,
  }) async {
    try {
      final response = await _apiService.get(
        '/shared-rides/search',
        queryParameters: {
          'pickup_latitude': pickupLat,
          'pickup_longitude': pickupLng,
          'dropoff_latitude': dropoffLat,
          'dropoff_longitude': dropoffLng,
          if (departureTime != null)
            'departure_time': departureTime.toIso8601String(),
          if (maxResults != null) 'limit': maxResults,
        },
      );

      final List<dynamic> data = response.data['data'];
      return data.map((json) => SharedRide.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search shared rides: $e');
    }
  }

  /// Create a new shared ride (driver)
  Future<SharedRide> createSharedRide({
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffAddress,
    required DateTime departureTime,
    required int maxPassengers,
    required double pricePerSeat,
    int? vehicleId,
  }) async {
    try {
      final response = await _apiService.post(
        '/shared-rides',
        data: {
          'pickup_latitude': pickupLat,
          'pickup_longitude': pickupLng,
          'pickup_address': pickupAddress,
          'dropoff_latitude': dropoffLat,
          'dropoff_longitude': dropoffLng,
          'dropoff_address': dropoffAddress,
          'departure_time': departureTime.toIso8601String(),
          'max_passengers': maxPassengers,
          'price_per_seat': pricePerSeat,
          if (vehicleId != null) 'vehicle_id': vehicleId,
        },
      );

      return SharedRide.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create shared ride: $e');
    }
  }

  /// Join a shared ride (passenger)
  Future<SharedRidePassenger> joinSharedRide({
    required int sharedRideId,
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffAddress,
  }) async {
    try {
      final response = await _apiService.post(
        '/shared-rides/$sharedRideId/join',
        data: {
          'pickup_latitude': pickupLat,
          'pickup_longitude': pickupLng,
          'pickup_address': pickupAddress,
          'dropoff_latitude': dropoffLat,
          'dropoff_longitude': dropoffLng,
          'dropoff_address': dropoffAddress,
        },
      );

      return SharedRidePassenger.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to join shared ride: $e');
    }
  }

  /// Leave a shared ride (passenger)
  Future<void> leaveSharedRide(int sharedRideId) async {
    try {
      await _apiService.post('/shared-rides/$sharedRideId/leave');
    } catch (e) {
      throw Exception('Failed to leave shared ride: $e');
    }
  }

  /// Cancel a shared ride (driver)
  Future<void> cancelSharedRide(int sharedRideId) async {
    try {
      await _apiService.post('/shared-rides/$sharedRideId/cancel');
    } catch (e) {
      throw Exception('Failed to cancel shared ride: $e');
    }
  }

  /// Start a shared ride (driver)
  Future<SharedRide> startSharedRide(int sharedRideId) async {
    try {
      final response = await _apiService.post(
        '/shared-rides/$sharedRideId/start',
      );

      return SharedRide.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to start shared ride: $e');
    }
  }

  /// Mark passenger as picked up
  Future<void> markPassengerPickedUp(
    int sharedRideId,
    int passengerId,
  ) async {
    try {
      await _apiService.post(
        '/shared-rides/$sharedRideId/passengers/$passengerId/pickup',
      );
    } catch (e) {
      throw Exception('Failed to mark passenger as picked up: $e');
    }
  }

  /// Mark passenger as dropped off
  Future<void> markPassengerDroppedOff(
    int sharedRideId,
    int passengerId,
  ) async {
    try {
      await _apiService.post(
        '/shared-rides/$sharedRideId/passengers/$passengerId/dropoff',
      );
    } catch (e) {
      throw Exception('Failed to mark passenger as dropped off: $e');
    }
  }

  /// Get shared ride details
  Future<SharedRide> getSharedRide(int sharedRideId) async {
    try {
      final response = await _apiService.get('/shared-rides/$sharedRideId');
      return SharedRide.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get shared ride: $e');
    }
  }

  /// Get my shared rides as driver
  Future<List<SharedRide>> getMySharedRidesAsDriver() async {
    try {
      final response = await _apiService.get('/shared-rides/my-rides/driver');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => SharedRide.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get my shared rides as driver: $e');
    }
  }

  /// Get my shared rides as passenger
  Future<List<SharedRide>> getMySharedRidesAsPassenger() async {
    try {
      final response = await _apiService.get('/shared-rides/my-rides/passenger');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => SharedRide.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get my shared rides as passenger: $e');
    }
  }
}
