// lib/screens/home_page.dart
import 'package:finalyear/Pages/Home/widgets/carousel_widget.dart';
import 'package:finalyear/Pages/Home/widgets/heading_widget.dart';
import 'package:finalyear/Pages/Home/widgets/news_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Providers/news_provider.dart';
import '../../greetings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Optionally, you can listen to scroll events for more complex "load more" logic
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) { // Load more when 200px from bottom
        // Debounce or add isLoading check here if needed
        final newsProvider = Provider.of<NewsProvider>(context, listen: false);
        if (!newsProvider.isLoading && newsProvider.hasMore) {
          newsProvider.fetchArticles(isLoadMore: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the provider
    // Using context.watch() makes this widget rebuild when NewsProvider notifies listeners
    final newsProvider = context.watch<NewsProvider>();
    final articles = newsProvider.articles;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            floating: false,
            pinned: false,
            snap: false,
            title: Greetings(), // Assumed to be stateless or managed independently
            // Add background color or flexible space if desired
            // flexibleSpace: FlexibleSpaceBar(title: Text("News App")),
          ),
          // START: Put your Carousel Widget here (remains the same or similar)
          const CarouselWidget(), // Keep this simple or manage its state separately
          // END: Put your Carousel Widget here

          const HeadingWidget(title: "Top Headlines"), // Keep this simple

          // START: Infinite Scroll List using Provider
          if (articles.isEmpty && newsProvider.isLoading)
            const SliverFillRemaining( // Show loading indicator if initial load and empty
              child: Center(child: CircularProgressIndicator()),
            )
          else if (articles.isEmpty && !newsProvider.isLoading)
            SliverFillRemaining( // Show message if no articles and not loading
              child: Center(child: Text("No articles found. Pull to refresh.", style: TextStyle(fontSize: 16, color: Colors.grey[600]))),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  // Logic for loading more items as user scrolls to the end
                  // This is an alternative or complementary to ScrollController listener
                  // if (index >= articles.length - 2 && !newsProvider.isLoading && newsProvider.hasMore) {
                  //   // Use WidgetsBinding.instance.addPostFrameCallback to avoid build-time state changes
                  //   WidgetsBinding.instance.addPostFrameCallback((_) {
                  //      Provider.of<NewsProvider>(context, listen: false).fetchArticles(isLoadMore: true);
                  //   });
                  // }

                  if (index < articles.length) {
                    final article = articles[index];
                    return NewsListItemWidget(article: article);
                  } else if (newsProvider.hasMore) {
                    // Show a loading indicator at the bottom of the list
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else {
                    // Optional: Show "No more articles" message
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(child: Text("You've reached the end!", style: TextStyle(color: Colors.grey[600]))),
                    );
                  }
                },
                // Add 1 to childCount if there are more items to load (for the loading indicator)
                // or if we want to show an "end of list" message
                childCount: articles.length + (newsProvider.hasMore || (articles.isNotEmpty && !newsProvider.hasMore) ? 1 : 0),
              ),
            ),
          // END: Infinite Scroll List Widget/Logic here
        ],
      ),
      // Optional: Add a FloatingActionButton for manual refresh
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => newsProvider.fetchArticles(),
      //   child: Icon(Icons.refresh),
      // ),
    );
  }
}