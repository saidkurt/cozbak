import 'package:flutter/material.dart';
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> ambientMd = [
    BoxShadow(
      color: Color(0x144D41DF),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> ambientLg = [
    BoxShadow(
      color: Color(0x104D41DF),
      blurRadius: 40,
      offset: Offset(0, 10),
      spreadRadius: 0,
    ),
  ];

  static BoxDecoration blurOrbDecoration({
    required Color color,
    double size = 180,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color,
          blurRadius: size * 0.55,
          spreadRadius: size * 0.08,
        ),
      ],
    );
  }
}