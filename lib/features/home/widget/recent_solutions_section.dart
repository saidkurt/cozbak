import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:cozbak/features/home/model/recent_question_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecentSolutionsSection extends StatelessWidget {
  const RecentSolutionsSection({
    super.key,
    required this.recentAsync,
    required this.onViewAll,
    required this.onQuestionTap,
  });

  final AsyncValue<List<RecentQuestionItem>> recentAsync;
  final VoidCallback onViewAll;
   final ValueChanged<RecentQuestionItem> onQuestionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Son Çözümler', style: AppTextStyles.titleMd),
            const Spacer(),
            TextButton(
              onPressed: onViewAll,
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: recentAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const _EmptyRecentSolutions();
              }

              return ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
  final item = items[index];
  return _RecentSolutionCard(
    item: item,
    onTap: () => onQuestionTap(item),
  );
},
              );
            },
            loading: () => ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, __) => const _RecentCardSkeleton(),
            ),
            error: (_, __) => const _EmptyRecentSolutions(
              text: 'Son çözümler yüklenemedi.',
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentSolutionCard extends StatelessWidget {
  const _RecentSolutionCard({
    required this.item,
    required this.onTap,
  });

  final RecentQuestionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badge = _statusBadge(item.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                clipBehavior: Clip.antiAlias,
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.photo_rounded,
                          color: AppColors.onSurfaceVariant,
                        ),
                      )
                    : const Icon(
                        Icons.photo_rounded,
                        color: AppColors.onSurfaceVariant,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.lesson} / ${item.category}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badge.background,
                            borderRadius:
                                BorderRadius.circular(AppRadii.full),
                          ),
                          child: Text(
                            badge.label,
                            style: AppTextStyles.labelMd.copyWith(
                              fontSize: 9,
                              color: badge.foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.recognizedQuestion.isEmpty
                          ? 'Çözüm hazırlanıyor...'
                          : item.recognizedQuestion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentCardSkeleton extends StatelessWidget {
  const _RecentCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
    );
  }
}

class _EmptyRecentSolutions extends StatelessWidget {
  const _EmptyRecentSolutions({
    this.text = 'Henüz çözülmüş soru yok.',
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(.08),
            AppColors.secondary.withOpacity(.04),
            AppColors.surfaceContainerLow,
          ],
        ),
        border: Border.all(
          color: AppColors.primary.withOpacity(.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(.14),
                  AppColors.secondary.withOpacity(.10),
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İlk çözümünü ekle',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                  child: Text(
                    'Bir soru yüklediğinde burada görünecek',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadgeData {
  final String label;
  final Color background;
  final Color foreground;

  const _StatusBadgeData({
    required this.label,
    required this.background,
    required this.foreground,
  });
}

_StatusBadgeData _statusBadge(String status) {
  switch (status) {
    case 'completed':
      return const _StatusBadgeData(
        label: 'Tamamlandı',
        background: AppColors.correctContainer,
        foreground: AppColors.success,
      );
    case 'failed':
      return const _StatusBadgeData(
        label: 'Hata',
        background: Color(0xFFFFECEC),
        foreground: AppColors.error,
      );
    default:
      return const _StatusBadgeData(
        label: 'İşleniyor',
        background: Color(0xFFEAF2FF),
        foreground: AppColors.secondary,
      );
  }
}