import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../Models/news_article.dart';
import '../../ArticleDetails/article_detail_page.dart';

// Magazine layout featured item
class MagazineFeaturedItem extends StatelessWidget {
  final NewsArticle article;

  const MagazineFeaturedItem({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        borderRadius: BorderRadius.circular(16), // Rounded corners on all sides
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArticleDetailPage(
                  article: article,
                  isCarouselView: false,
                  isGlobalView: true,
                ),
              ),
            );
          },
          child: Stack(
            children: [
              // Featured image
              Hero(
                tag: 'GLOBAL_article_image_${article.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Rounded corners on all sides
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[700]!,
                      highlightColor: Colors.grey[500]!,
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      return Container(
                        height: 300,
                        color: theme.colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Gradient overlay
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Rounded corners on all sides
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
              // Text content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            article.author,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            DateFormat.yMMMd().format(article.date),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
