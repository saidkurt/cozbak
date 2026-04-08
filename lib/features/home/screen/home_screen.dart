
import 'package:cozbak/app/router/route_names.dart';
import 'package:cozbak/core/ads/ad_providers.dart';
import 'package:cozbak/core/theme/app_colors.dart';
import 'package:cozbak/core/theme/app_radii.dart';
import 'package:cozbak/core/theme/app_spacing.dart';
import 'package:cozbak/core/theme/app_text_styles.dart';
import 'package:cozbak/features/home/provider/recent_questions_provider.dart';
import 'package:cozbak/features/home/widget/home_banner_ad.dart';
import 'package:cozbak/features/home/widget/home_hero_card.dart';
import 'package:cozbak/features/home/widget/recent_solutions_section.dart';
import 'package:cozbak/shared/model/app_user.dart';
import 'package:cozbak/shared/provider/current_user_provider.dart';

import 'package:cozbak/shared/widgets/app_aura_background.dart';
import 'package:cozbak/shared/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


void _handleCameraTap(AppUser? user) {
  final credits = user?.credits ?? 0;

  if (credits <= 0) {
    AppSnackbar.showError(
      'Çözüm hakkınız bitti. Reklam izleyerek +1 hak kazanabilirsiniz.',
    );
    return;
  }

  // kamera aç
}

void _handleGalleryTap(AppUser? user) {
  final credits = user?.credits ?? 0;

  if (credits <= 0) {
    AppSnackbar.showError(
      'Çözüm hakkınız bitti. Reklam izleyerek +1 hak kazanabilirsiniz.',
    );
    return;
  }

  // galeri aç
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final recentAsync = ref.watch(recentQuestionsProvider);
    final isRewardLoading = ref.watch(rewardedLoadingProvider);

    return Scaffold(
      body: Stack(
        children: [
          const AppAuraBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                16,
                AppSpacing.screenHorizontal,
                AppSpacing.screenBottom,
              ),
              child: Column(
                children: [
                  _HomeTopBar(
                    onProfileTap: () => context.push(RouteNames.profile),
                    userAsync: userAsync,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hoş geldin',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Bugün hangi soruyu çözelim?',
                          style: AppTextStyles.headlineMd,
                        ),
                        const SizedBox(height: 16),
                        HomeHeroCard(
  userAsync: userAsync,
  onCameraTap: () {
    final user = userAsync.asData?.value;
    final credits = user?.credits ?? 0;

    if (credits <= 0) {
      AppSnackbar.showError(
        'Çözüm hakkınız bitti. Reklam izleyerek +1 hak kazanabilirsiniz.',
      );
      return;
    }

    // kamera akışı
  },
  onGalleryTap: () {
    final user = userAsync.asData?.value;
    final credits = user?.credits ?? 0;

    if (credits <= 0) {
      AppSnackbar.showError(
        'Çözüm hakkınız bitti. Reklam izleyerek +1 hak kazanabilirsiniz.',
      );
      return;
    }

    // galeri akışı
  },
onWatchAdTap: isRewardLoading
    ? null
    : () async {
        final adService = ref.read(rewardedAdServiceProvider);

        ref.read(rewardedLoadingProvider.notifier).state = true;

        try {
          final ready = await adService.prepareAdIfNeeded();

          if (!ready) {
            AppSnackbar.showError(
              'Reklam şu anda hazırlanamadı. Lütfen tekrar deneyin.',
            );
            return;
          }

          final success = await adService.showAdAndRewardUser();

          if (success) {
            AppSnackbar.showSuccess('1 çözüm hakkı eklendi.');
          } else {
            AppSnackbar.showError(
              'Reklam ödülü alınamadı. Lütfen tekrar deneyin.',
            );
          }
        } catch (_) {
          AppSnackbar.showError(
            'Reklam hazırlanırken bir hata oluştu.',
          );
        } finally {
          ref.read(rewardedLoadingProvider.notifier).state = false;
        }
      },
),
                        const SizedBox(height: 14),
                        Expanded(
                          child: RecentSolutionsSection(
                            recentAsync: recentAsync,
                            onViewAll: () => context.push(RouteNames.history),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const HomeBannerAd(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({
    required this.onProfileTap,
    required this.userAsync,
  });

  final VoidCallback onProfileTap;
  final AsyncValue<dynamic> userAsync;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        userAsync.when(
          data: (user) {
            final photoUrl = user?.photoUrl as String?;
            final name = user?.name as String?;
            return GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.full),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(1.4),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    child: photoUrl != null && photoUrl.isNotEmpty
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _ProfileFallback(name: name),
                          )
                        : _ProfileFallback(name: name),
                  ),
                ),
              ),
            );
          },
          loading: () => Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.full),
            ),
          ),
          error: (_, __) => GestureDetector(
            onTap: onProfileTap,
            child: const _ProfileFallback(name: null),
          ),
        ),
      ],
    );
  }
}

class _ProfileFallback extends StatelessWidget {
  const _ProfileFallback({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final letter = (name != null && name!.trim().isNotEmpty)
        ? name!.trim().characters.first.toUpperCase()
        : 'P';

    return Container(
      color: AppColors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppTextStyles.titleMd.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}