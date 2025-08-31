// lib/screens/home_page.dart
import 'dart:async';

import 'package:finalyear/Pages/Home/widgets/carousel_widget.dart';
import 'package:finalyear/Pages/Home/widgets/news_list_item_widget.dart';
import 'package:finalyear/Pages/Home/widgets/category_pills_widget.dart';
import 'package:finalyear/Pages/_common_widgets/skeleton_loaders/news_list_item_skeleton_widget.dart';
import 'package:finalyear/Pages/_common_widgets/skeleton_loaders/simple_news_item_skeleton_widget.dart';
import 'package:finalyear/Pages/_common_widgets/skeleton_loaders/min_display_time_wrapper.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // For unawaited
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../Providers/news_provider.dart';
import '../../Models/news_article.dart';
import '../_common_widgets/title_widget.dart';
import '../_common_widgets/heading_widget.dart';
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

  @override
  void initState() {
    super.initState();
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
          // Clear caches immediately for fresh data
          newsProvider.clearAllCaches();
          // Fetch featured articles in the background (don't await)
          unawaited(newsProvider.fetchFeaturedArticles());
          // Refresh the paging controller directly for immediate skeleton loader display
          return Future.sync(() => newsProvider.pagingController.refresh());
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
            const HeadingWidget(title: "Top Headlines"), // Keep this simple
            // Add the category pills widget
            CategoryPillsWidget(
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
                      newPageProgressIndicatorBuilder: (_) => const MinDisplayTimeWrapper(
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
