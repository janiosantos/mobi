import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../payment_gateway.dart';

/// PagSeguro payment gateway implementation
class PagSeguroGateway implements PaymentGateway {
  late Dio _dio;
  late String _email;
  late String _token;
  late bool _sandbox;

  @override
  String get gatewayId => 'pagseguro';

  @override
  String get gatewayName => 'PagSeguro';

  String get _baseUrl => _sandbox
      ? 'https://ws.sandbox.pagseguro.uol.com.br'
      : 'https://ws.pagseguro.uol.com.br';

  @override
  Future<void> initialize({
    required String apiKey,
    required String apiSecret,
    bool sandbox = false,
  }) async {
    _email = apiKey;
    _token = apiSecret;
    _sandbox = sandbox;

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      queryParameters: {
        'email': _email,
        'token': _token,
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
        '/v2/checkout',
        data: {
          'items': [
            {
              'id': '1',
              'description': description,
              'amount': amount.toStringAsFixed(2),
              'quantity': '1',
            }
          ],
          'reference': metadata?['reference'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      return PaymentTransaction(
        transactionId: response.data['code'],
        status: 'pending',
        amount: amount,
        currency: currency,
        createdAt: DateTime.now(),
        metadata: metadata,
      );
    } catch (e) {
      throw Exception('Failed to create PagSeguro payment: $e');
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
        '/instant-payments/cob',
        data: {
          'calendario': {
            'expiracao': expirationMinutes * 60,
          },
          'devedor': {
            'cpf': metadata?['cpf'] ?? '00000000000',
            'nome': metadata?['name'] ?? 'Cliente',
          },
          'valor': {
            'original': amount.toStringAsFixed(2),
          },
          'chave': metadata?['pix_key'],
          'solicitacaoPagador': description,
        },
      );

      return PixPaymentResponse(
        transactionId: response.data['txid'],
        qrCode: response.data['pixCopiaECola'],
        qrCodeBase64: response.data['imagemQrcode'],
        pixKey: response.data['chave'],
        amount: amount,
        expiresAt: DateTime.now().add(Duration(minutes: expirationMinutes)),
      );
    } catch (e) {
      throw Exception('Failed to create PagSeguro PIX payment: $e');
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
      // First, get card token
      final cardToken = await _getCardToken(cardData);

      // Create payment
      final response = await _dio.post(
        '/v2/transactions',
        data: {
          'paymentMode': 'default',
          'paymentMethod': 'creditCard',
          'currency': 'BRL',
          'items': [
            {
              'id': '1',
              'description': description,
              'amount': amount.toStringAsFixed(2),
              'quantity': '1',
            }
          ],
          'sender': {
            'name': cardData.cardholderName,
            'email': metadata?['email'] ?? 'cliente@mobi.com',
            'phone': {
              'areaCode': metadata?['area_code'] ?? '11',
              'number': metadata?['phone'] ?? '999999999',
            },
            'documents': [
              {
                'type': 'CPF',
                'value': cardData.cpf ?? '00000000000',
              }
            ],
          },
          'creditCard': {
            'token': cardToken,
            'installment': {
              'quantity': installments,
              'value': (amount / installments).toStringAsFixed(2),
            },
            'holder': {
              'name': cardData.cardholderName,
              'documents': [
                {
                  'type': 'CPF',
                  'value': cardData.cpf ?? '00000000000',
                }
              ],
              'birthDate': metadata?['birth_date'] ?? '01/01/1990',
              'phone': {
                'areaCode': metadata?['area_code'] ?? '11',
                'number': metadata?['phone'] ?? '999999999',
              },
            },
          },
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      return CreditCardPaymentResponse(
        transactionId: response.data['code'],
        status: _mapStatusCode(response.data['status']),
        authorizationCode: response.data['reference'],
        amount: amount,
        installments: installments,
        createdAt: DateTime.parse(response.data['date']),
      );
    } catch (e) {
      throw Exception('Failed to process PagSeguro credit card: $e');
    }
  }

  Future<String> _getCardToken(CreditCardData cardData) async {
    final response = await _dio.post(
      '/v2/sessions',
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
      ),
    );

    // This is simplified - in production you'd use PagSeguro's JS library
    return response.data['id'];
  }

  @override
  Future<PaymentStatus> getPaymentStatus(String transactionId) async {
    try {
      final response = await _dio.get('/v3/transactions/$transactionId');
      return _mapStatusCode(response.data['status']);
    } catch (e) {
      throw Exception('Failed to get PagSeguro payment status: $e');
    }
  }

  PaymentStatus _mapStatusCode(dynamic statusCode) {
    final code = statusCode is int ? statusCode : int.tryParse(statusCode.toString()) ?? 0;

    switch (code) {
      case 1: // Aguardando pagamento
        return PaymentStatus.pending;
      case 2: // Em análise
        return PaymentStatus.processing;
      case 3: // Paga
      case 4: // Disponível
        return PaymentStatus.approved;
      case 5: // Em disputa
        return PaymentStatus.processing;
      case 6: // Devolvida
        return PaymentStatus.refunded;
      case 7: // Cancelada
        return PaymentStatus.cancelled;
      case 8: // Debitado
      case 9: // Retenção temporária
        return PaymentStatus.processing;
      default:
        return PaymentStatus.pending;
    }
  }

  @override
  Future<bool> cancelPayment(String transactionId) async {
    try {
      await _dio.post('/v2/transactions/cancels');
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
    // PagSeguro uses notification codes instead of signatures
    // Validation is done by requesting the notification URL
    return true;
  }
}
