import 'dart:io';
import 'dart:typed_data';

import 'package:cozbak/app/router/route_names.dart';
import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_shadows.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:cozbak/features/analysis/provider/analysis_image_provider.dart';
import 'package:cozbak/shared/widgets/app_aura_background.dart';
import 'package:cozbak/shared/widgets/app_bar.dart';
import 'package:cozbak/shared/widgets/app_gradient_button.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

class AnalysisCropScreen extends ConsumerStatefulWidget {
  const AnalysisCropScreen({super.key});

  @override
  ConsumerState<AnalysisCropScreen> createState() => _AnalysisCropScreenState();
}

class _AnalysisCropScreenState extends ConsumerState<AnalysisCropScreen> {
  final CropController _cropController = CropController();

  Uint8List? _imageBytes;
  bool _isCropping = false;

  @override
  void initState() {
    super.initState();
    _loadImageBytes();
  }

  Future<void> _loadImageBytes() async {
    final file = ref.read(analysisImageProvider);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    setState(() {
      _imageBytes = bytes;
    });
  }

  Future<void> _saveCroppedImage(Uint8List croppedBytes) async {
    setState(() {
      _isCropping = true;
    });

    try {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await file.writeAsBytes(croppedBytes, flush: true);

      ref.read(analysisImageProvider.notifier).state = file;

      if (!mounted) return;
      context.push(RouteNames.analysisPreview);
    } finally {
      if (mounted) {
        setState(() {
          _isCropping = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = ref.watch(analysisImageProvider);

    if (imageFile == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Stack(
          children: [
            const AppAuraBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _CircleBackButton(
                        onTap: () => context.pop(),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Fotoğraf bulunamadı',
                      style: AppTextStyles.headlineMd,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Lütfen yeniden bir fotoğraf seç.',
                      style: AppTextStyles.bodyMd,
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          const AppAuraBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _CircleBackButton(
                      onTap: () => context.pop(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Soruyu Hizala',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayMd.copyWith(
                      fontSize: 30,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Sorunun tamamını çerçevenin içine al. Gereksiz boş alanları çıkar.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        boxShadow: AppShadows.ambientLg,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _imageBytes == null
                          ? const Center(child: CircularProgressIndicator())
                          : Crop(
                              image: _imageBytes!,
                              controller: _cropController,
                              onCropped: (result) async {
  switch (result) {
    case CropSuccess(:final croppedImage):
      await _saveCroppedImage(croppedImage);

    case CropFailure():
     AppSnackbar.showError("Hata oluştu !");
      break;
  }
},
                              withCircleUi: false,
                              baseColor: AppColors.surfaceContainerLowest,
                              maskColor: Colors.black.withValues(alpha: 0.45),
                              cornerDotBuilder: (_, __) => Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: AppShadows.ambientMd,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppGradientButton(
                    text: _isCropping ? 'Hazırlanıyor...' : 'Kırp ve Devam Et',
                    icon: Icons.crop_rounded,
                    onPressed: _isCropping
                        ? null
                        : () {
                            _cropController.crop();
                          },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: _isCropping ? null : () => context.pop(),
                    child: Text(
                      'Vazgeç',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.full),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppRadii.full),
            boxShadow: AppShadows.ambientMd,
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primary.withValues(alpha: 0.95),
          ),
        ),
      ),
    );
  }
}