import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/wallet/wallet_home_screen.dart';
import '../../presentation/screens/topup/topup_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/wallet' : '/signup',
    routes: [
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/wallet',
        name: 'wallet',
        builder: (context, state) => const WalletHomeScreen(),
      ),
      GoRoute(
        path: '/topup',
        name: 'topup',
        builder: (context, state) => const TopupScreen(),
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnSignup = state.matchedLocation == '/signup';
      final isOnLogin = state.matchedLocation == '/login';

      if (!isAuthenticated && !isOnSignup && !isOnLogin) return '/signup';
      if (isAuthenticated && (isOnSignup || isOnLogin)) return '/wallet';
      return null;
    },
  );
});
