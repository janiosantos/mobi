import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobi_core/mobi_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CacheManager', () {
    late CacheManager cacheManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      cacheManager = CacheManager(prefs);
    });

    group('Basic Operations', () {
      test('put and get cache entry', () async {
        final response = CachedResponse(
          key: 'test-key',
          data: {'message': 'Hello, World!'},
          statusCode: 200,
          headers: {'content-type': 'application/json'},
          cachedAt: DateTime.now(),
          ttlSeconds: 300,
        );

        await cacheManager.put('test-key', response);
        final cached = await cacheManager.get('test-key');

        expect(cached, isNotNull);
        expect(cached!.key, equals('test-key'));
        expect(cached.data, equals({'message': 'Hello, World!'}));
        expect(cached.statusCode, equals(200));
      });

      test('get returns null for non-existent key', () async {
        final cached = await cacheManager.get('non-existent');

        expect(cached, isNull);
      });

      test('delete removes cache entry', () async {
        final response = CachedResponse(
          key: 'test-key',
          data: {'test': 'data'},
          statusCode: 200,
          headers: {},
          cachedAt: DateTime.now(),
          ttlSeconds: 300,
        );

        await cacheManager.put('test-key', response);
        await cacheManager.delete('test-key');

        final cached = await cacheManager.get('test-key');
        expect(cached, isNull);
      });

      test('clearAll removes all cache entries', () async {
        final response1 = CachedResponse(
          key: 'key1',
          data: {'data': 1},
          statusCode: 200,
          headers: {},
          cachedAt: DateTime.now(),
          ttlSeconds: 300,
        );

        final response2 = CachedResponse(
          key: 'key2',
          data: {'data': 2},
          statusCode: 200,
          headers: {},
          cachedAt: DateTime.now(),
          ttlSeconds: 300,
        );

        await cacheManager.put('key1', response1);
        await cacheManager.put('key2', response2);

        await cacheManager.clearAll();

        final keys = await cacheManager.getAllKeys();
        expect(keys.isEmpty, isTrue);
      });
    });

    group('TTL and Expiration', () {
      test('expired cache entries return null', () async {
        final response = CachedResponse(
          key: 'expired-key',
          data: {'data': 'old'},
          statusCode: 200,
          headers: {},
          cachedAt: DateTime.now().subtract(const Duration(hours: 2)),
          ttlSeconds: 60, // 1 minute TTL, but cached 2 hours ago
        );

        await cacheManager.put('expired-key', response);

        // Should return null because it's expired
        final cached = await cacheManager.get('expired-key');
        expect(cached, isNull);
      });

      test('non-expired cache entries return data', () async {
        final response = CachedResponse(
          key: 'fresh-key',
          data: {'data': 'fresh'},
          statusCode: 200,
          headers: {},
          cachedAt: DateTime.now(),
          ttlSeconds: 3600, // 1 hour TTL
        );

        await cacheManager.put('fresh-key', response);

        final cached = await cacheManager.get('fresh-key');
        expect(cached, isNotNull);
        expect(cached!.data, equals({'data': 'fresh'}));
      });

      test('clearExpired removes only expired entries', () async {
        final freshResponse = CachedResponse(
          key: 'fresh',
          data: {'status': 'fresh'},
          statusCode: 200,
          headers: {},
          cachedAt: DateTime.now(),
          ttlSeconds: 3600,
        );

        final expiredResponse = CachedResponse(
          key: 'expired',
          data: {'status': 'expired'},
          statusCode: 200,
          headers: {},
          cachedAt: DateTime.now().subtract(const Duration(hours: 2)),
          ttlSeconds: 60,
        );

        await cacheManager.put('fresh', freshResponse);
        await cacheManager.put('expired', expiredResponse);

        await cacheManager.clearExpired();

        final freshCached = await cacheManager.get('fresh');
        final expiredCached = await cacheManager.get('expired');

        expect(freshCached, isNotNull);
        expect(expiredCached, isNull);
      });
    });

    group('Cache Key Management', () {
      test('getAllKeys returns all cache keys', () async {
        final responses = [
          CachedResponse(
            key: 'key1',
            data: {},
            statusCode: 200,
            headers: {},
            cachedAt: DateTime.now(),
            ttlSeconds: 300,
          ),
          CachedResponse(
            key: 'key2',
            data: {},
            statusCode: 200,
            headers: {},
            cachedAt: DateTime.now(),
            ttlSeconds: 300,
          ),
          CachedResponse(
            key: 'key3',
            data: {},
            statusCode: 200,
            headers: {},
            cachedAt: DateTime.now(),
            ttlSeconds: 300,
          ),
        ];

        for (var i = 0; i < responses.length; i++) {
          await cacheManager.put('key${i + 1}', responses[i]);
        }

        final keys = await cacheManager.getAllKeys();
        expect(keys.length, equals(3));
        expect(keys, containsAll(['key1', 'key2', 'key3']));
      });

      test('generateKey creates consistent keys', () {
        final key1 = cacheManager.generateKey('/api/users', {'id': '1', 'name': 'John'});
        final key2 = cacheManager.generateKey('/api/users', {'name': 'John', 'id': '1'});

        // Same params in different order should generate same key
        expect(key1, equals(key2));
      });

      test('generateKey handles null params', () {
        final key = cacheManager.generateKey('/api/users', null);
        expect(key, equals('/api/users'));
      });

      test('generateKey handles empty params', () {
        final key = cacheManager.generateKey('/api/users', {});
        expect(key, equals('/api/users'));
      });
    });

    group('Pattern-based Invalidation', () {
      test('invalidatePattern removes matching entries', () async {
        final responses = [
          ('api/users/1', CachedResponse(
            key: 'api/users/1',
            data: {},
            statusCode: 200,
            headers: {},
            cachedAt: DateTime.now(),
            ttlSeconds: 300,
          )),
          ('api/users/2', CachedResponse(
            key: 'api/users/2',
            data: {},
            statusCode: 200,
            headers: {},
            cachedAt: DateTime.now(),
            ttlSeconds: 300,
          )),
          ('api/posts/1', CachedResponse(
            key: 'api/posts/1',
            data: {},
            statusCode: 200,
            headers: {},
            cachedAt: DateTime.now(),
            ttlSeconds: 300,
          )),
        ];

        for (final (key, response) in responses) {
          await cacheManager.put(key, response);
        }

        // Invalidate all user-related cache
        await cacheManager.invalidatePattern(RegExp(r'api/users/'));

        final keys = await cacheManager.getAllKeys();
        expect(keys.contains('api/users/1'), isFalse);
        expect(keys.contains('api/users/2'), isFalse);
        expect(keys.contains('api/posts/1'), isTrue);
      });

      test('invalidatePattern with complex regex', () async {
        final responses = [
          ('api/v1/users', CachedResponse(
            key: 'api/v1/users',
            data: {},
            statusCode: 200,
            headers: {},
            cachedAt: DateTime.now(),
            ttlSeconds: 300,
          )),
          ('api/v2/users', CachedResponse(
            key: 'api/v2/users',
            data: {},
            statusCode: 200,
            headers: {},
            cachedAt: DateTime.now(),
            ttlSeconds: 300,
          )),
          ('api/v1/posts', CachedResponse(
            key: 'api/v1/posts',
            data: {},
            statusCode: 200,
            headers: {},
            cachedAt: DateTime.now(),
            ttlSeconds: 300,
          )),
        ];

        for (final (key, response) in responses) {
          await cacheManager.put(key, response);
        }

        // Invalidate only v1 endpoints
        await cacheManager.invalidatePattern(RegExp(r'api/v1/'));

        final keys = await cacheManager.getAllKeys();
        expect(keys.contains('api/v1/users'), isFalse);
        expect(keys.contains('api/v1/posts'), isFalse);
        expect(keys.contains('api/v2/users'), isTrue);
      });
    });

    group('Cache Statistics', () {
      test('getStats returns accurate statistics', () async {
        final responses = [
          CachedResponse(
            key: 'fresh1',
            data: {'size': 100},
            statusCode: 200,
            headers: {},
            cachedAt: DateTime.now(),
            ttlSeconds: 3600,
          ),
          CachedResponse(
            key: 'fresh2',
            data: {'size': 200},
            statusCode: 200,
            headers: {},
            cachedAt: DateTime.now(),
            ttlSeconds: 3600,
          ),
          CachedResponse(
            key: 'expired',
            data: {'size': 50},
            statusCode: 200,
            headers: {},
            cachedAt: DateTime.now().subtract(const Duration(hours: 2)),
            ttlSeconds: 60,
          ),
        ];

        for (var i = 0; i < responses.length; i++) {
          await cacheManager.put(responses[i].key, responses[i]);
        }

        final stats = await cacheManager.getStats();

        expect(stats.totalEntries, equals(3));
        expect(stats.validEntries, equals(2));
        expect(stats.expiredEntries, equals(1));
        expect(stats.totalSizeBytes, greaterThan(0));
      });

      test('getStats handles empty cache', () async {
        final stats = await cacheManager.getStats();

        expect(stats.totalEntries, equals(0));
        expect(stats.validEntries, equals(0));
        expect(stats.expiredEntries, equals(0));
        expect(stats.totalSizeBytes, equals(0));
      });

      test('CacheStats provides formatted size', () async {
        final response = CachedResponse(
          key: 'large-data',
          data: {'data': 'x' * 1000000}, // ~1MB
          statusCode: 200,
          headers: {},
          cachedAt: DateTime.now(),
          ttlSeconds: 3600,
        );

        await cacheManager.put('large-data', response);

        final stats = await cacheManager.getStats();

        expect(stats.totalSizeKB, greaterThan(0));
        expect(stats.totalSizeMB, greaterThan(0));
      });
    });

    group('LRU Eviction', () {
      test('evicts oldest entries when cache size limit reached', () async {
        // Create cache manager with small size limit
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final limitedCache = CacheManager(
          prefs,
          maxCacheSize: 5000, // 5KB limit
        );

        // Add multiple entries that will exceed limit
        for (var i = 0; i < 10; i++) {
          final response = CachedResponse(
            key: 'key$i',
            data: {'data': 'x' * 1000}, // ~1KB each
            statusCode: 200,
            headers: {},
            cachedAt: DateTime.now().add(Duration(seconds: i)),
            ttlSeconds: 3600,
          );

          await limitedCache.put('key$i', response);
          await Future.delayed(const Duration(milliseconds: 10));
        }

        final stats = await limitedCache.getStats();

        // Should have evicted oldest entries to stay under limit
        expect(stats.totalSizeBytes, lessThanOrEqualTo(5000));
        expect(stats.validEntries, lessThan(10));
      });
    });

    group('CachedResponse', () {
      test('isExpired returns true for expired entries', () {
        final expired = CachedResponse(
          key: 'test',
          data: {},
          statusCode: 200,
          headers: {},
          cachedAt: DateTime.now().subtract(const Duration(hours: 2)),
          ttlSeconds: 60,
        );

        expect(expired.isExpired, isTrue);
      });

      test('isExpired returns false for fresh entries', () {
        final fresh = CachedResponse(
          key: 'test',
          data: {},
          statusCode: 200,
          headers: {},
          cachedAt: DateTime.now(),
          ttlSeconds: 3600,
        );

        expect(fresh.isExpired, isFalse);
      });

      test('ageSeconds calculates correct age', () async {
        final response = CachedResponse(
          key: 'test',
          data: {},
          statusCode: 200,
          headers: {},
          cachedAt: DateTime.now().subtract(const Duration(seconds: 30)),
          ttlSeconds: 300,
        );

        await Future.delayed(const Duration(milliseconds: 100));

        expect(response.ageSeconds, greaterThanOrEqualTo(30));
        expect(response.ageSeconds, lessThan(35));
      });

      test('toJson and fromJson preserve data', () {
        final original = CachedResponse(
          key: 'test-key',
          data: {'message': 'Hello', 'count': 42},
          statusCode: 200,
          headers: {'content-type': 'application/json'},
          cachedAt: DateTime(2024, 1, 1, 12, 0, 0),
          ttlSeconds: 300,
        );

        final json = original.toJson();
        final restored = CachedResponse.fromJson(json);

        expect(restored.key, equals(original.key));
        expect(restored.data, equals(original.data));
        expect(restored.statusCode, equals(original.statusCode));
        expect(restored.headers, equals(original.headers));
        expect(restored.ttlSeconds, equals(original.ttlSeconds));
      });
    });

    group('Error Handling', () {
      test('handles corrupted cache data gracefully', () async {
        SharedPreferences.setMockInitialValues({
          'http_cache_corrupted': 'invalid-json{]',
        });

        final prefs = await SharedPreferences.getInstance();
        final manager = CacheManager(prefs);

        // Should return null instead of throwing
        final cached = await manager.get('corrupted');
        expect(cached, isNull);
      });

      test('handles very large cache keys', () async {
        final longKey = 'x' * 1000;
        final response = CachedResponse(
          key: longKey,
          data: {'test': 'data'},
          statusCode: 200,
          headers: {},
          cachedAt: DateTime.now(),
          ttlSeconds: 300,
        );

        await cacheManager.put(longKey, response);
        final cached = await cacheManager.get(longKey);

        expect(cached, isNotNull);
        expect(cached!.key, equals(longKey));
      });
    });
  });
}
