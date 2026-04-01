import 'package:cozbak/core/services/firebase/firebase_providers.dart';
import 'package:cozbak/features/auth/providers/register_form_provider.dart';
import 'package:cozbak/shared/widgets/app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final registerSubmitProvider =
    AsyncNotifierProvider<RegisterSubmitNotifier, void>(
  RegisterSubmitNotifier.new,
);

class RegisterSubmitNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit() async {
    final form = ref.read(registerFormProvider);

    if (form.name.trim().isEmpty) {
      AppSnackbar.showError('Ad soyad zorunlu');
      return;
    }

    if (form.email.trim().isEmpty) {
      AppSnackbar.showError('E-posta zorunlu');
      return;
    }

    if (form.password.isEmpty) {
      AppSnackbar.showError('Şifre zorunlu');
      return;
    }

    if (form.password.length < 6) {
      AppSnackbar.showError('Şifre en az 6 karakter olmalı');
      return;
    }

    if (form.password != form.confirmPassword) {
      AppSnackbar.showError('Şifreler eşleşmiyor');
      return;
    }

    state = const AsyncLoading();

    try {
      final authService = ref.read(authServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      final credential = await authService.registerWithEmail(
        email: form.email,
        password: form.password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(form.name.trim());
        await user.reload();

        final refreshedUser = authService.currentUser;
        if (refreshedUser != null) {
          await firestoreService.createOrUpdateUser(refreshedUser);
        }
      }

      state = const AsyncData(null);
      ref.read(registerFormProvider.notifier).clear();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      AppSnackbar.showError('Kayıt sırasında hata oluştu');
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();

    try {
      final authService = ref.read(authServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      final credential = await authService.signInWithGoogle();
      final user = credential.user;

      if (user != null) {
        await firestoreService.createOrUpdateUser(user);
      }

      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      AppSnackbar.showError('Google ile giriş başarısız');
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();

    try {
      final authService = ref.read(authServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      final credential = await authService.signInWithApple();
      final user = credential.user;

      if (user != null) {
        await firestoreService.createOrUpdateUser(user);
      }

      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      AppSnackbar.showError('Apple ile giriş başarısız');
    }
  }
}