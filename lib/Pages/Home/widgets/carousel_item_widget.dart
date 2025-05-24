// lib/widgets/carousel_item_widget.dart
import 'package:flutter/material.dart';

import '../../../Models/news_article.dart';


class CarouselItemWidget extends StatelessWidget {
  final NewsArticle article;
  final bool isSelected; // To apply different styling/size if selected

  const CarouselItemWidget({
    super.key,
    required this.article,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final double scale = isSelected ? 1.0 : 0.85; // Scale down non-selected items
    final double verticalPadding = isSelected ? 0 : 20.0; // Add padding to non-selected

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..scale(scale),
      transformAlignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: isSelected ? 0 : 8, vertical: verticalPadding),
      child: Card(
        elevation: isSelected ? 6 : 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              // Use a unique tag for each article's image, consistent across widgets
              tag: 'article_image_${article.id}', // Key change here
              child: Image.network(
                article.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
              ),
            ),
            // Gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Text(
                article.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSelected ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  shadows: const [
                    Shadow(blurRadius: 2.0, color: Colors.black54, offset: Offset(1.0, 1.0)),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}