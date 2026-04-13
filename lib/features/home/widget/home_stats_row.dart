import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class InfoStatCard extends StatelessWidget {
  const InfoStatCard({
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