import 'dart:io';

import 'package:cozbak/app/router/route_names.dart';
import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_shadows.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:cozbak/features/analysis/provider/analysis_image_provider.dart';
import 'package:cozbak/features/analysis/provider/analysis_submit_provider.dart';
import 'package:cozbak/shared/widgets/app_aura_background.dart';
import 'package:cozbak/shared/widgets/app_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AnalysisPreviewScreen extends ConsumerWidget {
  const AnalysisPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageFile = ref.watch(analysisImageProvider);

    if (imageFile == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Stack(
          children: [
            const AppAuraBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _CircleBackButton(
                        onTap: () => context.pop(),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        boxShadow: AppShadows.ambientLg,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.image_not_supported_rounded,
                              color: AppColors.onSurfaceVariant,
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Fotoğraf bulunamadı',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headlineMd,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Lütfen yeniden kamera veya galeriden bir soru seç.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMd,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppGradientButton(
                            text: 'Geri Dön',
                            icon: Icons.arrow_back_rounded,
                            onPressed: () => context.pop(),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          const AppAuraBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _CircleBackButton(
                      onTap: () => context.pop(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Fotoğrafı kontrol et',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayMd.copyWith(
                            fontSize: 30,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text(
                            'Daha doğru sonuç için sorunun tamamı net, okunaklı ve ekrana tam sığmış olsun.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.onSurfaceVariant,
                              height: 1.55,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppRadii.xl),
                              boxShadow: AppShadows.ambientLg,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image(
                                    image: FileImage(imageFile),
                                    fit: BoxFit.contain,
                                  ),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white.withValues(alpha: 0.03),
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.05),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadii.xl),
                          ),
                          child: Column(
                            children: const [
                              _GuideItem(
                                icon: Icons.fullscreen_rounded,
                                text: 'Soru mümkünse ekrana tam sığsın',
                              ),
                              SizedBox(height: AppSpacing.md),
                              _GuideItem(
                                icon: Icons.visibility_rounded,
                                text: 'Yazılar net ve okunaklı görünsün',
                              ),
                              SizedBox(height: AppSpacing.md),
                              _GuideItem(
                                icon: Icons.light_mode_rounded,
                                text: 'Parlama, gölge ve bulanıklık olmasın',
                              ),
                              SizedBox(height: AppSpacing.md),
                              _GuideItem(
                                icon: Icons.filter_1_rounded,
                                text: 'Mümkünse tek bir soru görünsün',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppGradientButton(
                          text: 'Tamam, Anladım',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () {
                            context.push(RouteNames.analysisLoading);
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                     TextButton(
  onPressed: () async {
    final picked = await ref
        .read(analysisSubmitProvider.notifier)
        .pickFromGallery();

    if (!picked) return;
  },
  child: Text(
    'Başka Fotoğraf Seç',
    style: AppTextStyles.labelLg.copyWith(
      color: AppColors.primary,
    ),
  ),
),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
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

class _GuideItem extends StatelessWidget {
  const _GuideItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.full),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppRadii.full),
            boxShadow: AppShadows.ambientMd,
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primary.withValues(alpha: 0.95),
          ),
        ),
      ),
    );
  }
}