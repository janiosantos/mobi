import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobi_core/mobi_core.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late RideBloc rideBloc;
  late MockRideRepository mockRideRepository;

  setUp(() {
    mockRideRepository = MockRideRepository();
    rideBloc = RideBloc(rideRepository: mockRideRepository);

    // Register fallback values for mocktail
    registerFallbackValue(FakeRide());
  });

  tearDown(() {
    rideBloc.close();
  });

  group('RideBloc', () {
    group('RequestRide', () {
      final testRide = TestData.testRide(status: 'searching_driver');

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, RideRequesting, RideRequested] when ride request succeeds',
        build: () {
          when(() => mockRideRepository.requestRide(any()))
              .thenAnswer((_) async => TestData.successResponse(data: testRide.toJson()));
          return rideBloc;
        },
        act: (bloc) => bloc.add(RequestRide(
          pickupLatitude: -23.550520,
          pickupLongitude: -46.633308,
          pickupAddress: 'Av. Paulista, 1000',
          destinationLatitude: -23.561684,
          destinationLongitude: -46.656139,
          destinationAddress: 'Av. Faria Lima, 2000',
          categoryId: 1,
        )),
        expect: () => [
          isA<RideLoading>(),
          isA<RideRequesting>(),
          isA<RideRequested>()
              .having((s) => s.ride.status, 'ride status', 'searching_driver'),
        ],
        verify: (_) {
          verify(() => mockRideRepository.requestRide(any())).called(1);
        },
      );

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, RideRequesting, RideError] when ride request fails',
        build: () {
          when(() => mockRideRepository.requestRide(any()))
              .thenThrow(Exception('Failed to request ride'));
          return rideBloc;
        },
        act: (bloc) => bloc.add(RequestRide(
          pickupLatitude: -23.550520,
          pickupLongitude: -46.633308,
          pickupAddress: 'Av. Paulista, 1000',
          destinationLatitude: -23.561684,
          destinationLongitude: -46.656139,
          destinationAddress: 'Av. Faria Lima, 2000',
          categoryId: 1,
        )),
        expect: () => [
          isA<RideLoading>(),
          isA<RideRequesting>(),
          isA<RideError>()
              .having((s) => s.message, 'error message', contains('Failed')),
        ],
      );
    });

    group('LoadCurrentRide', () {
      final testRide = TestData.testRide(status: 'in_progress');

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, RideInProgress] when current ride exists',
        build: () {
          when(() => mockRideRepository.getCurrentRide())
              .thenAnswer((_) async => TestData.successResponse(data: testRide.toJson()));
          return rideBloc;
        },
        act: (bloc) => bloc.add(LoadCurrentRide()),
        expect: () => [
          isA<RideLoading>(),
          isA<RideInProgress>()
              .having((s) => s.ride.id, 'ride id', testRide.id)
              .having((s) => s.ride.status, 'ride status', 'in_progress'),
        ],
        verify: (_) {
          verify(() => mockRideRepository.getCurrentRide()).called(1);
        },
      );

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, NoActiveRide] when no current ride exists',
        build: () {
          when(() => mockRideRepository.getCurrentRide())
              .thenAnswer((_) async => TestData.successResponse(data: null));
          return rideBloc;
        },
        act: (bloc) => bloc.add(LoadCurrentRide()),
        expect: () => [
          isA<RideLoading>(),
          isA<NoActiveRide>(),
        ],
      );
    });

    group('TrackRide', () {
      final driverEnRouteRide = TestData.testRide(
        status: 'driver_en_route',
        driverId: 2,
      );

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, DriverEnRoute] when tracking driver en route',
        build: () {
          when(() => mockRideRepository.trackRide(any()))
              .thenAnswer((_) async => TestData.successResponse(data: driverEnRouteRide.toJson()));
          return rideBloc;
        },
        act: (bloc) => bloc.add(TrackRide(rideId: 1)),
        expect: () => [
          isA<RideLoading>(),
          isA<DriverEnRoute>()
              .having((s) => s.ride.status, 'ride status', 'driver_en_route')
              .having((s) => s.ride.driverId, 'driver id', 2),
        ],
      );

      final driverArrivedRide = TestData.testRide(
        status: 'driver_arrived',
        driverId: 2,
      );

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, DriverArrived] when driver arrives at pickup',
        build: () {
          when(() => mockRideRepository.trackRide(any()))
              .thenAnswer((_) async => TestData.successResponse(data: driverArrivedRide.toJson()));
          return rideBloc;
        },
        act: (bloc) => bloc.add(TrackRide(rideId: 1)),
        expect: () => [
          isA<RideLoading>(),
          isA<DriverArrived>()
              .having((s) => s.ride.status, 'ride status', 'driver_arrived'),
        ],
      );

      final completedRide = TestData.testRide(
        status: 'completed',
        driverId: 2,
        finalPrice: 30.0,
      );

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, RideCompleted] when ride is completed',
        build: () {
          when(() => mockRideRepository.trackRide(any()))
              .thenAnswer((_) async => TestData.successResponse(data: completedRide.toJson()));
          return rideBloc;
        },
        act: (bloc) => bloc.add(TrackRide(rideId: 1)),
        expect: () => [
          isA<RideLoading>(),
          isA<RideCompleted>()
              .having((s) => s.ride.status, 'ride status', 'completed')
              .having((s) => s.ride.finalPrice, 'final price', 30.0),
        ],
      );
    });

    group('CancelRideByPassenger', () {
      final cancelledRide = TestData.testRide(status: 'cancelled_by_passenger');

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, RideCancelled] when cancellation succeeds',
        build: () {
          when(() => mockRideRepository.cancelRideByPassenger(any(), any()))
              .thenAnswer((_) async => TestData.successResponse(data: cancelledRide.toJson()));
          return rideBloc;
        },
        act: (bloc) => bloc.add(CancelRideByPassenger(
          rideId: 1,
          reason: 'Changed my mind',
        )),
        expect: () => [
          isA<RideLoading>(),
          isA<RideCancelled>()
              .having((s) => s.ride.status, 'ride status', 'cancelled_by_passenger')
              .having((s) => s.cancelledBy, 'cancelled by', 'passenger'),
        ],
        verify: (_) {
          verify(() => mockRideRepository.cancelRideByPassenger(1, 'Changed my mind')).called(1);
        },
      );

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, RideError] when cancellation fails',
        build: () {
          when(() => mockRideRepository.cancelRideByPassenger(any(), any()))
              .thenThrow(Exception('Cannot cancel ride at this time'));
          return rideBloc;
        },
        act: (bloc) => bloc.add(CancelRideByPassenger(
          rideId: 1,
          reason: 'Changed my mind',
        )),
        expect: () => [
          isA<RideLoading>(),
          isA<RideError>()
              .having((s) => s.message, 'error message', contains('Cannot cancel')),
        ],
      );
    });

    group('RateRide', () {
      final ratedRide = TestData.testRide(status: 'completed');

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, RideRated] when rating succeeds',
        build: () {
          when(() => mockRideRepository.rateRide(any(), any(), any()))
              .thenAnswer((_) async => TestData.successResponse(data: ratedRide.toJson()));
          return rideBloc;
        },
        act: (bloc) => bloc.add(RateRide(
          rideId: 1,
          rating: 5,
          comment: 'Excellent service!',
        )),
        expect: () => [
          isA<RideLoading>(),
          isA<RideRated>()
              .having((s) => s.ride.id, 'ride id', 1)
              .having((s) => s.rating, 'rating', 5)
              .having((s) => s.comment, 'comment', 'Excellent service!'),
        ],
        verify: (_) {
          verify(() => mockRideRepository.rateRide(1, 5, 'Excellent service!')).called(1);
        },
      );

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, RideError] when invalid rating provided',
        build: () {
          when(() => mockRideRepository.rateRide(any(), any(), any()))
              .thenThrow(Exception('Rating must be between 1 and 5'));
          return rideBloc;
        },
        act: (bloc) => bloc.add(RateRide(
          rideId: 1,
          rating: 6, // Invalid rating
          comment: 'Test',
        )),
        expect: () => [
          isA<RideLoading>(),
          isA<RideError>()
              .having((s) => s.message, 'error message', contains('Rating must be')),
        ],
      );
    });

    group('AddTip', () {
      final tipResponse = {'success': true, 'message': 'Tip added successfully'};

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, TipAdded] when tip is added successfully',
        build: () {
          when(() => mockRideRepository.addTip(any(), any()))
              .thenAnswer((_) async => tipResponse);
          return rideBloc;
        },
        act: (bloc) => bloc.add(AddTip(
          rideId: 1,
          amount: 5.0,
        )),
        expect: () => [
          isA<RideLoading>(),
          isA<TipAdded>()
              .having((s) => s.rideId, 'ride id', 1)
              .having((s) => s.tipAmount, 'tip amount', 5.0),
        ],
        verify: (_) {
          verify(() => mockRideRepository.addTip(1, 5.0)).called(1);
        },
      );
    });

    group('LoadRideHistory', () {
      final rideHistory = [
        TestData.testRide(id: 1, status: 'completed', finalPrice: 25.0),
        TestData.testRide(id: 2, status: 'completed', finalPrice: 30.0),
        TestData.testRide(id: 3, status: 'cancelled_by_passenger'),
      ];

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, RideHistoryLoaded] with list of rides',
        build: () {
          when(() => mockRideRepository.getRideHistory(
                page: any(named: 'page'),
                perPage: any(named: 'perPage'),
              )).thenAnswer((_) async => TestData.successResponse(
                data: rideHistory.map((r) => r.toJson()).toList(),
              ));
          return rideBloc;
        },
        act: (bloc) => bloc.add(LoadRideHistory(page: 1, perPage: 10)),
        expect: () => [
          isA<RideLoading>(),
          isA<RideHistoryLoaded>()
              .having((s) => s.rides.length, 'rides count', 3)
              .having((s) => s.rides.first.id, 'first ride id', 1)
              .having((s) => s.rides.last.id, 'last ride id', 3),
        ],
      );

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, RideHistoryLoaded] with empty list when no history',
        build: () {
          when(() => mockRideRepository.getRideHistory(
                page: any(named: 'page'),
                perPage: any(named: 'perPage'),
              )).thenAnswer((_) async => TestData.successResponse(data: []));
          return rideBloc;
        },
        act: (bloc) => bloc.add(LoadRideHistory(page: 1, perPage: 10)),
        expect: () => [
          isA<RideLoading>(),
          isA<RideHistoryLoaded>()
              .having((s) => s.rides.isEmpty, 'empty rides', true),
        ],
      );
    });

    group('GetRideDetails', () {
      final detailedRide = TestData.testRide(
        id: 1,
        status: 'completed',
        finalPrice: 35.50,
      );

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, RideDetailsLoaded] when details are loaded',
        build: () {
          when(() => mockRideRepository.getRideDetails(any()))
              .thenAnswer((_) async => TestData.successResponse(data: detailedRide.toJson()));
          return rideBloc;
        },
        act: (bloc) => bloc.add(GetRideDetails(rideId: 1)),
        expect: () => [
          isA<RideLoading>(),
          isA<RideDetailsLoaded>()
              .having((s) => s.ride.id, 'ride id', 1)
              .having((s) => s.ride.finalPrice, 'final price', 35.50),
        ],
      );
    });

    group('ClearCurrentRide', () {
      blocTest<RideBloc, RideState>(
        'emits [NoActiveRide] when current ride is cleared',
        build: () => rideBloc,
        act: (bloc) => bloc.add(ClearCurrentRide()),
        expect: () => [isA<NoActiveRide>()],
      );
    });

    group('RefreshRideStatus', () {
      final updatedRide = TestData.testRide(
        id: 1,
        status: 'in_progress',
      );

      blocTest<RideBloc, RideState>(
        'emits updated ride state when status is refreshed',
        build: () {
          when(() => mockRideRepository.trackRide(any()))
              .thenAnswer((_) async => TestData.successResponse(data: updatedRide.toJson()));
          return rideBloc;
        },
        act: (bloc) => bloc.add(RefreshRideStatus(rideId: 1)),
        expect: () => [
          isA<RideLoading>(),
          isA<RideInProgress>()
              .having((s) => s.ride.status, 'ride status', 'in_progress'),
        ],
      );
    });

    group('State Transitions', () {
      test('RideRequested should have correct ride data', () {
        final ride = TestData.testRide(status: 'searching_driver');
        final state = RideRequested(ride);

        expect(state.ride, equals(ride));
        expect(state.ride.status, equals('searching_driver'));
      });

      test('DriverEnRoute should include driver location', () {
        final ride = TestData.testRide(
          status: 'driver_en_route',
          driverId: 2,
        );
        final state = DriverEnRoute(
          ride: ride,
          driverLatitude: -23.550520,
          driverLongitude: -46.633308,
        );

        expect(state.ride, equals(ride));
        expect(state.driverLatitude, equals(-23.550520));
        expect(state.driverLongitude, equals(-46.633308));
      });

      test('RideError should contain error message', () {
        const errorMessage = 'Failed to load ride';
        final state = RideError(errorMessage);

        expect(state.message, equals(errorMessage));
      });

      test('TipAdded should have correct tip amount', () {
        final state = TipAdded(rideId: 1, tipAmount: 5.0);

        expect(state.rideId, equals(1));
        expect(state.tipAmount, equals(5.0));
      });
    });
  });
}
