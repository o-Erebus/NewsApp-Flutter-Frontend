import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:finalyear/Models/podcast_model.dart';

/// Shared podcast row used by Trending and MyPodcasts sections.
/// Supports either an index badge (gradient) or an image thumbnail.
class PodcastCard extends StatelessWidget {
  final Podcast podcast;
  final int? index; // if provided shows index badge, otherwise image is used
  final bool showImage;
  final VoidCallback? onTap;
  final Widget? trailing; // trailing widget (play, edit, etc.)

  const PodcastCard({
    Key? key,
    required this.podcast,
    this.index,
    this.showImage = false,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline, width: 1),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Either index badge or image
            if (index != null && !showImage)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getGradientColors(index!),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: podcast.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: colorScheme.surfaceContainerHigh,
                    width: 50,
                    height: 50,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: colorScheme.surfaceContainerHigh,
                    width: 50,
                    height: 50,
                    child: Icon(
                      Icons.music_note,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

            const SizedBox(width: 12),

            // Podcast Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    podcast.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    podcast.channelName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(podcast.duration),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // trailing widget (play/edit) if provided
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors(int idx) {
    final gradients = [
      [Colors.purple.shade400, Colors.purple.shade600],
      [Colors.teal.shade400, Colors.teal.shade600],
      [Colors.orange.shade400, Colors.orange.shade600],
      [Colors.blue.shade400, Colors.blue.shade600],
    ];
    return List<Color>.from(gradients[idx % gradients.length]);
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
