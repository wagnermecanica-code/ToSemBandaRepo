// lib/app/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wegig_app/features/auth/presentation/pages/auth_page.dart';
import 'package:wegig_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:wegig_app/features/home/presentation/pages/home_page.dart';
import 'package:wegig_app/features/post/presentation/pages/post_detail_page.dart';
import 'package:wegig_app/features/profile/presentation/pages/view_profile_page.dart';

part 'app_router.g.dart';

/// Provider do GoRouter com auth guard e redirect logic
@riverpod
GoRouter goRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.value != null;
      final isGoingToAuth = state.matchedLocation == '/auth';

      // Se não está logado e não vai para auth, redireciona para auth
      if (!isLoggedIn && !isGoingToAuth) {
        return '/auth';
      }

      // Se está logado e vai para auth, redireciona para home
      if (isLoggedIn && isGoingToAuth) {
        return '/home';
      }

      // Caso contrário, permite navegação
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (BuildContext context, GoRouterState state) =>
            const AuthPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) =>
            const HomePage(),
      ),
      GoRoute(
        path: '/profile/:profileId',
        name: 'profile',
        builder: (BuildContext context, GoRouterState state) {
          final profileId = state.pathParameters['profileId']!;
          return ViewProfilePage(profileId: profileId);
        },
      ),
      GoRoute(
        path: '/post/:postId',
        name: 'postDetail',
        builder: (BuildContext context, GoRouterState state) {
          final postId = state.pathParameters['postId']!;
          return PostDetailPage(postId: postId);
        },
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página não encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Voltar ao Início'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Extension methods para navegação tipada
extension GoRouterExtension on BuildContext {
  void goToAuth() => go('/auth');
  void goToHome() => go('/home');
  void goToProfile(String profileId) => go('/profile/$profileId');
  void goToPostDetail(String postId) => go('/post/$postId');
}
