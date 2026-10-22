import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import './widgets/category_grid_widget.dart';
import './widgets/emergency_strip_widget.dart';
import './widgets/home_app_bar_widget.dart';
import './widgets/home_search_bar_widget.dart';
import './widgets/home_tagline_widget.dart';
import './widgets/nearby_providers_widget.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/avatar_widget.dart';

import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  // TODO: Replace with Riverpod/Bloc for production
  String _userName = '';
  String _community = '';
  String? _avatarUrl;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final Stream<List<Map<String, dynamic>>> _notificationStream;

  @override
  void initState() {
    super.initState();
    _notificationStream = Supabase.instance.client
        .from('notifications')
        .stream(primaryKey: ['id']);

    _loadProfile();
    profileChangedNotifier.addListener(_loadProfile);
  }

  @override
  void dispose() {
    profileChangedNotifier.removeListener(_loadProfile);
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final client = Supabase.instance.client;
      final row = await client
          .from('profiles')
          .select('full_name, avatar_url, communities(name, city)')
          .eq('id', client.auth.currentUser!.id)
          .single();

      final communityData = row['communities'];
      final fullName = (row['full_name'] as String? ?? '').trim();

      if (!mounted) return;
      setState(() {
        _avatarUrl = row['avatar_url'] as String?;
        _userName = fullName.split(' ').first;
        _community = communityData is Map
            ? '${communityData['name']}, ${communityData['city']}'
            : '';
      });
    } catch (_) {
      // Keep the screen working even if the profile could not load.
    }
  }

  String _searchQuery = '';

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }

  void _onCategoryTap(String categoryId, String categoryName) {
    final category = categoryName == 'AC & Repair' ? 'AC Repair' : categoryName;
    context.push(AppRoutes.providersByCategoryScreen, extra: category);
  }

  void _onProviderTap(String providerId) {
    context.push(AppRoutes.providerProfileScreen, extra: providerId);
  }

  void _onEmergencyTap() {
    context.push(AppRoutes.emergencyScreen);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _notificationStream,
                builder: (context, snapshot) {
                  final unread = (snapshot.data ?? [])
                      .where((n) => n['read_at'] == null)
                      .length;
                  return HomeAppBarWidget(
                    userName: _userName,
                    community: _community,
                    unreadCount: unread,
                    avatarUrl: _avatarUrl,
                    onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                    onNotificationTap: () =>
                        context.push(AppRoutes.notificationsScreen),
                    onAvatarTap: () => context.go('/profile'),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: HomeTaglineWidget(community: _community),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: HomeSearchBarWidget(
                  onChanged: _onSearchChanged,
                  onSubmitted: (query) =>
                      context.push(AppRoutes.searchScreen, extra: query.trim()),
                  onFilterTap: () {},
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: EmergencyStripWidget(onTap: _onEmergencyTap),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                child: CategoryGridWidget(
                  isTablet: isTablet,
                  onCategoryTap: _onCategoryTap,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                child: NearbyProvidersWidget(onProviderTap: _onProviderTap),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}
