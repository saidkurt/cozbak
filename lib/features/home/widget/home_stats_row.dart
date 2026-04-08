import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeStatsRow extends StatelessWidget {
  const HomeStatsRow({
    super.key,
    required this.userAsync,
  });

  final AsyncValue<dynamic> userAsync;

  @override
  Widget build(BuildContext context) {
    return userAsync.when(
      data: (user) {
        final credits = user?.credits ?? 0;
        final totalAnalyses = user?.totalAnalyses ?? 0;

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Kalan Çözüm',
                value: '$credits',
                icon: Icons.auto_awesome_rounded,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Toplam Çözüm',
                value: '$totalAnalyses',
                icon: Icons.check_circle_rounded,
                gradient: const LinearGradient(
                  colors: [AppColors.secondary, AppColors.success],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Row(
        children: [
          Expanded(child: _StatSkeleton()),
          SizedBox(width: 12),
          Expanded(child: _StatSkeleton()),
        ],
      ),
      error: (_, __) => const Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Kalan Çözüm',
              value: '-',
              icon: Icons.auto_awesome_rounded,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Toplam Çözüm',
              value: '-',
              icon: Icons.check_circle_rounded,
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.success],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
    );
  }
}