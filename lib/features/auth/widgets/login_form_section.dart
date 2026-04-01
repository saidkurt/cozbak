import 'package:cozbak/app/router/route_names.dart';
import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:cozbak/features/auth/providers/auth_action_provider.dart';
import 'package:cozbak/features/auth/providers/login_form_provider.dart';
import 'package:cozbak/features/auth/providers/login_submit_provider.dart';
import 'package:cozbak/features/auth/widgets/social_login_button.dart';
import 'package:cozbak/shared/widgets/app_gradient_button.dart';
import 'package:cozbak/shared/widgets/app_text_field.dart';
import 'package:cozbak/shared/widgets/auth_password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginFormSection extends ConsumerWidget {
  const LoginFormSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(loginFormProvider);
    final submitState = ref.watch(loginSubmitProvider);
    final isLoading = submitState.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xxl),

        Center(
          child: Text(
            'Hoş Geldin',
            style: AppTextStyles.displayMd,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Devam etmek için hesabına giriş yap.',
          style: AppTextStyles.bodyLg.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        AppTextField(
          labelText: 'E-posta Adresi',
          hintText: 'email@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          initialValue: form.email,
          onChanged: (value) {
            ref.read(loginFormProvider.notifier).setEmail(value);
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        AuthPasswordField(
          label: 'Şifre',
          hintText: '••••••••',
          topRightText: 'Şifremi Unuttum?',
          onTopRightTap: () => context.push(RouteNames.forgotPassword),
          initialValue: form.password,
          onChanged: (value) {
            ref.read(loginFormProvider.notifier).setPassword(value);
          },
          onSubmitted: (_) async {
            await ref.read(loginSubmitProvider.notifier).submit();
          },
        ),

        const SizedBox(height: AppSpacing.xl),

        AppGradientButton(
          text: 'Giriş Yap',
          icon: Icons.arrow_forward_rounded,
          isLoading: isLoading,
          onPressed: isLoading
              ? null
              : () async {
                  await ref.read(loginSubmitProvider.notifier).submit();
                },
        ),

        const SizedBox(height: AppSpacing.xl),

        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.outlineVariant.withValues(alpha: 0.40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'VEYA',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.outlineVariant.withValues(alpha: 0.40),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        SocialLoginButton.google(
          label: 'Google',
          enabled: !isLoading,
          onPressed: () async {
            await ref.read(authActionProvider).signInWithGoogle();
          },
        ),

        const SizedBox(height: AppSpacing.md),

        SocialLoginButton.apple(
          label: 'iOS',
          enabled: !isLoading,
          onPressed: () async {
            await ref.read(authActionProvider).signInWithApple();
          },
        ),

        const SizedBox(height: 56),

        Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Hesabın yok mu? ',
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(RouteNames.register),
                child: Text(
                  'Kayıt Ol',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}