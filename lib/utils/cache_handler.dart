import 'dart:collection';
import 'package:finalyear/Models/news_cache_models.dart';

/// A generic cache handler that can work with any model type
/// 
/// This class provides caching functionality with:
/// - LRU eviction policy
/// - Time-based expiration
/// - Configurable cache size and expiration time
class CacheHandler<T> {
  final CacheConfig config;
  
  // Cache storage with timestamps
  final LinkedHashMap<String, CachedPage<T>> _cache =
      LinkedHashMap<String, CachedPage<T>>();
  final Map<String, DateTime> _lastFetch = {};

  /// Create a new cache handler with the specified configuration
  /// 
  /// [config] The cache configuration (optional, uses default values if not provided)
  CacheHandler({CacheConfig? config}) : config = config ?? CacheConfig();

  /// Cache a page of items with the specified key
  /// 
  /// [key] The cache key
  /// [pageKey] The page number
  /// [items] The list of items to cache
  /// [isLastPage] Whether this is the last page of items
  void cachePage({
    required String key,
    required int pageKey,
    required List<T> items,
    required bool isLastPage,
  }) {
    final fullKey = '$key:$pageKey';

    // Implement LRU by removing oldest entries if cache is full
    // But don't remove the page we're about to add
    if (_cache.length >= config.maxSize && !_cache.containsKey(fullKey)) {
      // Remove the least recently used entry (first entry in LinkedHashMap)
      if (_cache.isNotEmpty) {
        final firstKey = _cache.keys.first;
        _cache.remove(firstKey);
        _lastFetch.remove(firstKey.split(':').first);
      }
    }

    _cache[fullKey] = CachedPage<T>(
      items: items,
      timestamp: DateTime.now(),
      isLastPage: isLastPage,
    );
    _lastFetch[key] = DateTime.now();
  }

  /// Check if a specific page is cached and not expired
  /// 
  /// [key] The cache key
  /// [pageKey] The page number to check
  /// 
  /// Returns true if the page is cached and not expired, false otherwise
  bool isPageCached({
    required String key,
    required int pageKey,
  }) {
    final fullKey = '$key:$pageKey';
    final cachedPage = _cache[fullKey];
    if (cachedPage == null) return false;

    // Check if cache is expired
    if (DateTime.now().difference(cachedPage.timestamp) > config.maxAge) {
      _cache.remove(fullKey);
      if (!_cache.keys.any((k) => k.startsWith('$key:'))) {
        _lastFetch.remove(key);
      }
      return false;
    }

    return true;
  }

  /// Get cached page if available and not expired
  /// 
  /// [key] The cache key
  /// [pageKey] The page number to get
  /// 
  /// Returns the cached page if available and not expired, null otherwise
  CachedPage<T>? getCachedPage({
    required String key,
    required int pageKey,
  }) {
    final fullKey = '$key:$pageKey';
    final cachedPage = _cache[fullKey];
    if (cachedPage == null) return null;

    // Check if cache is expired
    if (DateTime.now().difference(cachedPage.timestamp) > config.maxAge) {
      _cache.remove(fullKey);
      if (!_cache.keys.any((k) => k.startsWith('$key:'))) {
        _lastFetch.remove(key);
      }
      return null;
    }

    return cachedPage;
  }

  /// Clear all cached data for a specific key
  /// 
  /// [key] The cache key to clear
  void clearCacheForKey(String key) {
    // Remove all entries with this key prefix
    _cache.keys
        .where((k) => k.startsWith('$key:'))
        .toList()
        .forEach((k) => _cache.remove(k));
    _lastFetch.remove(key);
  }

  /// Clear all cached data
  void clearAllCache() {
    _cache.clear();
    _lastFetch.clear();
  }

  /// Get the last fetch time for a specific key
  /// 
  /// [key] The cache key to get last fetch time for
  /// 
  /// Returns the last fetch time, or null if the key has never been fetched
  DateTime? getLastFetch(String key) {
    return _lastFetch[key];
  }
}