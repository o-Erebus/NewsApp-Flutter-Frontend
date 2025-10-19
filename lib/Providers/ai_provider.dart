import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../constants/constants.dart';
import '../utils/request_handler.dart';
import '../utils/uri_utils.dart';

/// Provider that manages AI-powered article summaries.
///
/// It caches summaries per article, tracks loading state for each article,
/// and keeps whether the summary view is currently active so UI widgets can
/// toggle between the summary and the full article text without re-fetching.
class AiProvider with ChangeNotifier {
  final RequestHandler _requestHandler = RequestHandler();

  final Map<String, String> _summaries = {};
  final Set<String> _loadingArticles = {};
  final Map<String, bool> _summaryVisibility = {};

  /// Returns the cached summary for the given [articleId], if available.
  String? summaryFor(String articleId) => _summaries[articleId];

  /// Indicates whether the summary is currently being generated for [articleId].
  bool isGenerating(String articleId) => _loadingArticles.contains(articleId);

  /// Whether the summary should be shown instead of the full article text.
  bool isSummaryVisible(String articleId) =>
      _summaryVisibility[articleId] ?? false;

  /// Request an AI summary for the given [articleId].
  ///
  /// The summary is cached and the loader is displayed for at least two seconds
  /// to preserve the existing UX. On success, the summary view becomes active.
  Future<void> generateSummary(String articleId) async {
    if (_loadingArticles.contains(articleId)) {
      return;
    }

    _loadingArticles.add(articleId);
    // Reset visibility while we fetch a fresh summary.
    _summaryVisibility[articleId] = false;
    notifyListeners();

    try {
      final uri = UriUtils.buildUri('${Constants.articlesEndpoint}summarize');
      final requestFuture = _requestHandler.post(
        uri.toString(),
        body: {'article_id': articleId},
      );

      final responses = await Future.wait([
        requestFuture,
        Future.delayed(const Duration(seconds: 2)),
      ]);
      final resp = responses[0];

      if (resp != null && resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final summary = data['summary'] as String?;
        _summaries[articleId] = summary ?? 'No summary available.';
        _summaryVisibility[articleId] = true;
      } else if (resp != null) {
        _summaries[articleId] =
            'Failed to generate summary (code ${resp.statusCode}).';
        _summaryVisibility[articleId] = false;
      } else {
        _summaries[articleId] = 'Failed to generate summary.';
        _summaryVisibility[articleId] = false;
      }
    } catch (e) {
      _summaries[articleId] = 'Error generating summary: $e';
      _summaryVisibility[articleId] = false;
    } finally {
      _loadingArticles.remove(articleId);
      notifyListeners();
    }
  }

  /// Toggle between summary view and original article for [articleId].
  void toggleSummaryVisibility(String articleId) {
    if (!_summaries.containsKey(articleId)) {
      return;
    }
    final current = _summaryVisibility[articleId] ?? false;
    _summaryVisibility[articleId] = !current;
    notifyListeners();
  }

  /// Ensure the original article text is shown (no summary overlay).
  void showOriginal(String articleId) {
    if (_summaryVisibility[articleId] == true) {
      _summaryVisibility[articleId] = false;
      notifyListeners();
    }
  }

  /// Clears the cached summary and state for a particular article.
  void clearSummary(String articleId) {
    _summaries.remove(articleId);
    _loadingArticles.remove(articleId);
    _summaryVisibility.remove(articleId);
    notifyListeners();
  }

  /// Clears all cached summaries and state.
  void clearAll() {
    _summaries.clear();
    _loadingArticles.clear();
    _summaryVisibility.clear();
    notifyListeners();
  }
}
