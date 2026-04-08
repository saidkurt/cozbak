import 'package:cozbak/core/services/firebase/firebase_providers.dart';
import 'package:cozbak/features/auth/providers/login_form_provider.dart';
import 'package:cozbak/shared/widgets/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginSubmitProvider =
    AsyncNotifierProvider<LoginSubmitNotifier, void>(LoginSubmitNotifier.new);

class LoginSubmitNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit() async {
    final form = ref.read(loginFormProvider);

    if (form.email.trim().isEmpty) {
      AppSnackbar.showError('E-posta adresinizi girin.');
      return;
    }

    if (form.password.trim().isEmpty) {
      AppSnackbar.showError('Şifrenizi girin.');
      return;
    }

    state = const AsyncLoading();

    try {
      final authService = ref.read(authServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      final credential = await authService.signInWithEmail(
        email: form.email,
        password: form.password,
      );

      final user = credential.user;
      if (user != null) {
        await firestoreService.createOrUpdateUser(user);
        
      }

      state = const AsyncData(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncError(e, st);
      AppSnackbar.showError(_mapFirebaseError(e));
    } catch (e, st) {
      state = AsyncError(e, st);
      AppSnackbar.showError('Giriş yapılırken beklenmeyen bir hata oluştu.');
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Geçerli bir e-posta adresi girin.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'E-posta veya şifre hatalı.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin.';
      default:
        return e.message ?? 'Giriş yapılamadı.';
    }
  }
}