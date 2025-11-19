import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'payment_method.g.dart';

@JsonSerializable()
class PaymentMethod extends Equatable {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String type; // credit_card, debit_card, wallet, pix
  @JsonKey(name: 'card_brand')
  final String? cardBrand; // visa, mastercard, elo, etc.
  @JsonKey(name: 'last_four')
  final String lastFour;
  @JsonKey(name: 'expiry_month')
  final String? expiryMonth;
  @JsonKey(name: 'expiry_year')
  final String? expiryYear;
  @JsonKey(name: 'cardholder_name')
  final String? cardholderName;
  @JsonKey(name: 'is_default')
  final bool? isDefault;
  @JsonKey(name: 'gateway_token')
  final String? gatewayToken; // Token do gateway de pagamento
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    this.cardBrand,
    required this.lastFour,
    this.expiryMonth,
    this.expiryYear,
    this.cardholderName,
    this.isDefault,
    this.gatewayToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        cardBrand,
        lastFour,
        expiryMonth,
        expiryYear,
        cardholderName,
        isDefault,
        gatewayToken,
        createdAt,
        updatedAt,
      ];

  /// Display name for the payment method
  String get displayName {
    switch (type) {
      case 'credit_card':
        return 'Cartão de Crédito';
      case 'debit_card':
        return 'Cartão de Débito';
      case 'wallet':
        return 'Carteira';
      case 'pix':
        return 'PIX';
      default:
        return type;
    }
  }

  /// Get masked card number (e.g., "**** 1234")
  String get maskedNumber => '**** $lastFour';

  /// Get card expiry (e.g., "12/25")
  String? get expiryDisplay {
    if (expiryMonth != null && expiryYear != null) {
      return '$expiryMonth/$expiryYear';
    }
    return null;
  }

  /// Check if card is expired
  bool get isExpired {
    if (expiryMonth == null || expiryYear == null) return false;

    final now = DateTime.now();
    final month = int.tryParse(expiryMonth!) ?? 0;
    final year = int.tryParse(expiryYear!) ?? 0;

    // Year is stored as YY (last 2 digits)
    final fullYear = 2000 + year;

    // Card expires at the end of the expiry month
    final expiryDate = DateTime(fullYear, month + 1, 0); // Last day of month

    return now.isAfter(expiryDate);
  }

  /// Get card brand icon name
  String get cardBrandIcon {
    switch (cardBrand?.toLowerCase()) {
      case 'visa':
        return 'visa';
      case 'mastercard':
        return 'mastercard';
      case 'elo':
        return 'elo';
      case 'amex':
      case 'american express':
        return 'amex';
      case 'hipercard':
        return 'hipercard';
      case 'discover':
        return 'discover';
      default:
        return 'credit_card';
    }
  }

  PaymentMethod copyWith({
    int? id,
    int? userId,
    String? type,
    String? cardBrand,
    String? lastFour,
    String? expiryMonth,
    String? expiryYear,
    String? cardholderName,
    bool? isDefault,
    String? gatewayToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      cardBrand: cardBrand ?? this.cardBrand,
      lastFour: lastFour ?? this.lastFour,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cardholderName: cardholderName ?? this.cardholderName,
      isDefault: isDefault ?? this.isDefault,
      gatewayToken: gatewayToken ?? this.gatewayToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
