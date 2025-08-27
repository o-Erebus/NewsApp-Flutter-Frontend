import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class TTSProvider with ChangeNotifier {
  late FlutterTts _flutterTts;
  bool _isPlaying = false;
  bool _isMaleVoice = true;
  List<dynamic> _availableVoices = [];
  int _currentVoiceIndex = 0;
  double _speed = 0.75;
  String? _currentText;
  String? _errorMessage;

  // Pause/Resume state variables
  // --- MODIFIED: State variables for robust Pause/Resume ---
  bool _isPaused = false;
  // Tracks total characters spoken from the original text across multiple pause/resume cycles
  int _totalSpokenLength = 0;
  // Tracks the start of the current word within the CURRENT utterance being spoken
  int _currentUtteranceWordStart = 0;
  int _pausePosition = 0; // For Android pause position tracking
  bool _isAndroid = Platform.isAndroid; // Platform detection

  final List<double> speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  int _currentSpeedIndex = 1; // Index of 0.75 speed

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isMaleVoice => _isMaleVoice;
  double get speed => _speed;
  int get currentSpeedIndex => _currentSpeedIndex;
  String? get errorMessage => _errorMessage;
  bool get isPaused => _isPaused;
  int get pausePosition => _pausePosition;
  bool get isAndroid => _isAndroid;
  List<dynamic> get availableVoices => _availableVoices;
  int get currentVoiceIndex => _currentVoiceIndex;

  // Text chunking variables
  List<String> _textChunks = [];
  int _currentChunkIndex = 0;
  bool _isProcessingChunks = false;

  // Text chunking getters
  int get currentChunkIndex => _currentChunkIndex;
  int get totalChunks => _textChunks.length;
  bool get isProcessingChunks => _isProcessingChunks;

  TTSProvider() {
    print("TTSProvider: Constructor called");
    _initTts();
    print("TTS Provider initialized");
  }

  _initTts() async {
    _flutterTts = FlutterTts();
    if (_isAndroid) {
      await _flutterTts.awaitSpeakCompletion(true);
    }
    try {
      await _setVoice();
      print(
        "Voice setting completed, available voices: ${_availableVoices.length}",
      );
      await _flutterTts.setSpeechRate(_speed);

      // --- Set up listeners ---
      _flutterTts.setStartHandler(() {
        print('TTSProvider: TTS started');
        _isPlaying = true;
        _isPaused = false;
        _errorMessage = null;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        print('TTSProvider: TTS completed');
        if (!_isProcessingChunks) {
          _isPlaying = false;
          _isPaused = false;
          // MODIFIED: Reset position on completion
          _totalSpokenLength = 0;
          _currentUtteranceWordStart = 0;
          notifyListeners();
        }
      });

      _flutterTts.setErrorHandler((msg) {
        print('TTSProvider: TTS error: $msg');
        if (!_isProcessingChunks) {
          _isPlaying = false;
          _isPaused = false;
          _errorMessage = msg;
          // MODIFIED: Reset position on error
          _totalSpokenLength = 0;
          _currentUtteranceWordStart = 0;
          notifyListeners();
          print("TTS Error: $msg");
        }
      });

      // --- MODIFIED: Use setProgressHandler for reliable position tracking on Android ---
      if (Platform.isAndroid) {
        _flutterTts.setProgressHandler((
          String text,
          int startOffset,
          int endOffset,
          String word,
        ) {
          // This offset is relative to the text currently being spoken (which could be a substring)
          // We only update when not paused to avoid race conditions on stop.
          if (_isPlaying && !_isPaused) {
            _currentUtteranceWordStart = startOffset;
          }
        });
      }
    } catch (e) {
      _errorMessage = "Failed to initialize TTS: $e";
      print("TTS initialization error: $e");
    }
    print("TTS initialization completed");
  }

  Future<void> _setVoice() async {
    try {
      // Get available voices
      List<dynamic> voices = await _flutterTts.getVoices;
      print("All available voices: $voices");
      voices.forEach(print);
      if (voices != null && voices.isNotEmpty) {
        // Filter voices for en-IN and en-US locales with high quality
        // Be more permissive with the filtering - if no voices match our strict criteria, use all voices
        List<dynamic> filteredVoices = voices.where((voice) {
          String locale = voice['locale'] as String? ?? '';
          // Check if locale is en-IN or en-US (or include all if no specific locales found)
          return locale == 'en-GB' ||
              locale == 'en-IN' ||
              locale == 'en-US' ||
              locale == 'en-EU' ||
              locale == 'en-UK';
        }).toList();

        print("Filtered voices (en-IN/en-US): $filteredVoices");

        // If no filtered voices found, use all voices
        if (filteredVoices.isEmpty) {
          print("No filtered voices found, using all voices");
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

        print("Network voices: $networkVoices");
        print("Local voices: $localVoices");

        // Prefer network voices first, then local voices
        List<dynamic> preferredVoices = [...networkVoices, ...localVoices];

        // If no preferred voices found, use all filtered voices
        if (preferredVoices.isEmpty) {
          print("No preferred voices found, using all filtered voices");
          preferredVoices = filteredVoices;
        }

        print("Preferred voices: $preferredVoices");

        // Update available voices list
        _availableVoices = preferredVoices;
        _currentVoiceIndex = 0;

        print("Available voices count: ${_availableVoices.length}");

        // Select the current voice
        await _setSpecificVoice();
      } else {
        print("No voices available");
        // Even if no voices from getVoices, initialize with empty list
        _availableVoices = [];
        _currentVoiceIndex = 0;
      }
    } catch (e) {
      _errorMessage = "Error setting voice: $e";
      print("Error setting voice: $e");
    }
  }

  Future<void> _setSpecificVoice() async {
    try {
      print(
        "Setting specific voice, available voices count: ${_availableVoices.length}, current index: $_currentVoiceIndex",
      );
      if (_availableVoices.isNotEmpty) {
        // Ensure currentVoiceIndex is within bounds
        if (_currentVoiceIndex >= _availableVoices.length) {
          _currentVoiceIndex = 0;
        }

        // Get the current voice
        var currentVoice = _availableVoices[_currentVoiceIndex];
        String? voiceName = currentVoice['name'] as String?;
        String? voiceLocale = currentVoice['locale'] as String?;

        print("Setting voice - Name: $voiceName, Locale: $voiceLocale");

        // Only set voice if we have a valid voice name and locale
        if (voiceName != null && voiceLocale != null) {
          try {
            await _flutterTts.setVoice({
              "name": voiceName,
              "locale": voiceLocale,
            });
            print("Successfully set voice to $voiceName ($voiceLocale)");
          } catch (setVoiceError) {
            print(
              "Error setting voice to $voiceName ($voiceLocale): $setVoiceError",
            );
          }
        } else {
          print("Failed to set voice - invalid name or locale");
        }
      } else {
        print("No available voices to set");
      }
    } catch (e) {
      _errorMessage = "Error setting specific voice: $e";
      print("Error setting specific voice: $e");
    }
  }

  Future<void> togglePlayPause(String text) async {
    // Check if the text has changed from the current text
    if (_currentText != text) {
      // Reset state for new text
      print('TTSProvider: togglePlayPause - text changed, calling reset()');
      await reset();
      print('TTSProvider: togglePlayPause - reset() completed');
      _currentText = text;
    }

    if (_isPlaying) {
      await pause();
    } else if (_isPaused) {
      await resume();
    } else {
      // start fresh
      if (text.trim().isEmpty) {
        _errorMessage = "Cannot read empty text";
        notifyListeners();
        return;
      }

      _totalSpokenLength = 0;
      _currentUtteranceWordStart = 0;

      if (_shouldUseChunking(text)) {
        await speakWithChunking(text);
      } else {
        await _flutterTts.speak(text);
      }
    }
  }

  Future<void> pause() async {
    print('TTSProvider: pause() called');
    if (!_isPlaying && !_isProcessingChunks) {
      print(
        'TTSProvider: pause() returning early - not playing or processing chunks',
      );
      return;
    }
    try {
      // Save exact pause position BEFORE stop
      if (_currentText != null) {
        _pausePosition = _totalSpokenLength + _currentUtteranceWordStart;
        print('TTSProvider: pause position saved: $_pausePosition');
      }

      print('TTSProvider: Calling _flutterTts.stop() in pause()');
      await _flutterTts.stop();
      print('TTSProvider: _flutterTts.stop() completed in pause()');
      _isPlaying = false;
      _isPaused = true;

      notifyListeners();
      print('TTSProvider: pause() completed');
    } catch (e) {
      _errorMessage = "Error pausing TTS: $e";
      print("Error pausing TTS: $e");
    }
  }

  Future<void> resume() async {
    if (!_isPaused || _currentText == null) return;
    try {
      if (_pausePosition < _currentText!.length) {
        // Check if we were processing chunks before pausing
        if (_isProcessingChunks && _textChunks.isNotEmpty) {
          // For chunked text, we need to resume from the correct chunk
          // Use the currentChunkIndex which should be preserved from when we paused

          // Reset progress tracking for the new utterance
          _currentUtteranceWordStart = 0;
          _totalSpokenLength = _pausePosition;

          // Resume chunked processing from the stored chunk index
          await speakWithChunkingFromIndex(_currentText!, _currentChunkIndex);
        } else {
          // For non-chunked text, use the original resume logic
          final remainingText = _currentText!.substring(_pausePosition);

          // reset progress tracking for the new utterance
          _currentUtteranceWordStart = 0;
          _totalSpokenLength = _pausePosition;

          await _flutterTts.speak(remainingText);
          _isPlaying = true;
          _isPaused = false;
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = "Error resuming TTS: $e";
      print("Error resuming TTS: $e");
    }
  }

  Future<void> stop() async {
    print('TTSProvider: stop() called');
    try {
      print('TTSProvider: Calling _flutterTts.stop()');
      await _flutterTts.stop();
      print('TTSProvider: _flutterTts.stop() completed');
      _isPlaying = false;
      _isPaused = false;
      _isProcessingChunks = false;
      _currentChunkIndex = 0;
      // MODIFIED: Reset new position variables
      _totalSpokenLength = 0;
      _currentUtteranceWordStart = 0;
      notifyListeners();
      print('TTSProvider: stop() completed');
    } catch (e) {
      _errorMessage = "Error stopping TTS: $e";
      print("Error stopping TTS: $e");
    }
  }

  Future<void> toggleVoice() async {
    print(
      "Toggling voice, current available voices count: ${_availableVoices.length}, current index: $_currentVoiceIndex",
    );
    if (_availableVoices.isNotEmpty) {
      _currentVoiceIndex = (_currentVoiceIndex + 1) % _availableVoices.length;
      print("New voice index: $_currentVoiceIndex");
      await _setSpecificVoice();
      notifyListeners();
    } else {
      print("No available voices to toggle");
    }
  }

  Future<void> changeSpeed() async {
    _currentSpeedIndex = (_currentSpeedIndex + 1) % speedOptions.length;
    _speed = speedOptions[_currentSpeedIndex];
    try {
      await _flutterTts.setSpeechRate(_speed);
    } catch (e) {
      _errorMessage = "Error setting speech rate: $e";
      print("Error setting speech rate: $e");
    }
    notifyListeners();
  }

  /// Splits text into chunks based on paragraphs and sentences
  List<String> _splitTextIntoChunks(String text) {
    // First, try to split by paragraphs (double newlines)
    List<String> paragraphs = text.split('\n\n');

    // If we only have one paragraph or none, split by sentences
    if (paragraphs.length <= 1) {
      // Simple sentence splitting (this could be improved with more sophisticated NLP)
      final sentenceRegex = RegExp(r'([.!?]+)'); // Split on sentence endings
      List<String> sentences = [];
      String currentSentence = '';

      text.splitMapJoin(
        sentenceRegex,
        onMatch: (Match match) {
          currentSentence += match[0]!;
          if (currentSentence.trim().isNotEmpty) {
            sentences.add(currentSentence.trim());
          }
          currentSentence = '';
          return '';
        },
        onNonMatch: (String text) {
          currentSentence += text;
          return '';
        },
      );

      // Add any remaining text
      if (currentSentence.trim().isNotEmpty) {
        sentences.add(currentSentence.trim());
      }

      // Group sentences into chunks of reasonable size
      return _groupSentencesIntoChunks(sentences);
    }

    // Filter out empty paragraphs and trim whitespace
    List<String> filteredParagraphs = paragraphs
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return filteredParagraphs;
  }

  /// Groups sentences into chunks of reasonable size
  List<String> _groupSentencesIntoChunks(List<String> sentences) {
    List<String> chunks = [];
    const int maxChunkLength = 1000; // Maximum characters per chunk
    String currentChunk = '';

    for (String sentence in sentences) {
      // If adding this sentence would exceed the max length, start a new chunk
      if (currentChunk.isNotEmpty &&
          (currentChunk.length + sentence.length) > maxChunkLength) {
        chunks.add(currentChunk.trim());
        currentChunk = sentence;
      } else {
        // Otherwise, add the sentence to the current chunk
        if (currentChunk.isNotEmpty) {
          currentChunk += ' ';
        }
        currentChunk += sentence;
      }
    }

    // Add the last chunk if it's not empty
    if (currentChunk.trim().isNotEmpty) {
      chunks.add(currentChunk.trim());
    }

    return chunks;
  }

  /// Speaks text with chunking support
  Future<void> speakWithChunking(String text) async {
    // Reset chunk processing state
    _textChunks = _splitTextIntoChunks(text);
    _currentChunkIndex = 0;
    _isProcessingChunks = true;
    _errorMessage = null;
    notifyListeners();

    // Handle empty text
    if (_textChunks.isEmpty || (text.trim().isEmpty)) {
      _errorMessage = "Cannot read empty text";
      _isProcessingChunks = false;
      notifyListeners();
      return;
    }

    // Process chunks sequentially
    try {
      await _processNextChunk();
    } catch (e) {
      _isPlaying = false;
      _isProcessingChunks = false;
      _errorMessage = "Error in chunked text processing: $e";
      notifyListeners();
      print("Error in chunked text processing: $e");
    }
  }

  /// Speaks text with chunking support from a specific chunk index
  Future<void> speakWithChunkingFromIndex(String text, int startIndex) async {
    // Set up chunk processing state from the specified index
    _textChunks = _splitTextIntoChunks(text);
    _currentChunkIndex = startIndex;
    _isProcessingChunks = true;
    _errorMessage = null;
    notifyListeners();

    // Handle empty text or invalid start index
    if (_textChunks.isEmpty ||
        (text.trim().isEmpty) ||
        startIndex >= _textChunks.length) {
      _errorMessage = "Cannot read empty text or invalid start index";
      _isProcessingChunks = false;
      notifyListeners();
      return;
    }

    // Process chunks sequentially from the specified index
    try {
      await _processNextChunk();
    } catch (e) {
      _isPlaying = false;
      _isProcessingChunks = false;
      _errorMessage = "Error in chunked text processing: $e";
      notifyListeners();
      print("Error in chunked text processing: $e");
    }
  }

  /// Processes the next chunk in the queue
  Future<void> _processNextChunk() async {
    // Check if we've processed all chunks
    if (_currentChunkIndex >= _textChunks.length) {
      _isProcessingChunks = false;
      _isPlaying = false;
      notifyListeners();
      return;
    }

    String currentChunk = _textChunks[_currentChunkIndex];

    // Skip empty chunks
    if (currentChunk.trim().isEmpty) {
      _currentChunkIndex++;
      await _processNextChunk(); // Process next chunk
      return;
    }

    try {
      // Set up completion handler for this chunk
      _flutterTts.setCompletionHandler(() async {
        // Check if we're still processing chunks (not cancelled)
        if (_isProcessingChunks) {
          _currentChunkIndex++;
          notifyListeners();
          await _processNextChunk(); // Process next chunk
        }
      });

      // Set up error handler for this chunk
      _flutterTts.setErrorHandler((msg) async {
        // Check if we're still processing chunks (not cancelled)
        if (_isProcessingChunks) {
          _isPlaying = false;
          _isProcessingChunks = false;
          _errorMessage =
              "Error speaking chunk ${_currentChunkIndex + 1}/${_textChunks.length}: $msg";
          notifyListeners();
          print(
            "TTS Error in chunk ${_currentChunkIndex + 1}/${_textChunks.length}: $msg",
          );
        }
      });

      // Speak the current chunk
      _isPlaying = true;
      notifyListeners();
      await _flutterTts.speak(currentChunk);
    } catch (e) {
      _isPlaying = false;
      _isProcessingChunks = false;
      _errorMessage =
          "Error processing chunk ${_currentChunkIndex + 1}/${_textChunks.length}: $e";
      notifyListeners();
      print(
        "Error processing chunk ${_currentChunkIndex + 1}/${_textChunks.length}: $e",
      );
    }
  }

  /// Gets the progress of chunked text processing as a percentage
  double getChunkProgress() {
    if (_textChunks.isEmpty) return 0.0;
    return (_currentChunkIndex / _textChunks.length) * 100;
  }

  /// Gets the progress of chunked text processing as a formatted string
  String getChunkProgressText() {
    if (_textChunks.isEmpty) return "0/0";
    return "${_currentChunkIndex}/${_textChunks.length}";
  }

  /// Gets the overall progress of text processing (chunked or non-chunked) as a percentage
  double getOverallProgress() {
    if (_isProcessingChunks) {
      return getChunkProgress();
    } else {
      // For non-chunked text, we don't have precise progress tracking
      // Return 100% if playing, 0% otherwise
      return _isPlaying ? 100.0 : 0.0;
    }
  }

  /// Gets the overall progress of text processing as a formatted string
  String getOverallProgressText() {
    if (_isProcessingChunks) {
      return getChunkProgressText();
    } else {
      // For non-chunked text, we don't have precise progress tracking
      // Return simple status
      return _isPlaying ? "Playing" : "Stopped";
    }
  }

  /// Cancels chunked text processing
  Future<void> cancelChunkProcessing() async {
    print('TTSProvider: cancelChunkProcessing() called');
    try {
      print(
        'TTSProvider: Calling _flutterTts.stop() in cancelChunkProcessing()',
      );
      await _flutterTts.stop();
      print(
        'TTSProvider: _flutterTts.stop() completed in cancelChunkProcessing()',
      );
      _isPlaying = false;
      _isPaused = false;
      _isProcessingChunks = false;
      _currentChunkIndex = 0;
      _textChunks = [];
      _pausePosition = 0;
      _errorMessage = null;
      notifyListeners();
      print('TTSProvider: cancelChunkProcessing() completed');
    } catch (e) {
      _errorMessage = "Error cancelling chunk processing: $e";
      print("Error cancelling chunk processing: $e");
      notifyListeners();
    }
  }

  /// Checks if the current text is long enough to require chunking
  bool _shouldUseChunking(String text) {
    return text.length >
        1000; // Use chunking for texts longer than 1000 characters
  }

  /// Calculates which chunk index corresponds to a given character position
  int _calculateChunkIndexFromPosition(int position) {
    if (_textChunks.isEmpty || position < 0) return 0;

    int cumulativeLength = 0;
    for (int i = 0; i < _textChunks.length; i++) {
      cumulativeLength += _textChunks[i].length;
      // Add 1 for the space or separator between chunks
      if (i < _textChunks.length - 1) {
        cumulativeLength += 1; // Assuming space separator
      }

      if (position < cumulativeLength) {
        return i;
      }
    }

    // If position is beyond all chunks, return the last chunk index
    return _textChunks.length - 1;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Resets all TTS state variables
  Future<void> reset() async {
    print('TTSProvider: reset() called');
    _currentText = null;
    _textChunks = [];
    _currentChunkIndex = 0;
    _isProcessingChunks = false;
    _isPlaying = false;
    _isPaused = false;
    _totalSpokenLength = 0;
    _currentUtteranceWordStart = 0;
    _pausePosition = 0;
    _errorMessage = null;
    print('TTSProvider: Calling _flutterTts.stop()');
    try {
      await _flutterTts.stop();
      print('TTSProvider: _flutterTts.stop() completed');
    } catch (e) {
      print('TTSProvider: Error in _flutterTts.stop(): $e');
    }
    notifyListeners();
    print('TTSProvider: reset() completed');
  }

  void dispose() {
    print('TTSProvider: dispose() called');
    _flutterTts.stop();
    print('TTSProvider: _flutterTts.stop() called in dispose()');
    super.dispose();
    print('TTSProvider: dispose() completed');
  }
}
