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
  final bool isPublic; // New field for public/private status
  final String status; // "completed", "generating", "failed"

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
    this.isPublic = true,
    this.status = 'completed',
  });

  // Factory constructor for creating a Podcast from JSON (API response)
  factory Podcast.fromJson(Map<String, dynamic> json) {
    // Robust parsing for duration that may arrive as:
    // - int under keys: 'duration', 'total_duration'
    // - camelCase 'totalDuration'
    // - string numbers ("18")
    dynamic rawDuration =
        json['duration'] ?? json['total_duration'] ?? json['totalDuration'];
    int parsedDuration = 0;
    if (rawDuration != null) {
      if (rawDuration is int) {
        parsedDuration = rawDuration;
      } else if (rawDuration is double) {
        parsedDuration = rawDuration.toInt();
      } else if (rawDuration is String) {
        parsedDuration =
            int.tryParse(rawDuration) ??
            (double.tryParse(rawDuration)?.toInt() ?? 0);
      }
    }

    return Podcast(
      // Handle both 'id' and '_id' from API
      id: (json['id'] ?? json['_id'] ?? json['podcast_id'] ?? '') as String,
      title: json['title'] as String? ?? '',
      // Handle snake_case from new API: creator_name
      channelName:
          (json['channelName'] ??
                  json['channel_name'] ??
                  json['creator_name'] ??
                  'Unknown')
              as String,
      description: json['description'] as String? ?? '',
      // Handle snake_case from new API: image_url
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '') as String,
      // Handle snake_case from new API: audio_url
      audioUrl: (json['audioUrl'] ?? json['audio_url'] ?? '') as String,
      // Use parsed duration (from backend if provided) or 0
      duration: parsedDuration,
      // Handle listener_count from API, default to 0 if not present
      listenerCount:
          (json['listenerCount'] ?? json['listener_count'] ?? 0) as int,
      // Handle both publishedDate and created_time from new API
      publishedDate: json['publishedDate'] is String
          ? DateTime.parse(json['publishedDate'] as String)
          : json['created_time'] is String
          ? DateTime.parse(json['created_time'] as String)
          : DateTime.now(),
      // Default rating to 0 if not provided
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      // Handle is_public field from API
      isPublic:
          (json['is_public'] as bool?) ?? (json['isPublic'] as bool?) ?? true,
      // Handle status field from API - can be "completed", "generating", "failed"
      status: (json['status'] as String?)?.toLowerCase() ?? 'completed',
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
      'isPublic': isPublic,
      'status': status,
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
    bool? isPublic,
    String? status,
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
      isPublic: isPublic ?? this.isPublic,
      status: status ?? this.status,
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
