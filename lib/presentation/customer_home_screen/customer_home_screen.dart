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
import './widgets/specialty_scroll_widget.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  // TODO: Replace with Riverpod/Bloc for production
  final String _userName = 'Adnan';
  final String _community = 'Model Town, Gujranwala';
  String _searchQuery = '';

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }

  void _onCategoryTap(String categoryId, String categoryName) {
    context.push(AppRoutes.providerProfileScreen, extra: categoryId);
  }

  void _onProviderTap(String providerId) {
    context.push(AppRoutes.providerProfileScreen, extra: providerId);
  }

  void _onEmergencyTap() {
    // TODO: Navigate to emergency services screen
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: HomeAppBarWidget(
                userName: _userName,
                community: _community,
                onNotificationTap: () {},
                onAvatarTap: () {},
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                child: SpecialtyScrollWidget(onProviderTap: _onProviderTap),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}
