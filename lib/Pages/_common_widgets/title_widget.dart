// lib/Pages/_common_widgets/title_widget.dart
import 'package:flutter/material.dart';

// Common title widget that can be used across different pages
// Supports two variants matching the original greetings.dart
class CommonTitleWidget extends StatelessWidget {
  final String title;
  final String logoAssetPath;
  final int
  variant; // 1 for GreetingVariant1 layout, 2 for GreetingVariant2 layout

  const CommonTitleWidget({
    super.key,
    required this.title,
    this.logoAssetPath = '',
    this.variant = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 12),
      sliver: SliverAppBar(
        forceMaterialTransparency: true,
        floating: false,
        pinned: false,
        snap: false,
        title: _buildTitleContent(context),
      ),
    );
  }

  Widget _buildTitleContent(BuildContext context) {
    final theme = Theme.of(context);

    if (variant == 1) {
      // VARIANT 1: [Logo] [Title] [Emoji] (Title and Emoji Right Aligned)
      // Parse title to extract message and emoji if present
      final parts = _parseTitle(title);
      final message = parts['message'] ?? title;
      final emoji = parts['emoji'] ?? '';

      return Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 16),
        child: Row(
          children: [
            // Title and emoji on right
            Text(
              message,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            if (emoji.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                emoji,
                style: TextStyle(
                  fontSize: 20,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
            const Spacer(),
            // Logo on right
            if (logoAssetPath.isNotEmpty)
              Image.asset(
                logoAssetPath,
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.apps,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
          ],
        ),
      );
    } else {
      // VARIANT 2: [Title] [Emoji] (left aligned)
      // Parse title to extract message and emoji if present
      final parts = _parseTitle(title);
      final message = parts['message'] ?? title;
      final emoji = parts['emoji'] ?? '';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Emoji
            Row(
              children: [
                Text(
                  message,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                if (emoji.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 20,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }
  }

  Map<String, String> _parseTitle(String title) {
    // Simple parser to extract message and emoji from title
    // Assumes format: "Message Emoji" or just "Message"
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return {'message': '', 'emoji': ''};
    }

    // Check if the last character is an emoji (simple check)
    final lastChar = trimmedTitle.substring(trimmedTitle.length - 1);
    if (lastChar.codeUnitAt(0) > 0x10000) {
      // Likely an emoji
      return {
        'message': trimmedTitle.substring(0, trimmedTitle.length - 1).trim(),
        'emoji': lastChar,
      };
    }

    return {'message': trimmedTitle, 'emoji': ''};
  }
}
