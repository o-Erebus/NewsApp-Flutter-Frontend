class ReadHistoryEntry {
  final String id;
  final String articleId;
  final String articleTitle;
  final DateTime readAt;
  final String? topImage;
  final Map<String, dynamic>? articleDetails; // Full article details

  ReadHistoryEntry({
    required this.id,
    required this.articleId,
    required this.articleTitle,
    required this.readAt,
    this.topImage,
    this.articleDetails,
  });

  factory ReadHistoryEntry.fromJson(Map<String, dynamic> json) {
    // Try to get top_image from either the root level or from article_details
    String? topImage = json['top_image'];
    if (topImage == null && json['article_details'] != null) {
      topImage = json['article_details']['top_image'];
    }

    return ReadHistoryEntry(
      id: json['_id'] ?? '',
      articleId: json['article_id'] ?? '',
      articleTitle: json['article_title'] ?? '',
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'])
          : DateTime.now(),
      topImage: topImage,
      articleDetails: json['article_details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'article_id': articleId,
      'article_title': articleTitle,
      'read_at': readAt.toIso8601String(),
      'top_image': topImage,
      'article_details': articleDetails,
    };
  }
}
