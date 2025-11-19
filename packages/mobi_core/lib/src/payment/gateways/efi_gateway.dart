import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../payment_gateway.dart';

/// EFI (antiga Gerencianet) payment gateway implementation
class EfiGateway implements PaymentGateway {
  late Dio _dio;
  late String _clientId;
  late String _clientSecret;
  late bool _sandbox;
  String? _accessToken;

  @override
  String get gatewayId => 'efi';

  @override
  String get gatewayName => 'EFI (Gerencianet)';

  String get _baseUrl => _sandbox
      ? 'https://sandbox.gerencianet.com.br/v1'
      : 'https://api.gerencianet.com.br/v1';

  @override
  Future<void> initialize({
    required String apiKey,
    required String apiSecret,
    bool sandbox = false,
  }) async {
    _clientId = apiKey;
    _clientSecret = apiSecret;
    _sandbox = sandbox;

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    await _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));

      final response = await _dio.post(
        '/authorize',
        options: Options(
          headers: {
            'Authorization': 'Basic $credentials',
            'Content-Type': 'application/json',
          },
        ),
        data: {'grant_type': 'client_credentials'},
      );

      _accessToken = response.data['access_token'];

      _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
    } catch (e) {
      throw Exception('EFI authentication failed: $e');
    }
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
        '/charge',
        data: {
          'items': [
            {
              'name': description,
              'value': (amount * 100).toInt(),
              'amount': 1,
            }
          ],
          'metadata': metadata ?? {},
        },
      );

      return PaymentTransaction(
        transactionId: response.data['data']['charge_id'].toString(),
        status: 'pending',
        amount: amount,
        currency: currency,
        createdAt: DateTime.now(),
        metadata: metadata,
      );
    } catch (e) {
      throw Exception('Failed to create payment: $e');
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
      // Create charge
      final chargeResponse = await _dio.post(
        '/charge',
        data: {
          'items': [
            {
              'name': description,
              'value': (amount * 100).toInt(),
              'amount': 1,
            }
          ],
          'metadata': metadata ?? {},
        },
      );

      final chargeId = chargeResponse.data['data']['charge_id'];

      // Generate PIX QR Code
      final pixResponse = await _dio.post(
        '/charge/$chargeId/pix',
        data: {
          'expiration': expirationMinutes * 60,
        },
      );

      final pixData = pixResponse.data;

      return PixPaymentResponse(
        transactionId: chargeId.toString(),
        qrCode: pixData['qrcode'],
        qrCodeBase64: pixData['imagemQrcode'],
        pixKey: pixData['qrcode'],
        amount: amount,
        expiresAt: DateTime.now().add(Duration(minutes: expirationMinutes)),
      );
    } catch (e) {
      throw Exception('Failed to create PIX payment: $e');
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
      // Create charge
      final chargeResponse = await _dio.post(
        '/charge',
        data: {
          'items': [
            {
              'name': description,
              'value': (amount * 100).toInt(),
              'amount': 1,
            }
          ],
        },
      );

      final chargeId = chargeResponse.data['data']['charge_id'];

      // Process payment
      final paymentResponse = await _dio.post(
        '/charge/$chargeId/pay',
        data: {
          'payment': {
            'credit_card': {
              'installments': installments,
              'payment_token': await _createCardToken(cardData),
              'billing_address': {
                'street': metadata?['street'] ?? 'N/A',
                'number': metadata?['number'] ?? 'N/A',
                'neighborhood': metadata?['neighborhood'] ?? 'N/A',
                'zipcode': metadata?['zipcode'] ?? '00000000',
                'city': metadata?['city'] ?? 'N/A',
                'state': metadata?['state'] ?? 'SP',
              },
              'customer': {
                'name': cardData.cardholderName,
                'cpf': cardData.cpf ?? '00000000000',
                'email': metadata?['email'] ?? 'cliente@mobi.com',
                'phone_number': metadata?['phone'] ?? '11999999999',
              },
            },
          },
        },
      );

      return CreditCardPaymentResponse(
        transactionId: chargeId.toString(),
        status: paymentResponse.data['data']['status'],
        authorizationCode: paymentResponse.data['data']['authorization_code'],
        amount: amount,
        installments: installments,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to process credit card: $e');
    }
  }

  Future<String> _createCardToken(CreditCardData cardData) async {
    final response = await _dio.post(
      '/card',
      data: {
        'number': cardData.cardNumber.replaceAll(' ', ''),
        'brand': cardData.cardBrand.toLowerCase(),
        'cvv': cardData.cvv,
        'expiration_month': cardData.expirationMonth,
        'expiration_year': cardData.expirationYear,
      },
    );

    return response.data['payment_token'];
  }

  @override
  Future<PaymentStatus> getPaymentStatus(String transactionId) async {
    try {
      final response = await _dio.get('/charge/$transactionId');
      final status = response.data['data']['status'];

      return _mapStatus(status);
    } catch (e) {
      throw Exception('Failed to get payment status: $e');
    }
  }

  PaymentStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'waiting':
      case 'new':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.approved;
      case 'unpaid':
      case 'refunded':
        return PaymentStatus.refunded;
      case 'contested':
      case 'canceled':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }

  @override
  Future<bool> cancelPayment(String transactionId) async {
    try {
      await _dio.put('/charge/$transactionId/cancel');
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
    final calculatedSignature = digest.toString();

    return signature == calculatedSignature;
  }
}
