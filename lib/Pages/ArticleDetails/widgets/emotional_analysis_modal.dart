import 'package:flutter/material.dart';

/// A modal bottom sheet widget for displaying emotional analysis details
class EmotionalAnalysisModal extends StatelessWidget {
  final String primary;
  final String secondary;
  final List<String> quotes;
  final String overall;

  const EmotionalAnalysisModal({
    super.key,
    required this.primary,
    required this.secondary,
    required this.quotes,
    required this.overall,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FractionallySizedBox(
      heightFactor: 0.55,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pinned header
            Text('Emotional Analysis', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primary emotion: $primary',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Secondary emotion: $secondary',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text('Overall tone', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(overall, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    if (quotes.isNotEmpty) ...[
                      Text(
                        'Indicative quotes',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      // Render quotes as a vertical list inside the scroll area
                      ...quotes.map(
                        (q) => Column(
                          children: [
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.format_quote),
                              title: Text(q),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Text(
                        'No indicative quotes available.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(overall),
                    ],
                    const SizedBox(height: 8),
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
