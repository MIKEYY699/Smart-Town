import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Shows the logged-in user's details and a Log out button.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _future;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;
    final row = await client
        .from('profiles')
        .select('full_name, role')
        .eq('id', userId)
        .single();
    return Map<String, dynamic>.from(row);
  }

  Future<void> _logOut() async {
    setState(() => _isLoggingOut = true);
    try {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      context.go(AppRoutes.authScreen);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoggingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not log out. Try again.')),
      );
    }
  }

  Future<void> _becomeProvider() async {
    final registered = await context.push<bool>(AppRoutes.becomeProviderScreen);
    if (registered == true && mounted) {
      setState(() => _future = _load());
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load your profile'),
                    TextButton(
                      onPressed: () => setState(() => _future = _load()),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              );
            }

            final name = (snapshot.data?['full_name'] as String?) ?? '';
            final role = (snapshot.data?['role'] as String?) ?? 'customer';
            final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: AppTheme.primaryContainer,
                    child: Text(
                      initial,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name.isEmpty ? 'No name set' : name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF5C5C5C),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role[0].toUpperCase() + role.substring(1),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                if (role == 'customer') ...[
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _becomeProvider,
                      icon: const Icon(Icons.handyman),
                      label: const Text('Become a provider'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _isLoggingOut ? null : _logOut,
                    icon: const Icon(Icons.logout),
                    label: Text(_isLoggingOut ? 'Logging out...' : 'Log out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
