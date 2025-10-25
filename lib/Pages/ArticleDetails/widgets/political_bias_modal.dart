import 'package:flutter/material.dart';

/// A modal bottom sheet widget for displaying political bias analysis details
class PoliticalBiasModal extends StatelessWidget {
  final String classification;
  final List<String> loadedLanguage;
  final List<String> framing;
  final List<String> sources;

  const PoliticalBiasModal({
    super.key,
    required this.classification,
    required this.loadedLanguage,
    required this.framing,
    required this.sources,
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
            Text('Political Bias', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Classification: $classification',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Framing and headline',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    if (framing.isNotEmpty) ...[
                      ...framing.map(
                        (f) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '• $f',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        'No framing examples available.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Source and story selection',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    if (sources.isNotEmpty) ...[
                      ...sources.map(
                        (s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '• $s',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        'No source selection examples available.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text('Loaded language', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    if (loadedLanguage.isNotEmpty) ...[
                      // Render loaded language items inside scroll area
                      ...loadedLanguage.map(
                        (l) => Column(
                          children: [
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.arrow_right),
                              title: Text(l),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Text(
                        'No loaded language examples available.',
                        style: theme.textTheme.bodyMedium,
                      ),
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
