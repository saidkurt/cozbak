import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_durations.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_shadows.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class AppSnackbar {
  AppSnackbar._();

  static GlobalKey<ScaffoldMessengerState> messengerKey =
      rootScaffoldMessengerKey;

  static void showSuccess(String message) {
    _show(
      message: message,
      icon: Icons.check_circle_rounded,
      background: AppColors.correctContainer,
      foreground: AppColors.success,
      border: AppColors.success.withValues(alpha: 0.18),
    );
  }

  static void showError(String message) {
    _show(
      message: message,
      icon: Icons.error_rounded,
      background: const Color(0xFFFFF1F1),
      foreground: AppColors.error,
      border: AppColors.error.withValues(alpha: 0.16),
    );
  }

  static void showInfo(String message) {
    _show(
      message: message,
      icon: Icons.info_rounded,
      background: AppColors.surfaceContainerLowest,
      foreground: AppColors.primary,
      border: AppColors.primary.withValues(alpha: 0.14),
    );
  }

  static void showWarning(String message) {
    _show(
      message: message,
      icon: Icons.warning_rounded,
      background: const Color(0xFFFFF7EC),
      foreground: AppColors.warning,
      border: AppColors.warning.withValues(alpha: 0.16),
    );
  }

  static void _show({
    required String message,
    required IconData icon,
    required Color background,
    required Color foreground,
    required Color border,
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          padding: EdgeInsets.zero,
          animation: CurvedAnimation(
            parent: kAlwaysCompleteAnimation,
            curve: Curves.easeOutCubic,
          ),
          content: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.96, end: 1),
            duration: AppDurations.normal,
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: border),
                boxShadow: AppShadows.ambientMd,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                child: BackdropFilter(
                  filter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.04),
                    BlendMode.srcATop,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: foreground.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 22,
                            color: foreground,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            message,
                            style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }
}