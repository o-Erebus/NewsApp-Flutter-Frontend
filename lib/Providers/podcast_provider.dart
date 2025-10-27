import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../Models/podcast_model.dart';
import '../Services/podcast_api_service.dart';
import 'dart:developer' as developer;
import 'dart:async';

class PodcastProvider with ChangeNotifier {
  // Audio player instance
  late final AudioPlayer _audioPlayer;
  final PodcastApiService _apiService = PodcastApiService();

  // State variables
  final List<Podcast> _trendingPodcasts = [];
  final List<Podcast> _playHistory = [];
  final List<Podcast> _userPodcasts = [];

  Podcast? _currentPodcast;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isFetchingTrending = false;

  double _currentPosition = 0;
  double _totalDuration = 0;
  String? _audioError;

  // Subscription for position updates
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;

  // Getters
  List<Podcast> get trendingPodcasts => [..._trendingPodcasts];
  List<Podcast> get playHistory => [..._playHistory];

  // User's created podcasts
  List<Podcast> get userPodcasts => [..._userPodcasts];

  Podcast? get currentPodcast => _currentPodcast;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  bool get isFetchingTrending => _isFetchingTrending;
  String? get audioError => _audioError;

  double get currentPosition => _currentPosition;
  double get totalDuration => _totalDuration;

  String get currentPositionFormatted =>
      _formatDuration(Duration(seconds: _currentPosition.toInt()));
  String get totalDurationFormatted =>
      _formatDuration(Duration(seconds: _totalDuration.toInt()));

  PodcastProvider() {
    _audioPlayer = AudioPlayer();
    _setupAudioListeners();
    _initializeMockData();
  }

  /// Setup listeners for audio player state changes
  void _setupAudioListeners() {
    // Listen to position changes
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      _currentPosition = position.inMilliseconds / 1000;
      notifyListeners();
    });

    // Listen to duration changes
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration.inMilliseconds / 1000;
        notifyListeners();
      }
    });

    // Listen to player state changes
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      _isPlaying = playerState.playing;
      notifyListeners();
    });
  }

  /// Initialize with API data
  Future<void> _initializeMockData() async {
    _isFetchingTrending = true;
    notifyListeners();

    try {
      final trendingPodcasts = await _apiService.getTrendingPodcasts();
      _trendingPodcasts.addAll(trendingPodcasts);
      notifyListeners();
    } catch (e) {
      developer.log('Error initializing podcast data: $e');
      _audioError = 'Failed to load podcasts. Please check your connection.';
    } finally {
      _isFetchingTrending = false;
      notifyListeners();
    }
  }

  /// Play a podcast
  Future<void> playPodcast(Podcast podcast) async {
    try {
      _isLoading = true;
      _audioError = null;
      _currentPodcast = podcast;
      _currentPosition = 0;
      // Use the duration from backend if available, otherwise 0
      _totalDuration = podcast.duration > 0 ? podcast.duration.toDouble() : 0.0;
      notifyListeners();

      developer.log('Starting to load audio from: ${podcast.audioUrl}');
      developer.log('Duration from backend: ${podcast.duration} seconds');

      // Load the audio file from the URL
      // This fetches metadata immediately without starting playback
      await _audioPlayer.setUrl(podcast.audioUrl);

      developer.log(
        'Audio loaded, duration from backend: $_totalDuration seconds',
      );

      // Start playing
      await _audioPlayer.play();

      // Add to play history
      if (!_playHistory.contains(podcast)) {
        _playHistory.insert(0, podcast);
        if (_playHistory.length > 50) {
          _playHistory.removeLast();
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _audioError = e.toString();
      developer.log('Error playing podcast: $e');

      // Show more detailed error information
      if (e.toString().contains('UnknownContentType')) {
        _audioError = 'Audio format not supported';
        developer.log(
          'Warning: Audio format may not be recognized by the player',
        );
      } else if (e.toString().contains('Connection')) {
        _audioError = 'Network error - unable to load audio';
        developer.log('Error: Network connection issue - unable to load audio');
      } else if (e.toString().contains('404') ||
          e.toString().contains('not found')) {
        _audioError = 'Audio file not found';
        developer.log('Error: Audio file not found');
      }

      notifyListeners();
    }
  }

  /// Pause the current podcast
  Future<void> pausePodcast() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      developer.log('Error pausing podcast: $e');
    }
  }

  /// Resume the current podcast
  Future<void> resumePodcast() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      developer.log('Error resuming podcast: $e');
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pausePodcast();
    } else {
      await resumePodcast();
    }
  }

  /// Seek to a specific position
  Future<void> seek(double seconds) async {
    try {
      await _audioPlayer.seek(Duration(milliseconds: (seconds * 1000).toInt()));
      notifyListeners();
    } catch (e) {
      developer.log('Error seeking: $e');
    }
  }

  /// Skip forward by 15 seconds
  Future<void> skipForward() async {
    final newPosition = _currentPosition + 15;
    if (newPosition < _totalDuration) {
      await seek(newPosition);
    }
  }

  /// Skip backward by 15 seconds
  Future<void> skipBackward() async {
    final newPosition = _currentPosition - 15;
    if (newPosition > 0) {
      await seek(newPosition);
    }
  }

  /// Stop and reset
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _currentPodcast = null;
      _currentPosition = 0;
      _totalDuration = 0;
      notifyListeners();
    } catch (e) {
      developer.log('Error stopping podcast: $e');
    }
  }

  /// Refresh trending podcasts
  Future<void> refreshTrendingPodcasts() async {
    _isFetchingTrending = true;
    notifyListeners();

    try {
      final podcasts = await _apiService.getTrendingPodcasts();
      _trendingPodcasts.clear();
      _trendingPodcasts.addAll(podcasts);
      notifyListeners();
    } catch (e) {
      developer.log('Error refreshing trending podcasts: $e');
      _audioError = 'Failed to refresh trending podcasts';
    } finally {
      _isFetchingTrending = false;
      notifyListeners();
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await refreshTrendingPodcasts();
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      final hours = twoDigits(duration.inHours);
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  /// Fetch user's podcasts
  Future<void> fetchUserPodcasts() async {
    try {
      final podcasts = await _apiService.getMyPodcasts();
      _userPodcasts.clear();
      _userPodcasts.addAll(podcasts);
      notifyListeners();
    } catch (e) {
      developer.log('Error fetching user podcasts: $e');
      _audioError = 'Failed to load your podcasts';
    }
  }

  /// Create a new podcast
  Future<String?> createPodcast({
    required String topic,
    bool isPublic = true,
  }) async {
    try {
      final podcastId = await _apiService.createPodcast(
        topic: topic,
        isPublic: isPublic,
      );
      if (podcastId != null) {
        await fetchUserPodcasts(); // Refresh the list
      }
      return podcastId;
    } catch (e) {
      developer.log('Error creating podcast: $e');
      _audioError = 'Failed to create podcast';
      rethrow;
    }
  }

  /// Update a podcast
  Future<bool> updatePodcast({
    required String podcastId,
    String? title,
    String? description,
    String? imageUrl,
    bool? isPublic,
  }) async {
    try {
      final updated = await _apiService.updatePodcast(
        podcastId: podcastId,
        title: title,
        description: description,
        imageUrl: imageUrl,
        isPublic: isPublic,
      );
      if (updated != null) {
        await fetchUserPodcasts(); // Refresh the list
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error updating podcast: $e');
      _audioError = 'Failed to update podcast';
      rethrow;
    }
  }

  /// Delete a podcast
  Future<bool> deletePodcast(String podcastId) async {
    try {
      final success = await _apiService.deletePodcast(podcastId);
      if (success) {
        await fetchUserPodcasts(); // Refresh the list
      }
      return success;
    } catch (e) {
      developer.log('Error deleting podcast: $e');
      _audioError = 'Failed to delete podcast';
      rethrow;
    }
  }

  /// Add to play history
  Future<bool> addToPlayHistory(Podcast podcast) async {
    try {
      return await _apiService.addToPlayHistory(
        podcastId: podcast.id,
        title: podcast.title,
        creatorName: podcast.channelName,
        imageUrl: podcast.imageUrl,
        position: _currentPosition.toInt(),
        duration: _totalDuration.toInt(),
      );
    } catch (e) {
      developer.log('Error adding to play history: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
