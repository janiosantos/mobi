import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobi_core/mobi_core.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late PaymentBloc paymentBloc;
  late MockPaymentRepository mockPaymentRepository;

  setUp(() {
    mockPaymentRepository = MockPaymentRepository();
    paymentBloc = PaymentBloc(paymentRepository: mockPaymentRepository);

    // Register fallback values for mocktail
    registerFallbackValue(FakePaymentMethod());
  });

  tearDown(() {
    paymentBloc.close();
  });

  group('PaymentBloc', () {
    group('LoadPaymentMethods', () {
      final paymentMethods = [
        TestData.testPaymentMethod(id: 1, type: 'credit_card', isDefault: true),
        TestData.testPaymentMethod(id: 2, type: 'debit_card', isDefault: false),
        TestData.testPaymentMethod(id: 3, type: 'pix', isDefault: false),
      ];

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PaymentMethodsLoaded] when loading succeeds',
        build: () {
          when(() => mockPaymentRepository.getPaymentMethods())
              .thenAnswer((_) async => TestData.successResponse(
                    data: paymentMethods.map((pm) => pm.toJson()).toList(),
                  ));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(LoadPaymentMethods()),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentMethodsLoaded>()
              .having((s) => s.paymentMethods.length, 'methods count', 3)
              .having((s) => s.defaultPaymentMethod?.id, 'default method id', 1)
              .having((s) => s.defaultPaymentMethod?.isDefault, 'is default', true),
        ],
        verify: (_) {
          verify(() => mockPaymentRepository.getPaymentMethods()).called(1);
        },
      );

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PaymentMethodsLoaded] with no default when all methods are not default',
        build: () {
          final methods = [
            TestData.testPaymentMethod(id: 1, type: 'credit_card', isDefault: false),
            TestData.testPaymentMethod(id: 2, type: 'pix', isDefault: false),
          ];
          when(() => mockPaymentRepository.getPaymentMethods())
              .thenAnswer((_) async => TestData.successResponse(
                    data: methods.map((pm) => pm.toJson()).toList(),
                  ));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(LoadPaymentMethods()),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentMethodsLoaded>()
              .having((s) => s.paymentMethods.length, 'methods count', 2)
              .having((s) => s.defaultPaymentMethod, 'default method', null),
        ],
      );

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PaymentError] when loading fails',
        build: () {
          when(() => mockPaymentRepository.getPaymentMethods())
              .thenThrow(Exception('Failed to load payment methods'));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(LoadPaymentMethods()),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentError>()
              .having((s) => s.message, 'error message', contains('Failed')),
        ],
      );
    });

    group('AddCreditCard', () {
      final newCard = TestData.testPaymentMethod(
        id: 10,
        type: 'credit_card',
        cardBrand: 'mastercard',
        lastFourDigits: '5678',
      );

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PaymentMethodAdded] when card is added successfully',
        build: () {
          when(() => mockPaymentRepository.addCreditCard(
                cardNumber: any(named: 'cardNumber'),
                cardHolderName: any(named: 'cardHolderName'),
                expiryMonth: any(named: 'expiryMonth'),
                expiryYear: any(named: 'expiryYear'),
                cvv: any(named: 'cvv'),
                setAsDefault: any(named: 'setAsDefault'),
              )).thenAnswer((_) async => TestData.successResponse(data: newCard.toJson()));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(AddCreditCard(
          cardNumber: '5555555555555678',
          cardHolderName: 'John Doe',
          expiryMonth: '12',
          expiryYear: '2026',
          cvv: '123',
          setAsDefault: false,
        )),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentMethodAdded>()
              .having((s) => s.paymentMethod.id, 'card id', 10)
              .having((s) => s.paymentMethod.cardBrand, 'card brand', 'mastercard')
              .having((s) => s.paymentMethod.lastFourDigits, 'last four', '5678'),
        ],
        verify: (_) {
          verify(() => mockPaymentRepository.addCreditCard(
                cardNumber: '5555555555555678',
                cardHolderName: 'John Doe',
                expiryMonth: '12',
                expiryYear: '2026',
                cvv: '123',
                setAsDefault: false,
              )).called(1);
        },
      );

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PaymentError] when invalid card data provided',
        build: () {
          when(() => mockPaymentRepository.addCreditCard(
                cardNumber: any(named: 'cardNumber'),
                cardHolderName: any(named: 'cardHolderName'),
                expiryMonth: any(named: 'expiryMonth'),
                expiryYear: any(named: 'expiryYear'),
                cvv: any(named: 'cvv'),
                setAsDefault: any(named: 'setAsDefault'),
              )).thenThrow(Exception('Invalid card number'));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(AddCreditCard(
          cardNumber: '1234',
          cardHolderName: 'John Doe',
          expiryMonth: '12',
          expiryYear: '2026',
          cvv: '123',
        )),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentError>()
              .having((s) => s.message, 'error message', contains('Invalid')),
        ],
      );
    });

    group('RemovePaymentMethod', () {
      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PaymentMethodRemoved] when removal succeeds',
        build: () {
          when(() => mockPaymentRepository.removePaymentMethod(any()))
              .thenAnswer((_) async => TestData.successResponse(
                    message: 'Payment method removed',
                  ));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(RemovePaymentMethod(paymentMethodId: 5)),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentMethodRemoved>()
              .having((s) => s.paymentMethodId, 'removed method id', 5),
        ],
        verify: (_) {
          verify(() => mockPaymentRepository.removePaymentMethod(5)).called(1);
        },
      );

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PaymentError] when cannot remove default method',
        build: () {
          when(() => mockPaymentRepository.removePaymentMethod(any()))
              .thenThrow(Exception('Cannot remove default payment method'));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(RemovePaymentMethod(paymentMethodId: 1)),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentError>()
              .having((s) => s.message, 'error message', contains('Cannot remove default')),
        ],
      );
    });

    group('SetDefaultPaymentMethod', () {
      final updatedMethod = TestData.testPaymentMethod(id: 3, isDefault: true);

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, DefaultPaymentMethodUpdated] when setting default succeeds',
        build: () {
          when(() => mockPaymentRepository.setDefaultPaymentMethod(any()))
              .thenAnswer((_) async => TestData.successResponse(data: updatedMethod.toJson()));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(SetDefaultPaymentMethod(paymentMethodId: 3)),
        expect: () => [
          isA<PaymentLoading>(),
          isA<DefaultPaymentMethodUpdated>()
              .having((s) => s.paymentMethod.id, 'method id', 3)
              .having((s) => s.paymentMethod.isDefault, 'is default', true),
        ],
        verify: (_) {
          verify(() => mockPaymentRepository.setDefaultPaymentMethod(3)).called(1);
        },
      );
    });

    group('ProcessPayment', () {
      const rideId = 1;
      const amount = 45.50;

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentProcessing, PaymentSuccessful] when payment succeeds',
        build: () {
          when(() => mockPaymentRepository.processPayment(any(), any()))
              .thenAnswer((_) async => TestData.successResponse(
                    data: {
                      'success': true,
                      'transaction_id': 'TXN987654',
                      'amount': amount,
                      'status': 'completed',
                    },
                  ));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(ProcessPayment(
          rideId: rideId,
          amount: amount,
          paymentMethodId: 1,
        )),
        expect: () => [
          isA<PaymentProcessing>()
              .having((s) => s.rideId, 'ride id', rideId)
              .having((s) => s.amount, 'amount', amount),
          isA<PaymentSuccessful>()
              .having((s) => s.transactionId, 'transaction id', 'TXN987654')
              .having((s) => s.amount, 'amount', amount),
        ],
        verify: (_) {
          verify(() => mockPaymentRepository.processPayment(rideId, {
                'amount': amount,
                'payment_method_id': 1,
              })).called(1);
        },
      );

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentProcessing, PaymentFailed] when payment fails',
        build: () {
          when(() => mockPaymentRepository.processPayment(any(), any()))
              .thenAnswer((_) async => TestData.errorResponse(
                    message: 'Insufficient funds',
                    data: {
                      'success': false,
                      'error': 'Insufficient funds',
                    },
                  ));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(ProcessPayment(
          rideId: rideId,
          amount: amount,
          paymentMethodId: 1,
        )),
        expect: () => [
          isA<PaymentProcessing>(),
          isA<PaymentFailed>()
              .having((s) => s.rideId, 'ride id', rideId)
              .having((s) => s.reason, 'reason', contains('Insufficient funds')),
        ],
      );

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentProcessing, PaymentFailed] when network error occurs',
        build: () {
          when(() => mockPaymentRepository.processPayment(any(), any()))
              .thenThrow(Exception('Network error'));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(ProcessPayment(
          rideId: rideId,
          amount: amount,
          paymentMethodId: 1,
        )),
        expect: () => [
          isA<PaymentProcessing>(),
          isA<PaymentFailed>()
              .having((s) => s.reason, 'reason', contains('Network error')),
        ],
      );
    });

    group('LoadPaymentHistory', () {
      final paymentHistory = [
        TestData.testPayment(id: 1, rideId: 1, amount: 25.0, status: 'completed'),
        TestData.testPayment(id: 2, rideId: 2, amount: 30.0, status: 'completed'),
        TestData.testPayment(id: 3, rideId: 3, amount: 15.0, status: 'refunded'),
      ];

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PaymentHistoryLoaded] when history is loaded',
        build: () {
          when(() => mockPaymentRepository.getPaymentHistory(
                page: any(named: 'page'),
                perPage: any(named: 'perPage'),
              )).thenAnswer((_) async => TestData.successResponse(
                    data: paymentHistory.map((p) => p.toJson()).toList(),
                  ));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(LoadPaymentHistory(page: 1, perPage: 20)),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentHistoryLoaded>()
              .having((s) => s.payments.length, 'payments count', 3)
              .having((s) => s.payments.first.amount, 'first payment amount', 25.0)
              .having((s) => s.payments.last.status, 'last payment status', 'refunded'),
        ],
      );

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PaymentHistoryLoaded] with empty list when no history',
        build: () {
          when(() => mockPaymentRepository.getPaymentHistory(
                page: any(named: 'page'),
                perPage: any(named: 'perPage'),
              )).thenAnswer((_) async => TestData.successResponse(data: []));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(LoadPaymentHistory(page: 1)),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentHistoryLoaded>()
              .having((s) => s.payments.isEmpty, 'empty payments', true),
        ],
      );
    });

    group('LoadWalletBalance', () {
      const walletBalance = 150.75;

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, WalletBalanceLoaded] when balance is loaded',
        build: () {
          when(() => mockPaymentRepository.getWalletBalance())
              .thenAnswer((_) async => TestData.successResponse(
                    data: {'balance': walletBalance},
                  ));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(LoadWalletBalance()),
        expect: () => [
          isA<PaymentLoading>(),
          isA<WalletBalanceLoaded>()
              .having((s) => s.balance, 'balance', walletBalance),
        ],
        verify: (_) {
          verify(() => mockPaymentRepository.getWalletBalance()).called(1);
        },
      );

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, WalletBalanceLoaded] with zero when no balance',
        build: () {
          when(() => mockPaymentRepository.getWalletBalance())
              .thenAnswer((_) async => TestData.successResponse(
                    data: {'balance': 0.0},
                  ));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(LoadWalletBalance()),
        expect: () => [
          isA<PaymentLoading>(),
          isA<WalletBalanceLoaded>()
              .having((s) => s.balance, 'balance', 0.0),
        ],
      );
    });

    group('AddFundsToWallet', () {
      const amount = 50.0;
      const newBalance = 200.75;

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PaymentProcessing, FundsAddedToWallet] when funds added successfully',
        build: () {
          when(() => mockPaymentRepository.addFundsToWallet(any(), any()))
              .thenAnswer((_) async => TestData.successResponse(
                    data: {
                      'success': true,
                      'new_balance': newBalance,
                      'transaction_id': 'TXN123',
                    },
                  ));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(AddFundsToWallet(
          amount: amount,
          paymentMethodId: 1,
        )),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentProcessing>()
              .having((s) => s.amount, 'amount', amount),
          isA<FundsAddedToWallet>()
              .having((s) => s.amount, 'amount added', amount)
              .having((s) => s.newBalance, 'new balance', newBalance),
        ],
        verify: (_) {
          verify(() => mockPaymentRepository.addFundsToWallet(amount, 1)).called(1);
        },
      );

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PaymentProcessing, PaymentError] when adding funds fails',
        build: () {
          when(() => mockPaymentRepository.addFundsToWallet(any(), any()))
              .thenThrow(Exception('Payment method declined'));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(AddFundsToWallet(
          amount: amount,
          paymentMethodId: 1,
        )),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentProcessing>(),
          isA<PaymentError>()
              .having((s) => s.message, 'error message', contains('declined')),
        ],
      );
    });

    group('VerifyPaymentStatus', () {
      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PaymentStatusVerified] when verification succeeds',
        build: () {
          when(() => mockPaymentRepository.verifyPaymentStatus(any()))
              .thenAnswer((_) async => TestData.successResponse(
                    data: {
                      'transaction_id': 'TXN123',
                      'status': 'completed',
                      'verified_at': DateTime.now().toIso8601String(),
                    },
                  ));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(VerifyPaymentStatus(transactionId: 'TXN123')),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentStatusVerified>()
              .having((s) => s.transactionId, 'transaction id', 'TXN123')
              .having((s) => s.status, 'status', 'completed'),
        ],
        verify: (_) {
          verify(() => mockPaymentRepository.verifyPaymentStatus('TXN123')).called(1);
        },
      );

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PaymentError] when verification fails',
        build: () {
          when(() => mockPaymentRepository.verifyPaymentStatus(any()))
              .thenThrow(Exception('Transaction not found'));
          return paymentBloc;
        },
        act: (bloc) => bloc.add(VerifyPaymentStatus(transactionId: 'TXN999')),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentError>()
              .having((s) => s.message, 'error message', contains('not found')),
        ],
      );
    });

    group('PaymentMethod Model Tests', () {
      test('maskedNumber returns correctly formatted card number', () {
        final method = TestData.testPaymentMethod(
          type: 'credit_card',
          lastFourDigits: '1234',
        );

        expect(method.maskedNumber, equals('**** **** **** 1234'));
      });

      test('isExpired returns true for expired cards', () {
        final expiredMethod = TestData.testPaymentMethod(
          expiryMonth: '01',
          expiryYear: '2020', // Expired
        );

        expect(expiredMethod.isExpired, isTrue);
      });

      test('isExpired returns false for valid cards', () {
        final validMethod = TestData.testPaymentMethod(
          expiryMonth: '12',
          expiryYear: '2030', // Future date
        );

        expect(validMethod.isExpired, isFalse);
      });

      test('displayName returns correct format for credit card', () {
        final method = TestData.testPaymentMethod(
          type: 'credit_card',
          cardBrand: 'visa',
          lastFourDigits: '5678',
        );

        expect(method.displayName, equals('Visa ••5678'));
      });

      test('displayName returns correct format for PIX', () {
        final method = TestData.testPaymentMethod(
          id: 1,
          type: 'pix',
          cardBrand: null,
          lastFourDigits: null,
        );

        expect(method.displayName, equals('PIX'));
      });

      test('cardBrandIcon returns correct icon for different brands', () {
        final visaCard = TestData.testPaymentMethod(cardBrand: 'visa');
        final mastercardCard = TestData.testPaymentMethod(cardBrand: 'mastercard');
        final pixMethod = TestData.testPaymentMethod(type: 'pix', cardBrand: null);

        expect(visaCard.cardBrandIcon, equals('💳'));
        expect(mastercardCard.cardBrandIcon, equals('💳'));
        expect(pixMethod.cardBrandIcon, equals('📱'));
      });
    });

    group('Edge Cases', () {
      blocTest<PaymentBloc, PaymentState>(
        'handles concurrent payment method additions',
        build: () {
          when(() => mockPaymentRepository.addCreditCard(
                cardNumber: any(named: 'cardNumber'),
                cardHolderName: any(named: 'cardHolderName'),
                expiryMonth: any(named: 'expiryMonth'),
                expiryYear: any(named: 'expiryYear'),
                cvv: any(named: 'cvv'),
                setAsDefault: any(named: 'setAsDefault'),
              )).thenAnswer((_) async => TestData.successResponse(
                    data: TestData.testPaymentMethod().toJson(),
                  ));
          return paymentBloc;
        },
        act: (bloc) async {
          bloc.add(AddCreditCard(
            cardNumber: '4111111111111111',
            cardHolderName: 'John Doe',
            expiryMonth: '12',
            expiryYear: '2025',
            cvv: '123',
          ));
          bloc.add(AddCreditCard(
            cardNumber: '5555555555554444',
            cardHolderName: 'Jane Smith',
            expiryMonth: '06',
            expiryYear: '2026',
            cvv: '456',
          ));
        },
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentMethodAdded>(),
          isA<PaymentLoading>(),
          isA<PaymentMethodAdded>(),
        ],
      );
    });
  });
}
