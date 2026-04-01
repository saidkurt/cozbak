import 'package:cozbak/app/router/route_names.dart';
import 'package:cozbak/core/services/firebase/firebase_providers.dart';
import 'package:cozbak/features/auth/providers/forgot_password_form_provider.dart';
import 'package:cozbak/shared/widgets/app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final forgotPasswordSubmitProvider = StateNotifierProvider.autoDispose<
    ForgotPasswordSubmitNotifier, AsyncValue<void>>(
  (ref) => ForgotPasswordSubmitNotifier(ref),
);

class ForgotPasswordSubmitNotifier
    extends StateNotifier<AsyncValue<void>> {
  ForgotPasswordSubmitNotifier(this.ref)
      : super(const AsyncData(null));

  final Ref ref;

  Future<void> submit(GoRouter router) async {
    final form = ref.read(forgotPasswordFormProvider);
    final email = form.email.trim();

    if (email.isEmpty) {
      AppSnackbar.showError('E-posta adresi zorunlu');
      return;
    }

    state = const AsyncLoading();

    try {
      final authService = ref.read(authServiceProvider);

      await authService.sendPasswordResetEmail(email: email);

      ref.read(forgotPasswordFormProvider.notifier).clear();

      state = const AsyncData(null);

       router.push(RouteNames.successResetPasswordSent);

    } catch (e, st) {
      state = AsyncError(e, st);

      AppSnackbar.showError(
        'Sıfırlama bağlantısı gönderilemedi',
      );
    }
  }
}