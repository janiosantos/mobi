import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'cache_strategy.dart';

/// Manages HTTP response caching
class CacheManager {
  static const String _cachePrefix = 'http_cache_';
  static const String _cacheKeysKey = 'cache_keys';

  final SharedPreferences _prefs;
  final int? maxCacheSize;

  CacheManager(this._prefs, {this.maxCacheSize});

  /// Initialize cache manager
  static Future<CacheManager> init({int? maxCacheSize}) async {
    final prefs = await SharedPreferences.getInstance();
    return CacheManager(prefs, maxCacheSize: maxCacheSize);
  }

  /// Get cached response
  Future<CachedResponse?> get(String key) async {
    try {
      final cacheKey = _getCacheKey(key);
      final jsonString = _prefs.getString(cacheKey);

      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final cached = CachedResponse.fromJson(json);

      // Check if expired
      if (cached.isExpired) {
        await delete(key);
        return null;
      }

      return cached;
    } catch (e) {
      print('Error getting cache for key $key: $e');
      return null;
    }
  }

  /// Put response in cache
  Future<void> put(String key, CachedResponse response) async {
    try {
      final cacheKey = _getCacheKey(key);
      final jsonString = jsonEncode(response.toJson());

      // Check cache size limit
      if (maxCacheSize != null) {
        await _ensureCacheSize(jsonString.length);
      }

      await _prefs.setString(cacheKey, jsonString);
      await _addCacheKey(key);
    } catch (e) {
      print('Error putting cache for key $key: $e');
    }
  }

  /// Delete cached response
  Future<void> delete(String key) async {
    try {
      final cacheKey = _getCacheKey(key);
      await _prefs.remove(cacheKey);
      await _removeCacheKey(key);
    } catch (e) {
      print('Error deleting cache for key $key: $e');
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    try {
      final keys = await getAllKeys();
      for (final key in keys) {
        await delete(key);
      }
      await _prefs.remove(_cacheKeysKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Clear expired cache entries
  Future<void> clearExpired() async {
    try {
      final keys = await getAllKeys();
      for (final key in keys) {
        final cached = await get(key);
        if (cached == null || cached.isExpired) {
          await delete(key);
        }
      }
    } catch (e) {
      print('Error clearing expired cache: $e');
    }
  }

  /// Get all cached keys
  Future<List<String>> getAllKeys() async {
    try {
      final keysJson = _prefs.getString(_cacheKeysKey);
      if (keysJson == null) return [];

      final keys = jsonDecode(keysJson) as List<dynamic>;
      return keys.cast<String>();
    } catch (e) {
      print('Error getting cache keys: $e');
      return [];
    }
  }

  /// Get cache statistics
  Future<CacheStats> getStats() async {
    final keys = await getAllKeys();
    int totalSize = 0;
    int expiredCount = 0;
    int validCount = 0;

    for (final key in keys) {
      final cached = await get(key);
      if (cached == null || cached.isExpired) {
        expiredCount++;
      } else {
        validCount++;
        final cacheKey = _getCacheKey(key);
        final jsonString = _prefs.getString(cacheKey);
        if (jsonString != null) {
          totalSize += jsonString.length;
        }
      }
    }

    return CacheStats(
      totalEntries: keys.length,
      validEntries: validCount,
      expiredEntries: expiredCount,
      totalSizeBytes: totalSize,
    );
  }

  /// Invalidate cache by pattern
  Future<void> invalidatePattern(Pattern pattern) async {
    final keys = await getAllKeys();
    for (final key in keys) {
      if (pattern.allMatches(key).isNotEmpty) {
        await delete(key);
      }
    }
  }

  /// Generate cache key from URL and params
  String generateKey(String url, Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) {
      return url;
    }

    // Sort params for consistent keys
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    final paramsString = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return '$url?$paramsString';
  }

  // Private methods

  String _getCacheKey(String key) => '$_cachePrefix$key';

  Future<void> _addCacheKey(String key) async {
    final keys = await getAllKeys();
    if (!keys.contains(key)) {
      keys.add(key);
      await _prefs.setString(_cacheKeysKey, jsonEncode(keys));
    }
  }

  Future<void> _removeCacheKey(String key) async {
    final keys = await getAllKeys();
    keys.remove(key);
    await _prefs.setString(_cacheKeysKey, jsonEncode(keys));
  }

  Future<void> _ensureCacheSize(int newEntrySize) async {
    if (maxCacheSize == null) return;

    final stats = await getStats();
    final totalSize = stats.totalSizeBytes + newEntrySize;

    if (totalSize > maxCacheSize!) {
      // Remove oldest entries until we have space
      final keys = await getAllKeys();
      final entries = <MapEntry<String, DateTime>>[];

      for (final key in keys) {
        final cached = await get(key);
        if (cached != null) {
          entries.add(MapEntry(key, cached.cachedAt));
        }
      }

      // Sort by oldest first
      entries.sort((a, b) => a.value.compareTo(b.value));

      // Remove oldest entries
      int removedSize = 0;
      for (final entry in entries) {
        if (totalSize - removedSize <= maxCacheSize!) break;

        final cacheKey = _getCacheKey(entry.key);
        final jsonString = _prefs.getString(cacheKey);
        if (jsonString != null) {
          removedSize += jsonString.length;
          await delete(entry.key);
        }
      }
    }
  }
}

/// Cache statistics
class CacheStats {
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;
  final int totalSizeBytes;

  const CacheStats({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
    required this.totalSizeBytes,
  });

  double get totalSizeKB => totalSizeBytes / 1024;
  double get totalSizeMB => totalSizeKB / 1024;

  @override
  String toString() {
    return 'CacheStats('
        'total: $totalEntries, '
        'valid: $validEntries, '
        'expired: $expiredEntries, '
        'size: ${totalSizeMB.toStringAsFixed(2)} MB'
        ')';
  }
}
