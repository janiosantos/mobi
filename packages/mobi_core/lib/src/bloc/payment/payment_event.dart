import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Load payment methods
class LoadPaymentMethods extends PaymentEvent {
  const LoadPaymentMethods();
}

/// Add credit card
class AddCreditCard extends PaymentEvent {
  final String cardNumber;
  final String cardholderName;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String? cpf;

  const AddCreditCard({
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    this.cpf,
  });

  @override
  List<Object?> get props => [
        cardNumber,
        cardholderName,
        expiryMonth,
        expiryYear,
        cvv,
        cpf,
      ];
}

/// Remove payment method
class RemovePaymentMethod extends PaymentEvent {
  final int paymentMethodId;

  const RemovePaymentMethod(this.paymentMethodId);

  @override
  List<Object> get props => [paymentMethodId];
}

/// Set default payment method
class SetDefaultPaymentMethod extends PaymentEvent {
  final int paymentMethodId;

  const SetDefaultPaymentMethod(this.paymentMethodId);

  @override
  List<Object> get props => [paymentMethodId];
}

/// Process payment for ride
class ProcessPayment extends PaymentEvent {
  final int rideId;
  final int paymentMethodId;
  final double amount;

  const ProcessPayment({
    required this.rideId,
    required this.paymentMethodId,
    required this.amount,
  });

  @override
  List<Object> get props => [rideId, paymentMethodId, amount];
}

/// Get payment history
class LoadPaymentHistory extends PaymentEvent {
  final int page;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadPaymentHistory({
    this.page = 1,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [page, startDate, endDate];
}

/// Get wallet balance
class LoadWalletBalance extends PaymentEvent {
  const LoadWalletBalance();
}

/// Add funds to wallet
class AddFundsToWallet extends PaymentEvent {
  final double amount;
  final int paymentMethodId;

  const AddFundsToWallet({
    required this.amount,
    required this.paymentMethodId,
  });

  @override
  List<Object> get props => [amount, paymentMethodId];
}

/// Verify payment status
class VerifyPaymentStatus extends PaymentEvent {
  final String transactionId;

  const VerifyPaymentStatus(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}
