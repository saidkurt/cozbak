import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_gradients.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_shadows.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:cozbak/features/home/widget/home_stats_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    super.key,
    required this.userAsync,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  final AsyncValue<dynamic> userAsync;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    return userAsync.when(
      data: (user) {
        final credits = user?.credits ?? 0;
        final totalAnalyses = user?.totalAnalyses ?? 0;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.blurGreen,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            boxShadow: AppShadows.ambientLg,
          ),
          child:  Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sorunu Hemen Çöz',
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Fotoğraf çek, yükle ve adım adım çözümü gör.',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _HeroActionButton(
                            icon: Icons.photo_camera_rounded,
                            label: 'Kamerayla Çek',
                            isPrimary: true,
                            onTap: onCameraTap,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HeroActionButton(
                            icon: Icons.image_search_rounded,
                            label: 'Galeriden Yükle',
                            isPrimary: false,
                            onTap: onGalleryTap,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.18,
                            ),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                         Expanded(
  child: InfoStatCard(
    title: 'Kalan Çözüm',
    value: '$credits',
    icon: Icons.auto_awesome_rounded,
    gradient: const LinearGradient(
      colors: [
        AppColors.primary,
        AppColors.secondary,
      ],
    ),
  ),
),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InfoStatCard(
                              title: 'Toplam Çözüm',
                              value: '$totalAnalyses',
                              icon: Icons.check_circle_rounded,
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.secondary,
                                  AppColors.success,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        );
      },
      loading: () => Container(
        height: 210,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
      ),
      error: (_, __) => Container(
        height: 210,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  const _HeroActionButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          height: 80,
          decoration: BoxDecoration(
            gradient: isPrimary ? AppGradients.primaryCta : null,
            color: isPrimary ? null : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: isPrimary ? AppShadows.ambientMd : null,
            border: isPrimary
                ? null
                : Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.35),
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isPrimary ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isPrimary
                      ? AppTextStyles.buttonMd
                      : AppTextStyles.labelLg.copyWith(
                          color: AppColors.primary,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


