import 'dart:async';

import 'package:cozbak/app/router/route_names.dart';
import 'package:cozbak/features/analysis/screen/analysis_loading_screen.dart';
import 'package:cozbak/features/analysis/screen/analysis_preview_screen.dart';
import 'package:cozbak/features/analysis/screen/analysis_result_screen.dart';
import 'package:cozbak/features/analysis/screen/analysis_scrop_screen.dart';
import 'package:cozbak/features/auth/providers/auth_provider.dart';
import 'package:cozbak/features/auth/screens/forgot_password_screen.dart';
import 'package:cozbak/features/auth/screens/login_screen.dart';
import 'package:cozbak/features/auth/screens/register_screen.dart';
import 'package:cozbak/features/auth/screens/success_password_reset_screen.dart';
import 'package:cozbak/features/history/screen/history_screen.dart';
import 'package:cozbak/features/home/screen/home_screen.dart';
import 'package:cozbak/features/onboarding/screen/onboarding_screen.dart';
import 'package:cozbak/features/profile/screen/profile_screen.dart';
import 'package:cozbak/features/splash/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = RouterRefreshNotifier(
    ref.watch(authStateProvider.stream),
  );

  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: refreshNotifier,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SplashScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: RouteNames.onboarding,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        pageBuilder: (context, state) => const MaterialPage(
          child: LoginScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.register,
        name: RouteNames.register,
        pageBuilder: (context, state) => const MaterialPage(
          child: RegisterScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: RouteNames.forgotPassword,
        pageBuilder: (context, state) => const MaterialPage(
          child: ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.home,
        name: RouteNames.home,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: HomeScreen(),
        ),
      ),
       GoRoute(
        path: RouteNames.successResetPasswordSent,
        name: RouteNames.successResetPasswordSent,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SuccessPasswordResetScreen(),
        ),
      ),
         GoRoute(
        path: RouteNames.profile,
        name: RouteNames.profile,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ProfileScreen(),
        ),
      ),
         GoRoute(
        path: RouteNames.history,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: HistoryScreen(),
        ),
      ),
      GoRoute(
  path: RouteNames.analysisCrop,
  builder: (context, state) {
    return AnalysisCropScreen();
  },
),
       GoRoute(
  path: RouteNames.analysisLoading,
  builder: (context, state) => const AnalysisLoadingScreen(),
),
GoRoute(
  path: RouteNames.analysisPreview,
  builder: (context, state) => const AnalysisPreviewScreen(),
),
GoRoute(
  path: RouteNames.analysisResult,
  builder: (context, state) => const AnalysisResultScreen(),
),
    ],
    redirect: (context, state) {
  final authState = ref.read(authStateProvider);
  final location = state.matchedLocation;

  final isSplash = location == RouteNames.splash;
  final isOnboarding = location == RouteNames.onboarding;
  final isLogin = location == RouteNames.login;
  final isRegister = location == RouteNames.register;
  final isForgotPassword = location == RouteNames.forgotPassword;
  final isSuccessPassword =
      location == RouteNames.successResetPasswordSent;
  final isHome = location == RouteNames.home;

  if (authState.isLoading) {
    return isSplash ? null : RouteNames.splash;
  }

  if (authState.hasError) {
    return isOnboarding ? null : RouteNames.onboarding;
  }

  final user = authState.value;
  final isLoggedIn = user != null;

  if (!isLoggedIn) {
    if (isOnboarding ||
        isLogin ||
        isRegister ||
        isForgotPassword ||
        isSuccessPassword) {
      return null;
    }

    return RouteNames.onboarding;
  }

  // giriş yapmışsa sadece onboarding/login/register'da kalmasın
  if (isSplash || isOnboarding || isLogin || isRegister) {
    return RouteNames.home;
  }

  // forgot password ve success ekranlarına girmesine izin ver
  if (isForgotPassword || isSuccessPassword || isHome) {
    return null;
  }

  return null;
},
  );
});

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}