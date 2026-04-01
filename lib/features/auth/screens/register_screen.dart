import 'package:cozbak/app/router/route_names.dart';
import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:cozbak/features/auth/providers/register_form_provider.dart';
import 'package:cozbak/features/auth/providers/register_submit_provider.dart';
import 'package:cozbak/features/auth/widgets/social_login_button.dart';
import 'package:cozbak/shared/widgets/app_aura_background.dart';
import 'package:cozbak/shared/widgets/app_gradient_button.dart';
import 'package:cozbak/shared/widgets/app_text_field.dart';
import 'package:cozbak/shared/widgets/auth_password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(registerFormProvider);
    final submitState = ref.watch(registerSubmitProvider);
    final submitNotifier = ref.read(registerSubmitProvider.notifier);

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
               
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    18,
                    AppSpacing.screenHorizontal,
                    AppSpacing.screenBottom + bottomInset,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 18,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),

                          Text(
                            'Hesap Oluştur',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.displayMd.copyWith(
                              fontSize: 30,
                              height: 1.08,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Sorularını çözmeye hemen başla.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMd,
                          ),

                          const SizedBox(height: 24),

                          AppTextField(
                            labelText: 'AD SOYAD',
                            hintText: 'Ad Soyad',
                            initialValue: form.name,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              ref
                                  .read(registerFormProvider.notifier)
                                  .updateName(value);
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          AppTextField(
                            labelText: 'E-POSTA',
                            hintText: 'E-posta',
                            initialValue: form.email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              ref
                                  .read(registerFormProvider.notifier)
                                  .updateEmail(value);
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          AuthPasswordField(
                            label: 'ŞİFRE',
                            hintText: 'Şifre',
                            topRightText: '',
                            onTopRightTap: () {},
                            initialValue: form.password,
                            onChanged: (value) {
                              ref
                                  .read(registerFormProvider.notifier)
                                  .updatePassword(value);
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          AuthPasswordField(
                            label: 'ŞİFRE TEKRAR',
                            hintText: 'Şifre Tekrar',
                            topRightText: '',
                            onTopRightTap: () {},
                            initialValue: form.confirmPassword,
                            onChanged: (value) {
                              ref
                                  .read(registerFormProvider.notifier)
                                  .updateConfirmPassword(value);
                            },
                            onSubmitted: (_) => submitNotifier.submit(),
                          ),

                          const SizedBox(height: 20),

                          AppGradientButton(
                            text: 'Kayıt Ol',
                            isLoading: submitState.isLoading,
                            onPressed: () => submitNotifier.submit(),
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppColors.outlineVariant.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                child: Text(
                                  'VEYA',
                                  style: AppTextStyles.labelMd.copyWith(
                                    letterSpacing: 1.4,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppColors.outlineVariant.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          SocialLoginButton.google(
                            label: 'Google',
                            enabled: !submitState.isLoading,
                            onPressed: () async {
                              await submitNotifier.signInWithGoogle();
                            },
                          ),
                          const SizedBox(height: 12),

                          SocialLoginButton.apple(
                            label: 'Apple',
                            enabled: !submitState.isLoading,
                            onPressed: () async {
                              await submitNotifier.signInWithApple();
                            },
                          ),

                          const Spacer(),

                          const SizedBox(height: 18),

                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              children: [
                                Text(
                                  'Zaten hesabım var mı?',
                                  style: AppTextStyles.bodyMd,
                                ),
                                GestureDetector(
                                  onTap: () => context.push(RouteNames.login),
                                  child: Text(
                                    'Giriş Yap',
                                    style: AppTextStyles.labelLg.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),
                        ],
                      ),
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