import 'dart:async';

import 'package:cozbak/shared/widgets/network/network_restored_banner.dart';
import 'package:cozbak/shared/widgets/network/no_internet_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_providers.dart';

class OfflineGate extends ConsumerStatefulWidget {
  const OfflineGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<OfflineGate> createState() => _OfflineGateState();
}

class _OfflineGateState extends ConsumerState<OfflineGate> {
  bool _showRestoredBanner = false;
  Timer? _bannerTimer;

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isOfflineProvider, (previous, next) {
      if (previous == true && next == false) {
        _showOnlineBanner();
      }
    });

    final isOffline = ref.watch(isOfflineProvider);
    final isNetworkReady = ref.watch(isNetworkReadyProvider);

    final shouldShowOffline = isNetworkReady && isOffline;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          ignoring: !shouldShowOffline,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: shouldShowOffline
                ? const KeyedSubtree(
                    key: ValueKey('offline_overlay'),
                    child: NoInternetOverlay(),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Positioned(
          top: 18,
          left: 16,
          right: 16,
          child: SafeArea(
            child: IgnorePointer(
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                offset:
                    _showRestoredBanner ? Offset.zero : const Offset(0, -1.2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: _showRestoredBanner ? 1 : 0,
                  child: const Center(
                    child: NetworkRestoredBanner(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showOnlineBanner() {
    _bannerTimer?.cancel();

    if (!mounted) return;
    setState(() {
      _showRestoredBanner = true;
    });

    _bannerTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _showRestoredBanner = false;
      });
    });
  }
}