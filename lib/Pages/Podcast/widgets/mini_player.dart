import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:finalyear/Providers/podcast_provider.dart';
import 'full_player_page.dart';
import 'seek_bar.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  late Offset _startDragPosition;
  late Offset _currentDragPosition;
  double _offsetX = 0;
  double _offsetY = 0;
  String _dragDirection = ''; // 'up', 'down', 'left', 'right', or ''
  String? _lastPodcastId; // Track the last played podcast

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<PodcastProvider>(
      builder: (context, podcastProvider, _) {
        // Don't show mini player if no podcast is playing
        if (podcastProvider.currentPodcast == null) {
          _lastPodcastId = null; // Reset when no podcast
          return const SizedBox.shrink();
        }

        final podcast = podcastProvider.currentPodcast!;

        // Reset offsets when a new podcast starts playing
        if (_lastPodcastId != podcast.id) {
          _lastPodcastId = podcast.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _offsetX = 0;
                _offsetY = 0;
                _dragDirection = '';
              });
            }
          });
        }

        return Positioned(
          bottom:
              90 -
              _offsetY, // Move down/up based on swipe (increased gap from navbar)
          left: 12 + _offsetX, // Move left/right based on swipe
          right: 12 - _offsetX,
          child: GestureDetector(
            onTap: () {
              // Unfocus any input (search) before navigating to full player
              FocusScope.of(context).unfocus();

              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.bottomToTop,
                  duration: const Duration(milliseconds: 300),
                  reverseDuration: const Duration(milliseconds: 200),
                  child: FullPlayerPage(podcast: podcast),
                ),
              ).then((_) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FocusScope.of(context).unfocus();
                });
              });
            },
            onPanStart: (details) {
              _startDragPosition = details.globalPosition;
              _currentDragPosition = details.globalPosition;
              _dragDirection = '';
            },
            onPanUpdate: (details) {
              final dx = details.globalPosition.dx - _startDragPosition.dx;
              final dy = details.globalPosition.dy - _startDragPosition.dy;

              // Determine primary direction (left/right or down)
              if (_dragDirection.isEmpty) {
                if (dx.abs() > dy.abs()) {
                  _dragDirection = dx < 0 ? 'left' : 'right';
                } else if (dy > 0) {
                  _dragDirection = 'down';
                } else if (dy < 0) {
                  _dragDirection = 'up';
                }
              }

              // Update offset based on direction
              setState(() {
                if (_dragDirection == 'left') {
                  _offsetX = dx.clamp(-80, 0).toDouble();
                  _offsetY = 0;
                } else if (_dragDirection == 'right') {
                  _offsetX = dx.clamp(0, 80).toDouble();
                  _offsetY = 0;
                } else if (_dragDirection == 'down') {
                  _offsetX = 0;
                  _offsetY = dy.clamp(0, 100).toDouble();
                } else if (_dragDirection == 'up') {
                  _offsetX = 0;
                  _offsetY = 0; // Don't move on swipe up
                }
              });

              _currentDragPosition = details.globalPosition;
            },
            onPanEnd: (details) {
              final dx = _currentDragPosition.dx - _startDragPosition.dx;
              final dy = _currentDragPosition.dy - _startDragPosition.dy;
              final distance = (dx * dx + dy * dy).toDouble();

              // Swipe up: Open full player
              if (dy < -50 && distance > 2500) {
                FocusScope.of(context).unfocus();
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.bottomToTop,
                    duration: const Duration(milliseconds: 300),
                    reverseDuration: const Duration(milliseconds: 200),
                    child: FullPlayerPage(podcast: podcast),
                  ),
                ).then((_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                  });
                });
              }
              // Swipe left, right, or down: Stop and close mini player
              else if ((dx.abs() > 50 && distance > 2500) ||
                  (dy > 50 && distance > 2500)) {
                podcastProvider.stop();
                // Don't reset position - let it slide out with the animation
              } else {
                // Reset position only if swipe wasn't significant enough
                setState(() {
                  _offsetX = 0;
                  _offsetY = 0;
                  _dragDirection = '';
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                backgroundBlendMode: BlendMode.luminosity,
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline, width: 1),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main player row
                  Row(
                    children: [
                      // Podcast thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: podcast.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: colorScheme.surfaceContainerHigh,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: colorScheme.surfaceContainerHigh,
                            child: Icon(
                              Icons.music_note,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title and channel
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              podcast.title,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              podcast.channelName,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Play/Pause button
                      GestureDetector(
                        onTap: podcastProvider.togglePlayPause,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            podcastProvider.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Progress bar (interactive seek bar component)
                  SeekBar(
                    current: podcastProvider.currentPosition,
                    total: podcastProvider.totalDuration,
                    onSeek: (value) async {
                      await podcastProvider.seek(value);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
