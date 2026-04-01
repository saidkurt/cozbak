import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  static const primaryCta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.secondary,
    ],
    transform: GradientRotation(0.785398), // ~45deg görünür, Flutter tarafında yeterli
  );

  static const heroGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x22FFFFFF),
      Color(0x00FFFFFF),
    ],
  );
}