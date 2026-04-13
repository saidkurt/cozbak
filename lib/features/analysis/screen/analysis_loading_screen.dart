import 'dart:io';
import 'dart:math' as math;

import 'package:cozbak/app/router/route_names.dart';
import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_durations.dart';
import 'package:cozbak/core/theme/app_gradients.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_shadows.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:cozbak/features/analysis/provider/analysis_image_provider.dart';
import 'package:cozbak/features/analysis/provider/analysis_stage_provider.dart';
import 'package:cozbak/features/analysis/provider/analysis_submit_provider.dart';
import 'package:cozbak/features/analysis/provider/current_question_provider.dart';
import 'package:cozbak/shared/model/question_model.dart';
import 'package:cozbak/shared/widgets/app_aura_background.dart';
import 'package:cozbak/shared/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AnalysisLoadingScreen extends ConsumerStatefulWidget {
  const AnalysisLoadingScreen({super.key});

  @override
  ConsumerState<AnalysisLoadingScreen> createState() =>
      _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState
    extends ConsumerState<AnalysisLoadingScreen> with TickerProviderStateMixin {
  late final AnimationController _ringController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  ProviderSubscription<AsyncValue<QuestionModel?>>? _questionSub;
  bool _analysisStarted = false;
  bool _canListenQuestion = false;
  bool _didNavigateToResult = false;

@override
void initState() {
  super.initState();

  _ringController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  _pulseController = AnimationController(
    vsync: this,
    duration: AppDurations.slow * 2,
  )..repeat(reverse: true);

  _pulseAnimation = Tween<double>(
    begin: 0.96,
    end: 1.04,
  ).animate(
    CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _startAnalysisOnce();
  });
}

Future<void> _navigateToResult() async {
  if (_didNavigateToResult || !mounted) return;

  _didNavigateToResult = true;

  await Future.delayed(const Duration(milliseconds: 250));
  if (!mounted) return;

  context.pushReplacement(RouteNames.analysisResult);
}

void _listenQuestionStatus() {
  _questionSub = ref.listenManual<AsyncValue<QuestionModel?>>(
    currentQuestionProvider,
    (previous, next) {
      next.when(
        data: (question) {
          debugPrint('question listener data => ${question?.status}');
          if (!mounted || question == null) return;

          if (question.status == 'completed') {
            _navigateToResult();
            return;
          }

          if (question.status == 'failed') {
            AppSnackbar.showError(
              question.errorMessage ?? 'Çözüm hazırlanırken bir hata oluştu.',
            );
            context.pop();
          }
        },
        loading: () {
          debugPrint('question listener loading');
        },
        error: (e, st) {
          debugPrint('question listener error => $e');
          debugPrint('$st');
        },
      );
    },
    fireImmediately: true,
  );
}

Future<void> _startAnalysisOnce() async {
  if (_analysisStarted) return;
  _analysisStarted = true;

  try {
    await ref.read(analysisSubmitProvider.notifier).startAnalysis();
    if (!mounted) return;

    setState(() {
      _canListenQuestion = true;
    });

    _listenQuestionStatus();
  } catch (_) {
    _analysisStarted = false;

    if (!mounted) return;
    AppSnackbar.showError('Analiz başlatılamadı.');
    context.pop();
  }
}

  @override
  void dispose() {
    _questionSub?.close();
    _ringController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = ref.watch(analysisImageProvider);
final questionAsync =
    _canListenQuestion ? ref.watch(currentQuestionProvider) : null;

AnalysisStage stage = AnalysisStage.uploading;

if (_canListenQuestion && questionAsync != null) {
  stage = questionAsync.maybeWhen(
    data: (question) {
      final status = question?.status ?? 'uploading';

      switch (status) {
        case 'uploading':
          return AnalysisStage.uploading;
        case 'processing':
          return AnalysisStage.processing;
        case 'completed':
          return AnalysisStage.completed;
        case 'failed':
          return AnalysisStage.failed;
        default:
          return AnalysisStage.processing;
      }
    },
    orElse: () => AnalysisStage.processing,
  );
}

final meta = _statusMeta(stage);

if (stage == AnalysisStage.completed) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _navigateToResult();
  });
}
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
                  const SizedBox(height: AppSpacing.lg),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Opacity(
                        opacity: 0.55,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest
                                .withValues(alpha: 0.72),
                            borderRadius:
                                BorderRadius.circular(AppRadii.full),
                            boxShadow: AppShadows.ambientMd,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.primary.withValues(alpha: 0.92),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: Column(
                      children: [
                        _AnimatedPreviewRing(
                          imageFile: imageFile,
                          ringController: _ringController,
                          pulseAnimation: _pulseAnimation,
                          stage: stage,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          meta.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayMd.copyWith(
                            fontSize: 28,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: Text(
                            meta.description,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        _StatusTimeline(stage: stage),
                        const Spacer(),
                        Text(
                          _bottomHint(stage),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.78,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                      ],
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

  _LoadingMeta _statusMeta(AnalysisStage stage) {
    switch (stage) {
      case AnalysisStage.uploading:
        return const _LoadingMeta(
          title: 'Fotoğraf hazırlanıyor',
          description:
              'Sorun güvenli şekilde yükleniyor ve çözüm için hazırlanıyor.',
        );
      case AnalysisStage.processing:
        return const _LoadingMeta(
          title: 'Çözüm hazırlanıyor',
          description:
              'Sorun analiz ediliyor ve sana özel adım adım çözüm hazırlanıyor.',
        );
      case AnalysisStage.completed:
        return const _LoadingMeta(
          title: 'Çözüm hazır',
          description: 'Analiz tamamlandı, sonuç ekranı hazırlanıyor.',
        );
      case AnalysisStage.failed:
        return const _LoadingMeta(
          title: 'Bir sorun oluştu',
          description: 'Çözüm hazırlanırken beklenmeyen bir hata oluştu.',
        );
    }
  }

  String _bottomHint(AnalysisStage stage) {
    switch (stage) {
      case AnalysisStage.uploading:
      case AnalysisStage.processing:
        return 'Bu işlem genelde 1-2 dakika sürer.';
      case AnalysisStage.completed:
        return 'Sonuç ekranı açılıyor...';
      case AnalysisStage.failed:
        return 'İşlem sonlandırıldı.';
    }
  }
}

class _AnimatedPreviewRing extends StatelessWidget {
  const _AnimatedPreviewRing({
    required this.imageFile,
    required this.ringController,
    required this.pulseAnimation,
    required this.stage,
  });

  final File? imageFile;
  final AnimationController ringController;
  final Animation<double> pulseAnimation;
  final AnalysisStage stage;

  bool get _showRotation =>
      stage == AnalysisStage.uploading || stage == AnalysisStage.processing;

  @override
  Widget build(BuildContext context) {
    final isCompleted = stage == AnalysisStage.completed;
    final isFailed = stage == AnalysisStage.failed;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: pulseAnimation.value,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isFailed
                                ? AppColors.error
                                : isCompleted
                                    ? AppColors.success
                                    : AppColors.primary)
                            .withValues(alpha: 0.12),
                        blurRadius: 44,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_showRotation)
            RotationTransition(
              turns: ringController,
              child: CustomPaint(
                size: const Size(176, 176),
                painter: _GradientRingPainter(
                  gradient: AppGradients.primaryCta,
                ),
              ),
            )
          else
            CustomPaint(
              size: const Size(176, 176),
              painter: _StaticRingPainter(
                color: isFailed ? AppColors.error : AppColors.success,
              ),
            ),
          Container(
            width: 128,
            height: 128,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(36),
              boxShadow: AppShadows.ambientLg,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: imageFile == null
                  ? Container(
                      color: AppColors.surfaceContainerHigh,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image_rounded,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                        size: 34,
                      ),
                    )
                  : Image(
                      image: FileImage(imageFile!),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          if (isCompleted)
            const _CornerBadge(
              icon: Icons.check_rounded,
              color: AppColors.success,
            ),
          if (isFailed)
            const _CornerBadge(
              icon: Icons.close_rounded,
              color: AppColors.error,
            ),
        ],
      ),
    );
  }
}

class _CornerBadge extends StatelessWidget {
  const _CornerBadge({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 34,
      bottom: 34,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({
    required this.stage,
  });

  final AnalysisStage stage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TimelineTile(
          title: 'Fotoğraf yükleniyor',
          subtitle: stage == AnalysisStage.uploading ? 'İşleniyor...' : null,
          state: stage == AnalysisStage.uploading
              ? _TimelineState.active
              : stage == AnalysisStage.processing ||
                      stage == AnalysisStage.completed
                  ? _TimelineState.completed
                  : _TimelineState.idle,
          icon: Icons.cloud_upload_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        _TimelineTile(
          title: 'Soru okunuyor',
          subtitle: stage == AnalysisStage.processing ? 'İşleniyor...' : null,
          state: stage == AnalysisStage.processing
              ? _TimelineState.active
              : stage == AnalysisStage.completed
                  ? _TimelineState.completed
                  : stage == AnalysisStage.failed
                      ? _TimelineState.failed
                      : _TimelineState.idle,
          icon: Icons.center_focus_strong_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        _TimelineTile(
          title: stage == AnalysisStage.failed
              ? 'Çözüm hazırlanamadı'
              : 'Çözüm hazırlanıyor',
          subtitle: stage == AnalysisStage.completed
              ? 'Tamamlandı'
              : stage == AnalysisStage.failed
                  ? 'İşlem durdu'
                  : stage == AnalysisStage.processing
                      ? 'İşleniyor...'
                      : null,
          state: stage == AnalysisStage.completed
              ? _TimelineState.completed
              : stage == AnalysisStage.failed
                  ? _TimelineState.failed
                  : _TimelineState.idle,
          icon: stage == AnalysisStage.failed
              ? Icons.error_outline_rounded
              : Icons.psychology_alt_rounded,
        ),
      ],
    );
  }
}

enum _TimelineState {
  idle,
  active,
  completed,
  failed,
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.title,
    required this.state,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final _TimelineState state;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isActive = state == _TimelineState.active;
    final isCompleted = state == _TimelineState.completed;
    final isFailed = state == _TimelineState.failed;
    final isIdle = state == _TimelineState.idle;

    return AnimatedContainer(
      duration: AppDurations.normal,
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.surfaceContainerLowest
            : AppColors.surfaceContainerLow.withValues(
                alpha: isIdle ? 0.55 : 0.9,
              ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: isActive ? AppShadows.ambientMd : null,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.correctContainer
                  : isFailed
                      ? AppColors.error.withValues(alpha: 0.12)
                      : isActive
                          ? AppColors.primary.withValues(alpha: 0.10)
                          : AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : isFailed
                      ? Icons.error_rounded
                      : icon,
              color: isCompleted
                  ? AppColors.tertiary
                  : isFailed
                      ? AppColors.error
                      : isActive
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMd.copyWith(
                    color: isIdle
                        ? AppColors.onSurface.withValues(alpha: 0.42)
                        : AppColors.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTextStyles.labelMd.copyWith(
                      color: isFailed ? AppColors.error : AppColors.primary,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isActive)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
        ],
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  const _GradientRingPainter({
    required this.gradient,
  });

  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const strokeWidth = 8.0;

    final basePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final arcPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = size.center(Offset.zero);
    final radius = (size.width / 2) - strokeWidth;

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.45,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) => false;
}

class _StaticRingPainter extends CustomPainter {
  const _StaticRingPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    final center = size.center(Offset.zero);
    final radius = (size.width / 2) - strokeWidth;

    canvas.drawCircle(center, radius, glowPaint);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _StaticRingPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _LoadingMeta {
  const _LoadingMeta({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}