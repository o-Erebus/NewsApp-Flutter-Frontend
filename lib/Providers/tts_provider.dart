import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;
import 'dart:developer' as developer;

class TTSProvider with ChangeNotifier {
  late FlutterTts _flutterTts;
  bool _isPlaying = false;
  String? _errorMessage;

  // --- REFINED STATE FOR ACCURATE PAUSE/RESUME ---
  bool _isPaused = false;
  String _originalText = "";
  int _pausePosition = 0;
  int _currentUtteranceStartPosition = 0;

  // --- CHUNKING STATE ---
  List<String> _textChunks = [];
  int _currentChunkIndex = 0;
  bool _isProcessingChunks = false;
  final String _chunkSeparator = '\n\n';

  // --- VOICE AND SPEED CONFIGURATION ---
  List<dynamic> _availableVoices = [];
  int _currentVoiceIndex = 0;
  final List<double> speedOptions = [0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0];
  final List<double> uiSpeedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  int _currentSpeedIndex = 2;
  double get _speed => speedOptions[_currentSpeedIndex];

  // --- GETTERS ---
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  String? get errorMessage => _errorMessage;
  double get currentUiSpeed => uiSpeedOptions[_currentSpeedIndex];
  List<dynamic> get availableVoices => _availableVoices;
  int get currentVoiceIndex => _currentVoiceIndex;
  int get currentChunkForDisplay =>
      _isProcessingChunks ? _currentChunkIndex + 1 : 0;
  int get totalChunks => _textChunks.length;

  TTSProvider() {
    developer.log("TTSProvider: Constructor called");
    _initTts();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    if (Platform.isAndroid) {
      // This is crucial for the new await-based loop to work.
      await _flutterTts.awaitSpeakCompletion(true);
    }

    try {
      await _setVoice();
      await _flutterTts.setSpeechRate(_speed);

      // Handlers are now much simpler.
      _flutterTts.setStartHandler(() {
        developer.log('TTS Start Handler Fired');
        // We manage _isPlaying state manually now, so this is just for logging.
      });

      // The completion handler is no longer used for chaining chunks.
      _flutterTts.setCompletionHandler(() {
        developer.log('TTS Completion Handler Fired (for single utterance)');
      });

      _flutterTts.setErrorHandler((msg) {
        developer.log('TTS Error: $msg');
        _errorMessage = msg;
        _completePlayback(isError: true);
      });

      if (Platform.isAndroid) {
        _flutterTts.setProgressHandler((
          String text,
          int startOffset,
          int endOffset,
          String word,
        ) {
          if (_isPlaying && !_isPaused) {
            _pausePosition = _currentUtteranceStartPosition + startOffset;
          }
        });
      }
    } catch (e) {
      _errorMessage = "Failed to initialize TTS: $e";
      developer.log("TTS initialization error: $e");
    }
  }

  Future<void> togglePlayPause(String text) async {
    if (_originalText != text) {
      await reset();
      _originalText = text;
      _pausePosition = 0;
      if (_shouldUseChunking(_originalText)) {
        _textChunks = _splitTextIntoChunks(_originalText);
      }
    }

    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Kicks off the playback process.
  Future<void> play() async {
    if (_originalText.trim().isEmpty || _isPlaying) {
      return;
    }

    _isPlaying = true;
    _isPaused = false;
    notifyListeners();

    // Start the appropriate playback loop.
    if (_shouldUseChunking(_originalText)) {
      _isProcessingChunks = true;
      _playbackLoop(); // This is a fire-and-forget call
    } else {
      _isProcessingChunks = false;
      _speakNonChunked(); // Fire-and-forget
    }
  }

  /// The new robust playback loop for chunked text.
  Future<void> _playbackLoop() async {
    // Determine starting point
    _currentChunkIndex = _calculateChunkIndexFromPosition(_pausePosition);

    for (int i = _currentChunkIndex; i < _textChunks.length; i++) {
      // If pause() or stop() was called, _isPlaying will be false.
      if (!_isPlaying) {
        developer.log("Playback loop interrupted.");
        return;
      }

      _currentChunkIndex = i;
      notifyListeners(); // Update UI with the current chunk index

      _currentUtteranceStartPosition = _getUtteranceStartPosition();
      String textToSpeak = _textChunks[i];

      // If this is the first chunk in the loop (the one we're resuming)
      // we may need to speak only a part of it.
      if (i == _calculateChunkIndexFromPosition(_pausePosition)) {
        int offsetInChunk =
            _pausePosition - (_currentUtteranceStartPosition * 1.1).toInt();
        if (offsetInChunk > 0 && offsetInChunk < textToSpeak.length) {
          textToSpeak = textToSpeak.substring(offsetInChunk);
        }
      }

      if (textToSpeak.trim().isNotEmpty) {
        developer.log('Speaking chunk ${i + 1}/$totalChunks');
        // awaitSpeakCompletion(true) makes this a blocking call that waits
        // until the speech is finished before continuing the loop.
        await _flutterTts.speak(textToSpeak);
      }
    }

    // If the loop completes without being interrupted, it means playback finished.
    if (_isPlaying) {
      _completePlayback();
    }
  }

  /// Handles speaking non-chunked text.
  Future<void> _speakNonChunked() async {
    _currentUtteranceStartPosition = _pausePosition;
    final remainingText = _originalText.substring(_pausePosition);

    if (remainingText.isNotEmpty) {
      await _flutterTts.speak(remainingText);
    }

    if (_isPlaying) {
      _completePlayback();
    }
  }

  Future<void> pause() async {
    if (!_isPlaying) return;
    // Set isPlaying to false first to break the playback loop.
    _isPlaying = false;
    _isPaused = true;
    // Then, stop the current utterance.
    await _flutterTts.stop();
    developer.log('Paused at position: $_pausePosition');
    notifyListeners();
  }

  Future<void> stop() async {
    await reset();
  }

  void _completePlayback({bool isError = false}) {
    _isPlaying = false;
    _isPaused = false;
    _isProcessingChunks = false;
    _pausePosition = 0;
    _currentChunkIndex = 0;
    _currentUtteranceStartPosition = 0;
    if (isError) {
      _originalText = "";
      _textChunks = [];
    }
    notifyListeners();
  }

  Future<void> reset() async {
    _isPlaying = false; // This will stop any active playback loop.
    _isPaused = false;
    await _flutterTts.stop();
    _originalText = "";
    _textChunks = [];
    _currentChunkIndex = 0;
    _isProcessingChunks = false;
    _pausePosition = 0;
    _currentUtteranceStartPosition = 0;
    _errorMessage = null;
    notifyListeners();
  }

  // --- HELPER METHODS (Unchanged) ---
  int _getUtteranceStartPosition() {
    if (!_isProcessingChunks || _textChunks.isEmpty) return 0;
    int position = 0;
    for (int i = 0; i < _currentChunkIndex; i++) {
      position += _textChunks[i].length + _chunkSeparator.length;
    }
    return position;
  }

  int _calculateChunkIndexFromPosition(int position) {
    if (_textChunks.isEmpty || position <= 0) return 0;
    int cumulativeLength = 0;
    for (int i = 0; i < _textChunks.length; i++) {
      cumulativeLength += _textChunks[i].length + _chunkSeparator.length;
      if (position < cumulativeLength) {
        return i;
      }
    }
    return _textChunks.length - 1;
  }

  bool _shouldUseChunking(String text) {
    return text.length > 200;
  }

  List<String> _splitTextIntoChunks(String text) {
    return text
        .split(_chunkSeparator)
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  // --- VOICE AND SPEED METHODS (Unchanged) ---
  Future<void> toggleVoice() async {
    if (_availableVoices.isNotEmpty) {
      _currentVoiceIndex = (_currentVoiceIndex + 1) % _availableVoices.length;
      await _setSpecificVoice();
      notifyListeners();
    }
  }

  Future<void> changeSpeed() async {
    _currentSpeedIndex = (_currentSpeedIndex + 1) % speedOptions.length;
    await _flutterTts.setSpeechRate(_speed);
    notifyListeners();
  }

  Future<void> _setSpecificVoice() async {
    if (_availableVoices.isNotEmpty &&
        _currentVoiceIndex < _availableVoices.length) {
      var voice = _availableVoices[_currentVoiceIndex];
      try {
        await _flutterTts.setVoice({
          "name": voice['name'],
          "locale": voice['locale'],
        });
      } catch (e) {
        developer.log("Error setting voice: $e");
      }
    }
  }

  Future<void> _setVoice() async {
    try {
      // Get available voices
      List<dynamic> voices = await _flutterTts.getVoices;
      developer.log("All available voices: $voices");
      voices.forEach(print);
      List<dynamic> engines = await _flutterTts.getEngines;
      developer.log("Available Engines: $engines");
      engines.forEach(print);
      if (voices != null && voices.isNotEmpty) {
        // Filter voices for en-IN and en-US locales with high quality
        // Be more permissive with the filtering - if no voices match our strict criteria, use all voices
        List<dynamic> filteredVoices = voices.where((voice) {
          String locale = voice['locale'] as String? ?? '';
          // Check if locale is en-IN or en-US (or include all if no specific locales found)
          return locale == 'en-US' ||
              locale == 'en-EU' ||
              locale == 'en-UK' ||
              locale == 'en-GB' ||
              locale == 'en-IN' ||
              locale == 'en-AU';
        }).toList();

        developer.log("Filtered voices (en-IN/en-US): $filteredVoices");

        // If no filtered voices found, use all voices
        if (filteredVoices.isEmpty) {
          developer.log("No filtered voices found, using all voices");
          filteredVoices = voices;
        }

        // Separate network-required voices and local voices
        // Be more permissive - include voices even if they might not be installed
        List<dynamic> networkVoices = filteredVoices.where((voice) {
          // Safely convert network_required to int
          int networkRequired = 0;
          var networkRequiredValue = voice['network_required'];
          if (networkRequiredValue is int) {
            networkRequired = networkRequiredValue;
          } else if (networkRequiredValue is String) {
            networkRequired = int.tryParse(networkRequiredValue) ?? 0;
          }
          return networkRequired == 1;
        }).toList();

        List<dynamic> localVoices = filteredVoices.where((voice) {
          // Safely convert network_required to int
          int networkRequired = 0;
          var networkRequiredValue = voice['network_required'];
          if (networkRequiredValue is int) {
            networkRequired = networkRequiredValue;
          } else if (networkRequiredValue is String) {
            networkRequired = int.tryParse(networkRequiredValue) ?? 0;
          }
          return networkRequired == 0;
        }).toList();

        developer.log("Network voices: $networkVoices");
        developer.log("Local voices: $localVoices");

        // Prefer network voices first, then local voices
        List<dynamic> preferredVoices = [...networkVoices, ...localVoices];

        // If no preferred voices found, use all filtered voices
        if (preferredVoices.isEmpty) {
          developer.log("No preferred voices found, using all filtered voices");
          preferredVoices = filteredVoices;
        }

        developer.log("Preferred voices: $preferredVoices");

        // Update available voices list
        _availableVoices = preferredVoices;
        _currentVoiceIndex = 0;

        developer.log("Available voices count: ${_availableVoices.length}");

        // Select the current voice
        await _setSpecificVoice();
      } else {
        developer.log("No voices available");
        // Even if no voices from getVoices, initialize with empty list
        _availableVoices = [];
        _currentVoiceIndex = 0;
      }
    } catch (e) {
      _errorMessage = "Error setting voice: $e";
      developer.log("Error setting voice: $e");
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
