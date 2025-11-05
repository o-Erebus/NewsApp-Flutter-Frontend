import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Nexora/Providers/podcast_provider.dart';
import 'package:Nexora/Pages/Podcast/widgets/full_player_page.dart';
import 'create_podcast_page.dart';
import '../../../Models/podcast_model.dart';
import 'package:page_transition/page_transition.dart';
import 'podcast_card.dart';
// full player import used in tap handler

class MyPodcastsSection extends StatefulWidget {
  const MyPodcastsSection({super.key});

  @override
  State<MyPodcastsSection> createState() => _MyPodcastsSectionState();
}

class _MyPodcastsSectionState extends State<MyPodcastsSection> {
  bool _isManaging = false;

  void _onTapPodcast(Podcast podcast) {
    if (_isManaging) {
      // Open edit page with details filled in
      FocusScope.of(context).unfocus();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreatePodcastPage(existingPodcast: podcast),
        ),
      ).then((_) {
        // refresh after edit
        context.read<PodcastProvider>().fetchUserPodcasts();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).unfocus();
        });
      });
    } else {
      // If mini player is not visible (no currentPodcast), start playback and open full player.
      // If mini player is visible, only start playback.
      FocusScope.of(context).unfocus();
      final provider = context.read<PodcastProvider>();
      final miniVisible = provider.currentPodcast != null;
      provider.playPodcast(podcast);
      if (!miniVisible) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final podcastProvider = context.watch<PodcastProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.person,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'My Podcasts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => setState(() => _isManaging = !_isManaging),
                child: Text(
                  _isManaging ? 'Done' : 'Manage',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Podcasts list or empty state
        if (podcastProvider.userPodcasts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Icon(
                  Icons.mic_off,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No podcasts yet',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: podcastProvider.userPodcasts.length,
            itemBuilder: (context, index) {
              final Podcast podcast = podcastProvider.userPodcasts[index];
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 12.0,
                  left: 20,
                  right: 20,
                ),
                child: PodcastCard(
                  podcast: podcast,
                  showImage: true,
                  onTap: () => _onTapPodcast(podcast),
                  trailing: !_isManaging
                      ? Container(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.play_arrow,
                            color: colorScheme.onPrimary,
                            size: 20,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            // Unfocus before navigation
                            FocusScope.of(context).unfocus();
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                duration: const Duration(milliseconds: 300),
                                reverseDuration: const Duration(
                                  milliseconds: 200,
                                ),
                                child: CreatePodcastPage(
                                  existingPodcast: podcast,
                                ),
                              ),
                            ).then((_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                FocusScope.of(context).unfocus();
                              });
                              context
                                  .read<PodcastProvider>()
                                  .fetchUserPodcasts();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.edit,
                              color: colorScheme.primary,
                              size: 18,
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
      ],
    );
  }
}
