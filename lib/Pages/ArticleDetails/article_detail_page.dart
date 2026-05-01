import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../Models/news_article.dart';
import '../../Providers/tts_provider.dart';
import '../../Providers/auth_provider.dart';
import '../../Providers/history_provider.dart';
import '../../Providers/ai_provider.dart';
import 'widgets/tts_controls_widget.dart';
import 'widgets/emotional_analysis_modal.dart';
import 'widgets/political_bias_modal.dart';

class ArticleDetailPage extends StatefulWidget {
  final NewsArticle article;

  final bool isCarouselView;

  final bool isGlobalView;

  final bool isHistoryView;

  const ArticleDetailPage({
    super.key,
    required this.article,
    required this.isCarouselView,
    this.isGlobalView = false, // Default to false for backward compatibility
    this.isHistoryView = false, // Default to false for backward compatibility
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late TTSProvider _ttsProvider;

  @override
  void initState() {
    super.initState();
    // Get the TTS provider instance early so we can use it in dispose
    _ttsProvider = Provider.of<TTSProvider>(context, listen: false);

    // Record article read in history
    _recordArticleRead();
  }

  /// Record the article as read in the user's history
  Future<void> _recordArticleRead() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      final historyProvider = context.read<HistoryProvider>();
      await historyProvider.recordArticleRead(
        articleId: widget.article.id,
        articleTitle: widget.article.title,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiProvider = context.watch<AiProvider>();
    final authProvider = context.watch<AuthProvider>();
    final articleId = widget.article.id;
    final isGeneratingAnalysis = aiProvider.isGenerating(articleId);
    final summary = aiProvider.summaryFor(articleId);
    final isAnalysisVisible = aiProvider.isAnalysisVisible(articleId);
    var herotag = '';
    if (widget.isGlobalView) {
      if (widget.isCarouselView) {
        herotag = 'GLOBAL_${widget.article.imageUrl}';
      } else {
        herotag = 'GLOBAL_article_image_${widget.article.id}';
      }
    } else if (widget.isHistoryView) {
      herotag = 'HISTORY_article_image_${widget.article.id}';
    } else {
      if (widget.isCarouselView) {
        herotag = widget.article.imageUrl;
      } else {
        herotag = 'article_image_${widget.article.id}';
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Hero Image Background
          Hero(
            tag: herotag,
            child: CachedNetworkImage(
              imageUrl: widget.article.imageUrl,
              height: 350,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[700]!,
                highlightColor: Colors.grey[500]!,
                child: Container(
                  height: 350,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) {
                return Container(
                  height: 350,
                  color: theme.colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 50,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),

          // Back button (floating on top)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: theme.colorScheme.onPrimary.withOpacity(0.8),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Draggable Card overlapping image slightly at start
          DraggableScrollableSheet(
            initialChildSize: 0.65, // Already overlapping a bit
            minChildSize: 0.65,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Sticky Header (Title and Author/Date)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Article Title
                          Text(
                            widget.article.title,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),

                          // Enhanced Author and Date Section
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: theme.colorScheme.outline.withOpacity(
                                    0.3,
                                  ),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.article.author,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat.yMMMd().format(
                                        widget.article.date,
                                      ),
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                      // Add AI Button
                                    ),

                                    // AI Summarize Button
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Show AI button only for authenticated users
                                authProvider.isAuthenticated
                                    ? ElevatedButton.icon(
                                        onPressed: isGeneratingAnalysis
                                            ? null
                                            : () async {
                                                final ai = context
                                                    .read<AiProvider>();
                                                if (summary == null) {
                                                  await ai.generateAnalysis(
                                                    articleId,
                                                  );
                                                } else {
                                                  // Toggle between showing the analysis and the original article without calling the backend again
                                                  ai.toggleAnalysisVisibility(
                                                    articleId,
                                                  );
                                                }
                                              },
                                        icon: const Icon(
                                          Icons.smart_toy_outlined,
                                          size: 18,
                                        ),
                                        label: Text(
                                          isGeneratingAnalysis
                                              ? 'Thinking...'
                                              : summary == null
                                              ? 'AI'
                                              : isAnalysisVisible
                                              ? 'Deactivate AI'
                                              : 'Activate AI',
                                          style: theme.textTheme.labelSmall,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                isAnalysisVisible
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          top: 12.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  // Show emotional analysis details
                                                  final primary =
                                                      aiProvider.primaryEmotion(
                                                        articleId,
                                                      ) ??
                                                      'Unknown';
                                                  final secondary =
                                                      aiProvider
                                                          .secondaryEmotion(
                                                            articleId,
                                                          ) ??
                                                      'Unknown';
                                                  final quotes =
                                                      aiProvider
                                                          .indicativeQuotes(
                                                            articleId,
                                                          ) ??
                                                      <String>[];
                                                  final overall =
                                                      aiProvider.overallTone(
                                                        articleId,
                                                      ) ??
                                                      '';

                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                    ),
                                                    builder: (ctx) =>
                                                        EmotionalAnalysisModal(
                                                          primary: primary,
                                                          secondary: secondary,
                                                          quotes: quotes,
                                                          overall: overall,
                                                        ),
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 12,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme
                                                        .surfaceContainerHighest,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Emotion',
                                                        style: theme
                                                            .textTheme
                                                            .labelSmall,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        aiProvider
                                                                .primaryEmotion(
                                                                  articleId,
                                                                ) ??
                                                            '—',
                                                        style: theme
                                                            .textTheme
                                                            .bodyLarge,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  // Show political bias details
                                                  final classification =
                                                      aiProvider
                                                          .biasClassification(
                                                            articleId,
                                                          ) ??
                                                      'Unknown';
                                                  final loaded =
                                                      aiProvider.loadedLanguage(
                                                        articleId,
                                                      ) ??
                                                      <String>[];
                                                  final framing =
                                                      aiProvider
                                                          .framingAndHeadline(
                                                            articleId,
                                                          ) ??
                                                      <String>[];
                                                  final sources =
                                                      aiProvider
                                                          .sourceAndStorySelection(
                                                            articleId,
                                                          ) ??
                                                      <String>[];

                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                    ),
                                                    builder: (ctx) =>
                                                        PoliticalBiasModal(
                                                          classification:
                                                              classification,
                                                          loadedLanguage:
                                                              loaded,
                                                          framing: framing,
                                                          sources: sources,
                                                        ),
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 12,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme
                                                        .surfaceContainerHighest,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Bias',
                                                        style: theme
                                                            .textTheme
                                                            .labelSmall,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        aiProvider
                                                                .biasClassification(
                                                                  articleId,
                                                                ) ??
                                                            '—',
                                                        style: theme
                                                            .textTheme
                                                            .bodyLarge,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Content
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          // Add bottom padding to prevent overlap with TTS controls
                          padding: const EdgeInsets.only(bottom: 90),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              // If generating analysis show loader, otherwise show analysis (if available and requested) then full text
                              if (isGeneratingAnalysis) ...[
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24.0,
                                    ),
                                    child: LoadingAnimationWidget.dotsTriangle(
                                      color: theme.colorScheme.primary,
                                      size: 48,
                                    ),
                                  ),
                                ),
                              ] else if (summary != null &&
                                  isAnalysisVisible) ...[
                                Text(
                                  summary,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                // When in analysis mode we show the generated analysis above. The full article will be shown when _showAnalysis is false.
                              ] else ...[
                                // Default: show full article text
                                Text(
                                  widget.article.text,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // TTS Controls positioned below the back button
          Positioned(
            bottom: 15, // Below back button
            left: 0,
            right: 0,
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isAuthenticated) {
                  // If AI analysis mode is active and a summary is available, prefer the summary for TTS
                  final textForTts = (isAnalysisVisible && summary != null)
                      ? summary
                      : widget.article.text;
                  return TTSControlsWidget(textToRead: textForTts);
                }
                return const SizedBox.shrink(); // Don't show TTS controls for non-authenticated users
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Reset TTS provider when the article detail page is closed
    print('ArticleDetailPage: dispose method called');
    print('ArticleDetailPage: Calling _ttsProvider.reset()');
    _ttsProvider.reset();
    context.read<AiProvider>().showOriginal(widget.article.id);
    print('ArticleDetailPage: _ttsProvider.reset() completed');
    super.dispose();
    print('ArticleDetailPage: dispose method completed');
  }
}
