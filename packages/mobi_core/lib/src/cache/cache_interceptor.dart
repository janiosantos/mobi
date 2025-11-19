import 'package:dio/dio.dart';
import 'cache_manager.dart';
import 'cache_strategy.dart';

/// Interceptor that handles HTTP response caching
class CacheInterceptor extends Interceptor {
  final CacheManager cacheManager;
  final CacheConfig defaultConfig;
  final Map<String, CacheConfig> endpointConfigs;

  CacheInterceptor({
    required this.cacheManager,
    CacheConfig? defaultConfig,
    this.endpointConfigs = const {},
  }) : defaultConfig = defaultConfig ?? const CacheConfig();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Only cache GET requests
    if (options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }

    final config = _getConfigForEndpoint(options.path);
    final cacheKey = _generateCacheKey(options, config);

    // Store cache config in extra for use in response handler
    options.extra['cacheConfig'] = config;
    options.extra['cacheKey'] = cacheKey;

    // Handle different cache strategies
    switch (config.strategy) {
      case CacheStrategy.networkOnly:
        return handler.next(options);

      case CacheStrategy.cacheOnly:
        final cached = await cacheManager.get(cacheKey);
        if (cached != null) {
          return handler.resolve(_createResponse(options, cached));
        } else {
          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'No cache available for cache-only strategy',
              type: DioExceptionType.unknown,
            ),
          );
        }

      case CacheStrategy.cacheFirst:
        final cached = await cacheManager.get(cacheKey);
        if (cached != null && !cached.isExpired) {
          return handler.resolve(_createResponse(options, cached));
        }
        return handler.next(options);

      case CacheStrategy.networkFirst:
        // Try network first, cache is fallback in error handler
        return handler.next(options);

      case CacheStrategy.staleWhileRevalidate:
        final cached = await cacheManager.get(cacheKey);
        if (cached != null) {
          // Return cached data immediately
          handler.resolve(_createResponse(options, cached));

          // Fetch fresh data in background (don't wait)
          _fetchAndUpdateCache(options, config, cacheKey);
        } else {
          // No cache, fetch from network
          return handler.next(options);
        }
        break;
    }
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final config = response.requestOptions.extra['cacheConfig'] as CacheConfig?;
    final cacheKey = response.requestOptions.extra['cacheKey'] as String?;

    if (config != null && cacheKey != null) {
      // Check if should cache this response
      final shouldCache = _shouldCacheResponse(response, config);

      if (shouldCache) {
        await _cacheResponse(response, config, cacheKey);
      }
    }

    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final config = err.requestOptions.extra['cacheConfig'] as CacheConfig?;
    final cacheKey = err.requestOptions.extra['cacheKey'] as String?;

    // For network-first strategy, fallback to cache on error
    if (config?.strategy == CacheStrategy.networkFirst &&
        cacheKey != null) {
      final cached = await cacheManager.get(cacheKey);
      if (cached != null) {
        return handler.resolve(_createResponse(err.requestOptions, cached));
      }
    }

    return handler.next(err);
  }

  /// Get cache config for specific endpoint
  CacheConfig _getConfigForEndpoint(String path) {
    // Check for exact match
    if (endpointConfigs.containsKey(path)) {
      return endpointConfigs[path]!;
    }

    // Check for pattern match
    for (final entry in endpointConfigs.entries) {
      if (RegExp(entry.key).hasMatch(path)) {
        return entry.value;
      }
    }

    return defaultConfig;
  }

  /// Generate cache key
  String _generateCacheKey(RequestOptions options, CacheConfig config) {
    if (config.keyGenerator != null) {
      return config.keyGenerator!(
        options.path,
        options.queryParameters,
      );
    }

    return cacheManager.generateKey(
      options.path,
      options.queryParameters,
    );
  }

  /// Check if response should be cached
  bool _shouldCacheResponse(Response response, CacheConfig config) {
    // Don't cache if strategy is network-only
    if (config.strategy == CacheStrategy.networkOnly) {
      return false;
    }

    // Check status code
    final statusCode = response.statusCode ?? 0;
    final isSuccess = statusCode >= 200 && statusCode < 300;

    if (!isSuccess && !config.cacheErrors) {
      return false;
    }

    return true;
  }

  /// Cache response
  Future<void> _cacheResponse(
    Response response,
    CacheConfig config,
    String cacheKey,
  ) async {
    final cached = CachedResponse(
      key: cacheKey,
      data: response.data,
      statusCode: response.statusCode ?? 200,
      headers: response.headers.map.map(
        (key, value) => MapEntry(key, value.join(', ')),
      ),
      cachedAt: DateTime.now(),
      ttlSeconds: config.ttlSeconds,
    );

    await cacheManager.put(cacheKey, cached);
  }

  /// Create response from cached data
  Response _createResponse(
    RequestOptions options,
    CachedResponse cached,
  ) {
    return Response(
      requestOptions: options,
      data: cached.data,
      statusCode: cached.statusCode,
      headers: Headers.fromMap(
        cached.headers.map((key, value) => MapEntry(key, [value])),
      ),
      extra: {
        'fromCache': true,
        'cachedAt': cached.cachedAt.toIso8601String(),
        'ageSeconds': cached.ageSeconds,
      },
    );
  }

  /// Fetch and update cache in background
  Future<void> _fetchAndUpdateCache(
    RequestOptions options,
    CacheConfig config,
    String cacheKey,
  ) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: options.baseUrl,
        connectTimeout: options.connectTimeout,
        receiveTimeout: options.receiveTimeout,
      ));

      final response = await dio.request(
        options.path,
        queryParameters: options.queryParameters,
        options: Options(
          method: options.method,
          headers: options.headers,
        ),
      );

      if (_shouldCacheResponse(response, config)) {
        await _cacheResponse(response, config, cacheKey);
      }
    } catch (e) {
      // Silent fail - we already returned cached data
      print('Background cache refresh failed: $e');
    }
  }
}
