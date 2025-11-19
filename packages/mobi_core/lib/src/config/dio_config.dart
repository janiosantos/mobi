import 'package:dio/dio.dart';
import '../interceptors/retry_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../cache/cache_interceptor.dart';
import '../cache/cache_manager.dart';
import '../cache/cache_strategy.dart';
import '../constants/api_constants.dart';

/// Configuration class for Dio HTTP client
class DioConfig {
  /// Create a configured Dio instance with interceptors
  static Dio createDio({
    String? baseUrl,
    String? authToken,
    bool enableRetry = true,
    bool enableLogging = true,
    int maxRetries = 3,
    int connectTimeoutMs = 30000,
    int receiveTimeoutMs = 30000,
    int sendTimeoutMs = 30000,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.baseUrl,
        connectTimeout: Duration(milliseconds: connectTimeoutMs),
        receiveTimeout: Duration(milliseconds: receiveTimeoutMs),
        sendTimeout: Duration(milliseconds: sendTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ),
    );

    // Add retry interceptor (should be first to catch all errors)
    if (enableRetry) {
      dio.interceptors.add(
        RetryInterceptor(
          maxRetries: maxRetries,
          initialDelayMs: 1000, // 1 second
          backoffMultiplier: 2.0, // Double the delay each time
          maxDelayMs: 30000, // Max 30 seconds between retries
          onRetry: (attempt, delay, error) {
            print('🔄 Retry attempt $attempt after ${delay.inMilliseconds}ms');
            print('   Error: ${error.message}');
          },
        ),
      );
    }

    // Add logging interceptor (should be last to log everything)
    if (enableLogging) {
      dio.interceptors.add(
        LoggingInterceptor(
          logRequestHeader: true,
          logRequestBody: true,
          logResponseHeader: false,
          logResponseBody: true,
          logError: true,
        ),
      );
    }

    return dio;
  }

  /// Create a Dio instance for production (minimal logging, retry enabled)
  static Dio createProductionDio({
    String? baseUrl,
    String? authToken,
  }) {
    return createDio(
      baseUrl: baseUrl,
      authToken: authToken,
      enableRetry: true,
      enableLogging: false, // Disable detailed logging in production
      maxRetries: 3,
    );
  }

  /// Create a Dio instance for development (full logging, retry enabled)
  static Dio createDevelopmentDio({
    String? baseUrl,
    String? authToken,
  }) {
    return createDio(
      baseUrl: baseUrl,
      authToken: authToken,
      enableRetry: true,
      enableLogging: true,
      maxRetries: 2, // Fewer retries in dev for faster feedback
    );
  }

  /// Create a Dio instance with custom retry configuration
  static Dio createCustomRetryDio({
    String? baseUrl,
    String? authToken,
    required int maxRetries,
    required int initialDelayMs,
    required double backoffMultiplier,
    required int maxDelayMs,
    List<int>? retryStatusCodes,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
        sendTimeout: const Duration(milliseconds: 30000),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ),
    );

    dio.interceptors.add(
      RetryInterceptor(
        maxRetries: maxRetries,
        initialDelayMs: initialDelayMs,
        backoffMultiplier: backoffMultiplier,
        maxDelayMs: maxDelayMs,
        retryStatusCodes: retryStatusCodes ?? [408, 429, 500, 502, 503, 504],
        onRetry: (attempt, delay, error) {
          print('🔄 Custom retry attempt $attempt after ${delay.inMilliseconds}ms');
        },
      ),
    );

    return dio;
  }

  /// Create a Dio instance with caching enabled
  static Future<Dio> createCachedDio({
    String? baseUrl,
    String? authToken,
    bool enableRetry = true,
    bool enableLogging = false,
    CacheConfig? defaultCacheConfig,
    Map<String, CacheConfig>? endpointConfigs,
    int? maxCacheSizeBytes,
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
        sendTimeout: const Duration(milliseconds: 30000),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ),
    );

    // Initialize cache manager
    final cacheManager = await CacheManager.init(
      maxCacheSize: maxCacheSizeBytes,
    );

    // Add cache interceptor (should be first to intercept requests)
    dio.interceptors.add(
      CacheInterceptor(
        cacheManager: cacheManager,
        defaultConfig: defaultCacheConfig ?? const CacheConfig(),
        endpointConfigs: endpointConfigs ?? {},
      ),
    );

    // Add retry interceptor
    if (enableRetry) {
      dio.interceptors.add(
        RetryInterceptor(
          maxRetries: 3,
          initialDelayMs: 1000,
          backoffMultiplier: 2.0,
          maxDelayMs: 30000,
        ),
      );
    }

    // Add logging interceptor
    if (enableLogging) {
      dio.interceptors.add(
        LoggingInterceptor(
          logRequestHeader: true,
          logRequestBody: true,
          logResponseHeader: false,
          logResponseBody: true,
          logError: true,
        ),
      );
    }

    return dio;
  }

  /// Update authorization token on existing Dio instance
  static void updateAuthToken(Dio dio, String? token) {
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }
}
