import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment extends Equatable {
  final int id;
  @JsonKey(name: 'payment_number')
  final String paymentNumber;
  @JsonKey(name: 'ride_id')
  final int rideId;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'payment_type')
  final String paymentType;
  final double amount;
  @JsonKey(name: 'platform_fee')
  final double? platformFee;
  @JsonKey(name: 'driver_amount')
  final double? driverAmount;
  final String status;
  final String gateway;
  @JsonKey(name: 'gateway_payment_id')
  final String? gatewayPaymentId;
  @JsonKey(name: 'pix_qr_code')
  final String? pixQrCode;
  @JsonKey(name: 'pix_qr_code_base64')
  final String? pixQrCodeBase64;
  @JsonKey(name: 'card_brand')
  final String? cardBrand;
  @JsonKey(name: 'card_last_four')
  final String? cardLastFour;
  final int? installments;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'processed_at')
  final DateTime? processedAt;

  const Payment({
    required this.id,
    required this.paymentNumber,
    required this.rideId,
    required this.userId,
    required this.paymentType,
    required this.amount,
    this.platformFee,
    this.driverAmount,
    required this.status,
    required this.gateway,
    this.gatewayPaymentId,
    this.pixQrCode,
    this.pixQrCodeBase64,
    this.cardBrand,
    this.cardLastFour,
    this.installments,
    this.createdAt,
    this.processedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  bool get isPix => paymentType == 'pix';
  bool get isCreditCard => paymentType == 'credit_card';
  bool get isDebitCard => paymentType == 'debit_card';
  bool get isCash => paymentType == 'cash';

  @override
  List<Object?> get props => [
        id,
        paymentNumber,
        rideId,
        userId,
        paymentType,
        amount,
        platformFee,
        driverAmount,
        status,
        gateway,
        gatewayPaymentId,
        pixQrCode,
        pixQrCodeBase64,
        cardBrand,
        cardLastFour,
        installments,
        createdAt,
        processedAt,
      ];
}
