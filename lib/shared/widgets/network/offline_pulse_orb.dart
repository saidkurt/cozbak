import 'package:flutter/material.dart';

import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_shadows.dart';

class OfflinePulseOrb extends StatefulWidget {
  const OfflinePulseOrb({
    super.key,
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  State<OfflinePulseOrb> createState() => _OfflinePulseOrbState();
}

class _OfflinePulseOrbState extends State<OfflinePulseOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final value = Curves.easeInOut.transform(_controller.value);
        final scale = 0.92 + (value * 0.22);
        final opacity = 0.18 * (1 - value);

        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: scale * 1.25,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: opacity),
                ),
              ),
            ),
            Container(
              width: widget.size * 0.78,
              height: widget.size * 0.78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
                boxShadow: [
                  ...AppShadows.ambientLg,
                  BoxShadow(
                    color: AppColors.blurPurple.withValues(alpha: 0.28),
                    blurRadius: 36,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ],
        );
      },
    );
  }
}