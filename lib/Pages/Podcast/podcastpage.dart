import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finalyear/Providers/podcast_provider.dart';
import 'package:finalyear/Providers/auth_provider.dart';
import 'widgets/mini_player.dart';
import 'widgets/featured_podcast_section.dart';
import 'widgets/trending_podcasts_section.dart';
import 'widgets/top_channels_section.dart';
import 'widgets/my_podcasts_page.dart';

class PodcastPage extends StatefulWidget {
  const PodcastPage({super.key});

  @override
  State<PodcastPage> createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  @override
  void initState() {
    super.initState();
    // Initialize podcast data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PodcastProvider>().refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PodcastProvider>(
      builder: (context, podcastProvider, _) {
        return Scaffold(
          body: Stack(
            children: [
              // Main content
              RefreshIndicator(
                onRefresh: podcastProvider.refreshAll,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(context),
                      const SizedBox(height: 20),

                      // Search Bar
                      _buildSearchBar(context),
                      const SizedBox(height: 20),

                      // Featured Podcast Section
                      const FeaturedPodcastSection(),
                      const SizedBox(height: 30),

                      // Trending Section
                      const TrendingPodcastsSection(),
                      const SizedBox(height: 30),

                      // Top Channels Section
                      const TopChannelsSection(),
                      const SizedBox(height: 30),

                      // Extra padding to prevent content from being hidden by mini player
                      if (podcastProvider.currentPodcast != null)
                        const SizedBox(height: 200),
                      if (podcastProvider.currentPodcast == null)
                        const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Floating Mini Player (above navbar)
              const MiniPlayer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = context.watch<AuthProvider>();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Voices That Matter',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          // Profile icon button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyPodcastsPage()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Text(
                  (authProvider.user?.displayName ??
                          authProvider.user?.email ??
                          'U')
                      .substring(0, 1)
                      .toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search podcasts...',
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainer,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
