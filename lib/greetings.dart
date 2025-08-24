import 'package:flutter/material.dart';

// VARIANT 1: [Logo] [Good Morning] [☀️] (Greeting and Emoji Right Aligned)
class GreetingVariant1 extends StatelessWidget {
  final String logoAssetPath;

  const GreetingVariant1({super.key, required this.logoAssetPath});

  Map<String, String> getGreetingData() {
    var hour = DateTime.now().hour;

    if (hour >= 0 && hour < 5) {
      return {'message': 'Rest well!', 'emoji': '😴'};
    } else if (hour >= 5 && hour < 8) {
      return {'message': 'Rise and shine!', 'emoji': '🌅'};
    } else if (hour >= 8 && hour < 12) {
      return {'message': 'Ready for the day?', 'emoji': '☕'};
    } else if (hour >= 12 && hour < 14) {
      return {'message': 'Enjoy your break!', 'emoji': '🍔'};
    } else if (hour >= 14 && hour < 17) {
      return {'message': 'Power through!', 'emoji': '💪'};
    } else if (hour >= 17 && hour < 20) {
      return {'message': 'Relax this evening!', 'emoji': '🛋️'};
    } else {
      return {'message': 'Sweet dreams!', 'emoji': '✨'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final greetingData = getGreetingData();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 12.0, top: 16.0, bottom: 16),
      child: Row(
        children: [
          // Logo on left

          // Spacer to push greeting and emoji to the right

          // Greeting and emoji on right
          Text(
            greetingData['message']!,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            greetingData['emoji']!,
            style: TextStyle(fontSize: 20, color: theme.colorScheme.onSurface),
          ),
          const Spacer(),

          Image.asset(
            logoAssetPath,
            width: 20,
            height: 20,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 20,
                height: 20,
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
  }
}

// VARIANT 2: [Logo] [AppName] (top row) + [Good Morning] [☀️] (bottom row, all left aligned)
class GreetingVariant2 extends StatelessWidget {
  const GreetingVariant2({super.key});

  Map<String, String> getGreetingData() {
    var hour = DateTime.now().hour;

    if (hour < 12) {
      return {'greeting': 'Good Morning', 'emoji': '☀️'};
    } else if (hour < 17) {
      return {'greeting': 'Good Afternoon', 'emoji': '🌤️'};
    } else {
      return {'greeting': 'Good Evening', 'emoji': '🌙'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final greetingData = getGreetingData();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bottom row: Greeting + Emoji
          Row(
            children: [
              Text(
                greetingData['greeting']!,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                greetingData['emoji']!,
                style: TextStyle(
                  fontSize: 20,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
