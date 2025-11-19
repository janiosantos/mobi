import '../models/ride.dart';
import '../services/api_service.dart';

class RideRepository {
  final ApiService _apiService;

  RideRepository(this._apiService);

  Future<Map<String, dynamic>> estimateRide(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.estimateRide(data);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> requestRide(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.requestRide(data);
      if (response.response.statusCode == 201) {
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'message': 'Failed to request ride'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getRides({
    int page = 1,
    int perPage = 20,
    String? status,
  }) async {
    try {
      final queries = {
        'page': page,
        'per_page': perPage,
        if (status != null) 'status': status,
      };

      final response = await _apiService.getRides(queries);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getRideDetail(int rideId) async {
    try {
      final response = await _apiService.getRideDetail(rideId);
      return {'success': true, 'data': response.data['data']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> cancelRide(
      int rideId, String reason) async {
    try {
      final response = await _apiService.cancelRide(rideId, {
        'reason': reason,
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> rateRide(
      int rideId, int rating, String? comment) async {
    try {
      final response = await _apiService.rateRide(rideId, {
        'rating': rating,
        if (comment != null) 'comment': comment,
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Driver-specific methods
  Future<Map<String, dynamic>> getAvailableRides({
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final queries = {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radius != null) 'radius': radius,
      };

      final response = await _apiService.getAvailableRides(queries);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getActiveRide() async {
    try {
      final response = await _apiService.getActiveRide();
      if (response.response.statusCode == 200) {
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'message': 'No active ride'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> acceptRide(int rideId) async {
    try {
      final response = await _apiService.acceptRide(rideId);
      return {'success': true, 'data': response.data['data']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> markArrival(int rideId) async {
    try {
      final response = await _apiService.markArrival(rideId);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> startRide(int rideId) async {
    try {
      final response = await _apiService.startRide(rideId);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> completeRide(
      int rideId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.completeRide(rideId, data);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> driverCancelRide(
      int rideId, String reason) async {
    try {
      final response = await _apiService.driverCancelRide(rideId, {
        'reason': reason,
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
