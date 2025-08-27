import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' show pow;

// Providers and Pages (assuming they exist as in the original code)
import 'Providers/navigation_provider.dart';
import 'Providers/auth_provider.dart';
import 'Pages/Auth/login_page.dart';
import 'Pages/Auth/signup_page.dart';

//==============================================================================
// 1. TOP-LEVEL WIDGET (Handles State and Business Logic)
//==============================================================================

class FloatingNavbar extends StatelessWidget {
  final dynamic pages;

  const FloatingNavbar({super.key, required this.pages});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navProvider = context.watch<NavigationProvider>();
    final authProvider = context.watch<AuthProvider>();

    // Define tabs dynamically based on authentication status
    final List<GNavInspiredButton> tabs = [
      GNavInspiredButton(icon: Icons.newspaper_rounded, text: 'Home'),
      GNavInspiredButton(icon: Icons.public_rounded, text: 'Global'),
      GNavInspiredButton(icon: Icons.podcasts_rounded, text: 'Podcast'),
      authProvider.isAuthenticated
          ? GNavInspiredButton(icon: Icons.person_outline, text: 'Profile')
          : GNavInspiredButton(icon: Icons.login, text: 'Login'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: GNavInspiredBar(
        selectedIndex: navProvider.selectedIndex,
        tabs: tabs,
        onTabChange: (index) {
          if (index == 3 && !authProvider.isAuthenticated) {
            final prevIndex = navProvider.selectedIndex;
            _showAuthModalSheet(context, navProvider, authProvider, prevIndex);
          } else {
            navProvider.setSelectedIndex(index);
          }
        },
      ),
    );
  }

  void _showAuthModalSheet(
    BuildContext context,
    NavigationProvider navProvider,
    AuthProvider authProvider,
    int previousIndex,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => const AuthModalSheet(),
    ).then((_) {
      if (authProvider.isAuthenticated) {
        navProvider.setSelectedIndex(3);
      } else {
        navProvider.restoreTo(previousIndex);
      }
    });
  }
}

//==============================================================================
// 2. NAVBAR CONTAINER WIDGET (Like GNav)
//==============================================================================

class GNavInspiredBar extends StatelessWidget {
  const GNavInspiredBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChange,
  });

  final List<GNavInspiredButton> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.map((button) {
          final int index = tabs.indexOf(button);
          final bool isActive = selectedIndex == index;

          return GNavAnimatedButton(
            key: button.key,
            active: isActive,
            icon: button.icon,
            text: button.text,
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.colorScheme.onSurfaceVariant,
            textColor: theme.colorScheme.onPrimary,
            onPressed: () => onTabChange(index),
          );
        }).toList(),
      ),
    );
  }
}

//==============================================================================
// 3. BUTTON CONFIGURATION WIDGET (A simplified GButton)
//==============================================================================

class GNavInspiredButton extends StatelessWidget {
  final IconData icon;
  final String text;

  const GNavInspiredButton({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
//==============================================================================
// 4. CORE ANIMATED BUTTON WIDGET (The Animation Engine)
//==============================================================================

class GNavAnimatedButton extends StatefulWidget {
  const GNavAnimatedButton({
    super.key,
    required this.active,
    required this.icon,
    required this.text,
    required this.onPressed,
    required this.activeColor,
    required this.inactiveColor,
    required this.textColor,
    // ✅ CHANGE 1: Increased overall animation speed
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOutCubic,
    this.gap = 8.0,
  });

  final bool active;
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final Color activeColor;
  final Color inactiveColor;
  final Color textColor;
  final Duration duration;
  final Curve curve;
  final double gap;

  @override
  State<GNavAnimatedButton> createState() => _GNavAnimatedButtonState();
}

class _GNavAnimatedButtonState extends State<GNavAnimatedButton>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Color?> _iconColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    if (widget.active) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant GNavAnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ CHANGE 2: Use different durations and curves for expand/collapse
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        HapticFeedback.lightImpact();
        // Animate EXPANSION with the default (faster) duration
        _controller.animateTo(
          1.0,
          duration: widget.duration,
          curve: widget.curve,
        );
      } else {
        // Animate COLLAPSE with a much shorter duration for a near-instant effect
        _controller.animateBack(
          0.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeIn,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Animate the icon color directly on the controller's value
    _iconColorAnimation = ColorTween(
      begin: widget.inactiveColor,
      end: widget.textColor,
    ).animate(_controller);

    return Semantics(
      label: widget.text,
      selected: widget.active,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(30),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // The controller's value is now curved directly by the `animateTo` calls
              final animationValue = _controller.value;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.activeColor.withOpacity(animationValue),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: _iconColorAnimation.value,
                      size: 22,
                    ),
                    const SizedBox(width: 4),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: animationValue,
                        child: Opacity(
                          opacity: pow(animationValue, 13).toDouble(),
                          child: Padding(
                            padding: EdgeInsets.only(left: widget.gap / 2),
                            child: Text(
                              widget.text,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(
                                color: widget.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

//==============================================================================
// AUTH MODAL SHEET (Unchanged)
//==============================================================================

class AuthModalSheet extends StatefulWidget {
  const AuthModalSheet({Key? key}) : super(key: key);

  @override
  State<AuthModalSheet> createState() => _AuthModalSheetState();
}

class _AuthModalSheetState extends State<AuthModalSheet> {
  bool _isLogin = true;

  void _switchToSignup() => setState(() => _isLogin = false);
  void _switchToLogin() => setState(() => _isLogin = true);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _isLogin
          ? LoginPage(onSwitchToSignup: _switchToSignup)
          : SignupPage(onSwitchToLogin: _switchToLogin),
    );
  }
}
