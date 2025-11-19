/// Abstract payment gateway interface
abstract class PaymentGateway {
  /// Gateway identifier
  String get gatewayId;

  /// Gateway name
  String get gatewayName;

  /// Initialize payment gateway
  Future<void> initialize({
    required String apiKey,
    required String apiSecret,
    bool sandbox = false,
  });

  /// Create payment transaction
  Future<PaymentTransaction> createPayment({
    required double amount,
    required String currency,
    required String description,
    required PaymentMethod method,
    Map<String, dynamic>? metadata,
  });

  /// Process PIX payment
  Future<PixPaymentResponse> createPixPayment({
    required double amount,
    required String description,
    int expirationMinutes = 30,
    Map<String, dynamic>? metadata,
  });

  /// Process credit card payment
  Future<CreditCardPaymentResponse> processCreditCard({
    required double amount,
    required String description,
    required CreditCardData cardData,
    int installments = 1,
    Map<String, dynamic>? metadata,
  });

  /// Get payment status
  Future<PaymentStatus> getPaymentStatus(String transactionId);

  /// Cancel/refund payment
  Future<bool> cancelPayment(String transactionId);

  /// Validate webhook signature
  bool validateWebhook({
    required String signature,
    required String payload,
    required String secret,
  });
}

/// Payment transaction result
class PaymentTransaction {
  final String transactionId;
  final String status;
  final double amount;
  final String currency;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  PaymentTransaction({
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.createdAt,
    this.metadata,
  });
}

/// PIX payment response
class PixPaymentResponse {
  final String transactionId;
  final String qrCode;
  final String qrCodeBase64;
  final String pixKey;
  final double amount;
  final DateTime expiresAt;

  PixPaymentResponse({
    required this.transactionId,
    required this.qrCode,
    required this.qrCodeBase64,
    required this.pixKey,
    required this.amount,
    required this.expiresAt,
  });
}

/// Credit card payment response
class CreditCardPaymentResponse {
  final String transactionId;
  final String status;
  final String? authorizationCode;
  final double amount;
  final int installments;
  final DateTime createdAt;

  CreditCardPaymentResponse({
    required this.transactionId,
    required this.status,
    this.authorizationCode,
    required this.amount,
    required this.installments,
    required this.createdAt,
  });
}

/// Credit card data
class CreditCardData {
  final String cardNumber;
  final String cardholderName;
  final String expirationMonth;
  final String expirationYear;
  final String cvv;
  final String? cpf;

  CreditCardData({
    required this.cardNumber,
    required this.cardholderName,
    required this.expirationMonth,
    required this.expirationYear,
    required this.cvv,
    this.cpf,
  });

  /// Get masked card number
  String get maskedCardNumber {
    if (cardNumber.length < 4) return '****';
    return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  /// Get card brand
  String get cardBrand {
    final number = cardNumber.replaceAll(' ', '');
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith(RegExp(r'5[1-5]'))) return 'Mastercard';
    if (number.startsWith(RegExp(r'3[47]'))) return 'Amex';
    if (number.startsWith('6011') || number.startsWith('65')) return 'Discover';
    if (number.startsWith('35')) return 'JCB';
    if (number.startsWith('36') || number.startsWith('38')) return 'Diners';
    if (number.startsWith('606282')) return 'Hipercard';
    if (number.startsWith('636368')) return 'Elo';
    return 'Unknown';
  }
}

/// Payment method enum
enum PaymentMethod {
  pix,
  creditCard,
  debitCard,
  cash,
}

/// Payment status enum
enum PaymentStatus {
  pending,
  processing,
  approved,
  declined,
  cancelled,
  refunded,
  expired,
}
