import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_gradients.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_shadows.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    super.key,
    required this.userAsync,
    required this.onCameraTap,
    required this.onGalleryTap,
    this.onWatchAdTap,
  });

  final AsyncValue<dynamic> userAsync;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback ? onWatchAdTap;

  @override
  Widget build(BuildContext context) {
    return userAsync.when(
      data: (user) {
        final credits = user?.credits ?? 0;
        final totalAnalyses = user?.totalAnalyses ?? 0;
        final hasCredits = credits > 0;

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
                    const SizedBox(height: 16),
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
                            child: hasCredits
                                ? _InfoStatCard(
                                    title: 'Kalan Çözüm',
                                    value: '$credits',
                                    icon: Icons.auto_awesome_rounded,
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.secondary,
                                      ],
                                    ),
                                  )
                                : _WatchAdCard(
                                    onTap: onWatchAdTap,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoStatCard(
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
          height: 62,
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

class _InfoStatCard extends StatelessWidget {
  const _InfoStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTextStyles.headlineMd.copyWith(fontSize: 26),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title.toUpperCase(),
            style: AppTextStyles.labelMd.copyWith(
              fontSize: 10,
              letterSpacing: 0.7,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchAdCard extends StatelessWidget {
  const _WatchAdCard({
    required this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Opacity(
          opacity: isDisabled ? 0.6 : 1,
          child: Ink(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFA43C),
                  Color(0xFFFF7A1A),
                ],
              ),
              boxShadow: AppShadows.ambientMd,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reklam İzle',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLg.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDisabled ? 'Hazırlanıyor...' : '+1 Hak Kazan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySm.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}