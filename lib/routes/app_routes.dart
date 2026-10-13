import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/my_requests_screen/my_requests_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import '../presentation/auth_screen/auth_screen.dart';

import '../presentation/create_service_request_screen/create_service_request_screen.dart';
import '../presentation/customer_home_screen/customer_home_screen.dart';
import '../presentation/provider_profile_screen/provider_profile_screen.dart';
import '../widgets/app_scaffold.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/become_provider_screen/become_provider_screen.dart';
import '../presentation/provider_dashboard_screen/provider_dashboard_screen.dart';
import '../presentation/providers_by_category_screen/providers_by_category_screen.dart';
import '../presentation/search_providers_screen/search_providers_screen.dart';
import '../presentation/emergency_screen/emergency_screen.dart';
import '../presentation/chat_screen/chat_screen.dart';
import '../presentation/admin_screen/admin_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String authScreen = '/auth';
  static const String myRequestsScreen = '/my-requests';
  static const String becomeProviderScreen = '/become-provider';
  static const String providerDashboardScreen = '/provider-dashboard';
  static const String providersByCategoryScreen = '/providers-by-category';
  static const String searchScreen = '/search';
  static const String emergencyScreen = '/emergency';
  static const String chatScreen = '/chat';
  static const String adminScreen = '/admin';
  static const String customerHomeScreen = '/customer-home-screen';
  static const String providerProfileScreen = '/provider-profile-screen';
  static const String createServiceRequestScreen =
      '/create-service-request-screen';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.initial,
  redirect: (context, state) {
    final loggedIn = Supabase.instance.client.auth.currentSession != null;
    final goingToAuth = state.matchedLocation == AppRoutes.authScreen;
    if (!loggedIn && !goingToAuth) return AppRoutes.authScreen;
    if (loggedIn && goingToAuth) return AppRoutes.initial;
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.authScreen,
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: AppRoutes.initial,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const CustomerHomeScreen(),
        transitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.becomeProviderScreen,
      builder: (context, state) => const BecomeProviderScreen(),
    ),
    GoRoute(
      path: AppRoutes.providerDashboardScreen,
      builder: (context, state) => const ProviderDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.chatScreen,
      builder: (context, state) {
        final args = (state.extra as Map<String, dynamic>?) ?? const {};
        return ChatScreen(
          requestId: args['requestId'] as String? ?? '',
          title: args['title'] as String? ?? 'Chat',
          canSend: args['canSend'] as bool? ?? false,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.adminScreen,
      builder: (context, state) => const AdminScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.customerHomeScreen,
              builder: (context, state) => const CustomerHomeScreen(),
            ),
            GoRoute(
              path: AppRoutes.providersByCategoryScreen,
              builder: (context, state) {
                final category = state.extra as String? ?? '';
                return ProvidersByCategoryScreen(category: category);
              },
            ),
            GoRoute(
              path: AppRoutes.searchScreen,
              builder: (context, state) {
                final query = state.extra as String? ?? '';
                return SearchProvidersScreen(initialQuery: query);
              },
            ),
            GoRoute(
              path: AppRoutes.emergencyScreen,
              builder: (context, state) => const EmergencyScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/services',
              builder: (context, state) => const SearchProvidersScreen(),
            ),
            GoRoute(
              path: AppRoutes.providerProfileScreen,
              builder: (context, state) {
                final providerId = state.extra as String?;
                return ProviderProfileScreen(
                  providerId: providerId ?? 'default',
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.myRequestsScreen,
              builder: (context, state) => const MyRequestsScreen(),
            ),
            GoRoute(
              path: AppRoutes.createServiceRequestScreen,
              builder: (context, state) => const CreateServiceRequestScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
