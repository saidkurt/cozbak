import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/features/auth/providers/forgot_password_form_provider.dart';
import 'package:cozbak/features/auth/providers/forgot_password_submit_provider.dart';
import 'package:cozbak/shared/widgets/app_aura_background.dart';
import 'package:cozbak/shared/widgets/app_gradient_button.dart';
import 'package:cozbak/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SuccessPasswordResetScreen extends ConsumerStatefulWidget {
  const SuccessPasswordResetScreen({super.key});

  @override
  ConsumerState<SuccessPasswordResetScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<SuccessPasswordResetScreen> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(forgotPasswordSubmitProvider);
    final submitNotifier = ref.read(forgotPasswordSubmitProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppAuraBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              child: Column(
                children: [
                  AppTextField(
                    labelText: 'E-POSTA ADRESİ',
                    hintText: 'E-posta Adresi',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      ref
                          .read(forgotPasswordFormProvider.notifier)
                          .updateEmail(value);
                    },
                    onSubmitted: (_) {
                      submitNotifier.submit(GoRouter.of(context));
                    },
                  ),
                  const SizedBox(height: 24),
                  AppGradientButton(
                    text: 'Sıfırlama Bağlantısı Gönder',
                    isLoading: submitState is AsyncLoading,
                    onPressed: () async {
                      await submitNotifier.submit(GoRouter.of(context));
                      if (mounted) {
                        _emailController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}