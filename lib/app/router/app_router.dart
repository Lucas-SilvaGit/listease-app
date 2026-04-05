import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/session_controller.dart';
import '../../features/lists/presentation/dashboard_page.dart';
import '../../features/lists/presentation/list_detail_page.dart';
import '../../features/products/presentation/products_page.dart';
import '../../features/profile/presentation/profile_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final sessionState = ref.watch(sessionControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = sessionState.valueOrNull?.isAuthenticated ?? false;
      final isLoading = sessionState.isLoading;
      final isLoginRoute = state.matchedLocation == '/login';

      if (isLoading) {
        return isLoginRoute ? null : '/login';
      }

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      if (isLoggedIn && isLoginRoute) {
        return '/lists';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/lists',
        builder: (context, state) => const DashboardPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return ListDetailPage(listId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});
