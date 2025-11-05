import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Nexora/Providers/navigation_provider.dart';

import 'package:Nexora/Providers/podcast_provider.dart';
import 'widgets/mini_player.dart';
import 'widgets/featured_podcast_section.dart';
import 'widgets/trending_podcasts_section.dart';
import 'widgets/my_podcasts_section.dart';
// import 'widgets/top_channels_section.dart';

class PodcastPage extends StatefulWidget {
  const PodcastPage({super.key});

  @override
  State<PodcastPage> createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  late FocusNode _searchFocusNode;
  bool _showTrending = true;
  bool _navListenerAttached = false;
  VoidCallback? _navListener;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    // Initialize podcast data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PodcastProvider>().refreshAll();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_navListenerAttached) {
      final navProvider = context.read<NavigationProvider>();
      _navListener = () {
        // If the user navigated away from Podcast tab, unfocus the search
        if (navProvider.selectedIndex != 2) {
          // Unfocus the local FocusNode and clear any primary focus
          _searchFocusNode.unfocus();
          FocusScope.of(context).unfocus();
        }
      };
      navProvider.addListener(_navListener!);
      _navListenerAttached = true;
    }
  }

  @override
  void dispose() {
    // Remove navigation listener if attached
    if (_navListenerAttached) {
      try {
        context.read<NavigationProvider>().removeListener(_navListener!);
      } catch (_) {}
    }
    _searchFocusNode.dispose();
    super.dispose();
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
                onRefresh: () async {
                  // Only refresh the currently visible section
                  if (_showTrending) {
                    await podcastProvider.refreshTrendingPodcasts();
                  } else {
                    await podcastProvider.fetchUserPodcasts();
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(context),
                      const SizedBox(height: 20),

                      // // Search Bar
                      // _buildSearchBar(context),
                      // const SizedBox(height: 20),

                      // Toggle Pills (Trending / My Podcasts)

                      // Featured Podcast Section
                      const FeaturedPodcastSection(),
                      const SizedBox(height: 30),
                      _buildTogglePills(context),
                      const SizedBox(height: 20),
                      // Selected Section (Trending or My Podcasts)
                      if (_showTrending)
                        const TrendingPodcastsSection()
                      else
                        const MyPodcastsSection(),
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
        ],
      ),
    );
  }

  Widget _buildTogglePills(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showTrending = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _showTrending
                      ? colorScheme.primary
                      : colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    'Trending',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: _showTrending
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // When switching to My Podcasts, ensure we load the user's podcasts
                setState(() => _showTrending = false);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<PodcastProvider>().fetchUserPodcasts();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_showTrending
                      ? colorScheme.primary
                      : colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    'My Podcasts',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: !_showTrending
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
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
        focusNode: _searchFocusNode,
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
