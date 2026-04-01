import 'package:cozbak/core/services/firebase/firebase_providers.dart';
import 'package:cozbak/shared/widgets/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authActionProvider = Provider<AuthActionController>((ref) {
  return AuthActionController(ref);
});

class AuthActionController {
  AuthActionController(this.ref);

  final Ref ref;

  Future<void> signInWithGoogle() async {
    try {
      final authService = ref.read(authServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      final credential = await authService.signInWithGoogle();
      final user = credential.user;

      if (user != null) {
        await firestoreService.createOrUpdateUser(user);
      }

      AppSnackbar.showSuccess('Google ile giriş başarılı.');
    } on FirebaseAuthException catch (e) {
      AppSnackbar.showError(_mapFirebaseError(e));
    } catch (_) {
      AppSnackbar.showError('Google ile giriş yapılamadı.');
    }
  }

  Future<void> signInWithApple() async {
    try {
      final authService = ref.read(authServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      final credential = await authService.signInWithApple();
      final user = credential.user;

      if (user != null) {
        await firestoreService.createOrUpdateUser(user);
      }

      AppSnackbar.showSuccess('iOS ile giriş başarılı.');
    } on FirebaseAuthException catch (e) {
      AppSnackbar.showError(_mapFirebaseError(e));
    } catch (_) {
      AppSnackbar.showError('iOS ile giriş yapılamadı.');
    }
  }

  Future<void> signOut() async {
    try {
      await ref.read(authServiceProvider).signOut();
    } catch (_) {
      AppSnackbar.showError('Çıkış yapılırken hata oluştu.');
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
      case 'aborted-by-user':
        return 'İşlem iptal edildi.';
      default:
        return e.message ?? 'Bir hata oluştu.';
    }
  }
}