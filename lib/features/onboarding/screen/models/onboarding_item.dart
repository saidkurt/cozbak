import 'package:flutter/widgets.dart';

class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;
  final bool isLast;
  final Widget? overlay;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
    this.isLast = false,
    this.overlay,
  });
}