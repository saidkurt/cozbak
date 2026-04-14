import 'package:cozbak/app/router/route_names.dart';
import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_shadows.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:cozbak/features/analysis/provider/analysis_submit_provider.dart';
import 'package:cozbak/features/analysis/provider/current_question_provider.dart';
import 'package:cozbak/shared/model/question_model.dart';
import 'package:cozbak/shared/widgets/app_aura_background.dart';
import 'package:cozbak/shared/widgets/app_gradient_button.dart';
import 'package:cozbak/shared/widgets/app_math_text.dart';
import 'package:cozbak/shared/widgets/app_math_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

String _normalizeGeneralMethod(String value) {
  return value
      .replaceAllMapped(
        RegExp(r'\\frac\{([^}]*)\}\{([^}]*)\}'),
        (m) => '${m.group(1)}/${m.group(2)}',
      )
      .replaceAllMapped(
        RegExp(r'\\sqrt\{([^}]*)\}'),
        (m) => '√(${m.group(1)})',
      )
      .replaceAll(r'\cdot', ' · ')
      .replaceAll(r'\pi', 'π')
      .replaceAll(r'\tan', 'tan')
      .replaceAll(r'\sin', 'sin')
      .replaceAll(r'\cos', 'cos')
      .replaceAll(r'\log', 'log')
      .replaceAll(r'\ln', 'ln')
      .replaceAll('{', '')
      .replaceAll('}', '')
      .replaceAll('\\', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

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
    final finalAnswer = question.finalAnswer ?? '';
    final generalMethod = question.generalMethod ?? '';
    final steps = question.steps;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _CircleIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => context.pop(),
            ),
          
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Çözüm hazır',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Soru ve adım adım çözüm',
                  style: AppTextStyles.displayMd.copyWith(
                    fontSize: 24,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
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
                const SizedBox(height: AppSpacing.md),

                if (imageUrl != null && imageUrl.isNotEmpty) ...[
                  Text(
                    'Soru',
                    style: AppTextStyles.titleMd.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => _showQuestionImageDialog(context, imageUrl),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        boxShadow: AppShadows.ambientMd,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Text(
                              'Soru görseli yüklenemedi.',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                if (generalMethod.isNotEmpty) ...[
                  Text(
                    'Kısa yöntem',
                    style: AppTextStyles.titleMd.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: Text(
                      _normalizeGeneralMethod(generalMethod),
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurface,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                Text(
                  'Adım adım çözüm',
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (steps.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: Text(
                      'Adımlar bulunamadı.',
                      style: AppTextStyles.bodySm,
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
                              : AppSpacing.sm,
                        ),
                        child: _StepCard(step: steps[index]),
                      ),
                    ),
                  ),

                if (finalAnswer.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Sonuç',
                    style: AppTextStyles.titleMd.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Center(
                      child: AppMathView(
                        latex: finalAnswer,
                        textAlign: TextAlign.center,
                        textStyle: AppTextStyles.titleMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.md),
                AppGradientButton(
                  text: 'Yeni Soru Çöz',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    ref.read(analysisSubmitProvider.notifier).clearSession();
                    context.go(RouteNames.home);
                  },
                ),
                const SizedBox(height: 4),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(RouteNames.home),
                    child: Text(
                      'Ana sayfaya dön',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showQuestionImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.xl),
                child: Container(
                  color: AppColors.surfaceContainerLowest,
                  child: InteractiveViewer(
                    minScale: 0.9,
                    maxScale: 4,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => SizedBox(
                        height: 220,
                        child: Center(
                          child: Text(
                            'Soru görseli açılamadı.',
                            style: AppTextStyles.bodyMd,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    child: Ink(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(AppRadii.full),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.ambientMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  '${step.stepNumber}',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  step.title,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (step.explanation.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            AppMixedMathText(
              text: step.explanation,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onSurface,
                height: 1.45,
              ),
            ),
          ],
          if (step.result.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: AppMathView(
                latex: step.result,
                textStyle: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
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
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMd.copyWith(
          color: foreground,
          fontSize: 11,
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppRadii.full),
            boxShadow: AppShadows.ambientMd,
          ),
          child: Icon(
            icon,
            size: 20,
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