// lib/screens/home_page.dart
import 'dart:async';

import 'package:finalyear/Pages/Home/widgets/carousel_widget.dart';
import 'package:finalyear/Pages/Home/widgets/news_list_item_widget.dart';
import 'package:finalyear/Pages/Home/widgets/category_pills_widget.dart';
import 'package:finalyear/Pages/_common_widgets/skeleton_loaders/news_list_item_skeleton_widget.dart';
import 'package:finalyear/Pages/_common_widgets/skeleton_loaders/min_display_time_wrapper.dart';
import 'package:finalyear/Pages/_common_widgets/skeleton_loaders/heading_skeleton_widget.dart';
import 'package:finalyear/Pages/_common_widgets/skeleton_loaders/category_pills_skeleton_widget.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // For unawaited
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../Providers/news_provider.dart';
import '../../Models/news_article.dart';
import '../_common_widgets/title_widget.dart';
import '../_common_widgets/greeting_logic.dart';
import '../_common_widgets/error_indicator_widget.dart';
import '../_common_widgets/no_articles_indicator_widget.dart';
import '../_common_widgets/end_of_list_indicator_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _getGreetingTitle() {
    final greetingData = GreetingLogic.getGreetingDataVariant1();
    return '${greetingData['message']} ${greetingData['emoji']}';
  }

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Set loading to false after a delay to simulate initial loading
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Access the provider
    final newsProvider = context.watch<NewsProvider>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          // Set loading state to true
          setState(() {
            _isLoading = true;
          });
          // Clear caches immediately for fresh data
          newsProvider.clearAllCaches();
          // Fetch featured articles in the background (don't await)
          unawaited(newsProvider.fetchFeaturedArticles());
          // Refresh the paging controller directly for immediate skeleton loader display
          return Future.sync(
            () => newsProvider.pagingController.refresh(),
          ).then((_) {
            // Set loading state back to false after refresh is complete
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
        },
        child: CustomScrollView(
          slivers: <Widget>[
            CommonTitleWidget(
              title: _getGreetingTitle(),
              logoAssetPath: "logoAssetPath",
              variant: 1,
            ),
            // START: Put your Carousel Widget here (remains the same or similar)
            const CarouselWidget(), // Keep this simple or manage its state separately
            // END: Put your Carousel Widget here
            // Show heading skeleton when loading, otherwise show the actual heading and mood button
            _isLoading
                ? const MinDisplayTimeWrapper(
                    child: HeadingSkeletonWidget(),
                    minDisplayTime: Duration(milliseconds: 2500),
                  )
                : SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Top Headlines',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Tooltip(
                            message: newsProvider.isMoodBoosterActivated
                                ? 'Mood Booster: Active'
                                : 'Mood Booster: Inactive',
                            child: GestureDetector(
                              onTap: () {
                                newsProvider.toggleMoodBooster();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      newsProvider.isMoodBoosterActivated
                                          ? 'Mood Booster Activated! 🌟'
                                          : 'Mood Booster Deactivated',
                                    ),
                                    duration: const Duration(milliseconds: 800),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: newsProvider.isMoodBoosterActivated
                                      ? theme.colorScheme.primary.withAlpha(200)
                                      : theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                ),
                                child: Semantics(
                                  label: newsProvider.isMoodBoosterActivated
                                      ? 'Mood Booster Active'
                                      : 'Mood Booster Inactive',
                                  button: true,
                                  child: newsProvider.isMoodBoosterActivated
                                      ? Text(
                                          '😁', // Beaming Face with Smiling Eyes
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                        )
                                      : ColorFiltered(
                                          colorFilter:
                                              const ColorFilter.matrix(<double>[
                                                0.2126,
                                                0.7152,
                                                0.0722,
                                                0,
                                                0,
                                                0.2126,
                                                0.7152,
                                                0.0722,
                                                0,
                                                0,
                                                0.2126,
                                                0.7152,
                                                0.0722,
                                                0,
                                                0,
                                                0,
                                                0,
                                                0,
                                                1,
                                                0,
                                              ]),
                                          child: Text(
                                            '😁',
                                            style: TextStyle(
                                              fontSize: 22,
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ), // Keep this simple
            // Show category pills skeleton when loading, otherwise show the actual category pills
            _isLoading
                ? const MinDisplayTimeWrapper(
                    child: CategoryPillsSkeletonWidget(),
                    minDisplayTime: Duration(milliseconds: 2500),
                  )
                : CategoryPillsWidget(
                    onCategorySelected: (category) {
                      // Use read to avoid rebuilding the widget when provider changes
                      context.read<NewsProvider>().selectCategory(category);
                    },
                  ),
            // START: Infinite Scroll List using infinite_scroll_pagination
            PagingListener(
              controller: newsProvider.pagingController,
              builder: (context, state, fetchNextPage) =>
                  PagedSliverList<int, NewsArticle>.separated(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate<NewsArticle>(
                      itemBuilder: (context, item, index) =>
                          NewsListItemWidget(article: item),
                      firstPageErrorIndicatorBuilder: (_) =>
                          ErrorIndicatorWidget(
                            error: state.error,
                            onRetry: () {
                              final newsProvider = context.read<NewsProvider>();
                              newsProvider.pagingController.refresh();
                            },
                          ),
                      newPageErrorIndicatorBuilder: (_) => ErrorIndicatorWidget(
                        error: state.error,
                        onRetry: () {
                          final newsProvider = context.read<NewsProvider>();
                          newsProvider.pagingController.refresh();
                        },
                      ),
                      firstPageProgressIndicatorBuilder: (_) =>
                          const MinDisplayTimeWrapper(
                            child: NewsListItemSkeletonWidget(),
                            minDisplayTime: Duration(milliseconds: 500),
                          ),
                      newPageProgressIndicatorBuilder: (_) =>
                          const MinDisplayTimeWrapper(
                            child: NewsListItemSkeletonWidget(),
                            minDisplayTime: Duration(milliseconds: 500),
                          ),
                      noItemsFoundIndicatorBuilder: (_) =>
                          NoArticlesIndicatorWidget(theme: theme),
                      noMoreItemsIndicatorBuilder: (_) =>
                          EndOfListIndicatorWidget(theme: theme),
                    ),
                    separatorBuilder: (context, index) =>
                        const SizedBox.shrink(),
                  ),
            ),
            // END: Infinite Scroll List Widget/Logic here
          ],
        ),
      ),
      // Optional: Add a FloatingActionButton for manual refresh
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => newsProvider.fetchArticles(),
      //   child: Icon(Icons.refresh),
      // ),
    );
  }
}
