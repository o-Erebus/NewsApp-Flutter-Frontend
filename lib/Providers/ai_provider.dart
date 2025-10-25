import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../constants/constants.dart';
import '../utils/request_handler.dart';
import '../utils/uri_utils.dart';

/// Provider that manages AI-powered article analysis.
///
/// It caches analysis results (summary, political bias, emotional analysis) per article,
/// tracks loading state for each article, and keeps whether the analysis view is
/// currently active so UI widgets can toggle between analysis and full article text
/// without re-fetching.
class AiProvider with ChangeNotifier {
  final RequestHandler _requestHandler = RequestHandler();

  // Caches for different analysis components
  final Map<String, Map<String, dynamic>> _analysis = {};
  final Set<String> _loadingArticles = {};
  final Map<String, bool> _analysisVisibility = {};

  /// Returns the cached analysis for the given [articleId], if available.
  Map<String, dynamic>? analysisFor(String articleId) => _analysis[articleId];

  /// Returns the cached summary for the given [articleId], if available.
  String? summaryFor(String articleId) =>
      _analysis[articleId]?['summary'] as String?;

  /// Returns the emotional analysis for the given [articleId], if available.
  Map<String, dynamic>? emotionalAnalysisFor(String articleId) =>
      _analysis[articleId]?['emotionalAnalysis'] as Map<String, dynamic>?;

  // --- Convenience accessors for emotionalAnalysis ---
  String? primaryEmotion(String articleId) =>
      emotionalAnalysisFor(articleId)?['primaryEmotion'] as String?;

  String? secondaryEmotion(String articleId) =>
      emotionalAnalysisFor(articleId)?['secondaryEmotion'] as String?;

  List<String>? indicativeQuotes(String articleId) {
    final quotes = emotionalAnalysisFor(
      articleId,
    )?['justification']?['indicativeQuotes'];
    if (quotes is List) return quotes.map((e) => e.toString()).toList();
    return null;
  }

  String? overallTone(String articleId) =>
      emotionalAnalysisFor(articleId)?['justification']?['overallTone']
          as String?;

  // --- Convenience accessors for politicalBias ---
  Map<String, dynamic>? politicalBiasFor(String articleId) =>
      _analysis[articleId]?['politicalBias'] as Map<String, dynamic>?;

  String? biasClassification(String articleId) =>
      politicalBiasFor(articleId)?['classification'] as String?;

  List<String>? loadedLanguage(String articleId) {
    final list = politicalBiasFor(
      articleId,
    )?['justification']?['loadedLanguage'];
    if (list is List) return list.map((e) => e.toString()).toList();
    return null;
  }

  List<String>? framingAndHeadline(String articleId) {
    final list = politicalBiasFor(
      articleId,
    )?['justification']?['framingAndHeadline'];
    if (list is List) return list.map((e) => e.toString()).toList();
    return null;
  }

  List<String>? sourceAndStorySelection(String articleId) {
    final list = politicalBiasFor(
      articleId,
    )?['justification']?['sourceAndStorySelection'];
    if (list is List) return list.map((e) => e.toString()).toList();
    return null;
  }

  /// Indicates whether the analysis is currently being generated for [articleId].
  bool isGenerating(String articleId) => _loadingArticles.contains(articleId);

  /// Whether the analysis should be shown instead of the full article text.
  bool isAnalysisVisible(String articleId) =>
      _analysisVisibility[articleId] ?? false;

  /// Request comprehensive AI analysis for the given [articleId].
  ///
  /// Performs:
  /// 1. High-fidelity summary (1-2 paragraphs)
  /// 2. Political bias detection (5-point scale)
  /// 3. Emotional analysis (primary and secondary emotions)
  ///
  /// The analysis is cached and the loader is displayed for at least two seconds
  /// to preserve the existing UX. On success, the analysis view becomes active.
  Future<void> generateAnalysis(String articleId) async {
    if (_loadingArticles.contains(articleId)) {
      return;
    }

    _loadingArticles.add(articleId);
    // Reset visibility while we fetch a fresh analysis.
    _analysisVisibility[articleId] = false;
    notifyListeners();

    try {
      final uri = UriUtils.buildUri(Constants.aiAnalyzeEndpoint);
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

        // Extract the analysis from the response
        // Backend returns: summary, politicalBias, emotionalAnalysis
        final analysis = {
          'summary': data['summary'] as String?,
          'politicalBias': data['politicalBias'] as Map<String, dynamic>?,
          'emotionalAnalysis':
              data['emotionalAnalysis'] as Map<String, dynamic>?,
        };

        _analysis[articleId] = analysis;
        _analysisVisibility[articleId] = true;
      } else if (resp != null) {
        _analysis[articleId] = {
          'error': 'Failed to generate analysis (code ${resp.statusCode}).',
        };
        _analysisVisibility[articleId] = false;
      } else {
        _analysis[articleId] = {'error': 'Failed to generate analysis.'};
        _analysisVisibility[articleId] = false;
      }
    } catch (e) {
      _analysis[articleId] = {'error': 'Error generating analysis: $e'};
      _analysisVisibility[articleId] = false;
    } finally {
      _loadingArticles.remove(articleId);
      notifyListeners();
    }
  }

  /// Legacy method for backward compatibility - calls generateAnalysis
  @Deprecated('Use generateAnalysis instead')
  Future<void> generateSummary(String articleId) async {
    return generateAnalysis(articleId);
  }

  /// Toggle between analysis view and original article for [articleId].
  void toggleAnalysisVisibility(String articleId) {
    if (!_analysis.containsKey(articleId)) {
      return;
    }
    final current = _analysisVisibility[articleId] ?? false;
    _analysisVisibility[articleId] = !current;
    notifyListeners();
  }

  /// Legacy method for backward compatibility
  @Deprecated('Use toggleAnalysisVisibility instead')
  void toggleSummaryVisibility(String articleId) {
    return toggleAnalysisVisibility(articleId);
  }

  /// Ensure the original article text is shown (no analysis overlay).
  void showOriginal(String articleId) {
    if (_analysisVisibility[articleId] == true) {
      _analysisVisibility[articleId] = false;
      notifyListeners();
    }
  }

  /// Clears the cached analysis and state for a particular article.
  void clearAnalysis(String articleId) {
    _analysis.remove(articleId);
    _loadingArticles.remove(articleId);
    _analysisVisibility.remove(articleId);
    notifyListeners();
  }

  /// Legacy method for backward compatibility
  @Deprecated('Use clearAnalysis instead')
  void clearSummary(String articleId) {
    return clearAnalysis(articleId);
  }

  /// Clears all cached analysis and state.
  void clearAll() {
    _analysis.clear();
    _loadingArticles.clear();
    _analysisVisibility.clear();
    notifyListeners();
  }
}
