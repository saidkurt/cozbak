import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/shared/widgets/app_banner_ad.dart';
import 'package:flutter/material.dart';

class HomeBannerAd extends StatelessWidget {
  const HomeBannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      alignment: Alignment.center,
      child: const AppBannerAd()
    );
  }
}