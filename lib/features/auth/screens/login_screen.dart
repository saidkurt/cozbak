import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/features/auth/widgets/login_form_section.dart';
import 'package:cozbak/shared/widgets/app_aura_background.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          const AppAuraBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    20,
                    AppSpacing.screenHorizontal,
                    AppSpacing.screenBottom,
                  ),
                  child: const LoginFormSection(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
