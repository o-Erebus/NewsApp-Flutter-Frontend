import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../Providers/history_provider.dart';
import '../../../Models/news_article.dart';
import '../../ArticleDetails/article_detail_page.dart';

class ProfileHistoryTab extends StatefulWidget {
  const ProfileHistoryTab({super.key});

  @override
  State<ProfileHistoryTab> createState() => _ProfileHistoryTabState();
}

class _ProfileHistoryTabState extends State<ProfileHistoryTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch history when tab is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().fetchReadHistory();
    });

    // Set up infinite scroll listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // User reached the bottom
      final provider = context.read<HistoryProvider>();
      if (provider.hasMore && !provider.isLoading) {
        provider.fetchReadHistory();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, _) {
        if (historyProvider.isLoading && historyProvider.readHistory.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (historyProvider.error != null &&
            historyProvider.readHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  historyProvider.error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    historyProvider.refreshHistory();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (historyProvider.readHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text('No read history yet', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Articles you read will appear here',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => historyProvider.refreshHistory(),
          child: ListView.builder(
            controller: _scrollController,
            itemCount:
                historyProvider.readHistory.length +
                (historyProvider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == historyProvider.readHistory.length) {
                // Loading indicator at the bottom
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: historyProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const SizedBox.shrink(),
                  ),
                );
              }

              final entry = historyProvider.readHistory[index];
              final isLastItem =
                  index == historyProvider.readHistory.length - 1;

              // Build the main item with the same bottom padding for the last item
              final item = Padding(
                padding: EdgeInsets.only(bottom: isLastItem ? 80 : 0),
                child: _buildHistoryItem(context, entry, theme),
              );

              // If this is the last item, just return it. Otherwise include a divider below.
              if (isLastItem) return item;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  item,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: theme.colorScheme.onSurface.withOpacity(0.1),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    dynamic entry,
    ThemeData theme,
  ) {
    // `entry.readAt` is stored in UTC in the DB. Some timestamps may be stored
    // without timezone markers which causes `DateTime.parse` to treat them as
    // local. To ensure we always treat the stored timestamp as UTC and then
    // convert to IST (UTC+5:30), build a UTC DateTime from the parsed
    // components (ignoring any local timezone assumptions).
    DateTime buildUtcFrom(dynamic value) {
      try {
        if (value is DateTime) {
          // Use the component fields but force UTC so we treat the stored
          // components as UTC values.
          return DateTime.utc(
            value.year,
            value.month,
            value.day,
            value.hour,
            value.minute,
            value.second,
            value.millisecond,
            value.microsecond,
          );
        }

        final s = value?.toString() ?? '';
        // Try to parse; if parsing succeeds, take the components and make a
        // UTC DateTime from them (this avoids local timezone conversions).
        final parsed = DateTime.tryParse(s);
        if (parsed != null) {
          return DateTime.utc(
            parsed.year,
            parsed.month,
            parsed.day,
            parsed.hour,
            parsed.minute,
            parsed.second,
            parsed.millisecond,
            parsed.microsecond,
          );
        }
      } catch (_) {}

      // Fallback to current time in UTC if parsing fails
      return DateTime.now().toUtc();
    }

    final DateTime readAtUtc = buildUtcFrom(entry.readAt);
    // IST is UTC+5:30
    const Duration istOffset = Duration(hours: 5, minutes: 30);
    final DateTime readAtLocal = readAtUtc.add(istOffset);

    final readTime = DateFormat('MMM d, y ').add_jm().format(readAtLocal);

    // Build a NewsArticle from the article_details if available
    NewsArticle? article;
    if (entry.articleDetails != null) {
      try {
        article = NewsArticle.fromJson(entry.articleDetails!);
      } catch (e) {
        // If parsing fails, article remains null
        print('Error parsing article details: $e');
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: article != null
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailPage(
                          article: article!,
                          isCarouselView: false,
                          isGlobalView: false,
                          isHistoryView: true,
                        ),
                      ),
                    );
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Image or fallback icon (use cached network image)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: entry.topImage != null && entry.topImage!.isNotEmpty
                        ? Hero(
                            tag: 'HISTORY_article_image_${entry.articleId}',
                            child: CachedNetworkImage(
                              imageUrl: entry.topImage!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        theme.colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.bookmark_outline,
                                  color: theme.colorScheme.onPrimaryContainer,
                                  size: 24,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.bookmark_outline,
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 24,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Title and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.articleTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              readTime,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
