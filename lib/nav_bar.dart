import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

import 'Providers/navigation_provider.dart';

class FloatingNavbar extends StatelessWidget {
  final dynamic pages;

  const FloatingNavbar({super.key, required this.pages});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navProvider = context.watch<NavigationProvider>();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Using theme surface color
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GNav(
        rippleColor: theme.colorScheme.onSurface.withValues(alpha: .1),
        hoverColor: theme.colorScheme.onSurface.withValues(alpha: .1),
        gap: 8,
        iconSize: 24,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        duration: const Duration(milliseconds: 400),
        tabBackgroundColor: theme.colorScheme.surfaceContainerHighest, // Card surface color
        color: theme.colorScheme.onSurfaceVariant, // Secondary text color
        activeColor: theme.colorScheme.onPrimary, // Accent color for active tab
        textStyle: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          GButton(icon: Icons.newspaper_rounded, text: 'Home'),
          GButton(icon: Icons.public_rounded, text: 'Global'),
          GButton(icon: Icons.podcasts_rounded, text: 'Podcast'),
          GButton(icon: Icons.person_outline, text: 'Profile'),
        ],
        selectedIndex: navProvider.selectedIndex,
        onTabChange: (index) => navProvider.setSelectedIndex(index),
      ),
    );
  }
}