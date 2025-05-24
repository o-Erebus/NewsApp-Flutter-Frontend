// lib/widgets/news_list_item_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Models/news_article.dart'; // For date formatting

class NewsListItemWidget extends StatelessWidget {
  final NewsArticle article;

  const NewsListItemWidget({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.1, // Adjust as needed for your design
      child: Container(
        // Using Card for a bit of elevation and rounded corners
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            Expanded(
              flex: 3, // Give more space to the image
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Hero(
                  // Use the exact same tag format as in CarouselItemWidget
                  tag: 'article_image_${article.id}', // Key change here
                  child: Image.network(
                    article.imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey,
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Text Section
            Expanded(
              flex: 2, // Give less space to text compared to image
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 6.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Distribute space
                  children: [
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (article.shortDescription != null &&
                        article.shortDescription!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          article.shortDescription!,
                          style: Theme.of(context).textTheme.labelLarge,
                          maxLines: 2, // Adjust as needed
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          article.author,
                          style: Theme.of(context).textTheme.labelMedium
                        ),
                        Text(
                          DateFormat.yMMMd().format(
                            article.date,
                          ), // e.g., Jan 23, 2024
                          style: Theme.of(context).textTheme.labelMedium
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
    );
  }
}
