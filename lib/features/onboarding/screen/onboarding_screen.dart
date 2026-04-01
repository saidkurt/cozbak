import 'package:cozbak/features/onboarding/screen/models/onboarding_item.dart';
import 'package:cozbak/features/onboarding/screen/widgets/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      title: 'Sorunun Fotoğrafını\nYükle',
      description:
          'Çözmek istediğin sorunun fotoğrafını çek ya da galeriden seç. Uygulama soruyu senin için analiz etsin.',
      imagePath: 'assets/images/logo1.png',
      overlay: FirstPageOverlay(),
    ),
    OnboardingItem(
      title: 'Cevabı ve Adım Adım\nÇözümü Gör',
      description:
          'Sadece doğru cevabı değil, sorunun nasıl çözüldüğünü de adım adım anlaşılır şekilde öğren.',
      imagePath: 'assets/images/logo3.png',
    ),
    OnboardingItem(
      title: 'Bu Tarz Soruları\nÇözmeyi Öğren',
      description:
          'Uygulama sadece o soruyu çözmekle kalmaz, benzer soruları çözerken kullanacağın yöntemi de açıklar.',
      imagePath: 'assets/images/logo2.png',
      isLast: true,
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_isLastPage) {
      context.go(RouteNames.login);
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _goLogin() {
    context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ÜST KISIM SABİT
            const _OnboardingTopBar(),

            const SizedBox(height: 8),

            // SADECE ORTA ALAN SLIDER
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return OnboardingPage(
                    title: item.title,
                    description: item.description,
                    imagePath: item.imagePath,
                    overlay: item.overlay,
                    animateImage: index != 0,
                  );
                },
              ),
            ),

            // ALT KISIM SABİT
            _OnboardingFooter(
              currentPage: _currentPage,
              pageCount: _pages.length,
              isLastPage: _isLastPage,
              onNextPressed: _nextPage,
              onLoginPressed: _goLogin,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 12);
  }
}

class _OnboardingFooter extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final bool isLastPage;
  final VoidCallback onNextPressed;
  final VoidCallback onLoginPressed;

  const _OnboardingFooter({
    required this.currentPage,
    required this.pageCount,
    required this.isLastPage,
    required this.onNextPressed,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        8,
        AppSpacing.screenHorizontal,
        24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OnboardingIndicator(
            currentIndex: currentPage,
            count: pageCount,
          ),
          const SizedBox(height: 24),
          _PrimaryOnboardingButton(
            text: isLastPage ? 'Hemen Başla' : 'Devam Et',
            icon: isLastPage ? null : Icons.arrow_forward_rounded,
            onPressed: onNextPressed,
          ),

          // BURASI SABİT YÜKSEKLİK
          const SizedBox(height: 18),
          SizedBox(
            height: 26,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: isLastPage ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !isLastPage,
                  child: GestureDetector(
                    onTap: onLoginPressed,
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(text: 'Zaten hesabım var, '),
                          TextSpan(
                            text: 'giriş yap',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingIndicator extends StatelessWidget {
  final int currentIndex;
  final int count;

  const _OnboardingIndicator({
    required this.currentIndex,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = currentIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 38 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.outlineVariant.withOpacity(0.45),
            borderRadius: BorderRadius.circular(AppRadii.full),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.20),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

class _PrimaryOnboardingButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;

  const _PrimaryOnboardingButton({
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  State<_PrimaryOnboardingButton> createState() =>
      _PrimaryOnboardingButtonState();
}

class _PrimaryOnboardingButtonState extends State<_PrimaryOnboardingButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.22),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                style: AppTextStyles.titleLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: 10),
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}