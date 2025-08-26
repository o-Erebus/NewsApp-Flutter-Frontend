import 'package:flutter/material.dart';

class EndOfListIndicatorWidget extends StatelessWidget {
  final ThemeData theme;

  const EndOfListIndicatorWidget({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Center(
        child: Text(
          "You've reached the end!",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
