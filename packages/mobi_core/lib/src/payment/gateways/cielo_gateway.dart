import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../payment_gateway.dart';

/// Cielo payment gateway implementation
class CieloGateway implements PaymentGateway {
  late Dio _dio;
  late String _merchantId;
  late String _merchantKey;
  late bool _sandbox;

  @override
  String get gatewayId => 'cielo';

  @override
  String get gatewayName => 'Cielo';

  String get _baseUrl => _sandbox
      ? 'https://apisandbox.cieloecommerce.cielo.com.br'
      : 'https://api.cieloecommerce.cielo.com.br';

  @override
  Future<void> initialize({
    required String apiKey,
    required String apiSecret,
    bool sandbox = false,
  }) async {
    _merchantId = apiKey;
    _merchantKey = apiSecret;
    _sandbox = sandbox;

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'MerchantId': _merchantId,
        'MerchantKey': _merchantKey,
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
        '/1/sales',
        data: {
          'MerchantOrderId': DateTime.now().millisecondsSinceEpoch.toString(),
          'Payment': {
            'Amount': (amount * 100).toInt(),
            'Currency': currency,
            'Description': description,
          },
        },
      );

      return PaymentTransaction(
        transactionId: response.data['Payment']['PaymentId'],
        status: _mapStatus(response.data['Payment']['Status']),
        amount: amount,
        currency: currency,
        createdAt: DateTime.now(),
        metadata: metadata,
      );
    } catch (e) {
      throw Exception('Failed to create Cielo payment: $e');
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
        '/1/sales',
        data: {
          'MerchantOrderId': DateTime.now().millisecondsSinceEpoch.toString(),
          'Payment': {
            'Type': 'Pix',
            'Amount': (amount * 100).toInt(),
            'Description': description,
          },
        },
      );

      return PixPaymentResponse(
        transactionId: response.data['Payment']['PaymentId'],
        qrCode: response.data['Payment']['QrCodeString'],
        qrCodeBase64: response.data['Payment']['QrCodeBase64Image'],
        pixKey: response.data['Payment']['QrCodeString'],
        amount: amount,
        expiresAt: DateTime.now().add(Duration(minutes: expirationMinutes)),
      );
    } catch (e) {
      throw Exception('Failed to create Cielo PIX payment: $e');
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
        '/1/sales',
        data: {
          'MerchantOrderId': DateTime.now().millisecondsSinceEpoch.toString(),
          'Payment': {
            'Type': 'CreditCard',
            'Amount': (amount * 100).toInt(),
            'Installments': installments,
            'SoftDescriptor': description.substring(0, 13),
            'CreditCard': {
              'CardNumber': cardData.cardNumber.replaceAll(' ', ''),
              'Holder': cardData.cardholderName,
              'ExpirationDate': '${cardData.expirationMonth}/${cardData.expirationYear}',
              'SecurityCode': cardData.cvv,
              'Brand': cardData.cardBrand,
            },
          },
        },
      );

      return CreditCardPaymentResponse(
        transactionId: response.data['Payment']['PaymentId'],
        status: _mapStatus(response.data['Payment']['Status']),
        authorizationCode: response.data['Payment']['AuthorizationCode'],
        amount: amount,
        installments: installments,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to process Cielo credit card: $e');
    }
  }

  @override
  Future<PaymentStatus> getPaymentStatus(String transactionId) async {
    try {
      final response = await _dio.get('/1/sales/$transactionId');
      return _mapStatus(response.data['Payment']['Status']);
    } catch (e) {
      throw Exception('Failed to get Cielo payment status: $e');
    }
  }

  String _mapStatus(dynamic status) {
    final code = status is int ? status : int.tryParse(status.toString()) ?? 0;

    switch (code) {
      case 0:
        return 'pending';
      case 1:
        return 'approved';
      case 2:
        return 'approved';
      case 3:
        return 'declined';
      case 10:
        return 'cancelled';
      case 11:
        return 'refunded';
      case 12:
        return 'pending';
      default:
        return 'pending';
    }
  }

  @override
  Future<bool> cancelPayment(String transactionId) async {
    try {
      await _dio.put('/1/sales/$transactionId/void');
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
