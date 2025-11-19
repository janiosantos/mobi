import 'package:equatable/equatable.dart';
import '../../models/payment_method.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

/// Loading state
class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

/// Payment methods loaded
class PaymentMethodsLoaded extends PaymentState {
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? defaultMethod;

  const PaymentMethodsLoaded({
    required this.paymentMethods,
    this.defaultMethod,
  });

  @override
  List<Object?> get props => [paymentMethods, defaultMethod];
}

/// Payment method added successfully
class PaymentMethodAdded extends PaymentState {
  final PaymentMethod paymentMethod;

  const PaymentMethodAdded(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}

/// Payment method removed
class PaymentMethodRemoved extends PaymentState {
  final int paymentMethodId;

  const PaymentMethodRemoved(this.paymentMethodId);

  @override
  List<Object> get props => [paymentMethodId];
}

/// Default payment method updated
class DefaultPaymentMethodUpdated extends PaymentState {
  final PaymentMethod paymentMethod;

  const DefaultPaymentMethodUpdated(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}

/// Payment processing
class PaymentProcessing extends PaymentState {
  final int rideId;
  final double amount;

  const PaymentProcessing({
    required this.rideId,
    required this.amount,
  });

  @override
  List<Object> get props => [rideId, amount];
}

/// Payment successful
class PaymentSuccessful extends PaymentState {
  final String transactionId;
  final double amount;
  final DateTime timestamp;

  const PaymentSuccessful({
    required this.transactionId,
    required this.amount,
    required this.timestamp,
  });

  @override
  List<Object> get props => [transactionId, amount, timestamp];
}

/// Payment failed
class PaymentFailed extends PaymentState {
  final String reason;
  final String? errorCode;

  const PaymentFailed({
    required this.reason,
    this.errorCode,
  });

  @override
  List<Object?> get props => [reason, errorCode];
}

/// Payment history loaded
class PaymentHistoryLoaded extends PaymentState {
  final List<Map<String, dynamic>> transactions;
  final int currentPage;
  final int? totalPages;
  final bool hasMore;

  const PaymentHistoryLoaded({
    required this.transactions,
    required this.currentPage,
    this.totalPages,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [transactions, currentPage, totalPages, hasMore];
}

/// Wallet balance loaded
class WalletBalanceLoaded extends PaymentState {
  final double balance;
  final double creditBalance;
  final double totalEarnings;

  const WalletBalanceLoaded({
    required this.balance,
    this.creditBalance = 0.0,
    this.totalEarnings = 0.0,
  });

  @override
  List<Object> get props => [balance, creditBalance, totalEarnings];
}

/// Funds added to wallet
class FundsAddedToWallet extends PaymentState {
  final double amount;
  final double newBalance;

  const FundsAddedToWallet({
    required this.amount,
    required this.newBalance,
  });

  @override
  List<Object> get props => [amount, newBalance];
}

/// Payment status verified
class PaymentStatusVerified extends PaymentState {
  final String transactionId;
  final String status;
  final Map<String, dynamic>? details;

  const PaymentStatusVerified({
    required this.transactionId,
    required this.status,
    this.details,
  });

  @override
  List<Object?> get props => [transactionId, status, details];
}

/// Error state
class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object> get props => [message];
}
