import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../Models/news_article.dart';

class ArticleDetailPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var herotag = '';
    if (isGlobalView) {
      if (isCarouselView) {
        herotag = 'GLOBAL_${article.imageUrl}';
      } else {
        herotag = 'GLOBAL_article_image_${article.id}';
      }
    } else {
      if (isCarouselView) {
        herotag = article.imageUrl;
      } else {
        herotag = 'article_image_${article.id}';
      }
    }
    return Scaffold(
      body: Stack(
        children: [
          // Hero Image Background
          Hero(
            tag: herotag,
            child: CachedNetworkImage(
              imageUrl: article.imageUrl,
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
                            article.title,
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
                                  article.author,
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
                                  DateFormat.yMMMd().format(article.date),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              // Placeholder body text
                              Text(
                                article.text,
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
        ],
      ),
    );
  }
}
