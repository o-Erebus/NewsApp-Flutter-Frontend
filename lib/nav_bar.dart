import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

import 'Providers/navigation_provider.dart';

class FloatingNavbar extends StatelessWidget {
  final dynamic pages;

  const FloatingNavbar({super.key , required this.pages});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    return Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(40),
        ),
        child: GNav(
          rippleColor: Colors.grey[300]!,
          hoverColor: Colors.grey[100]!,
          gap: 8,

          iconSize: 24,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: Colors.grey.shade900,
          color: Colors.white70,
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
