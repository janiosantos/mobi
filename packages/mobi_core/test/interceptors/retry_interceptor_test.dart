import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:mobi_core/mobi_core.dart';

import '../helpers/mocks.dart';

void main() {
  late RetryInterceptor retryInterceptor;
  late MockDio mockDio;
  late MockErrorInterceptorHandler mockHandler;

  setUp(() {
    mockDio = MockDio();
    mockHandler = MockErrorInterceptorHandler();

    retryInterceptor = RetryInterceptor(
      maxRetries: 3,
      initialDelayMs: 100, // Shorter delay for testing
      backoffMultiplier: 2.0,
      maxDelayMs: 1000,
    );

    // Register fallback values
    registerFallbackValue(FakeRequestOptions());
    registerFallbackValue(FakeResponse());
    registerFallbackValue(FakeDioException());
  });

  group('RetryInterceptor', () {
    group('Retryable Errors', () {
      test('retries on network timeout (408)', () async {
        final requestOptions = RequestOptions(path: '/test');
        var callCount = 0;

        when(() => mockHandler.next(any())).thenAnswer((_) {});
        when(() => mockHandler.resolve(any())).thenAnswer((_) {});
        when(() => mockDio.fetch<dynamic>(any())).thenAnswer((_) async {
          callCount++;
          if (callCount < 3) {
            throw DioException(
              requestOptions: requestOptions,
              response: Response(
                requestOptions: requestOptions,
                statusCode: 408,
              ),
              type: DioExceptionType.badResponse,
            );
          }
          return Response(
            requestOptions: requestOptions,
            statusCode: 200,
            data: {'success': true},
          );
        });

        final error = DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 408,
          ),
          type: DioExceptionType.badResponse,
        );

        await retryInterceptor.onError(error, mockHandler);

        expect(callCount, equals(3));
        verify(() => mockHandler.resolve(any())).called(1);
      });

      test('retries on server error (500)', () async {
        final requestOptions = RequestOptions(path: '/test');
        var callCount = 0;

        when(() => mockHandler.next(any())).thenAnswer((_) {});
        when(() => mockHandler.resolve(any())).thenAnswer((_) {});
        when(() => mockDio.fetch<dynamic>(any())).thenAnswer((_) async {
          callCount++;
          if (callCount < 2) {
            throw DioException(
              requestOptions: requestOptions,
              response: Response(
                requestOptions: requestOptions,
                statusCode: 500,
              ),
              type: DioExceptionType.badResponse,
            );
          }
          return Response(
            requestOptions: requestOptions,
            statusCode: 200,
            data: {'success': true},
          );
        });

        final error = DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        );

        await retryInterceptor.onError(error, mockHandler);

        expect(callCount, equals(2));
      });

      test('retries on bad gateway (502)', () async {
        final requestOptions = RequestOptions(path: '/test');
        var callCount = 0;

        when(() => mockHandler.next(any())).thenAnswer((_) {});
        when(() => mockHandler.resolve(any())).thenAnswer((_) {});
        when(() => mockDio.fetch<dynamic>(any())).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw DioException(
              requestOptions: requestOptions,
              response: Response(
                requestOptions: requestOptions,
                statusCode: 502,
              ),
              type: DioExceptionType.badResponse,
            );
          }
          return Response(
            requestOptions: requestOptions,
            statusCode: 200,
          );
        });

        final error = DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 502,
          ),
          type: DioExceptionType.badResponse,
        );

        await retryInterceptor.onError(error, mockHandler);

        expect(callCount, greaterThan(1));
      });

      test('retries on service unavailable (503)', () async {
        final requestOptions = RequestOptions(path: '/test');
        var callCount = 0;

        when(() => mockHandler.next(any())).thenAnswer((_) {});
        when(() => mockHandler.resolve(any())).thenAnswer((_) {});
        when(() => mockDio.fetch<dynamic>(any())).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw DioException(
              requestOptions: requestOptions,
              response: Response(
                requestOptions: requestOptions,
                statusCode: 503,
              ),
              type: DioExceptionType.badResponse,
            );
          }
          return Response(
            requestOptions: requestOptions,
            statusCode: 200,
          );
        });

        final error = DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 503,
          ),
          type: DioExceptionType.badResponse,
        );

        await retryInterceptor.onError(error, mockHandler);

        expect(callCount, greaterThan(1));
      });
    });

    group('Non-Retryable Errors', () {
      test('does not retry on client error (400)', () async {
        final requestOptions = RequestOptions(path: '/test');
        var callCount = 0;

        when(() => mockHandler.next(any())).thenAnswer((_) {});
        when(() => mockDio.fetch<dynamic>(any())).thenAnswer((_) async {
          callCount++;
          throw DioException(
            requestOptions: requestOptions,
            response: Response(
              requestOptions: requestOptions,
              statusCode: 400,
            ),
            type: DioExceptionType.badResponse,
          );
        });

        final error = DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 400,
          ),
          type: DioExceptionType.badResponse,
        );

        await retryInterceptor.onError(error, mockHandler);

        // Should not retry, just pass error through
        expect(callCount, equals(0));
        verify(() => mockHandler.next(any())).called(1);
      });

      test('does not retry on unauthorized (401)', () async {
        final requestOptions = RequestOptions(path: '/test');

        when(() => mockHandler.next(any())).thenAnswer((_) {});

        final error = DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        );

        await retryInterceptor.onError(error, mockHandler);

        verify(() => mockHandler.next(any())).called(1);
        verifyNever(() => mockDio.fetch<dynamic>(any()));
      });

      test('does not retry on not found (404)', () async {
        final requestOptions = RequestOptions(path: '/test');

        when(() => mockHandler.next(any())).thenAnswer((_) {});

        final error = DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 404,
          ),
          type: DioExceptionType.badResponse,
        );

        await retryInterceptor.onError(error, mockHandler);

        verify(() => mockHandler.next(any())).called(1);
      });
    });

    group('Retry Limits', () {
      test('respects maxRetries limit', () async {
        final requestOptions = RequestOptions(path: '/test');
        var callCount = 0;

        when(() => mockHandler.next(any())).thenAnswer((_) {});
        when(() => mockDio.fetch<dynamic>(any())).thenAnswer((_) async {
          callCount++;
          // Always fail
          throw DioException(
            requestOptions: requestOptions,
            response: Response(
              requestOptions: requestOptions,
              statusCode: 500,
            ),
            type: DioExceptionType.badResponse,
          );
        });

        final error = DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        );

        await retryInterceptor.onError(error, mockHandler);

        // Should retry exactly maxRetries (3) times
        expect(callCount, equals(3));
        verify(() => mockHandler.next(any())).called(1);
      });

      test('stops retrying after successful response', () async {
        final requestOptions = RequestOptions(path: '/test');
        var callCount = 0;

        when(() => mockHandler.resolve(any())).thenAnswer((_) {});
        when(() => mockDio.fetch<dynamic>(any())).thenAnswer((_) async {
          callCount++;
          if (callCount == 2) {
            // Succeed on second try
            return Response(
              requestOptions: requestOptions,
              statusCode: 200,
              data: {'success': true},
            );
          }
          throw DioException(
            requestOptions: requestOptions,
            response: Response(
              requestOptions: requestOptions,
              statusCode: 503,
            ),
            type: DioExceptionType.badResponse,
          );
        });

        final error = DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 503,
          ),
          type: DioExceptionType.badResponse,
        );

        await retryInterceptor.onError(error, mockHandler);

        expect(callCount, equals(2)); // First fail + second success
        verify(() => mockHandler.resolve(any())).called(1);
      });
    });

    group('Exponential Backoff', () {
      test('calculates correct delay with exponential backoff', () {
        final interceptor = RetryInterceptor(
          initialDelayMs: 1000,
          backoffMultiplier: 2.0,
          maxDelayMs: 30000,
        );

        // First retry: 1000ms
        final delay1 = interceptor.calculateDelay(1);
        expect(delay1.inMilliseconds, greaterThanOrEqualTo(800)); // Account for jitter
        expect(delay1.inMilliseconds, lessThanOrEqualTo(2400));

        // Second retry: 2000ms (1000 * 2^1)
        final delay2 = interceptor.calculateDelay(2);
        expect(delay2.inMilliseconds, greaterThanOrEqualTo(1600));
        expect(delay2.inMilliseconds, lessThanOrEqualTo(4800));

        // Third retry: 4000ms (1000 * 2^2)
        final delay3 = interceptor.calculateDelay(3);
        expect(delay3.inMilliseconds, greaterThanOrEqualTo(3200));
        expect(delay3.inMilliseconds, lessThanOrEqualTo(9600));
      });

      test('respects maxDelayMs cap', () {
        final interceptor = RetryInterceptor(
          initialDelayMs: 1000,
          backoffMultiplier: 2.0,
          maxDelayMs: 5000,
        );

        // Large retry count should still be capped at maxDelayMs
        final delay = interceptor.calculateDelay(10);
        expect(delay.inMilliseconds, lessThanOrEqualTo(6000)); // 5000 + 20% jitter
      });

      test('applies jitter to prevent thundering herd', () {
        final interceptor = RetryInterceptor(
          initialDelayMs: 1000,
          backoffMultiplier: 2.0,
          maxDelayMs: 30000,
        );

        // Generate multiple delays and ensure they're not all identical (jitter working)
        final delays = List.generate(10, (_) => interceptor.calculateDelay(1));
        final uniqueDelays = delays.toSet();

        // With jitter, we should have different delay values
        expect(uniqueDelays.length, greaterThan(1));
      });
    });

    group('Custom Retry Status Codes', () {
      test('respects custom retryable status codes', () async {
        final customInterceptor = RetryInterceptor(
          maxRetries: 2,
          retryStatusCodes: [400, 401], // Custom: retry on client errors
          initialDelayMs: 100,
        );

        final requestOptions = RequestOptions(path: '/test');
        var callCount = 0;

        when(() => mockHandler.next(any())).thenAnswer((_) {});
        when(() => mockDio.fetch<dynamic>(any())).thenAnswer((_) async {
          callCount++;
          throw DioException(
            requestOptions: requestOptions,
            response: Response(
              requestOptions: requestOptions,
              statusCode: 400,
            ),
            type: DioExceptionType.badResponse,
          );
        });

        final error = DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 400,
          ),
          type: DioExceptionType.badResponse,
        );

        await customInterceptor.onError(error, mockHandler);

        // Should retry on 400 with custom config
        expect(callCount, equals(2));
      });
    });

    group('Retry Callback', () {
      test('calls onRetry callback with correct parameters', () async {
        var retryCallbackInvoked = false;
        var lastAttempt = 0;

        final interceptor = RetryInterceptor(
          maxRetries: 3,
          initialDelayMs: 100,
          onRetry: (attempt, delay, error) {
            retryCallbackInvoked = true;
            lastAttempt = attempt;
          },
        );

        final requestOptions = RequestOptions(path: '/test');
        var callCount = 0;

        when(() => mockHandler.next(any())).thenAnswer((_) {});
        when(() => mockHandler.resolve(any())).thenAnswer((_) {});
        when(() => mockDio.fetch<dynamic>(any())).thenAnswer((_) async {
          callCount++;
          if (callCount < 3) {
            throw DioException(
              requestOptions: requestOptions,
              response: Response(
                requestOptions: requestOptions,
                statusCode: 500,
              ),
              type: DioExceptionType.badResponse,
            );
          }
          return Response(
            requestOptions: requestOptions,
            statusCode: 200,
          );
        });

        final error = DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        );

        await interceptor.onError(error, mockHandler);

        expect(retryCallbackInvoked, isTrue);
        expect(lastAttempt, greaterThan(0));
      });
    });

    group('Edge Cases', () {
      test('handles null response gracefully', () async {
        final requestOptions = RequestOptions(path: '/test');

        when(() => mockHandler.next(any())).thenAnswer((_) {});

        final error = DioException(
          requestOptions: requestOptions,
          response: null, // No response
          type: DioExceptionType.connectionTimeout,
        );

        await retryInterceptor.onError(error, mockHandler);

        // Should handle null response without crashing
        verify(() => mockHandler.next(any())).called(1);
      });

      test('handles connection errors', () async {
        final requestOptions = RequestOptions(path: '/test');
        var callCount = 0;

        when(() => mockHandler.next(any())).thenAnswer((_) {});
        when(() => mockHandler.resolve(any())).thenAnswer((_) {});
        when(() => mockDio.fetch<dynamic>(any())).thenAnswer((_) async {
          callCount++;
          if (callCount < 2) {
            throw DioException(
              requestOptions: requestOptions,
              type: DioExceptionType.connectionError,
            );
          }
          return Response(
            requestOptions: requestOptions,
            statusCode: 200,
          );
        });

        final error = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionError,
        );

        await retryInterceptor.onError(error, mockHandler);

        expect(callCount, greaterThan(1));
      });
    });
  });
}
