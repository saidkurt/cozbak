import 'package:cozbak/app/router/route_names.dart';
import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_shadows.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:cozbak/features/analysis/provider/current_question_id_provider.dart';
import 'package:cozbak/features/history/provider/history_provider.dart';
import 'package:cozbak/features/home/model/recent_question_item.dart';
import 'package:cozbak/shared/widgets/app_aura_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(questionHistoryProvider);

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
                  Row(
                    children: [
                      _CircleBackButton(
                        onTap: () => context.pop(),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Geçmiş Sorularım',
                              style: AppTextStyles.headlineMd,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Daha önce çözdüğün sorular burada listelenir.',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: historyAsync.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return const _EmptyHistoryState();
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.xl,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return _HistoryQuestionCard(
                              item: item,
                              onTap: () {
                                ref
                                    .read(currentQuestionIdProvider.notifier)
                                    .state = item.id;
                                context.push(RouteNames.analysisResult);
                              },
                            );
                          },
                        );
                      },
                      loading: () => ListView.separated(
                        itemCount: 6,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (_, __) => const _HistoryCardSkeleton(),
                      ),
                      error: (_, __) => const _EmptyHistoryState(
                        text: 'Sorular yüklenemedi.',
                      ),
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

class _HistoryQuestionCard extends StatelessWidget {
  const _HistoryQuestionCard({
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
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: AppShadows.ambientMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
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
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 8),
                    Text(
                      item.recognizedQuestion.isEmpty
                          ? '${item.lesson} • ${item.category}'
                          : item.recognizedQuestion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurface,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.finalAnswer.isEmpty
                                ? 'Sonuç hazırlanıyor'
                                : 'Sonuç: ${item.finalAnswer}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.70,
                          ),
                        ),
                      ],
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

class _HistoryCardSkeleton extends StatelessWidget {
  const _HistoryCardSkeleton();

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

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState({
    this.text = 'Henüz çözülmüş soru bulunmuyor.',
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
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
                Icons.history_rounded,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Geçmiş Sorularım',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMd,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
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
            color: AppColors.primary,
          ),
        ),
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