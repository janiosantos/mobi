import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../payment_gateway.dart';

/// Stone payment gateway implementation
class StoneGateway implements PaymentGateway {
  late Dio _dio;
  late String _apiKey;
  late bool _sandbox;

  @override
  String get gatewayId => 'stone';

  @override
  String get gatewayName => 'Stone';

  String get _baseUrl => _sandbox
      ? 'https://sandbox-api.stone.com.br/v1'
      : 'https://api.stone.com.br/v1';

  @override
  Future<void> initialize({
    required String apiKey,
    required String apiSecret,
    bool sandbox = false,
  }) async {
    _apiKey = apiKey;
    _sandbox = sandbox;

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    ));
  }

  @override
  Future<PaymentTransaction> createPayment({
    required double amount,
    required String currency,
    required String description,
    required PaymentMethod method,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        '/charges',
        data: {
          'amount': (amount * 100).toInt(),
          'currency': currency,
          'description': description,
          'metadata': metadata ?? {},
        },
      );

      return PaymentTransaction(
        transactionId: response.data['id'],
        status: response.data['status'],
        amount: amount,
        currency: currency,
        createdAt: DateTime.parse(response.data['created_at']),
        metadata: metadata,
      );
    } catch (e) {
      throw Exception('Failed to create Stone payment: $e');
    }
  }

  @override
  Future<PixPaymentResponse> createPixPayment({
    required double amount,
    required String description,
    int expirationMinutes = 30,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        '/charges',
        data: {
          'amount': (amount * 100).toInt(),
          'payment_method': 'pix',
          'description': description,
          'expiration': expirationMinutes * 60,
          'metadata': metadata ?? {},
        },
      );

      return PixPaymentResponse(
        transactionId: response.data['id'],
        qrCode: response.data['pix']['qr_code'],
        qrCodeBase64: response.data['pix']['qr_code_image'],
        pixKey: response.data['pix']['qr_code'],
        amount: amount,
        expiresAt: DateTime.parse(response.data['pix']['expires_at']),
      );
    } catch (e) {
      throw Exception('Failed to create Stone PIX payment: $e');
    }
  }

  @override
  Future<CreditCardPaymentResponse> processCreditCard({
    required double amount,
    required String description,
    required CreditCardData cardData,
    int installments = 1,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        '/charges',
        data: {
          'amount': (amount * 100).toInt(),
          'payment_method': 'credit_card',
          'description': description,
          'installments': installments,
          'card': {
            'number': cardData.cardNumber.replaceAll(' ', ''),
            'holder_name': cardData.cardholderName,
            'exp_month': cardData.expirationMonth,
            'exp_year': cardData.expirationYear,
            'cvv': cardData.cvv,
          },
          'metadata': metadata ?? {},
        },
      );

      return CreditCardPaymentResponse(
        transactionId: response.data['id'],
        status: response.data['status'],
        authorizationCode: response.data['authorization_code'],
        amount: amount,
        installments: installments,
        createdAt: DateTime.parse(response.data['created_at']),
      );
    } catch (e) {
      throw Exception('Failed to process Stone credit card: $e');
    }
  }

  @override
  Future<PaymentStatus> getPaymentStatus(String transactionId) async {
    try {
      final response = await _dio.get('/charges/$transactionId');
      return _mapStatus(response.data['status']);
    } catch (e) {
      throw Exception('Failed to get Stone payment status: $e');
    }
  }

  PaymentStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'approved':
      case 'paid':
        return PaymentStatus.approved;
      case 'declined':
      case 'failed':
        return PaymentStatus.declined;
      case 'canceled':
        return PaymentStatus.cancelled;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  @override
  Future<bool> cancelPayment(String transactionId) async {
    try {
      await _dio.post('/charges/$transactionId/cancel');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  bool validateWebhook({
    required String signature,
    required String payload,
    required String secret,
  }) {
    final hmac = Hmac(sha256, utf8.encode(secret));
    final digest = hmac.convert(utf8.encode(payload));
    return signature == digest.toString();
  }
}
