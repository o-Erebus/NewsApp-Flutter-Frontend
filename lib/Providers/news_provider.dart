// lib/providers/news_provider.dart
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import '../Models/news_article.dart';

import 'package:uuid/uuid.dart'; // For generating unique IDs

var _uuid = Uuid();

class NewsProvider with ChangeNotifier {
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  bool _hasMore = true; // To indicate if more articles can be loaded

  List<NewsArticle> get articles => [..._articles]; // Return a copy
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  NewsProvider() {
    fetchArticles(); // Initial fetch
  }

  // Simulate fetching articles
  Future<void> fetchArticles({bool isLoadMore = false}) async {
    if (_isLoading) return;
    if (isLoadMore && !_hasMore) return;

    _isLoading = true;
    if (!isLoadMore) {
      // For initial load, clear existing articles
      _articles = [];
    }
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate some dummy articles
    List<NewsArticle> newArticles = List.generate(10, (index) {
      final articleIndex = _articles.length + index;
      return NewsArticle(
        id: _uuid.v4(),
        title: 'News Headline Item $articleIndex by Author',
        imageUrl: 'https://picsum.photos/id/${articleIndex + 20}/400/300',
        author: 'Author ${articleIndex % 5 + 1}',
        date: DateTime.now().subtract(Duration(days: articleIndex)),
        shortDescription:
        'This is a concise and engaging summary of news item $articleIndex, designed to capture attention.',
      );
    });

    _articles.addAll(newArticles);
    _isLoading = false;
    _hasMore = _articles.length < 50; // Simulate having a total of 50 articles
    notifyListeners();
  }
}