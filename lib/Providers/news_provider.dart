import 'dart:convert';
import 'dart:io'; // For HttpException
import 'package:finalyear/constants/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../Models/news_article.dart';
import '../utils/request_handler.dart';
import 'dart:async'; // For TimeoutException
import 'dart:collection'; // For LinkedHashMap (LRU Cache)

// Cache entry for a page of articles
class _CachedPage {
  final List<NewsArticle> articles;
  final DateTime timestamp;
  final bool isLastPage;

  _CachedPage({
    required this.articles,
    required this.timestamp,
    required this.isLastPage,
  });
}

class NewsProvider with ChangeNotifier {
  static const _pageSize = 5;
  static const _cacheMaxAge = Duration(minutes: 5); // Cache expiry time
  static const _maxCacheSize = 20; // Maximum number of cached responses

  /// This example uses a [PagingController] to manage the paging state.
  ///
  /// This is a robust inbuilt way to store your pagination state.
  /// The controller can also be used in multiple Paged layouts simultaneously,
  /// to share their state.
  late final _pagingController = PagingController<int, NewsArticle>(
    getNextPageKey: (state) {
      // This convenience getter checks if the last returned page is empty.
      // You can replace this with a check if the last page has returned less items than expected,
      // for a more efficient implementation.
      if (state.lastPageIsEmpty) return null;
      // This convenience getter increments the page key by 1, assuming keys start at 1.
      return state.nextIntPageKey;
    },
    fetchPage: (pageKey) => _fetchArticlesPage(pageKey),
  );

  /// Global paging controller for fetching global articles
  late final globalPagingController = PagingController<int, NewsArticle>(
    getNextPageKey: (state) {
      // This convenience getter checks if the last returned page is empty.
      // You can replace this with a check if the last page has returned less items than expected,
      // for a more efficient implementation.
      if (state.lastPageIsEmpty) return null;
      // This convenience getter increments the page key by 1, assuming keys start at 1.
      return state.nextIntPageKey;
    },
    fetchPage: (pageKey) => fetchGlobalArticles(pageKey),
  );

  final List<NewsArticle> _featuredArticles = [];
  final RequestHandler _requestHandler = RequestHandler();

  // Cache for articles by category with timestamps
  final Map<String, LinkedHashMap<int, _CachedPage>> _categoryCache = {};
  final Map<String, DateTime> _categoryLastFetch = {};

  // Cache for global articles with timestamps
  final LinkedHashMap<int, _CachedPage> _globalCache =
      LinkedHashMap<int, _CachedPage>();
  DateTime _globalLastFetch = DateTime.now();

  // Current selected category
  String _currentCategory = 'all';

  // Debouncing for rapid category switching
  Timer? _categoryChangeTimer;
  static const _categoryChangeDelay = Duration(milliseconds: 300);

  // Getters
  PagingController<int, NewsArticle> get pagingController => _pagingController;
  List<NewsArticle> get featuredArticles => [..._featuredArticles];
  String get currentCategory => _currentCategory;

  // Helper method to get featured article IDs
  Set<String> _getFeaturedArticleIds() {
    return _featuredArticles.map((article) => article.id).toSet();
  }

  NewsProvider() {
    // Add listener for error handling
    _pagingController.addListener(_handleError);
    globalPagingController.addListener(_handleError);

    // Initial fetch
    fetchArticles(); // This will trigger the first page load
    fetchFeaturedArticles(); // Separate fetch for featured articles

    // Prefetch articles for all categories
    _prefetchCategoryArticles();
  }

  /// Select a category and refresh the article list
  void selectCategory(String category) {
    // Cancel any pending category change
    _categoryChangeTimer?.cancel();

    // Set up a new timer for debouncing
    _categoryChangeTimer = Timer(_categoryChangeDelay, () {
      if (_currentCategory != category) {
        _currentCategory = category;
        _pagingController.refresh();
        notifyListeners();

        // Prefetch the next likely categories
        _prefetchCategoryArticles();
      }
    });
  }

  /// Prefetch articles for all categories to improve UX
  Future<void> _prefetchCategoryArticles() async {
    final categories = [
      'business',
      'technology',
      'entertainment',
      'science',
      'sports',
      'health',
    ];

    // Prefetch multiple pages for each category in the background
    for (final category in categories) {
      // Check if first page is already cached
      if (!_isCategoryCached(category, 1)) {
        // Fetch first 2 pages for each category without affecting UI
        unawaited(_fetchCategoryPage(category, 1).catchError((_) {}));
        unawaited(_fetchCategoryPage(category, 2).catchError((_) {}));
      }

      // Also check second page
      if (!_isCategoryCached(category, 2)) {
        unawaited(_fetchCategoryPage(category, 2).catchError((_) {}));
      }
    }
  }

  /// Check if a specific page of a category is cached and not expired
  bool _isCategoryCached(String category, int pageKey) {
    final cache = _categoryCache[category];
    if (cache == null) return false;

    final cachedPage = cache[pageKey];
    if (cachedPage == null) return false;

    // Check if cache is expired
    if (DateTime.now().difference(cachedPage.timestamp) > _cacheMaxAge) {
      cache.remove(pageKey);
      return false;
    }

    return true;
  }

  /// Get cached page if available and not expired
  _CachedPage? _getCachedPage(String category, int pageKey) {
    final cache = _categoryCache[category];
    if (cache == null) return null;

    final cachedPage = cache[pageKey];
    if (cachedPage == null) return null;

    // Check if cache is expired
    if (DateTime.now().difference(cachedPage.timestamp) > _cacheMaxAge) {
      cache.remove(pageKey);
      // Also update the last fetch time
      _categoryLastFetch.remove(category);
      return null;
    }

    return cachedPage;
  }

  /// Cache a page of articles
  void _cachePage(String category, int pageKey, _CachedPage page) {
    // Initialize cache for category if needed
    _categoryCache.putIfAbsent(
      category,
      () => LinkedHashMap<int, _CachedPage>(),
    );

    final cache = _categoryCache[category]!;

    // Implement LRU by removing oldest entries if cache is full
    // But don't remove the page we're about to add
    if (cache.length >= _maxCacheSize && !cache.containsKey(pageKey)) {
      final firstKey = cache.keys.first;
      cache.remove(firstKey);
    }

    cache[pageKey] = page;
    _categoryLastFetch[category] = DateTime.now();
  }

  /// Check if a specific page of global articles is cached and not expired
  bool _isGlobalCached(int pageKey) {
    final cachedPage = _globalCache[pageKey];
    if (cachedPage == null) return false;

    // Check if cache is expired
    if (DateTime.now().difference(cachedPage.timestamp) > _cacheMaxAge) {
      _globalCache.remove(pageKey);
      return false;
    }

    return true;
  }

  /// Get cached global page if available and not expired
  _CachedPage? _getGlobalCachedPage(int pageKey) {
    final cachedPage = _globalCache[pageKey];
    if (cachedPage == null) return null;

    // Check if cache is expired
    if (DateTime.now().difference(cachedPage.timestamp) > _cacheMaxAge) {
      _globalCache.remove(pageKey);
      return null;
    }

    return cachedPage;
  }

  /// Cache a page of global articles
  void _cacheGlobalPage(int pageKey, _CachedPage page) {
    // Implement LRU by removing oldest entries if cache is full
    // But don't remove the page we're about to add
    if (_globalCache.length >= _maxCacheSize &&
        !_globalCache.containsKey(pageKey)) {
      final firstKey = _globalCache.keys.first;
      _globalCache.remove(firstKey);
    }

    _globalCache[pageKey] = page;
    _globalLastFetch = DateTime.now();
  }

  /// Fetch articles for a specific category with caching
  Future<List<NewsArticle>> _fetchCategoryPage(
    String category,
    int pageKey,
  ) async {
    // Try to get from cache first
    final cachedPage = _getCachedPage(category, pageKey);
    if (cachedPage != null) {
      return cachedPage.articles;
    }

    try {
      // Construct endpoint based on category
      String endpoint = Constants.articlesEndpoint;
      if (category != 'all') {
        endpoint = '${Constants.articlesEndpoint}/$category';
      }

      final uri =
          Uri.https(Constants.baseUrl.replaceAll('https://', ''), endpoint, {
            'page': pageKey.toString(),
            'page_size': (_pageSize + _featuredArticles.length).toString(),
          });

      final response = await _requestHandler.get(uri.toString());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articleList = data["data"];

        List<NewsArticle> fetchedArticles = articleList
            .map((json) => NewsArticle.fromJson(json))
            .toList();

        // Filter out featured articles from the fetched list
        final featuredIds = _getFeaturedArticleIds();
        final filteredArticles = fetchedArticles
            .where((article) => !featuredIds.contains(article.id))
            .toList();

        // Take only the required number of articles for this page
        final pageArticles = filteredArticles.take(_pageSize).toList();

        // Determine if this is the last page
        final pagination = data["pagination"];
        bool isLastPage = true;

        if (pagination != null) {
          isLastPage = pagination["page"] >= pagination["pages"];
        } else {
          // Fallback to the old logic if pagination info is not available
          isLastPage = pageArticles.length < _pageSize;
        }

        // Cache the page
        _cachePage(
          category,
          pageKey,
          _CachedPage(
            articles: pageArticles,
            timestamp: DateTime.now(),
            isLastPage: isLastPage,
          ),
        );

        // Return the filtered articles for this page
        return pageArticles;
      } else if (response.statusCode == 404) {
        // Handle specific HTTP errors
        return [];
      } else {
        // Handle other HTTP errors
        throw HttpException(
          'Server error: ${response.statusCode} - ${response.body}',
          uri: uri,
        );
      }
    } on SocketException catch (e) {
      // Handle network connectivity issues
      throw e;
    } on TimeoutException catch (e) {
      // Handle request timeouts
      throw e;
    } catch (error) {
      // Handle all other errors
      throw error;
    }
  }

  /// Fetch global articles with caching
  Future<List<NewsArticle>> _fetchGlobalPage(int pageKey) async {
    // Try to get from cache first
    final cachedPage = _getGlobalCachedPage(pageKey);
    if (cachedPage != null) {
      return cachedPage.articles;
    }

    try {
      // Construct endpoint for global articles
      final uri = Uri.https(
        Constants.baseUrl.replaceAll('https://', ''),
        Constants.globalArticlesEndpoint,
        {
          'page': pageKey.toString(),
          'page_size': (_pageSize + _featuredArticles.length).toString(),
        },
      );

      final response = await _requestHandler.get(uri.toString());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articleList = data["data"];

        List<NewsArticle> fetchedArticles = articleList
            .map((json) => NewsArticle.fromJson(json))
            .toList();

        // Filter out featured articles from the fetched list
        final featuredIds = _getFeaturedArticleIds();
        final filteredArticles = fetchedArticles
            .where((article) => !featuredIds.contains(article.id))
            .toList();

        // Take only the required number of articles for this page
        final pageArticles = filteredArticles.take(_pageSize).toList();

        // Determine if this is the last page
        final pagination = data["pagination"];
        bool isLastPage = true;

        if (pagination != null) {
          isLastPage = pagination["page"] >= pagination["pages"];
        } else {
          // Fallback to the old logic if pagination info is not available
          isLastPage = pageArticles.length < _pageSize;
        }

        // Cache the page
        _cacheGlobalPage(
          pageKey,
          _CachedPage(
            articles: pageArticles,
            timestamp: DateTime.now(),
            isLastPage: isLastPage,
          ),
        );

        // Return the filtered articles for this page
        return pageArticles;
      } else if (response.statusCode == 404) {
        // Handle specific HTTP errors
        return [];
      } else {
        // Handle other HTTP errors
        throw HttpException(
          'Server error: ${response.statusCode} - ${response.body}',
          uri: uri,
        );
      }
    } on SocketException catch (e) {
      // Handle network connectivity issues
      throw e;
    } on TimeoutException catch (e) {
      // Handle request timeouts
      throw e;
    } catch (error) {
      // Handle all other errors
      throw error;
    }
  }

  Future<List<NewsArticle>> _fetchArticlesPage(int pageKey) async {
    if (_currentCategory == 'all') {
      // Use the original fetch method for 'all' category
      return _fetchOriginalArticlesPage(pageKey);
    } else {
      // Use the category-specific fetch method
      return _fetchCategoryPage(_currentCategory, pageKey);
    }
  }

  Future<List<NewsArticle>> _fetchOriginalArticlesPage(int pageKey) async {
    try {
      final uri = Uri.https(
        Constants.baseUrl.replaceAll('https://', ''),
        Constants.articlesEndpoint,
        {
          'page': pageKey.toString(),
          'page_size': (_pageSize + _featuredArticles.length).toString(),
        }, // Fetch extra to account for filtering
      );

      final response = await _requestHandler.get(uri.toString());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articleList = data["data"];

        List<NewsArticle> fetchedArticles = articleList
            .map((json) => NewsArticle.fromJson(json))
            .toList();

        // Filter out featured articles from the fetched list
        final featuredIds = _getFeaturedArticleIds();
        final filteredArticles = fetchedArticles
            .where((article) => !featuredIds.contains(article.id))
            .toList();

        // Take only the required number of articles for this page
        final pageArticles = filteredArticles.take(_pageSize).toList();

        // Determine if this is the last page
        final pagination = data["pagination"];
        bool isLastPage = true;

        if (pagination != null) {
          isLastPage = pagination["page"] >= pagination["pages"];
        } else {
          // Fallback to the old logic if pagination info is not available
          isLastPage = pageArticles.length < _pageSize;
        }

        // Return the filtered articles for this page
        return pageArticles;
      } else if (response.statusCode == 404) {
        // Handle specific HTTP errors
        return [];
      } else {
        // Handle other HTTP errors
        throw HttpException(
          'Server error: ${response.statusCode} - ${response.body}',
          uri: uri,
        );
      }
    } on SocketException catch (e) {
      // Handle network connectivity issues
      throw e;
    } on TimeoutException catch (e) {
      // Handle request timeouts
      throw e;
    } catch (error) {
      // Handle all other errors
      throw error;
    }
  }

  /// This method listens to notifications from the [_pagingController] and
  /// shows a [SnackBar] when an error occurs.
  Future<void> _handleError() async {
    // Error handling is done in the UI layer
  }

  Future<void> fetchFeaturedArticles() async {
    // Create a separate loading state for featured articles to avoid conflicts
    // Note: We don't need to notifyListeners here as the PagingController handles that

    final uri = Uri.https(
      Constants.baseUrl.replaceAll('https://', ''),
      Constants.featuredArticlesEndpoint,
    );

    try {
      final response = await _requestHandler.get(uri.toString());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articleList = data["data"];

        List<NewsArticle> fetchedArticles = articleList
            .map((json) => NewsArticle.fromJson(json))
            .toList();

        _featuredArticles.clear();
        _featuredArticles.addAll(fetchedArticles);

        // Only notifyListeners for featuredArticles as pagingController handles its own state
        notifyListeners();
      } else {
        print("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching featured articles: $e");
    }
  }

  Future<void> fetchArticles() async {
    // Refresh both regular and featured articles
    // Load featured articles first to ensure they're available for exclusion
    await fetchFeaturedArticles();
    _pagingController.refresh();
  }

  /// Fetch global articles with pagination support
  Future<List<NewsArticle>> fetchGlobalArticles(int pageKey) async {
    return _fetchGlobalPage(pageKey);
  }

  void dispose() {
    _pagingController.dispose();
    globalPagingController.dispose();
    _categoryChangeTimer?.cancel();
    super.dispose();
  }
}
