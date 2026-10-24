import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show FileOptions, Supabase;

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar_widget.dart';

/// Shows the logged-in user's details and a Log out button.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _future;
  bool _isLoggingOut = false;
  bool _uploadingPhoto = false;

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
        .select('full_name, role, avatar_url')
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
      setState(() {
        _future = _load();
      });
    }
  }

  Future<void> _changePhoto() async {
    if (_uploadingPhoto) return;
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (picked == null) return;

      setState(() {
        _uploadingPhoto = true;
      });

      final client = Supabase.instance.client;
      final userId = client.auth.currentUser!.id;
      final extension = picked.path.split('.').last.toLowerCase();
      final isPng = extension == 'png';
      final isWebp = extension == 'webp';
      final fileExtension = isPng ? 'png' : (isWebp ? 'webp' : 'jpg');
      final contentType = isPng
          ? 'image/png'
          : (isWebp ? 'image/webp' : 'image/jpeg');

      final path =
          '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      await client.storage
          .from('avatars')
          .upload(
            path,
            File(picked.path),
            fileOptions: FileOptions(contentType: contentType),
          );
      final url = client.storage.from('avatars').getPublicUrl(path);

      await client
          .from('profiles')
          .update({'avatar_url': url})
          .eq('id', userId);
      // Providers show the same photo on their listing.
      await client
          .from('providers')
          .update({'photo_url': url})
          .eq('user_id', userId);

      profileChangedNotifier.value++;
      if (!mounted) return;
      setState(() {
        _future = _load();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not upload your photo. Try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingPhoto = false;
        });
      }
    }
  }

  Future<void> _editProfile() async {
    final saved = await context.push<bool>(AppRoutes.editProviderScreen);
    if (saved == true && mounted) {
      setState(() {
        _future = _load();
      });
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text(
          'This permanently deletes your account, requests and messages. '
          'It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final client = Supabase.instance.client;
      await client.rpc('delete_my_account');
      try {
        await client.auth.signOut();
      } catch (_) {
        // The account is already gone, so signing out can fail. That is fine.
      }
      if (!mounted) return;
      context.go(AppRoutes.authScreen);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete your account. Try again.'),
        ),
      );
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
                      onPressed: () {
                        setState(() {
                          _future = _load();
                        });
                      },
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              );
            }

            final name = (snapshot.data?['full_name'] as String?) ?? '';
            final role = (snapshot.data?['role'] as String?) ?? 'customer';
            final avatarUrl = snapshot.data?['avatar_url'] as String?;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _changePhoto,
                    child: Stack(
                      children: [
                        AvatarWidget(
                          name: name,
                          imageUrl: avatarUrl,
                          radius: 48,
                        ),
                        if (_uploadingPhoto)
                          const Positioned.fill(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
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
                if (role == 'admin') ...[
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push(AppRoutes.adminScreen),
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Admin panel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (role == 'provider') ...[
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.push(AppRoutes.providerDashboardScreen),
                      icon: const Icon(Icons.dashboard),
                      label: const Text('Provider dashboard'),
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
                    onPressed: _editProfile,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit profile'),
                  ),
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _deleteAccount,
                  child: const Text(
                    'Delete my account',
                    style: TextStyle(color: Color(0xFF9E9E9E)),
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
