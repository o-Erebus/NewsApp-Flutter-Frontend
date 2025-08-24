// lib/models/news_article.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewsArticle {
  final String id; // Unique ID for keys
  final String title;
  final String imageUrl;
  final String author;
  final DateTime date;
  final String? shortDescription; // Optional
  final String text;
  NewsArticle({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.author,
    required this.date,
    required this.text,
    this.shortDescription,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final timestampStr = json['timestamp'] ?? '';
    DateTime parsedDate;
    try {
      // Try parsing ISO timestamp first
      if (timestampStr.isNotEmpty) {
        parsedDate = DateTime.parse(timestampStr);
      } else {
        parsedDate = DateTime.now();
      }
    } catch (e) {
      // Fallback to parsing the publish_date if timestamp fails
      try {
        final publishDateStr = json['publish_date'] ?? '';
        if (publishDateStr.isNotEmpty) {
          parsedDate = DateFormat('yyyy-MM-dd').parse(publishDateStr);
        } else {
          parsedDate = DateTime.now();
        }
      } catch (e2) {
        parsedDate = DateTime.now(); // final fallback
        print("Failed to parse date: $timestampStr. Error: $e");
      }
    }

    return NewsArticle(
      id: json['_id'] ?? UniqueKey().toString(),
      title: json['title'] ?? '',
      imageUrl: json['top_image'] ?? '',
      author: json['authors'] ?? '',
      date: parsedDate,
      shortDescription: json['headline'] ?? '',
      text: json['text'] ?? '',
    );
  }
}
