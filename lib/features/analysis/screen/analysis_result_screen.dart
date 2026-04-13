import 'package:cozbak/app/router/route_names.dart';
import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_shadows.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:cozbak/features/analysis/provider/current_question_provider.dart';
import 'package:cozbak/features/analysis/provider/analysis_submit_provider.dart';
import 'package:cozbak/shared/model/question_model.dart';
import 'package:cozbak/shared/widgets/app_aura_background.dart';
import 'package:cozbak/shared/widgets/app_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AnalysisResultScreen extends ConsumerWidget {
  const AnalysisResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionAsync = ref.watch(currentQuestionProvider);

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
              child: questionAsync.when(
                data: (question) {
                  if (question == null) {
                    return const _ResultEmptyState();
                  }

                  return _ResultContent(question: question);
                },
                loading: () => const _ResultLoadingState(),
                error: (_, __) => const _ResultErrorState(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultContent extends ConsumerWidget {
  const _ResultContent({
    required this.question,
  });

  final QuestionModel question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = question.imageUrl;
    final lesson = question.lesson ?? '';
    final category = question.category ?? '';
    final finalAnswer = question.finalAnswer ?? '-';
    final generalMethod = question.generalMethod ?? '';
    final steps = question.steps;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _CircleIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => context.pop(),
            ),
            const Spacer(),
            if (imageUrl != null && imageUrl.isNotEmpty)
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.full),
                  boxShadow: AppShadows.ambientMd,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.surfaceContainerHigh,
                    child: const Icon(
                      Icons.photo_rounded,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Çözüm hazır',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Sonuç ve adım adım çözüm',
                  style: AppTextStyles.displayMd.copyWith(
                    fontSize: 30,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      label: lesson.isEmpty ? 'Ders' : lesson,
                      foreground: AppColors.primary,
                      background: AppColors.primary.withValues(alpha: 0.08),
                    ),
                    _InfoChip(
                      label: category.isEmpty ? 'Konu' : category,
                      foreground: AppColors.secondary,
                      background: AppColors.secondary.withValues(alpha: 0.08),
                    ),
                    const _InfoChip(
                      label: 'Tamamlandı',
                      foreground: AppColors.success,
                      background: AppColors.correctContainer,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    boxShadow: AppShadows.ambientLg,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Doğru Sonuç',
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        finalAnswer,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayLg.copyWith(
                          fontSize: 42,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (generalMethod.isNotEmpty) ...[
                  Text(
                    'Kısa yöntem',
                    style: AppTextStyles.titleMd,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                    ),
                    child: Text(
                      generalMethod,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurface,
                        height: 1.55,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                Text(
                  'Adım adım çözüm',
                  style: AppTextStyles.titleMd,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (steps.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                    ),
                    child: Text(
                      'Adımlar bulunamadı.',
                      style: AppTextStyles.bodyMd,
                    ),
                  )
                else
                  Column(
                    children: List.generate(
                      steps.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                          bottom: index == steps.length - 1
                              ? 0
                              : AppSpacing.md,
                        ),
                        child: _StepCard(step: steps[index]),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),
                AppGradientButton(
                  text: 'Yeni Soru Çöz',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    ref.read(analysisSubmitProvider.notifier).clearSession();
                    context.go(RouteNames.home);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(RouteNames.home),
                    child: Text(
                      'Ana sayfaya dön',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
  });

  final QuestionStepModel step;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.ambientMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  '${step.stepNumber}',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  step.title,
                  style: AppTextStyles.titleMd,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            step.explanation,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurface,
              height: 1.55,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Text(
              step.result,
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMd.copyWith(
          color: foreground,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
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
            icon,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _ResultLoadingState extends StatelessWidget {
  const _ResultLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _ResultErrorState extends StatelessWidget {
  const _ResultErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Çözüm yüklenemedi.',
        style: AppTextStyles.bodyMd,
      ),
    );
  }
}

class _ResultEmptyState extends StatelessWidget {
  const _ResultEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Çözüm bulunamadı.',
        style: AppTextStyles.bodyMd,
      ),
    );
  }
}