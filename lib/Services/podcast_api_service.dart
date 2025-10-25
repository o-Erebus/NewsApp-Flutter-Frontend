import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finalyear/Models/podcast_model.dart';
import 'package:finalyear/constants/constants.dart';
import 'package:finalyear/utils/request_handler.dart';
import 'dart:developer' as developer;

class PodcastApiService {
  static final PodcastApiService _instance = PodcastApiService._internal();
  factory PodcastApiService() => _instance;
  PodcastApiService._internal();

  final RequestHandler _requestHandler = RequestHandler();
  final String _baseEndpoint = '/api/podcasts';

  // ==================== TRENDING PODCASTS ====================
  Future<List<Podcast>> getTrendingPodcasts({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final url =
          '${Constants.baseUrl}$_baseEndpoint/trending?limit=$limit&offset=$offset';
      developer.log('Fetching trending podcasts from: $url');
      final response = await _requestHandler.get(url);

      developer.log(
        'Trending podcasts response status: ${response.statusCode}',
      );
      developer.log('Trending podcasts response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          // Handle both response formats
          final List<dynamic> podcastsJson =
              json['podcasts'] ?? json['data']?['podcasts'] ?? [];
          developer.log('Found ${podcastsJson.length} trending podcasts');
          return podcastsJson.map((p) => Podcast.fromJson(p)).toList();
        }
      }
      developer.log(
        'Failed to fetch trending podcasts: status ${response.statusCode}',
      );
      return [];
    } catch (e) {
      developer.log('Error fetching trending podcasts: $e');
      return [];
    }
  }

  // ==================== GET SINGLE PODCAST ====================
  Future<Podcast?> getPodcast(String podcastId) async {
    try {
      final url = '${Constants.baseUrl}$_baseEndpoint/$podcastId';
      final response = await _requestHandler.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return Podcast.fromJson(json['data']);
        }
      }
      return null;
    } catch (e) {
      developer.log('Error fetching podcast: $e');
      return null;
    }
  }

  // ==================== GET MY PODCASTS ====================
  Future<List<Podcast>> getMyPodcasts({int limit = 20, int offset = 0}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        developer.log('User not authenticated for getMyPodcasts');
        throw Exception('User not authenticated');
      }

      final url =
          '${Constants.baseUrl}$_baseEndpoint/users/my-podcasts?limit=$limit&offset=$offset';
      developer.log('Fetching my podcasts from: $url');
      final response = await _requestHandler.get(url);

      developer.log('My podcasts response status: ${response.statusCode}');
      developer.log('My podcasts response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          // Handle both response formats: top-level "podcasts" or nested "data.podcasts"
          final List<dynamic> podcastsJson =
              json['podcasts'] ?? json['data']?['podcasts'] ?? [];
          developer.log('Found ${podcastsJson.length} user podcasts');
          return podcastsJson.map((p) => Podcast.fromJson(p)).toList();
        }
      }
      developer.log(
        'Failed to fetch my podcasts: status ${response.statusCode}',
      );
      return [];
    } catch (e) {
      developer.log('Error fetching my podcasts: $e');
      return [];
    }
  }

  // ==================== SEARCH PODCASTS ====================
  Future<List<Podcast>> searchPodcasts({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final url =
          '${Constants.baseUrl}$_baseEndpoint/search?q=$query&limit=$limit&offset=$offset';
      final response = await _requestHandler.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          // Handle both response formats
          final List<dynamic> podcastsJson =
              json['podcasts'] ?? json['data']?['podcasts'] ?? [];
          return podcastsJson.map((p) => Podcast.fromJson(p)).toList();
        }
      }
      return [];
    } catch (e) {
      developer.log('Error searching podcasts: $e');
      return [];
    }
  }

  // ==================== CREATE PODCAST ====================
  Future<String?> createPodcast({
    required String title,
    required String description,
    required String audioUrl,
    String? imageUrl,
    bool isPublic = true,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final url = '${Constants.baseUrl}$_baseEndpoint';
      final body = {
        'title': title,
        'description': description,
        'audio_url': audioUrl,
        'image_url': imageUrl,
        'is_public': isPublic,
      };

      developer.log('Creating podcast at: $url with body: $body');
      final response = await _requestHandler.post(url, body: body);

      developer.log('Create podcast response status: ${response.statusCode}');
      developer.log('Create podcast response body: ${response.body}');

      // Accept both 200 and 201 status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          // Handle both response formats: direct or nested in data
          final podcastId = json['podcast_id'] ?? json['data']?['podcast_id'];
          developer.log('Podcast created with ID: $podcastId');
          return podcastId as String?;
        }
      }
      developer.log('Failed to create podcast: status ${response.statusCode}');
      return null;
    } catch (e) {
      developer.log('Error creating podcast: $e');
      rethrow;
    }
  }

  // ==================== UPDATE PODCAST ====================
  Future<Podcast?> updatePodcast({
    required String podcastId,
    String? title,
    String? description,
    String? imageUrl,
    bool? isPublic,
  }) async {
    try {
      final url = '${Constants.baseUrl}$_baseEndpoint/$podcastId';
      final body = {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
        if (isPublic != null) 'is_public': isPublic,
      };

      final response = await _requestHandler.put(url, body: body);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          // Accept multiple possible response shapes from the backend:
          // - { success: true, data: { ...updated podcast... } }
          // - { success: true, podcast: { ...updated podcast... } }
          // - { success: true, data: { "podcast": { ... } } }
          dynamic podcastJson;
          if (json['data'] is Map && json['data']['id'] != null) {
            podcastJson = json['data'];
          } else if (json['podcast'] is Map) {
            podcastJson = json['podcast'];
          } else if (json['data'] is Map && json['data']['podcast'] is Map) {
            podcastJson = json['data']['podcast'];
          }

          if (podcastJson is Map<String, dynamic>) {
            return Podcast.fromJson(podcastJson);
          } else {
            developer.log(
              'Unexpected updatePodcast response shape, body: ${response.body}',
            );
          }
        } else {
          developer.log(
            'updatePodcast returned success=false, body: ${response.body}',
          );
        }
      } else {
        developer.log(
          'updatePodcast HTTP ${response.statusCode}, body: ${response.body}',
        );
      }
      return null;
    } catch (e) {
      developer.log('Error updating podcast: $e');
      rethrow;
    }
  }

  // ==================== DELETE PODCAST ====================
  Future<bool> deletePodcast(String podcastId) async {
    try {
      final url = '${Constants.baseUrl}$_baseEndpoint/$podcastId';
      final response = await _requestHandler.delete(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['success'] == true;
      }
      return false;
    } catch (e) {
      developer.log('Error deleting podcast: $e');
      rethrow;
    }
  }

  // ==================== ADD TO PLAY HISTORY ====================
  Future<bool> addToPlayHistory({
    required String podcastId,
    required String title,
    required String creatorName,
    required String imageUrl,
    required int position,
    required int duration,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final url = '${Constants.baseUrl}$_baseEndpoint/play-history';
      final body = {
        'podcast_id': podcastId,
        'title': title,
        'creator_name': creatorName,
        'image_url': imageUrl,
        'position': position,
        'duration': duration,
      };

      final response = await _requestHandler.post(url, body: body);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['success'] == true;
      }
      return false;
    } catch (e) {
      developer.log('Error adding to play history: $e');
      return false;
    }
  }

  // ==================== GET PLAY HISTORY ====================
  Future<List<Map<String, dynamic>>> getPlayHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final url =
          '${Constants.baseUrl}$_baseEndpoint/play-history?limit=$limit&offset=$offset';
      final response = await _requestHandler.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          // Handle both response formats
          final List<dynamic> historyJson =
              json['history'] ?? json['data']?['history'] ?? [];
          return historyJson.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      developer.log('Error fetching play history: $e');
      return [];
    }
  }
}
