import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aprecture/screens/navigation_shell.dart';

// Screens
import 'package:aprecture/screens/tabs/apps_screen.dart';
import 'package:aprecture/screens/app_details_screen.dart';
import 'package:aprecture/screens/tabs/search_screen.dart';
import 'package:aprecture/screens/tabs/settings_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/apps',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return NavigationShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/apps',
              builder: (context, state) => const AppsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/app-details/:id',
      builder: (context, state) {
        final appId = state.pathParameters['id']!;
        return AppDetailsScreen(appId: appId);
      },
    ),
  ],
);
