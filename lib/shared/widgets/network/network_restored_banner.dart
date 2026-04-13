import 'package:flutter/material.dart';

import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_shadows.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';

class NetworkRestoredBanner extends StatelessWidget {
  const NetworkRestoredBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(
            color: AppColors.correctContainer,
          ),
          boxShadow: AppShadows.ambientMd,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Bağlantı geri geldi',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.onSurface,
                decoration: TextDecoration.none,
                backgroundColor: Colors.transparent,
                shadows: const [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}