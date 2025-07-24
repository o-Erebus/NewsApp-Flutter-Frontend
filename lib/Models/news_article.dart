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
    final rfcDateStr = json['timestamp'] ?? '';
    DateTime parsedDate;
    try {
      parsedDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US').parseUtc(rfcDateStr);
    } catch (e) {
      parsedDate = DateTime.now(); // fallback
      print("Failed to parse date: $rfcDateStr. Error: $e");
    }
    print(json['top_image']);
    return NewsArticle(
      id: json['id'] ?? UniqueKey().toString(),
      title: json['title'] ?? '',
      imageUrl: json['top_image'] ?? '',
      author: json['author'] ?? '',
      date: parsedDate,
      shortDescription: json['headline'] ?? '',
      text : json['text']
    );
  }

}