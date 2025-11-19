import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/payment_repository.dart';
import '../../models/payment_method.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository paymentRepository;

  PaymentBloc({required this.paymentRepository})
      : super(const PaymentInitial()) {
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<AddCreditCard>(_onAddCreditCard);
    on<RemovePaymentMethod>(_onRemovePaymentMethod);
    on<SetDefaultPaymentMethod>(_onSetDefaultPaymentMethod);
    on<ProcessPayment>(_onProcessPayment);
    on<LoadPaymentHistory>(_onLoadPaymentHistory);
    on<LoadWalletBalance>(_onLoadWalletBalance);
    on<AddFundsToWallet>(_onAddFundsToWallet);
    on<VerifyPaymentStatus>(_onVerifyPaymentStatus);
  }

  Future<void> _onLoadPaymentMethods(
    LoadPaymentMethods event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      final result = await paymentRepository.getPaymentMethods();

      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>;
        final methods =
            data.map((json) => PaymentMethod.fromJson(json)).toList();

        final defaultMethod = methods.firstWhere(
          (method) => method.isDefault ?? false,
          orElse: () => methods.isNotEmpty ? methods.first : PaymentMethod(
            id: 0,
            userId: 0,
            type: '',
            lastFour: '',
            isDefault: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        emit(PaymentMethodsLoaded(
          paymentMethods: methods,
          defaultMethod: defaultMethod.id != 0 ? defaultMethod : null,
        ));
      } else {
        emit(PaymentError(
            result['message'] ?? 'Erro ao carregar métodos de pagamento'));
      }
    } catch (e) {
      emit(PaymentError(
          'Erro ao carregar métodos de pagamento: ${e.toString()}'));
    }
  }

  Future<void> _onAddCreditCard(
    AddCreditCard event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      final data = {
        'card_number': event.cardNumber.replaceAll(' ', ''),
        'cardholder_name': event.cardholderName,
        'expiry_month': event.expiryMonth,
        'expiry_year': event.expiryYear,
        'cvv': event.cvv,
        if (event.cpf != null) 'cpf': event.cpf,
      };

      final result = await paymentRepository.addPaymentMethod(data);

      if (result['success'] == true) {
        final paymentMethod = PaymentMethod.fromJson(result['data']);
        emit(PaymentMethodAdded(paymentMethod));

        // Reload all payment methods
        add(const LoadPaymentMethods());
      } else {
        emit(PaymentError(
            result['message'] ?? 'Erro ao adicionar cartão de crédito'));
      }
    } catch (e) {
      emit(PaymentError('Erro ao adicionar cartão: ${e.toString()}'));
    }
  }

  Future<void> _onRemovePaymentMethod(
    RemovePaymentMethod event,
    Emitter<PaymentState> emit,
  ) async {
    final currentState = state;

    try {
      final result =
          await paymentRepository.deletePaymentMethod(event.paymentMethodId);

      if (result['success'] == true) {
        emit(PaymentMethodRemoved(event.paymentMethodId));

        // Reload all payment methods
        add(const LoadPaymentMethods());
      } else {
        emit(PaymentError(
            result['message'] ?? 'Erro ao remover método de pagamento'));
        if (currentState is! PaymentError) {
          emit(currentState);
        }
      }
    } catch (e) {
      emit(PaymentError('Erro ao remover método de pagamento: ${e.toString()}'));
      if (currentState is! PaymentError) {
        emit(currentState);
      }
    }
  }

  Future<void> _onSetDefaultPaymentMethod(
    SetDefaultPaymentMethod event,
    Emitter<PaymentState> emit,
  ) async {
    final currentState = state;

    try {
      final result = await paymentRepository.setDefaultPaymentMethod(
          event.paymentMethodId);

      if (result['success'] == true) {
        final paymentMethod = PaymentMethod.fromJson(result['data']);
        emit(DefaultPaymentMethodUpdated(paymentMethod));

        // Reload all payment methods
        add(const LoadPaymentMethods());
      } else {
        emit(PaymentError(
            result['message'] ?? 'Erro ao definir método padrão'));
        if (currentState is! PaymentError) {
          emit(currentState);
        }
      }
    } catch (e) {
      emit(PaymentError('Erro ao definir método padrão: ${e.toString()}'));
      if (currentState is! PaymentError) {
        emit(currentState);
      }
    }
  }

  Future<void> _onProcessPayment(
    ProcessPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentProcessing(
      rideId: event.rideId,
      amount: event.amount,
    ));

    try {
      final data = {
        'payment_method_id': event.paymentMethodId,
        'amount': event.amount,
      };

      final result = await paymentRepository.processPayment(event.rideId, data);

      if (result['success'] == true) {
        final paymentData = result['data'];
        emit(PaymentSuccessful(
          transactionId: paymentData['transaction_id'] ?? '',
          amount: event.amount,
          timestamp: DateTime.now(),
        ));
      } else {
        emit(PaymentFailed(
          reason: result['message'] ?? 'Erro ao processar pagamento',
          errorCode: result['error_code'],
        ));
      }
    } catch (e) {
      emit(PaymentFailed(
        reason: 'Erro ao processar pagamento: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadPaymentHistory(
    LoadPaymentHistory event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      final queryParams = <String, dynamic>{
        'page': event.page,
        if (event.startDate != null)
          'start_date': event.startDate!.toIso8601String(),
        if (event.endDate != null)
          'end_date': event.endDate!.toIso8601String(),
      };

      final result = await paymentRepository.getPaymentHistory(queryParams);

      if (result['success'] == true) {
        final data = result['data'];
        final transactions = (data['data'] as List<dynamic>)
            .map((json) => json as Map<String, dynamic>)
            .toList();

        emit(PaymentHistoryLoaded(
          transactions: transactions,
          currentPage: data['current_page'] ?? event.page,
          totalPages: data['last_page'],
          hasMore: data['current_page'] < (data['last_page'] ?? 0),
        ));
      } else {
        emit(PaymentError(
            result['message'] ?? 'Erro ao carregar histórico de pagamentos'));
      }
    } catch (e) {
      emit(PaymentError(
          'Erro ao carregar histórico de pagamentos: ${e.toString()}'));
    }
  }

  Future<void> _onLoadWalletBalance(
    LoadWalletBalance event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      final result = await paymentRepository.getWalletBalance();

      if (result['success'] == true) {
        final data = result['data'];
        emit(WalletBalanceLoaded(
          balance: (data['wallet_balance'] ?? 0.0).toDouble(),
          creditBalance: (data['credit_balance'] ?? 0.0).toDouble(),
          totalEarnings: (data['total_earnings'] ?? 0.0).toDouble(),
        ));
      } else {
        emit(PaymentError(
            result['message'] ?? 'Erro ao carregar saldo da carteira'));
      }
    } catch (e) {
      emit(PaymentError('Erro ao carregar saldo: ${e.toString()}'));
    }
  }

  Future<void> _onAddFundsToWallet(
    AddFundsToWallet event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      final data = {
        'amount': event.amount,
        'payment_method_id': event.paymentMethodId,
      };

      final result = await paymentRepository.addFundsToWallet(data);

      if (result['success'] == true) {
        final responseData = result['data'];
        emit(FundsAddedToWallet(
          amount: event.amount,
          newBalance: (responseData['new_balance'] ?? 0.0).toDouble(),
        ));

        // Reload wallet balance
        add(const LoadWalletBalance());
      } else {
        emit(PaymentError(
            result['message'] ?? 'Erro ao adicionar fundos à carteira'));
      }
    } catch (e) {
      emit(PaymentError('Erro ao adicionar fundos: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyPaymentStatus(
    VerifyPaymentStatus event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      final result =
          await paymentRepository.verifyPaymentStatus(event.transactionId);

      if (result['success'] == true) {
        final data = result['data'];
        emit(PaymentStatusVerified(
          transactionId: event.transactionId,
          status: data['status'] ?? 'unknown',
          details: data,
        ));
      } else {
        emit(PaymentError(
            result['message'] ?? 'Erro ao verificar status do pagamento'));
      }
    } catch (e) {
      emit(PaymentError('Erro ao verificar pagamento: ${e.toString()}'));
    }
  }
}
