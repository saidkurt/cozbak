import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Display / Headlines - Plus Jakarta Sans
  static TextStyle get displayLg => GoogleFonts.plusJakartaSans(
        fontSize: 40,
        height: 1.1,
        fontWeight: FontWeight.w800,
        color: AppColors.onSurface,
        letterSpacing: -0.8,
      );

  static TextStyle get displayMd => GoogleFonts.plusJakartaSans(
        fontSize: 34,
        height: 1.12,
        fontWeight: FontWeight.w800,
        color: AppColors.onSurface,
        letterSpacing: -0.6,
      );

  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: AppColors.onSurface,
        letterSpacing: -0.4,
      );

  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
        letterSpacing: -0.3,
      );

  static TextStyle get titleLg => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  static TextStyle get titleMd => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  // Body / Labels - Manrope
  static TextStyle get bodyLg => GoogleFonts.manrope(
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMd => GoogleFonts.manrope(
        fontSize: 14,
        height: 1.55,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get bodySm => GoogleFonts.manrope(
        fontSize: 12,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get labelLg => GoogleFonts.manrope(
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  static TextStyle get labelMd => GoogleFonts.manrope(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get buttonLg => GoogleFonts.manrope(
        fontSize: 16,
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      );

  static TextStyle get buttonMd => GoogleFonts.manrope(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      );
}