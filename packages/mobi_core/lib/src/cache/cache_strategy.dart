/// Cache strategies for API requests
enum CacheStrategy {
  /// Network first, fallback to cache on failure
  /// Best for: Data that changes frequently but needs offline support
  networkFirst,

  /// Cache first, fallback to network if cache miss or expired
  /// Best for: Data that doesn't change often (categories, configs)
  cacheFirst,

  /// Cache only, never hit network
  /// Best for: Completely static data
  cacheOnly,

  /// Network only, never use cache
  /// Best for: Real-time data, auth requests
  networkOnly,

  /// Stale-while-revalidate: Return cache immediately, fetch in background
  /// Best for: Best UX - instant response, fresh data on next request
  staleWhileRevalidate,
}

/// Cache configuration for specific endpoints
class CacheConfig {
  /// Cache strategy to use
  final CacheStrategy strategy;

  /// Time-to-live in seconds (null = never expires)
  final int? ttlSeconds;

  /// Whether to cache error responses
  final bool cacheErrors;

  /// Maximum cache size in bytes (null = unlimited)
  final int? maxCacheSize;

  /// Custom cache key generator
  final String Function(String url, Map<String, dynamic>? params)? keyGenerator;

  const CacheConfig({
    this.strategy = CacheStrategy.networkFirst,
    this.ttlSeconds,
    this.cacheErrors = false,
    this.maxCacheSize,
    this.keyGenerator,
  });

  /// Create a cache config for frequently changing data
  factory CacheConfig.frequent({int ttlSeconds = 60}) {
    return CacheConfig(
      strategy: CacheStrategy.networkFirst,
      ttlSeconds: ttlSeconds,
    );
  }

  /// Create a cache config for rarely changing data
  factory CacheConfig.rare({int ttlSeconds = 3600}) {
    return CacheConfig(
      strategy: CacheStrategy.cacheFirst,
      ttlSeconds: ttlSeconds,
    );
  }

  /// Create a cache config for static data
  factory CacheConfig.static_() {
    return const CacheConfig(
      strategy: CacheStrategy.cacheFirst,
      ttlSeconds: null, // Never expires
    );
  }

  /// Create a cache config for real-time data
  factory CacheConfig.realtime() {
    return const CacheConfig(
      strategy: CacheStrategy.networkOnly,
      ttlSeconds: 0,
    );
  }

  /// Create a cache config for optimal UX
  factory CacheConfig.staleWhileRevalidate({int ttlSeconds = 300}) {
    return CacheConfig(
      strategy: CacheStrategy.staleWhileRevalidate,
      ttlSeconds: ttlSeconds,
    );
  }
}

/// Cached response data
class CachedResponse {
  final String key;
  final dynamic data;
  final int statusCode;
  final Map<String, dynamic> headers;
  final DateTime cachedAt;
  final int? ttlSeconds;

  const CachedResponse({
    required this.key,
    required this.data,
    required this.statusCode,
    required this.headers,
    required this.cachedAt,
    this.ttlSeconds,
  });

  /// Check if cache is expired
  bool get isExpired {
    if (ttlSeconds == null) return false;
    final now = DateTime.now();
    final expiresAt = cachedAt.add(Duration(seconds: ttlSeconds!));
    return now.isAfter(expiresAt);
  }

  /// Get age of cache in seconds
  int get ageSeconds {
    return DateTime.now().difference(cachedAt).inSeconds;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'statusCode': statusCode,
      'headers': headers,
      'cachedAt': cachedAt.toIso8601String(),
      'ttlSeconds': ttlSeconds,
    };
  }

  /// Create from JSON
  factory CachedResponse.fromJson(Map<String, dynamic> json) {
    return CachedResponse(
      key: json['key'] as String,
      data: json['data'],
      statusCode: json['statusCode'] as int,
      headers: Map<String, dynamic>.from(json['headers'] as Map),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      ttlSeconds: json['ttlSeconds'] as int?,
    );
  }
}
