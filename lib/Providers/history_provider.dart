import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:Nexora/utils/request_handler.dart';
import 'package:Nexora/utils/uri_utils.dart';
import 'package:Nexora/constants/constants.dart';
import '../Models/read_history_model.dart';

class HistoryProvider with ChangeNotifier {
  final RequestHandler _requestHandler = RequestHandler();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<ReadHistoryEntry> _readHistory = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 20;
  String? _error;

  // Getters
  List<ReadHistoryEntry> get readHistory => [..._readHistory];
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  /// Record that the user has read an article
  Future<bool> recordArticleRead({
    required String articleId,
    required String articleTitle,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        notifyListeners();
        return false;
      }

      // Get Firebase token
      final idToken = await user.getIdToken();

      // Validate articleId looks like a MongoDB ObjectId (24 hex chars)
      final objectIdRegex = RegExp(r'^[0-9a-fA-F]{24}$');
      if (!objectIdRegex.hasMatch(articleId)) {
        developer.log(
          'Skipping history POST: articleId is not a 24-hex ObjectId: $articleId',
        );
        return false;
      }

      final uri = UriUtils.buildUri(Constants.userHistoryEndpoint);

      final Map<String, dynamic> body = {
        'article_id': articleId,
        'article_title': articleTitle,
      };

      final response = await _requestHandler.post(
        uri.toString(),
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        developer.log('Article read recorded successfully: $articleId');
        return true;
      } else {
        _error = 'Failed to record article read: ${response.statusCode}';
        try {
          developer.log('Response body: ${response.body}');
        } catch (_) {}
        developer.log(_error!);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error recording article read: $e';
      developer.log(_error!);
      notifyListeners();
      return false;
    }
  }

  /// Fetch user's read history with pagination
  Future<void> fetchReadHistory({bool refresh = false}) async {
    if (_isLoading) return;

    // Reset pagination if refreshing
    if (refresh) {
      _currentPage = 1;
      _readHistory.clear();
      _hasMore = true;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        notifyListeners();
        return;
      }

      // Get Firebase token
      final idToken = await user.getIdToken();

      _isLoading = true;
      _error = null;
      notifyListeners();

      final uri = UriUtils.buildUri(Constants.userHistoryEndpoint, {
        'page': _currentPage.toString(),
        'limit': _pageSize.toString(),
      });

      final response = await _requestHandler.get(
        uri.toString(),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> historyList = data['data'];
          final entries = historyList
              .map((json) => ReadHistoryEntry.fromJson(json))
              .toList();

          _readHistory.addAll(entries);

          // Check pagination
          final pagination = data['pagination'];
          if (pagination != null) {
            _hasMore = pagination['page'] < pagination['pages'];
          } else {
            _hasMore = entries.length >= _pageSize;
          }

          _currentPage++;
          developer.log('Fetched ${entries.length} history entries');
        } else {
          _error = data['message'] ?? 'Failed to fetch history';
        }
      } else if (response.statusCode == 401) {
        _error = 'Unauthorized. Please login again.';
      } else {
        _error = 'Server error: ${response.statusCode}';
        developer.log('Error response: ${response.body}');
      }
    } on SocketException catch (e) {
      _error = 'Network error: ${e.message}';
      developer.log(_error!);
    } catch (e) {
      _error = 'Error fetching history: $e';
      developer.log(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear read history
  void clearHistory() {
    _readHistory.clear();
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }

  /// Refresh history (reset and fetch first page)
  Future<void> refreshHistory() async {
    clearHistory();
    await fetchReadHistory(refresh: true);
  }
}
