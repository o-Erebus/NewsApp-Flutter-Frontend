// lib/models/news_article.dart
class NewsArticle {
  final String id; // Unique ID for keys
  final String title;
  final String imageUrl;
  final String author;
  final DateTime date;
  final String? shortDescription; // Optional

  NewsArticle({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.author,
    required this.date,
    this.shortDescription,
  });
}