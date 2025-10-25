class Podcast {
  final String id;
  final String title;
  final String channelName;
  final String description;
  final String imageUrl;
  final String audioUrl;
  final int duration; // in seconds
  final int listenerCount;
  final DateTime publishedDate;
  final double rating; // 0-5

  Podcast({
    required this.id,
    required this.title,
    required this.channelName,
    required this.description,
    required this.imageUrl,
    required this.audioUrl,
    required this.duration,
    required this.listenerCount,
    required this.publishedDate,
    required this.rating,
  });

  // Factory constructor for creating a Podcast from JSON (API response)
  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'] as String,
      title: json['title'] as String,
      channelName:
          json['channelName'] as String? ?? json['channel_name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String,
      audioUrl: json['audioUrl'] as String? ?? json['audio_url'] as String,
      duration: json['duration'] as int,
      listenerCount:
          json['listenerCount'] as int? ?? json['listener_count'] as int,
      publishedDate: json['publishedDate'] is String
          ? DateTime.parse(json['publishedDate'] as String)
          : DateTime.parse(json['published_date'] as String),
      rating: (json['rating'] as num).toDouble(),
    );
  }

  // Convert Podcast to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'channelName': channelName,
      'description': description,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'duration': duration,
      'listenerCount': listenerCount,
      'publishedDate': publishedDate.toIso8601String(),
      'rating': rating,
    };
  }

  // Copyith method for creating a modified copy
  Podcast copyWith({
    String? id,
    String? title,
    String? channelName,
    String? description,
    String? imageUrl,
    String? audioUrl,
    int? duration,
    int? listenerCount,
    DateTime? publishedDate,
    double? rating,
  }) {
    return Podcast(
      id: id ?? this.id,
      title: title ?? this.title,
      channelName: channelName ?? this.channelName,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      listenerCount: listenerCount ?? this.listenerCount,
      publishedDate: publishedDate ?? this.publishedDate,
      rating: rating ?? this.rating,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Podcast && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PodcastChannel {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int episodeCount;
  final String category;

  PodcastChannel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.episodeCount,
    required this.category,
  });

  factory PodcastChannel.fromJson(Map<String, dynamic> json) {
    return PodcastChannel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String? ?? json['icon_url'] as String,
      episodeCount:
          json['episodeCount'] as int? ?? json['episode_count'] as int,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'episodeCount': episodeCount,
      'category': category,
    };
  }
}
