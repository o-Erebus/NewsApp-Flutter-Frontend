import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:finalyear/Providers/podcast_provider.dart';
import 'package:finalyear/Models/podcast_model.dart';
import 'package:finalyear/Pages/Podcast/widgets/full_player_page.dart';
import 'package:finalyear/Pages/Podcast/widgets/podcast_card.dart';

class TrendingPodcastCard extends StatelessWidget {
  final Podcast podcast;
  final int index;

  const TrendingPodcastCard({
    required this.podcast,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Keep behavior: unfocus, start playback, navigate to FullPlayerPage
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: PodcastCard(
        podcast: podcast,
        index: index,
        showImage: true,
        onTap: () {
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
        },
        trailing: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.play_arrow,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }
}
