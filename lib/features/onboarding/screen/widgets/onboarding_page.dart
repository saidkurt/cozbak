import 'dart:ui';
import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:cozbak/shared/widgets/app_aura_background.dart';
import 'package:flutter/material.dart';



class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final Widget? overlay;
  final bool animateImage;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.overlay,
    this.animateImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AppAuraBackground(),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: _IllustrationArea(
                          imagePath: imagePath,
                          overlay: overlay,
                          animateImage: animateImage,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineLg.copyWith(
                        fontSize: 30,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        description,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 16,
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IllustrationArea extends StatelessWidget {
  final String imagePath;
  final Widget? overlay;
  final bool animateImage;

  const _IllustrationArea({
    required this.imagePath,
    this.overlay,
    required this.animateImage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 340,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 18,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.07),
                  width: 2,
                ),
              ),
            ),
          ),
          Positioned(
            top: 28,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.08),
                  width: 1.2,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.07),
                ),
              ),
            ),
          ),
          AnimatedFloat(
            enabled: animateImage,
            begin: -6,
            end: 6,
            duration: const Duration(milliseconds: 2200),
            child: Image.asset(
              imagePath,
              width: 235,
              fit: BoxFit.contain,
            ),
          ),
          if (overlay != null) overlay!,
        ],
      ),
    );
  }
}

class AnimatedFloat extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double begin;
  final double end;
  final Duration duration;

  const AnimatedFloat({
    super.key,
    required this.child,
    this.enabled = true,
    this.begin = -8,
    this.end = 8,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<AnimatedFloat> createState() => _AnimatedFloatState();
}

class _AnimatedFloatState extends State<AnimatedFloat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedFloat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class FirstPageOverlay extends StatelessWidget {
  const FirstPageOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned(
          left: 34,
          top: 92,
          child: AnimatedFloat(
            begin: -8,
            end: 8,
            duration: Duration(milliseconds: 1800),
            child: _FloatingIconBox(
              icon: Icons.camera_alt_rounded,
              color: Color(0xFF5B4CF4),
            ),
          ),
        ),
        Positioned(
          right: 34,
          top: 182,
          child: AnimatedFloat(
            begin: 8,
            end: -8,
            duration: Duration(milliseconds: 2100),
            child: _FloatingIconBox(
              icon: Icons.image_rounded,
              color: Color(0xFF2F80ED),
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _FloatingIconBox({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
