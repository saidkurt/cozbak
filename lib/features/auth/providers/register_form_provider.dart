import 'package:flutter_riverpod/flutter_riverpod.dart';

final registerFormProvider =
    NotifierProvider<RegisterFormNotifier, RegisterFormState>(
  RegisterFormNotifier.new,
);

class RegisterFormState {
  const RegisterFormState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
  });

  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  RegisterFormState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
  }) {
    return RegisterFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}

class RegisterFormNotifier extends Notifier<RegisterFormState> {
  @override
  RegisterFormState build() {
    return const RegisterFormState();
  }

  void updateName(String value) {
    state = state.copyWith(name: value);
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value);
  }

  void updateConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value);
  }

  void clear() {
    state = const RegisterFormState();
  }
}