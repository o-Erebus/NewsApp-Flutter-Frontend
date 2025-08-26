import 'package:flutter/material.dart';

class NoArticlesIndicatorWidget extends StatelessWidget {
  final ThemeData theme;

  const NoArticlesIndicatorWidget({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    // Check if we should use SliverFillRemaining (for homepage) or regular Center (for globalpage)
    final bool useSliver = ModalRoute.of(context)?.settings.name != '/global';

    final content = Center(
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
    );

    // Return appropriate widget based on context
    return useSliver ? SliverFillRemaining(child: content) : content;
  }
}
