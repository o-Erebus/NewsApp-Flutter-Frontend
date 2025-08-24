// lib/screens/home_page.dart
import 'package:finalyear/Pages/Home/widgets/carousel_widget.dart';
import 'package:finalyear/Pages/Home/widgets/heading_widget.dart';
import 'package:finalyear/Pages/Home/widgets/news_list_item_widget.dart';
import 'package:finalyear/Pages/Home/widgets/category_pills_widget.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../Providers/news_provider.dart';
import '../../greetings.dart';
import '../../Models/news_article.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        onRefresh: () => newsProvider.fetchArticles(),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.only(top: 12),
              sliver: SliverAppBar(
                forceMaterialTransparency: true,
                floating: false,
                pinned: false,
                snap: false,
                title: GreetingVariant1(logoAssetPath: "logoAssetPath"),
              ),
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
                          _buildErrorIndicator(context, state.error),
                      newPageErrorIndicatorBuilder: (_) =>
                          _buildErrorIndicator(context, state.error),
                      firstPageProgressIndicatorBuilder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                      newPageProgressIndicatorBuilder: (_) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      noItemsFoundIndicatorBuilder: (_) =>
                          _buildNoArticlesIndicator(theme),
                      noMoreItemsIndicatorBuilder: (_) =>
                          _buildEndOfListIndicator(theme),
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

  Widget _buildErrorIndicator(BuildContext context, dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error?.toString() ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final newsProvider = context.read<NewsProvider>();
              newsProvider.pagingController.refresh();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoArticlesIndicator(ThemeData theme) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "No articles found.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndOfListIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Center(
        child: Text(
          "You've reached the end!",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
