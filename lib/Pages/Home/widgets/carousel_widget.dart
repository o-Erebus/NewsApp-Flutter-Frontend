// lib/widgets/carousel_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();
    final List<NewsArticle> featuredArticles = newsProvider.articles.take(5).toList();

    if (featuredArticles.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        height: 280.0,
        margin: const EdgeInsets.symmetric(horizontal:12, vertical: 16.0),
        child: CarouselView.weighted( // Or your specific CarouselView constructor
          itemSnapping: true,
          flexWeights: const <int>[5,1],
          onTap: (int index) {
            if (index >= 0 && index < featuredArticles.length) {
              final NewsArticle selectedArticle = featuredArticles[index];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailPage(article: selectedArticle,isCarouselView: true,),
                ),
              );
            }
          },
          children: featuredArticles.map((article) {
            // **Define a unique tag for the Hero widget**
            // Prefer a unique ID if your NewsArticle model has one (e.g., article.id)
            // Using imageUrl as a fallback, ensure it's unique for each article.
            final String heroTag = article.imageUrl; // Or article.id if available and unique

            return Stack(
              fit: StackFit.expand,
              children: [
                // **Wrap the Image.network with a Hero widget**
                Hero(
                  tag: heroTag,
                  child: Image.network(
                    article.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
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
                      double opacity = ((constraints.maxWidth - minWidth) / (maxWidth - minWidth))
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
                                  padding: EdgeInsets.all(constraints.maxWidth * 0.035),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.black.withOpacity(0.8), Colors.transparent],
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
                                        fontSize: (constraints.maxWidth * 0.060),
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