import 'package:flutter_riverpod/flutter_riverpod.dart';

final forgotPasswordFormProvider = StateNotifierProvider.autoDispose<
    ForgotPasswordFormNotifier, ForgotPasswordFormState>(
  (ref) => ForgotPasswordFormNotifier(),
);

class ForgotPasswordFormState {
  const ForgotPasswordFormState({
    this.email = '',
  });

  final String email;

  ForgotPasswordFormState copyWith({
    String? email,
  }) {
    return ForgotPasswordFormState(
      email: email ?? this.email,
    );
  }
}

class ForgotPasswordFormNotifier
    extends StateNotifier<ForgotPasswordFormState> {
  ForgotPasswordFormNotifier()
      : super(const ForgotPasswordFormState());

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void clear() {
    state = const ForgotPasswordFormState();
  }
}