import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_durations.dart';
import 'package:cozbak/core/theme/app_gradients.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_shadows.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:cozbak/shared/widgets/app_aura_background.dart';
import 'package:cozbak/shared/widgets/network/offline_pulse_orb.dart';

class NoInternetOverlay extends StatefulWidget {
  const NoInternetOverlay({super.key});

  @override
  State<NoInternetOverlay> createState() => _NoInternetOverlayState();
}

class _NoInternetOverlayState extends State<NoInternetOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.slow,
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.05),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AppAuraBackground(),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              color: AppColors.onSurface.withValues(alpha: 0.08),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Center(
                child: SlideTransition(
                  position: _slide,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 430),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest.withValues(
                        alpha: 0.78,
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.45),
                      ),
                      boxShadow: [
                        ...AppShadows.ambientLg,
                        BoxShadow(
                          color: AppColors.blurPurple.withValues(alpha: 0.10),
                          blurRadius: 60,
                          spreadRadius: 4,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const OfflinePulseOrb(
                          size: 116,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'İnternet Bağlantısı Yok',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineMd.copyWith(
                            color: AppColors.onSurface,
                            decoration: TextDecoration.none,
                            backgroundColor: Colors.transparent,
                            shadows: const [],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Bağlantın geri geldiğinde uygulama otomatik olarak kaldığın yerden devam edecek.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            decoration: TextDecoration.none,
                            backgroundColor: Colors.transparent,
                            shadows: const [],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppGradients.primaryCta,
                            borderRadius: BorderRadius.circular(AppRadii.full),
                            boxShadow: AppShadows.ambientMd,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.1,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Bağlantı kontrol ediliyor...',
                                style: AppTextStyles.buttonMd.copyWith(
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                  backgroundColor: Colors.transparent,
                                  shadows: const [],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Wi-Fi veya mobil veri yeniden açıldığında ekran otomatik kapanır.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textHint,
                            decoration: TextDecoration.none,
                            backgroundColor: Colors.transparent,
                            shadows: const [],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}