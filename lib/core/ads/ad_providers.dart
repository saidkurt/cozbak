import 'package:cozbak/core/ads/rewarded_ad_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rewardedAdServiceProvider = Provider<RewardedAdService>((ref) {
  final service = RewardedAdService();
  ref.onDispose(service.dispose);
  return service;
});