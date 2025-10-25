import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../Models/podcast_model.dart';
import 'dart:developer' as developer;
import 'dart:async';

class PodcastProvider with ChangeNotifier {
  // Audio player instance
  late final AudioPlayer _audioPlayer;

  // State variables
  final List<Podcast> _trendingPodcasts = [];
  final List<Podcast> _featuredPodcasts = [];
  final List<PodcastChannel> _topChannels = [];
  final List<Podcast> _playHistory = [];

  Podcast? _currentPodcast;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isFetchingTrending = false;
  bool _isFetchingFeatured = false;
  bool _isFetchingChannels = false;

  double _currentPosition = 0;
  double _totalDuration = 0;
  String? _audioError;

  // Subscription for position updates
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;

  // Getters
  List<Podcast> get trendingPodcasts => [..._trendingPodcasts];
  List<Podcast> get featuredPodcasts => [..._featuredPodcasts];
  List<PodcastChannel> get topChannels => [..._topChannels];
  List<Podcast> get playHistory => [..._playHistory];

  // Mock user's created podcasts
  List<Podcast> get userPodcasts => _getMockUserPodcasts();

  Podcast? get currentPodcast => _currentPodcast;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  bool get isFetchingTrending => _isFetchingTrending;
  bool get isFetchingFeatured => _isFetchingFeatured;
  bool get isFetchingChannels => _isFetchingChannels;
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

  /// Initialize with mock data
  Future<void> _initializeMockData() async {
    _isFetchingTrending = true;
    _isFetchingFeatured = true;
    _isFetchingChannels = true;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      _trendingPodcasts.addAll(_getMockTrendingPodcasts());
      _featuredPodcasts.addAll(_getMockFeaturedPodcasts());
      _topChannels.addAll(_getMockTopChannels());

      notifyListeners();
    } catch (e) {
      developer.log('Error initializing podcast data: $e');
    } finally {
      _isFetchingTrending = false;
      _isFetchingFeatured = false;
      _isFetchingChannels = false;
      notifyListeners();
    }
  }

  /// Play a podcast
  Future<void> playPodcast(Podcast podcast) async {
    try {
      _isLoading = true;
      _audioError = null;
      _currentPodcast = podcast;
      notifyListeners();

      developer.log('Starting to load audio from: ${podcast.audioUrl}');

      // Load the audio file from the URL
      await _audioPlayer.setUrl(podcast.audioUrl);

      developer.log('Audio loaded successfully, starting playback');

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

  /// Refresh trending podcasts (simulates API call)
  Future<void> refreshTrendingPodcasts() async {
    _isFetchingTrending = true;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      _trendingPodcasts.clear();
      _trendingPodcasts.addAll(_getMockTrendingPodcasts());
      notifyListeners();
    } catch (e) {
      developer.log('Error refreshing trending podcasts: $e');
    } finally {
      _isFetchingTrending = false;
      notifyListeners();
    }
  }

  /// Refresh featured podcasts (simulates API call)
  Future<void> refreshFeaturedPodcasts() async {
    _isFetchingFeatured = true;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      _featuredPodcasts.clear();
      _featuredPodcasts.addAll(_getMockFeaturedPodcasts());
      notifyListeners();
    } catch (e) {
      developer.log('Error refreshing featured podcasts: $e');
    } finally {
      _isFetchingFeatured = false;
      notifyListeners();
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([refreshTrendingPodcasts(), refreshFeaturedPodcasts()]);
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

  /// Mock data generators
  List<Podcast> _getMockTrendingPodcasts() {
    const String sampleAudioUrl =
        'asset:///assets/sample-type-rap-beat-lucky-night-193659.mp3';
    return [
      Podcast(
        id: '1',
        title: 'The Future of AI in 2025',
        channelName: 'Tech Talks',
        description:
            'Exploring the latest developments in artificial intelligence and machine learning. Join us as we discuss the future of AI technology.',
        imageUrl: 'https://via.placeholder.com/150?text=AI+2025',
        audioUrl: sampleAudioUrl,
        duration: 2723, // 45:23
        listenerCount: 234000,
        publishedDate: DateTime.now().subtract(const Duration(days: 2)),
        rating: 4.8,
      ),
      Podcast(
        id: '2',
        title: 'Building Mental Resilience',
        channelName: 'Mind Matters',
        description:
            'Strategies for developing mental toughness and emotional resilience in today\'s challenging world.',
        imageUrl: 'https://via.placeholder.com/150?text=Mental',
        audioUrl: sampleAudioUrl,
        duration: 2295, // 38:15
        listenerCount: 189000,
        publishedDate: DateTime.now().subtract(const Duration(days: 3)),
        rating: 4.6,
      ),
      Podcast(
        id: '3',
        title: 'Startup Stories: Zero to Hero',
        channelName: 'Founders',
        description:
            'Real stories from founders who built successful startups from scratch. Hear their journey, challenges, and lessons learned.',
        imageUrl: 'https://via.placeholder.com/150?text=Startup',
        audioUrl: sampleAudioUrl,
        duration: 3160, // 52:40
        listenerCount: 167000,
        publishedDate: DateTime.now().subtract(const Duration(days: 1)),
        rating: 4.9,
      ),
      Podcast(
        id: '4',
        title: 'Crypto Revolution 2025',
        channelName: 'Web3 Daily',
        description:
            'Breaking news and analysis on blockchain technology, cryptocurrencies, and decentralized finance.',
        imageUrl: 'https://via.placeholder.com/150?text=Crypto',
        audioUrl: sampleAudioUrl,
        duration: 1758, // 29:18
        listenerCount: 145000,
        publishedDate: DateTime.now().subtract(const Duration(days: 4)),
        rating: 4.5,
      ),
    ];
  }

  List<Podcast> _getMockFeaturedPodcasts() {
    const String sampleAudioUrl =
        'asset:///assets/sample-type-rap-beat-lucky-night-193659.mp3';

    return [
      Podcast(
        id: '5',
        title: 'The AI Revolution Podcast',
        channelName: 'Tech Talks Daily',
        description:
            'Exploring the future of artificial intelligence and its impact on humanity. Subscribe for weekly episodes.',
        imageUrl: 'https://via.placeholder.com/300?text=AI+Revolution',
        audioUrl: sampleAudioUrl,
        duration: 3600,
        listenerCount: 1200000,
        publishedDate: DateTime.now(),
        rating: 4.9,
      ),
    ];
  }

  List<PodcastChannel> _getMockTopChannels() {
    return [
      PodcastChannel(
        id: 'ch1',
        name: 'Tech Talks',
        description: 'Technology and innovation discussions',
        iconUrl: 'https://via.placeholder.com/80?text=TT',
        episodeCount: 124,
        category: 'Technology',
      ),
      PodcastChannel(
        id: 'ch2',
        name: 'Mind Matters',
        description: 'Mental health and wellness topics',
        iconUrl: 'https://via.placeholder.com/80?text=MM',
        episodeCount: 89,
        category: 'Wellness',
      ),
      PodcastChannel(
        id: 'ch3',
        name: 'Founders',
        description: 'Startup and entrepreneurship stories',
        iconUrl: 'https://via.placeholder.com/80?text=FD',
        episodeCount: 156,
        category: 'Business',
      ),
      PodcastChannel(
        id: 'ch4',
        name: 'Web3 Daily',
        description: 'Blockchain and crypto news',
        iconUrl: 'https://via.placeholder.com/80?text=W3',
        episodeCount: 203,
        category: 'Technology',
      ),
    ];
  }

  List<Podcast> _getMockUserPodcasts() {
    const String sampleAudioUrl =
        'asset:///assets/sample-type-rap-beat-lucky-night-193659.mp3';
    return [
      Podcast(
        id: 'user1',
        title: 'My Tech Insights',
        channelName: 'My Channel',
        description:
            'Weekly episodes about technology trends, coding tips, and digital innovation.',
        imageUrl: 'https://via.placeholder.com/150?text=Tech+Insights',
        audioUrl: sampleAudioUrl,
        duration: 2345, // 39:05
        listenerCount: 12500,
        publishedDate: DateTime.now().subtract(const Duration(days: 5)),
        rating: 4.7,
      ),
      Podcast(
        id: 'user2',
        title: 'Learning Daily',
        channelName: 'My Channel',
        description:
            'Short daily episodes focused on personal growth and professional development.',
        imageUrl: 'https://via.placeholder.com/150?text=Learning',
        audioUrl: sampleAudioUrl,
        duration: 1560, // 26:00
        listenerCount: 8300,
        publishedDate: DateTime.now().subtract(const Duration(days: 3)),
        rating: 4.5,
      ),
      Podcast(
        id: 'user3',
        title: 'Creative Stories',
        channelName: 'My Channel',
        description:
            'Original fiction and storytelling from a creative perspective.',
        imageUrl: 'https://via.placeholder.com/150?text=Stories',
        audioUrl: sampleAudioUrl,
        duration: 3020, // 50:20
        listenerCount: 15600,
        publishedDate: DateTime.now().subtract(const Duration(days: 7)),
        rating: 4.8,
      ),
    ];
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
