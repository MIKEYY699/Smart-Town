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

class AppRoutes {
  static const String initial = '/';
  static const String authScreen = '/auth';
  static const String myRequestsScreen = '/my-requests';
    static const String becomeProviderScreen = '/become-provider';
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
          ],
        ),
        StatefulShellBranch(
          routes: [
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
