/// Cache entry for a page of items
class CachedPage<T> {
  final List<T> items;
  final DateTime timestamp;
  final bool isLastPage;

  CachedPage({
    required this.items,
    required this.timestamp,
    required this.isLastPage,
  });
}

/// Configuration for cache behavior
class CacheConfig {
  final Duration maxAge;
  final int maxSize;

  CacheConfig({
    this.maxAge = const Duration(minutes: 5),
    this.maxSize = 20,
  });
}