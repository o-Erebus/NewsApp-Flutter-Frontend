import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../../Models/news_article.dart';
import '../../Providers/tts_provider.dart';
import '../../Providers/auth_provider.dart';
import 'widgets/tts_controls_widget.dart';

class ArticleDetailPage extends StatefulWidget {
  final NewsArticle article;

  final bool isCarouselView;

  final bool isGlobalView;

  const ArticleDetailPage({
    super.key,
    required this.article,
    required this.isCarouselView,
    this.isGlobalView = false, // Default to false for backward compatibility
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var herotag = '';
    if (widget.isGlobalView) {
      if (widget.isCarouselView) {
        herotag = 'GLOBAL_${widget.article.imageUrl}';
      } else {
        herotag = 'GLOBAL_article_image_${widget.article.id}';
      }
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
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.article.author,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurfaceVariant,
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
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
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
                              // Placeholder body text
                              Text(
                                widget.article.text,
                                style: theme.textTheme.bodyLarge,
                              ),
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
                  return TTSControlsWidget(textToRead: widget.article.text);
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
    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
    ttsProvider.reset();
    super.dispose();
  }
}
