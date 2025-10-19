import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/auth_provider.dart';
import '../../Providers/navigation_provider.dart';
import './widgets/profile_history_tab.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _displayNameController = TextEditingController();
  late final FocusNode _displayNameFocusNode;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _displayNameFocusNode = FocusNode();
    _tabController = TabController(length: 2, vsync: this);
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      _displayNameController.text = authProvider.user!.displayName ?? '';
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _displayNameFocusNode.dispose();
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _updateProfile(AuthProvider authProvider) async {
    try {
      // Update display name
      if (_displayNameController.text.isNotEmpty) {
        await authProvider.updateDisplayName(_displayNameController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error updating profile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final navProvider = context.watch<NavigationProvider>();
    final theme = Theme.of(context);

    // Unfocus the text field when navigating away from the profile page
    if (navProvider.selectedIndex != 3) {
      _displayNameFocusNode.unfocus();
    }

    if (!authProvider.isAuthenticated) {
      return Center(
        child: Text('You are not logged in.', style: theme.textTheme.bodyLarge),
      );
    }

    final user = authProvider.user;

    return Scaffold(
      body: Column(
        children: [
          // Profile header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ??
                                user?.email?.split('@')[0] ??
                                'User',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Settings'),
              Tab(text: 'History'),
            ],
          ),
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Settings tab
                _buildSettingsTab(authProvider),
                // History tab
                const ProfileHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _displayNameController,
              focusNode: _displayNameFocusNode,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
              onTapOutside: (event) {
                _displayNameFocusNode.unfocus();
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _updateProfile(authProvider),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Update Profile'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  authProvider.signOut();
                  final navProvider = context.read<NavigationProvider>();
                  navProvider.setSelectedIndex(0);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
