import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/create_service_request_screen/create_service_request_screen.dart';
import '../presentation/customer_home_screen/customer_home_screen.dart';
import '../presentation/provider_profile_screen/provider_profile_screen.dart';
import '../widgets/app_scaffold.dart';

class AppRoutes {
  static const String initial = '/';
  static const String customerHomeScreen = '/customer-home-screen';
  static const String providerProfileScreen = '/provider-profile-screen';
  static const String createServiceRequestScreen =
      '/create-service-request-screen';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.initial,
  routes: [
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
              path: AppRoutes.createServiceRequestScreen,
              builder: (context, state) => const CreateServiceRequestScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
