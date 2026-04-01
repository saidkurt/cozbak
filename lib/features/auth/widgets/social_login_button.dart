import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_durations.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_shadows.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton._({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.enabled,
    required this.onPressed,
    this.borderColor,
  });

  factory SocialLoginButton.google({
    required String label,
    required bool enabled,
    required Future<void> Function() onPressed,
  }) {
    return SocialLoginButton._(
      label: label,
      backgroundColor: AppColors.googleSurface,
      foregroundColor: AppColors.onSurface,
      borderColor: AppColors.outlineVariant.withValues(alpha: 0.22),
      icon: const _GoogleIcon(),
      enabled: enabled,
      onPressed: onPressed,
    );
  }

  factory SocialLoginButton.apple({
    required String label,
    required bool enabled,
    required Future<void> Function() onPressed,
  }) {
    return SocialLoginButton._(
      label: label,
      backgroundColor: AppColors.appleSurface,
      foregroundColor: Colors.white,
      icon: const Icon(
        Icons.apple_rounded,
        size: 22,
        color: Colors.white,
      ),
      enabled: enabled,
      onPressed: onPressed,
    );
  }

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final Widget icon;
  final bool enabled;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: AppDurations.fast,
      opacity: enabled ? 1 : 0.6,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async => onPressed(),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: Ink(
              height: 64,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: borderColor == null ? null : Border.all(color: borderColor!),
                boxShadow: backgroundColor == AppColors.googleSurface
                    ? AppShadows.ambientMd
                    : null,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLg.copyWith(
                          color: foregroundColor,
                          fontSize: 16,
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
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Text(
      'G',
      style: AppTextStyles.titleLg.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}