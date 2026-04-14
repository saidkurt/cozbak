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
  bool _completionFlowStarted = false;

  AnalysisStage _visibleStage = AnalysisStage.uploading;

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
      begin: 0.97,
      end: 1.03,
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

  Future<void> _showCompletedFlow() async {
    if (_completionFlowStarted || !mounted) return;
    _completionFlowStarted = true;

    setState(() {
      _visibleStage = AnalysisStage.uploading;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _visibleStage = AnalysisStage.processing;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _visibleStage = AnalysisStage.completed;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    _navigateToResult();
  }

  void _listenQuestionStatus() {
    _questionSub = ref.listenManual<AsyncValue<QuestionModel?>>(
      currentQuestionProvider,
      (previous, next) {
        next.when(
          data: (question) {
            if (!mounted || question == null) return;

            if (question.status == 'completed') {
              _showCompletedFlow();
              return;
            }

            if (question.status == 'failed') {
              setState(() {
                _visibleStage = AnalysisStage.failed;
              });

              AppSnackbar.showError(
                question.errorMessage ?? 'Çözüm hazırlanırken bir hata oluştu.',
              );
              context.pop();
            }
          },
          loading: () {},
          error: (_, __) {},
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
        _visibleStage = AnalysisStage.uploading;
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
    final stage = _visibleStage;
    final meta = _statusMeta(stage);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          const AppAuraBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                10,
                AppSpacing.screenHorizontal,
                10,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Opacity(
                        opacity: 0.50,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest
                                .withValues(alpha: 0.78),
                            borderRadius:
                                BorderRadius.circular(AppRadii.full),
                            boxShadow: AppShadows.ambientMd,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 20,
                            color: AppColors.primary.withValues(alpha: 0.92),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _AnimatedPreviewRing(
                    imageFile: imageFile,
                    ringController: _ringController,
                    pulseAnimation: _pulseAnimation,
                    stage: stage,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Sorun analiz ediliyor',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      meta.description,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _StatusTimeline(stage: stage),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StageDot(
                        isActive: stage == AnalysisStage.uploading,
                        isPassed: stage == AnalysisStage.processing ||
                            stage == AnalysisStage.completed,
                      ),
                      const SizedBox(width: 6),
                      _StageDot(
                        isActive: stage == AnalysisStage.processing,
                        isPassed: stage == AnalysisStage.completed,
                      ),
                      const SizedBox(width: 6),
                      _StageDot(
                        isActive: stage == AnalysisStage.completed,
                        isPassed: false,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    _bottomHint(stage),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.78),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
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
          title: 'Fotoğraf yükleniyor',
          description: 'Fotoğraf hazırlanıyor ve çözüm için güvenli şekilde yükleniyor.',
        );
      case AnalysisStage.processing:
        return const _LoadingMeta(
          title: 'Soru okunuyor',
          description: 'Metin ve matematiksel ifadeler okunuyor.',
        );
      case AnalysisStage.completed:
        return const _LoadingMeta(
          title: 'Çözüm hazırlanıyor',
          description: 'Son kontroller yapılıyor ve sonuç hazırlanıyor.',
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
        return 'Fotoğraf yükleniyor...';
      case AnalysisStage.processing:
        return 'Soru okunuyor...';
      case AnalysisStage.completed:
        return 'Çözüm ekranı açılıyor...';
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
      width: 170,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: pulseAnimation.value,
                child: Container(
                  width: 126,
                  height: 126,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isFailed
                                ? AppColors.error
                                : isCompleted
                                    ? AppColors.success
                                    : AppColors.primary)
                            .withValues(alpha: 0.10),
                        blurRadius: 30,
                        spreadRadius: 4,
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
                size: const Size(136, 136),
                painter: _GradientRingPainter(
                  gradient: AppGradients.primaryCta,
                ),
              ),
            )
          else
            CustomPaint(
              size: const Size(136, 136),
              painter: _StaticRingPainter(
                color: isFailed ? AppColors.error : AppColors.success,
              ),
            ),
          Container(
            width: 96,
            height: 96,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppShadows.ambientLg,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: imageFile == null
                  ? Container(
                      color: AppColors.surfaceContainerHigh,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image_rounded,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                        size: 26,
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
      right: 22,
      bottom: 22,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.20),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
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
    final List<_TimelineData> items = [];

    if (stage == AnalysisStage.uploading) {
      items.add(
        const _TimelineData(
          key: 'uploading',
          title: 'Fotoğraf yükleniyor',
          subtitle: 'Sorun hazırlanıyor',
          icon: Icons.cloud_upload_rounded,
          state: _TimelineState.active,
        ),
      );
    }

    if (stage == AnalysisStage.processing) {
      items.add(
        const _TimelineData(
          key: 'reading',
          title: 'Soru okunuyor',
          subtitle: 'Metin algılanıyor',
          icon: Icons.center_focus_strong_rounded,
          state: _TimelineState.active,
        ),
      );
    }

    if (stage == AnalysisStage.completed) {
      items.add(
        const _TimelineData(
          key: 'solving',
          title: 'Çözüm hazırlanıyor',
          subtitle: 'Son kontroller yapılıyor',
          icon: Icons.psychology_alt_rounded,
          state: _TimelineState.active,
        ),
      );
    }

    if (stage == AnalysisStage.failed) {
      items.add(
        const _TimelineData(
          key: 'failed',
          title: 'Bir sorun oluştu',
          subtitle: 'Lütfen tekrar dene',
          icon: Icons.error_outline_rounded,
          state: _TimelineState.failed,
        ),
      );
    }

    return SizedBox(
      height: 86,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 700),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.42),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
        child: _TimelineCard(
          key: ValueKey(items.first.key),
          data: items.first,
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    super.key,
    required this.data,
  });

  final _TimelineData data;

  @override
  Widget build(BuildContext context) {
    final isFailed = data.state == _TimelineState.failed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.ambientMd,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isFailed
                  ? AppColors.error.withValues(alpha: 0.12)
                  : AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
            child: Icon(
              data.icon,
              size: 20,
              color: isFailed ? AppColors.error : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTextStyles.bodySm.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  style: AppTextStyles.bodySm.copyWith(
                    fontSize: 11,
                    color: isFailed ? AppColors.error : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          if (!isFailed)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
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

class _StageDot extends StatelessWidget {
  const _StageDot({
    required this.isActive,
    required this.isPassed,
  });

  final bool isActive;
  final bool isPassed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 18 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive || isPassed
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _TimelineData {
  const _TimelineData({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.state,
  });

  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final _TimelineState state;
}

enum _TimelineState {
  active,
  failed,
}

class _GradientRingPainter extends CustomPainter {
  const _GradientRingPainter({
    required this.gradient,
  });

  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const strokeWidth = 7.0;

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
    const strokeWidth = 7.0;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

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