import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobi_core/mobi_core.dart';
import 'package:fake_async/fake_async.dart';
import 'dart:async';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late LocationTrackingBloc locationBloc;
  late MockLocationService mockLocationService;

  setUp(() {
    mockLocationService = MockLocationService();
    locationBloc = LocationTrackingBloc(locationService: mockLocationService);

    // Register fallback values
    registerFallbackValue(FakeUser());
  });

  tearDown(() {
    locationBloc.close();
  });

  group('LocationTrackingBloc', () {
    group('StartLocationTracking', () {
      final location = TestData.testLocation(
        latitude: -23.550520,
        longitude: -46.633308,
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingLoading, LocationTrackingActive, LocationUpdated] when tracking starts',
        build: () {
          when(() => mockLocationService.hasPermission())
              .thenAnswer((_) async => true);
          when(() => mockLocationService.isLocationServiceEnabled())
              .thenAnswer((_) async => true);
          when(() => mockLocationService.getCurrentLocation())
              .thenAnswer((_) async => location);
          when(() => mockLocationService.getLocationStream())
              .thenAnswer((_) => Stream.value(location));
          when(() => mockLocationService.sendLocationToBackend(
                rideId: any(named: 'rideId'),
                latitude: any(named: 'latitude'),
                longitude: any(named: 'longitude'),
                accuracy: any(named: 'accuracy'),
              )).thenAnswer((_) async => TestData.successResponse());
          return locationBloc;
        },
        act: (bloc) => bloc.add(StartLocationTracking(rideId: 1)),
        expect: () => [
          isA<LocationTrackingLoading>(),
          isA<LocationTrackingActive>()
              .having((s) => s.rideId, 'ride id', 1),
          isA<LocationUpdated>()
              .having((s) => s.latitude, 'latitude', -23.550520)
              .having((s) => s.longitude, 'longitude', -46.633308),
        ],
        verify: (_) {
          verify(() => mockLocationService.hasPermission()).called(1);
          verify(() => mockLocationService.isLocationServiceEnabled()).called(1);
          verify(() => mockLocationService.getCurrentLocation()).called(1);
        },
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingLoading, LocationPermissionDenied] when permission denied',
        build: () {
          when(() => mockLocationService.hasPermission())
              .thenAnswer((_) async => false);
          return locationBloc;
        },
        act: (bloc) => bloc.add(StartLocationTracking(rideId: 1)),
        expect: () => [
          isA<LocationTrackingLoading>(),
          isA<LocationPermissionDenied>()
              .having((s) => s.message, 'message', contains('Permission')),
        ],
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingLoading, LocationServicesDisabled] when service disabled',
        build: () {
          when(() => mockLocationService.hasPermission())
              .thenAnswer((_) async => true);
          when(() => mockLocationService.isLocationServiceEnabled())
              .thenAnswer((_) async => false);
          return locationBloc;
        },
        act: (bloc) => bloc.add(StartLocationTracking(rideId: 1)),
        expect: () => [
          isA<LocationTrackingLoading>(),
          isA<LocationServicesDisabled>()
              .having((s) => s.message, 'message', contains('disabled')),
        ],
      );
    });

    group('StopLocationTracking', () {
      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingStopped] when tracking stops',
        build: () {
          when(() => mockLocationService.stopLocationUpdates())
              .thenAnswer((_) async => {});
          return locationBloc;
        },
        act: (bloc) => bloc.add(StopLocationTracking()),
        expect: () => [isA<LocationTrackingStopped>()],
        verify: (_) {
          verify(() => mockLocationService.stopLocationUpdates()).called(1);
        },
      );
    });

    group('UpdateLocation', () {
      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationUpdated] when location is manually updated',
        build: () => locationBloc,
        act: (bloc) => bloc.add(UpdateLocation(
          latitude: -23.561684,
          longitude: -46.656139,
          accuracy: 10.0,
        )),
        expect: () => [
          isA<LocationUpdated>()
              .having((s) => s.latitude, 'latitude', -23.561684)
              .having((s) => s.longitude, 'longitude', -46.656139)
              .having((s) => s.accuracy, 'accuracy', 10.0),
        ],
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'filters out GPS drift (location changes < 5 meters)',
        build: () => locationBloc,
        seed: () => LocationUpdated(
          latitude: -23.550520,
          longitude: -46.633308,
          accuracy: 5.0,
          timestamp: DateTime.now(),
        ),
        act: (bloc) {
          // Very small change (< 5 meters) should be filtered
          bloc.add(UpdateLocation(
            latitude: -23.550521, // ~1 meter change
            longitude: -46.633308,
            accuracy: 5.0,
          ));
        },
        // No new state emitted because change is too small
        expect: () => [],
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'accepts location changes > 5 meters',
        build: () => locationBloc,
        seed: () => LocationUpdated(
          latitude: -23.550520,
          longitude: -46.633308,
          accuracy: 5.0,
          timestamp: DateTime.now(),
        ),
        act: (bloc) {
          // Significant change (> 5 meters)
          bloc.add(UpdateLocation(
            latitude: -23.550620, // ~100 meters change
            longitude: -46.633308,
            accuracy: 5.0,
          ));
        },
        expect: () => [
          isA<LocationUpdated>()
              .having((s) => s.latitude, 'latitude', -23.550620),
        ],
      );
    });

    group('SendLocationToBackend', () {
      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationSentToBackend] when sending succeeds',
        build: () {
          when(() => mockLocationService.sendLocationToBackend(
                rideId: any(named: 'rideId'),
                latitude: any(named: 'latitude'),
                longitude: any(named: 'longitude'),
                accuracy: any(named: 'accuracy'),
              )).thenAnswer((_) async => TestData.successResponse(
                    message: 'Location updated',
                  ));
          return locationBloc;
        },
        act: (bloc) => bloc.add(SendLocationToBackend(
          rideId: 1,
          latitude: -23.550520,
          longitude: -46.633308,
          accuracy: 10.0,
        )),
        expect: () => [
          isA<LocationSentToBackend>()
              .having((s) => s.rideId, 'ride id', 1),
        ],
        verify: (_) {
          verify(() => mockLocationService.sendLocationToBackend(
                rideId: 1,
                latitude: -23.550520,
                longitude: -46.633308,
                accuracy: 10.0,
              )).called(1);
        },
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingError] when sending fails',
        build: () {
          when(() => mockLocationService.sendLocationToBackend(
                rideId: any(named: 'rideId'),
                latitude: any(named: 'latitude'),
                longitude: any(named: 'longitude'),
                accuracy: any(named: 'accuracy'),
              )).thenThrow(Exception('Network error'));
          return locationBloc;
        },
        act: (bloc) => bloc.add(SendLocationToBackend(
          rideId: 1,
          latitude: -23.550520,
          longitude: -46.633308,
        )),
        expect: () => [
          isA<LocationTrackingError>()
              .having((s) => s.message, 'error message', contains('Network error')),
        ],
      );
    });

    group('RequestLocationPermission', () {
      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationPermissionGranted] when permission granted',
        build: () {
          when(() => mockLocationService.requestPermission())
              .thenAnswer((_) async => true);
          return locationBloc;
        },
        act: (bloc) => bloc.add(RequestLocationPermission()),
        expect: () => [isA<LocationPermissionGranted>()],
        verify: (_) {
          verify(() => mockLocationService.requestPermission()).called(1);
        },
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationPermissionDenied] when permission denied',
        build: () {
          when(() => mockLocationService.requestPermission())
              .thenAnswer((_) async => false);
          return locationBloc;
        },
        act: (bloc) => bloc.add(RequestLocationPermission()),
        expect: () => [
          isA<LocationPermissionDenied>()
              .having((s) => s.message, 'message', contains('denied')),
        ],
      );
    });

    group('LocationPermissionChanged', () {
      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationPermissionGranted] when permission becomes granted',
        build: () => locationBloc,
        act: (bloc) => bloc.add(LocationPermissionChanged(hasPermission: true)),
        expect: () => [isA<LocationPermissionGranted>()],
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationPermissionDenied] when permission becomes denied',
        build: () => locationBloc,
        act: (bloc) => bloc.add(LocationPermissionChanged(hasPermission: false)),
        expect: () => [isA<LocationPermissionDenied>()],
      );
    });

    group('CheckLocationServices', () {
      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationServicesEnabled] when services are on',
        build: () {
          when(() => mockLocationService.isLocationServiceEnabled())
              .thenAnswer((_) async => true);
          return locationBloc;
        },
        act: (bloc) => bloc.add(CheckLocationServices()),
        expect: () => [isA<LocationServicesEnabled>()],
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationServicesDisabled] when services are off',
        build: () {
          when(() => mockLocationService.isLocationServiceEnabled())
              .thenAnswer((_) async => false);
          return locationBloc;
        },
        act: (bloc) => bloc.add(CheckLocationServices()),
        expect: () => [isA<LocationServicesDisabled>()],
      );
    });

    group('LocationServicesChanged', () {
      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationServicesEnabled] when services turn on',
        build: () => locationBloc,
        act: (bloc) => bloc.add(LocationServicesChanged(isEnabled: true)),
        expect: () => [isA<LocationServicesEnabled>()],
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationServicesDisabled] when services turn off',
        build: () => locationBloc,
        act: (bloc) => bloc.add(LocationServicesChanged(isEnabled: false)),
        expect: () => [isA<LocationServicesDisabled>()],
      );
    });

    group('GetCurrentLocation', () {
      final location = TestData.testLocation(
        latitude: -23.550520,
        longitude: -46.633308,
        accuracy: 15.0,
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingLoading, CurrentLocationObtained] when getting location succeeds',
        build: () {
          when(() => mockLocationService.getCurrentLocation())
              .thenAnswer((_) async => location);
          return locationBloc;
        },
        act: (bloc) => bloc.add(GetCurrentLocation()),
        expect: () => [
          isA<LocationTrackingLoading>(),
          isA<CurrentLocationObtained>()
              .having((s) => s.latitude, 'latitude', -23.550520)
              .having((s) => s.longitude, 'longitude', -46.633308)
              .having((s) => s.accuracy, 'accuracy', 15.0),
        ],
        verify: (_) {
          verify(() => mockLocationService.getCurrentLocation()).called(1);
        },
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [LocationTrackingLoading, LocationTrackingError] when getting location fails',
        build: () {
          when(() => mockLocationService.getCurrentLocation())
              .thenThrow(Exception('Location unavailable'));
          return locationBloc;
        },
        act: (bloc) => bloc.add(GetCurrentLocation()),
        expect: () => [
          isA<LocationTrackingLoading>(),
          isA<LocationTrackingError>()
              .having((s) => s.message, 'error message', contains('unavailable')),
        ],
      );
    });

    group('CalculateDistance', () {
      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'emits [DistanceCalculated] with correct distance using Haversine formula',
        build: () => locationBloc,
        act: (bloc) => bloc.add(CalculateDistance(
          fromLatitude: -23.550520,
          fromLongitude: -46.633308,
          toLatitude: -23.561684,
          toLongitude: -46.656139,
        )),
        expect: () => [
          isA<DistanceCalculated>()
              .having(
                (s) => (s.distanceInMeters - 2800).abs() < 100,
                'distance approximately 2.8km',
                true,
              ),
        ],
      );

      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'calculates zero distance for same coordinates',
        build: () => locationBloc,
        act: (bloc) => bloc.add(CalculateDistance(
          fromLatitude: -23.550520,
          fromLongitude: -46.633308,
          toLatitude: -23.550520,
          toLongitude: -46.633308,
        )),
        expect: () => [
          isA<DistanceCalculated>()
              .having((s) => s.distanceInMeters, 'distance', 0.0),
        ],
      );

      test('Haversine formula accuracy test', () {
        // Test known distances
        // Paulista Ave to Faria Lima Ave in São Paulo is approximately 2.8km
        const lat1 = -23.550520;
        const lon1 = -46.633308;
        const lat2 = -23.561684;
        const lon2 = -46.656139;

        final bloc = LocationTrackingBloc(locationService: mockLocationService);

        bloc.add(CalculateDistance(
          fromLatitude: lat1,
          fromLongitude: lon1,
          toLatitude: lat2,
          toLongitude: lon2,
        ));

        expectLater(
          bloc.stream,
          emits(isA<DistanceCalculated>()
              .having((s) => s.distanceInMeters > 2700 && s.distanceInMeters < 2900,
                  'distance in range', true)),
        );

        bloc.close();
      });
    });

    group('AddRoutePoint', () {
      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'adds point to route and emits updated route',
        build: () => locationBloc,
        act: (bloc) {
          bloc.add(AddRoutePoint(
            latitude: -23.550520,
            longitude: -46.633308,
          ));
          bloc.add(AddRoutePoint(
            latitude: -23.551000,
            longitude: -46.634000,
          ));
        },
        expect: () => [
          isA<LocationUpdated>()
              .having((s) => s.routePoints?.length, 'route points', 1),
          isA<LocationUpdated>()
              .having((s) => s.routePoints?.length, 'route points', 2),
        ],
      );
    });

    group('ClearRoute', () {
      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'clears all route points',
        build: () => locationBloc,
        seed: () => LocationUpdated(
          latitude: -23.550520,
          longitude: -46.633308,
          timestamp: DateTime.now(),
          routePoints: [
            TestData.testLocation(),
            TestData.testLocation(),
          ],
        ),
        act: (bloc) => bloc.add(ClearRoute()),
        expect: () => [
          isA<LocationUpdated>()
              .having((s) => s.routePoints?.isEmpty ?? true, 'route cleared', true),
        ],
      );
    });

    group('Periodic Location Updates', () {
      test('sends location to backend every 10 seconds during active tracking', () {
        fakeAsync((async) {
          final location = TestData.testLocation();
          final streamController = StreamController<Location>();

          when(() => mockLocationService.hasPermission())
              .thenAnswer((_) async => true);
          when(() => mockLocationService.isLocationServiceEnabled())
              .thenAnswer((_) async => true);
          when(() => mockLocationService.getCurrentLocation())
              .thenAnswer((_) async => location);
          when(() => mockLocationService.getLocationStream())
              .thenAnswer((_) => streamController.stream);
          when(() => mockLocationService.sendLocationToBackend(
                rideId: any(named: 'rideId'),
                latitude: any(named: 'latitude'),
                longitude: any(named: 'longitude'),
                accuracy: any(named: 'accuracy'),
              )).thenAnswer((_) async => TestData.successResponse());

          final bloc = LocationTrackingBloc(locationService: mockLocationService);

          bloc.add(StartLocationTracking(rideId: 1));

          // Emit location updates
          streamController.add(location);
          async.elapse(const Duration(seconds: 10));
          streamController.add(location);
          async.elapse(const Duration(seconds: 10));

          // Verify periodic updates were sent
          verify(() => mockLocationService.sendLocationToBackend(
                rideId: 1,
                latitude: location.latitude,
                longitude: location.longitude,
                accuracy: location.accuracy,
              )).called(greaterThanOrEqualTo(2));

          streamController.close();
          bloc.close();
        });
      });
    });

    group('Error Handling', () {
      blocTest<LocationTrackingBloc, LocationTrackingState>(
        'handles location service errors gracefully',
        build: () {
          when(() => mockLocationService.hasPermission())
              .thenAnswer((_) async => true);
          when(() => mockLocationService.isLocationServiceEnabled())
              .thenAnswer((_) async => true);
          when(() => mockLocationService.getCurrentLocation())
              .thenThrow(Exception('GPS timeout'));
          return locationBloc;
        },
        act: (bloc) => bloc.add(StartLocationTracking(rideId: 1)),
        expect: () => [
          isA<LocationTrackingLoading>(),
          isA<LocationTrackingError>()
              .having((s) => s.message, 'error message', contains('GPS timeout')),
        ],
      );
    });

    group('State Persistence', () {
      test('LocationUpdated state contains complete location data', () {
        final state = LocationUpdated(
          latitude: -23.550520,
          longitude: -46.633308,
          accuracy: 10.0,
          timestamp: DateTime.now(),
          routePoints: [
            TestData.testLocation(latitude: -23.550520, longitude: -46.633308),
            TestData.testLocation(latitude: -23.551000, longitude: -46.634000),
          ],
        );

        expect(state.latitude, equals(-23.550520));
        expect(state.longitude, equals(-46.633308));
        expect(state.accuracy, equals(10.0));
        expect(state.routePoints?.length, equals(2));
      });

      test('DistanceCalculated state has correct distance', () {
        final state = DistanceCalculated(distanceInMeters: 2800.0);

        expect(state.distanceInMeters, equals(2800.0));
        expect(state.distanceInKilometers, closeTo(2.8, 0.01));
      });
    });
  });
}
