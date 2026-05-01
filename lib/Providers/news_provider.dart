import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io'; // For HttpException
import 'package:Nexora/constants/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../Models/news_article.dart';
import '../utils/request_handler.dart';
import '../utils/uri_utils.dart';
import 'dart:async'; // For TimeoutException
import 'package:Nexora/utils/cache_handler.dart';
import 'package:Nexora/Models/news_cache_models.dart';

class NewsProvider with ChangeNotifier {
  static final _pageSize = int.parse(
    Constants.pageSize,
  ); // Number of articles per page
  static final _featuredArticlesSize = int.parse(
    Constants.featuredArticlesSize,
  ); // Number of featured articles

  // Mood booster state for home screen
  bool _isMoodBoosterActivated = false;

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
  bool _isFetchingFeaturedArticles = false;

  // Cache handlers for different purposes
  final Map<String, CacheHandler<NewsArticle>> _categoryCacheHandlers = {};
  final CacheHandler<NewsArticle> _globalCacheHandler =
      CacheHandler<NewsArticle>();
  final CacheHandler<NewsArticle> _allCacheHandler =
      CacheHandler<NewsArticle>();

  // Current selected category
  String _currentCategory = 'all';

  // Debouncing for rapid category switching
  Timer? _categoryChangeTimer;
  static const _categoryChangeDelay = Duration(milliseconds: 300);

  // Getters
  PagingController<int, NewsArticle> get pagingController => _pagingController;
  List<NewsArticle> get featuredArticles => [..._featuredArticles];
  String get currentCategory => _currentCategory;
  bool get isFetchingFeaturedArticles => _isFetchingFeaturedArticles;
  bool get isMoodBoosterActivated => _isMoodBoosterActivated;

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

  /// Toggle mood booster and refresh articles
  void toggleMoodBooster() {
    _isMoodBoosterActivated = !_isMoodBoosterActivated;
    clearAllCaches();
    _pagingController.refresh();
    notifyListeners();
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
      } else if (!_isCategoryCached(category, 2)) {
        // If first page is cached but second isn't, fetch second page
        unawaited(_fetchCategoryPage(category, 2).catchError((_) {}));
      }
    }
  }

  /// Get or create a cache handler for a specific category
  CacheHandler<NewsArticle> _getCategoryCacheHandler(String category) {
    if (!_categoryCacheHandlers.containsKey(category)) {
      _categoryCacheHandlers[category] = CacheHandler<NewsArticle>();
    }
    return _categoryCacheHandlers[category]!;
  }

  /// Check if a specific page of a category is cached and not expired
  bool _isCategoryCached(String category, int pageKey) {
    final cacheHandler = _getCategoryCacheHandler(category);
    return cacheHandler.isPageCached(key: category, pageKey: pageKey);
  }

  /// Get cached page if available and not expired
  CachedPage<NewsArticle>? _getCachedPage(String category, int pageKey) {
    final cacheHandler = _getCategoryCacheHandler(category);
    return cacheHandler.getCachedPage(key: category, pageKey: pageKey);
  }

  /// Check if a specific page of global articles is cached and not expired
  bool _isGlobalCached(int pageKey) {
    return _globalCacheHandler.isPageCached(key: 'global', pageKey: pageKey);
  }

  /// Get cached global page if available and not expired
  CachedPage<NewsArticle>? _getGlobalCachedPage(int pageKey) {
    return _globalCacheHandler.getCachedPage(key: 'global', pageKey: pageKey);
  }

  /// Fetch articles for a specific category with caching
  Future<List<NewsArticle>> _fetchCategoryPage(
    String category,
    int pageKey,
  ) async {
    // Determine which cache handler to use
    final cacheHandler = category == 'all'
        ? _allCacheHandler
        : _getCategoryCacheHandler(category);
    final cacheKey = category == 'all' ? 'all' : category;

    // Try to get from cache first
    final cachedPage = cacheHandler.getCachedPage(
      key: cacheKey,
      pageKey: pageKey,
    );
    if (cachedPage != null) {
      return cachedPage.items;
    }

    try {
      // Construct endpoint based on category
      String endpoint = Constants.articlesEndpoint;

      // Create query parameters
      final queryParams = {
        'page': pageKey.toString(),
        'limit': (_pageSize + _featuredArticles.length).toString(),
        'isMoodBoosterActivated': _isMoodBoosterActivated.toString(),
      };

      // Add tags filter if category is not 'all'
      if (category != 'all') {
        queryParams['tags'] = category;
      }

      final uri = UriUtils.buildUri(endpoint, queryParams);

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
        cacheHandler.cachePage(
          key: cacheKey,
          pageKey: pageKey,
          items: pageArticles,
          isLastPage: isLastPage,
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
      rethrow;
    } on TimeoutException catch (e) {
      // Handle request timeouts
      rethrow;
    } catch (error) {
      // Handle all other errors
      rethrow;
    }
  }

  /// Fetch global articles with caching
  Future<List<NewsArticle>> _fetchGlobalPage(int pageKey) async {
    // Try to get from cache first
    final cachedPage = _globalCacheHandler.getCachedPage(
      key: 'global',
      pageKey: pageKey,
    );
    if (cachedPage != null) {
      return cachedPage.items;
    }

    try {
      // Construct endpoint for global articles
      final uri = UriUtils.buildUri(Constants.globalArticlesEndpoint, {
        'page': pageKey.toString(),
        'limit': (_pageSize + _featuredArticles.length).toString(),
        'tags': 'world',
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
        _globalCacheHandler.cachePage(
          key: 'global',
          pageKey: pageKey,
          items: pageArticles,
          isLastPage: isLastPage,
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
      rethrow;
    } on TimeoutException catch (e) {
      // Handle request timeouts
      rethrow;
    } catch (error) {
      // Handle all other errors
      rethrow;
    }
  }

  Future<List<NewsArticle>> _fetchArticlesPage(int pageKey) async {
    if (_currentCategory == 'all') {
      // Use the original fetch method for 'all' category
      return _fetchCategoryPage('all', pageKey);
    } else {
      // Use the category-specific fetch method
      return _fetchCategoryPage(_currentCategory, pageKey);
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

    _isFetchingFeaturedArticles = true;
    notifyListeners();

    final uri = UriUtils.buildUri(Constants.featuredArticlesEndpoint);

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
        developer.log("Server error: ${response.statusCode}");
      }
    } catch (e) {
      developer.log("Error fetching featured articles: $e");
    } finally {
      _isFetchingFeaturedArticles = false;
      notifyListeners();
    }
  }

  Future<void> fetchArticles() async {
    // Refresh both regular and featured articles
    // Load featured articles first to ensure they're available for exclusion
    await fetchFeaturedArticles();
    // Clear all caches for fresh data
    clearAllCaches();
    _pagingController.refresh();
  }

  /// Fetch global articles with pagination support
  Future<List<NewsArticle>> fetchGlobalArticles(int pageKey) async {
    return _fetchGlobalPage(pageKey);
  }

  /// Clear all caches for pull-to-refresh functionality
  void clearAllCaches() {
    // Clear all category caches
    for (var cacheHandler in _categoryCacheHandlers.values) {
      cacheHandler.clearAllCache();
    }

    // Clear global cache
    _globalCacheHandler.clearAllCache();

    // Clear 'all' cache
    _allCacheHandler.clearAllCache();

    developer.log('All caches cleared');
  }

  @override
  void dispose() {
    _pagingController.dispose();
    globalPagingController.dispose();
    _categoryChangeTimer?.cancel();
    super.dispose();
  }
}
