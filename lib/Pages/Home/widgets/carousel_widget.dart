// lib/widgets/carousel_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Models/news_article.dart'; // Ensure your NewsArticle has a unique ID or use imageUrl
import '../../../Providers/news_provider.dart';

import 'article_detail_page.dart'; // Ensure this path is correct
// e.g., import 'package:carousel_view/carousel_view.dart';

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({super.key});

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch featured articles when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsProvider = context.read<NewsProvider>();
      newsProvider.fetchFeaturedArticles().then((_) {
        // Update the loading state after fetching
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();
    final List<NewsArticle> featuredArticles = newsProvider.featuredArticles;

    // Show loading indicator while fetching or if there are no articles
    if (_isLoading || featuredArticles.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 280.0,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        height: 280.0,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16.0),
        child: CarouselView.weighted(
          // Or your specific CarouselView constructor
          itemSnapping: true,
          flexWeights: const <int>[5, 1],
          onTap: (int index) {
            if (index >= 0 && index < featuredArticles.length) {
              final NewsArticle selectedArticle = featuredArticles[index];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailPage(
                    article: selectedArticle,
                    isCarouselView: true,
                  ),
                ),
              );
            }
          },
          children: featuredArticles.map((article) {
            // **Define a unique tag for the Hero widget**
            // Prefer a unique ID if your NewsArticle model has one (e.g., article.id)
            // Using imageUrl as a fallback, ensure it's unique for each article.
            final String heroTag =
                article.imageUrl; // Or article.id if available and unique

            return Stack(
              fit: StackFit.expand,
              children: [
                // **Wrap the CachedNetworkImage with a Hero widget**
                Hero(
                  tag: heroTag,
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[700]!,
                      highlightColor: Colors.grey[500]!,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      print('Error loading carousel image: $error');
                      return Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0.0, 0.4],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double minWidth = 50;
                      double maxWidth = 250;
                      double opacity =
                          ((constraints.maxWidth - minWidth) /
                                  (maxWidth - minWidth))
                              .clamp(0.0, 1.0);

                      return Stack(
                        children: [
                          if (opacity > 0)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: constraints.maxHeight * 0.25,
                              child: Opacity(
                                opacity: opacity,
                                child: Container(
                                  padding: EdgeInsets.all(
                                    constraints.maxWidth * 0.035,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.8),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(
                                      article.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            (constraints.maxWidth * 0.060),
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
