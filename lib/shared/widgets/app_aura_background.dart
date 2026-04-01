import 'dart:ui';

import 'package:cozbak/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppAuraBackground extends StatelessWidget {
  const AppAuraBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -90,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                color: AppColors.blurPurple,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -80,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                color: AppColors.blurBlue,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}