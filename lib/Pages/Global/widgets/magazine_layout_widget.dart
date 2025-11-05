// lib/Pages/Global/widgets/magazine_layout_widget.dart
import 'package:Nexora/Pages/Global/widgets/magazine_feature_item_widget.dart';
import 'package:Nexora/Pages/_common_widgets/skeleton_loaders/magazine_skeleton_widgets.dart';
import 'package:Nexora/Pages/_common_widgets/skeleton_loaders/min_display_time_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../Providers/news_provider.dart';
import '../../../Models/news_article.dart';
import 'magazine_news_item_widget.dart';
import '../../_common_widgets/title_widget.dart';
import '../../_common_widgets/error_indicator_widget.dart';
import '../../_common_widgets/no_articles_indicator_widget.dart';
import '../../_common_widgets/end_of_list_indicator_widget.dart';

class MagazineLayoutWidget extends StatelessWidget {
  final NewsProvider newsProvider;

  const MagazineLayoutWidget({super.key, required this.newsProvider});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        // Clear caches immediately for fresh data
        newsProvider.clearAllCaches();
        // Refresh the paging controller directly for immediate skeleton loader display
        return Future.sync(() => newsProvider.globalPagingController.refresh());
      },
      child: CustomScrollView(
        slivers: <Widget>[
          const CommonTitleWidget(title: "Global News", variant: 1),
          PagingListener(
            controller: newsProvider.globalPagingController,
            builder: (context, state, fetchNextPage) =>
                PagedSliverList<int, NewsArticle>(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  builderDelegate: PagedChildBuilderDelegate<NewsArticle>(
                    itemBuilder: (context, item, index) {
                      // For the first item, show the featured item without a divider
                      if (index == 0) {
                        return MagazineFeaturedItem(article: item);
                      }
                      // For subsequent items, show a divider before the MagazineNewsItem
                      else {
                        return Column(
                          children: [
                            const Divider(
                              height: 1,
                              thickness: 1,
                              indent: 16.0,
                              endIndent: 16.0,
                            ),
                            MagazineNewsItem(article: item),
                          ],
                        );
                      }
                    },
                    firstPageErrorIndicatorBuilder: (_) => ErrorIndicatorWidget(
                      error: state.error,
                      onRetry: () {
                        final newsProvider = context.read<NewsProvider>();
                        newsProvider.globalPagingController.refresh();
                      },
                    ),
                    newPageErrorIndicatorBuilder: (_) => ErrorIndicatorWidget(
                      error: state.error,
                      onRetry: () {
                        final newsProvider = context.read<NewsProvider>();
                        newsProvider.globalPagingController.refresh();
                      },
                    ),
                    firstPageProgressIndicatorBuilder: (_) =>
                        const MinDisplayTimeWrapper(
                          child: Column(
                            children: [
                              MagazineFeaturedItemSkeleton(),
                              MagazineNewsItemSkeleton(),
                              MagazineNewsItemSkeleton(),
                              MagazineNewsItemSkeleton(),
                            ],
                          ),
                          minDisplayTime: Duration(milliseconds: 500),
                        ),
                    newPageProgressIndicatorBuilder: (_) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: MinDisplayTimeWrapper(
                        child: MagazineNewsItemSkeleton(),
                        minDisplayTime: Duration(milliseconds: 500),
                      ),
                    ),
                    noItemsFoundIndicatorBuilder: (_) =>
                        NoArticlesIndicatorWidget(theme: Theme.of(context)),
                    noMoreItemsIndicatorBuilder: (_) =>
                        EndOfListIndicatorWidget(theme: Theme.of(context)),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
