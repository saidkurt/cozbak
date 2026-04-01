import 'package:cozbak/core/theme/app_durations.dart';
import 'package:cozbak/core/theme/app_gradients.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_shadows.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppGradientButton extends StatelessWidget {
  const AppGradientButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;

    return AnimatedOpacity(
      duration: AppDurations.fast,
      opacity: disabled ? 0.70 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Ink(
            height: 64,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryCta,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              boxShadow: AppShadows.ambientLg,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(text, style: AppTextStyles.buttonLg),
                        if (icon != null) ...[
                          const SizedBox(width: 10),
                          Icon(icon, color: Colors.white, size: 22),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}