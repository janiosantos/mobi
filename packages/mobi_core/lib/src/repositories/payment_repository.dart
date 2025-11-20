import '../models/payment.dart';
import '../services/api_service.dart';

class PaymentRepository {
  final ApiService _apiService;

  PaymentRepository(this._apiService);

  Future<Map<String, dynamic>> getPayments({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queries = {
        'page': page,
        'per_page': perPage,
      };

      final response = await _apiService.getPayments(queries);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await _apiService.getPaymentMethods();
      return {'success': true, 'data': response.data['data']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> addPaymentMethod(
      Map<String, dynamic> data) async {
    try {
      final response = await _apiService.addPaymentMethod(data);
      return {'success': true, 'data': response.data['data']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deletePaymentMethod(int paymentMethodId) async {
    try {
      await _apiService.deletePaymentMethod(paymentMethodId);
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> setDefaultPaymentMethod(
      int paymentMethodId) async {
    try {
      final response =
          await _apiService.setDefaultPaymentMethod(paymentMethodId);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createRidePayment(
      int rideId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.createRidePayment(rideId, data);
      return {'success': true, 'data': response.data['data']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Payment> processPayment(int rideId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.createRidePayment(rideId, data);
      return Payment.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  Future<Map<String, dynamic>> getPaymentHistory(Map<String, dynamic> queryParams) async {
    try {
      final response = await _apiService.getPayments(queryParams);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<double> getWalletBalance() async {
    try {
      final response = await _apiService.get('/wallet/balance');
      return (response.data['data']['balance'] as num).toDouble();
    } catch (e) {
      throw Exception('Failed to get wallet balance: $e');
    }
  }

  Future<Map<String, dynamic>> addFundsToWallet(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/wallet/add-funds', data: data);
      return {'success': true, 'data': response.data['data']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Payment> verifyPaymentStatus(String transactionId) async {
    try {
      final response = await _apiService.get('/payments/verify/$transactionId');
      return Payment.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to verify payment status: $e');
    }
  }
}
