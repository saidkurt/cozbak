import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    required this.label,
    required this.hintText,
    required this.topRightText,
    required this.onTopRightTap,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final String hintText;
  final String topRightText;
  final VoidCallback onTopRightTap;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            GestureDetector(
              onTap: widget.onTopRightTap,
              child: Text(
                widget.topRightText,
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          initialValue: widget.initialValue,
          obscureText: _obscure,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          style: AppTextStyles.bodyLg.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => _obscure = !_obscure);
              },
              icon: Icon(
                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}