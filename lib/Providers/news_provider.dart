import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../Models/news_article.dart';

class NewsProvider with ChangeNotifier {
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 5;

  List<NewsArticle> get articles => [..._articles];
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  NewsProvider() {
    fetchArticles(); // Initial fetch
  }

  Future<void> fetchArticles({bool isLoadMore = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    if (isLoadMore) {
      _currentPage++;
    } else {
      _currentPage = 1;
      _articles.clear();
    }

    final uri = Uri.parse("http://10.0.0.215:5000/tech");

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "page": _currentPage,
          "page_size": _pageSize,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articleList = data["articles"];

        List<NewsArticle> fetchedArticles = articleList
            .map((json) => NewsArticle.fromJson(json))
            .toList();

        _articles.addAll(fetchedArticles);
        _hasMore = fetchedArticles.length == _pageSize;
      } else {
        print("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching articles: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
