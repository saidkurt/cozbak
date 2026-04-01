import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:cozbak/features/auth/providers/forgot_password_form_provider.dart';
import 'package:cozbak/features/auth/providers/forgot_password_submit_provider.dart';
import 'package:cozbak/shared/widgets/app_aura_background.dart';
import 'package:cozbak/shared/widgets/app_gradient_button.dart';
import 'package:cozbak/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(forgotPasswordFormProvider);
    final submitState = ref.watch(forgotPasswordSubmitProvider);
    final submitNotifier = ref.read(forgotPasswordSubmitProvider.notifier);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: AppAuraBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    20,
                    AppSpacing.screenHorizontal,
                    AppSpacing.screenBottom + bottomInset,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),

                        const SizedBox(height: 44),

                        Center(
                          child: Container(
                            width: 188,
                            height: 188,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(36),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.mark_email_read_outlined,
                                size: 78,
                                color: AppColors.primary.withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        Text(
                          'Şifreni Mi Unuttun?',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayMd.copyWith(
                            fontSize: 28,
                            height: 1.15,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        Text(
                          'Kayıtlı e-posta adresini gir. Şifreni yenilemen için sana bir sıfırlama bağlantısı gönderelim.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLg.copyWith(
                            color: AppColors.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 32),

                        AppTextField(
                          labelText: 'E-POSTA ADRESİ',
                          hintText: 'E-posta Adresi',
                          initialValue: form.email,
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

                        const SizedBox(height: 18),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.info_outline_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Bağlantı birkaç dakika içinde e-posta adresine ulaşabilir.',
                                style: AppTextStyles.bodyMd.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        AppGradientButton(
                          text: 'Sıfırlama Bağlantısı Gönder',
                          isLoading: submitState is AsyncLoading,
                          onPressed: () {
                            submitNotifier.submit(GoRouter.of(context));
                          },
                        ),

                        const SizedBox(height: 28),

                        Center(
                          child: TextButton.icon(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: Text(
                              'Giriş ekranına dön',
                              style: AppTextStyles.labelLg.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}