import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import './avatar_widget.dart';

/// The side menu that opens from the home screen.
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _name = '';
  String _role = 'customer';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final client = Supabase.instance.client;
      final row = await client
          .from('profiles')
          .select('full_name, role, avatar_url')
          .eq('id', client.auth.currentUser!.id)
          .single();
      if (!mounted) return;
      setState(() {
        _name = (row['full_name'] as String? ?? '').trim();
        _role = row['role'] as String? ?? 'customer';
        _avatarUrl = row['avatar_url'] as String?;
      });
    } catch (_) {
      // The menu still works without the header details.
    }
  }

  // Close the menu first, then move.
  void _go(String route) {
    Navigator.of(context).pop();
    context.go(route);
  }

  void _open(String route) {
    Navigator.of(context).pop();
    context.push(route);
  }

  Future<void> _logOut() async {
    Navigator.of(context).pop();
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // Go to the login screen anyway.
    }
    if (!mounted) return;
    context.go(AppRoutes.authScreen);
  }

  Widget _item(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1A1A1A)),
      title: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  AvatarWidget(name: _name, imageUrl: _avatarUrl, radius: 30),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name.isEmpty ? 'Welcome' : _name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF5C5C5C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                children: [
                  _item(Icons.home_outlined, 'Home',
                      () => _go(AppRoutes.customerHomeScreen)),
                  _item(Icons.assignment_outlined, 'My requests',
                      () => _go(AppRoutes.myRequestsScreen)),
                  _item(Icons.notifications_none, 'Notifications',
                      () => _open(AppRoutes.notificationsScreen)),
                  _item(Icons.emergency_outlined, 'Emergency services',
                      () => _open(AppRoutes.emergencyScreen)),
                  if (_role == 'provider')
                    _item(Icons.dashboard_outlined, 'Provider dashboard',
                        () => _open(AppRoutes.providerDashboardScreen)),
                  if (_role == 'customer')
                    _item(Icons.handyman_outlined, 'Become a provider',
                        () => _open(AppRoutes.becomeProviderScreen)),
                  if (_role == 'admin')
                    _item(Icons.admin_panel_settings_outlined, 'Admin panel',
                        () => _open(AppRoutes.adminScreen)),
                  _item(Icons.person_outline, 'My profile',
                      () => _go('/profile')),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.error),
              title: Text(
                'Log out',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.error,
                ),
              ),
              onTap: _logOut,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
