import '../models/scheduled_ride.dart';
import '../services/api_service.dart';

/// Repository for managing scheduled rides
class ScheduledRideRepository {
  final ApiService _apiService;

  ScheduledRideRepository(this._apiService);

  /// Schedule a new ride
  Future<ScheduledRide> scheduleRide({
    required DateTime scheduledAt,
    required int vehicleCategoryId,
    required double pickupLatitude,
    required double pickupLongitude,
    required String pickupAddress,
    required double dropoffLatitude,
    required double dropoffLongitude,
    required String dropoffAddress,
    String? passengerNotes,
  }) async {
    try {
      final response = await _apiService.post(
        '/scheduled-rides',
        data: {
          'scheduled_at': scheduledAt.toIso8601String(),
          'vehicle_category_id': vehicleCategoryId,
          'pickup_latitude': pickupLatitude,
          'pickup_longitude': pickupLongitude,
          'pickup_address': pickupAddress,
          'dropoff_latitude': dropoffLatitude,
          'dropoff_longitude': dropoffLongitude,
          'dropoff_address': dropoffAddress,
          if (passengerNotes != null) 'passenger_notes': passengerNotes,
        },
      );

      return ScheduledRide.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to schedule ride: $e');
    }
  }

  /// Get upcoming scheduled rides
  Future<List<ScheduledRide>> getUpcomingRides() async {
    try {
      final response = await _apiService.get('/scheduled-rides/upcoming');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => ScheduledRide.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming rides: $e');
    }
  }

  /// Get all scheduled rides (paginated)
  Future<Map<String, dynamic>> getScheduledRides({
    int page = 1,
    String? scheduledStatus,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        if (scheduledStatus != null) 'scheduled_status': scheduledStatus,
      };

      final response = await _apiService.get(
        '/scheduled-rides',
        queryParameters: queryParams,
      );

      final List<dynamic> ridesData = response.data['data'];
      final rides = ridesData.map((json) => ScheduledRide.fromJson(json)).toList();

      return {
        'rides': rides,
        'current_page': response.data['current_page'],
        'last_page': response.data['last_page'],
        'total': response.data['total'],
      };
    } catch (e) {
      throw Exception('Failed to get scheduled rides: $e');
    }
  }

  /// Update a scheduled ride
  Future<ScheduledRide> updateScheduledRide({
    required int rideId,
    DateTime? scheduledAt,
    double? pickupLatitude,
    double? pickupLongitude,
    String? pickupAddress,
    double? dropoffLatitude,
    double? dropoffLongitude,
    String? dropoffAddress,
    String? passengerNotes,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (scheduledAt != null) data['scheduled_at'] = scheduledAt.toIso8601String();
      if (pickupLatitude != null) data['pickup_latitude'] = pickupLatitude;
      if (pickupLongitude != null) data['pickup_longitude'] = pickupLongitude;
      if (pickupAddress != null) data['pickup_address'] = pickupAddress;
      if (dropoffLatitude != null) data['dropoff_latitude'] = dropoffLatitude;
      if (dropoffLongitude != null) data['dropoff_longitude'] = dropoffLongitude;
      if (dropoffAddress != null) data['dropoff_address'] = dropoffAddress;
      if (passengerNotes != null) data['passenger_notes'] = passengerNotes;

      final response = await _apiService.put(
        '/scheduled-rides/$rideId',
        data: data,
      );

      return ScheduledRide.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update scheduled ride: $e');
    }
  }

  /// Cancel a scheduled ride
  Future<ScheduledRide> cancelScheduledRide({
    required int rideId,
    String? reason,
  }) async {
    try {
      final response = await _apiService.post(
        '/scheduled-rides/$rideId/cancel',
        data: {
          if (reason != null) 'reason': reason,
        },
      );

      return ScheduledRide.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to cancel scheduled ride: $e');
    }
  }

  /// Validate if datetime can be scheduled
  bool canScheduleAt(DateTime dateTime) {
    final now = DateTime.now();
    final minScheduleTime = now.add(const Duration(minutes: 30));
    final maxScheduleTime = now.add(const Duration(days: 30));

    return dateTime.isAfter(minScheduleTime) && dateTime.isBefore(maxScheduleTime);
  }

  /// Get minimum scheduleable datetime (30 minutes from now)
  DateTime getMinScheduleTime() {
    return DateTime.now().add(const Duration(minutes: 30));
  }

  /// Get maximum scheduleable datetime (30 days from now)
  DateTime getMaxScheduleTime() {
    return DateTime.now().add(const Duration(days: 30));
  }
}
