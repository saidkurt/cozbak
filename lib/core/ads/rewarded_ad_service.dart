import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cozbak/core/ads/ads_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;

class RewardedAdService {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  bool get isReady => _rewardedAd != null;
  bool get isLoading => _isLoading;

 Future<void> loadAd() async {
  if (_isLoading || _rewardedAd != null) return;

  _isLoading = true;

  final completer = Completer<void>();

  RewardedAd.load(
    adUnitId: AdHelper.rewardedAdUnitId,
    request: const AdRequest(),
    rewardedAdLoadCallback: RewardedAdLoadCallback(
      onAdLoaded: (ad) {
        _rewardedAd = ad;
        _isLoading = false;
        debugPrint('Rewarded ad loaded');
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToLoad: (error) {
        _rewardedAd = null;
        _isLoading = false;
        debugPrint('Rewarded ad failed to load: $error');
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    ),
  );

  await completer.future;
}

  Future<bool> showAdAndRewardUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Reward failed: currentUser is null');
      return false;
    }

    if (_rewardedAd == null) {
      debugPrint('Rewarded ad not ready, loading again...');
      await loadAd();
      return false;
    }

    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        loadAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) async {
        rewardEarned = await _sendRewardToBackend(uid: user.uid);
      },
    );

    return rewardEarned;
  }

  Future<bool> _sendRewardToBackend({
    required String uid,
  }) async {
    const url =
        'https://us-central1-cozbak-e7a9a.cloudfunctions.net/rewardUserForAd';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uid': uid,
          'rewardAmount': 1,
          'rewardType': 'credit',
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'adUnit': 'rewarded_credit',
          'sourceScreen': 'home',
        }),
      );

      debugPrint(
        'rewardUserForAd response => ${response.statusCode} ${response.body}',
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('rewardUserForAd request error: $e');
      return false;
    }
  }

  Future<bool> prepareAdIfNeeded() async {
  if (isReady) return true;
  await loadAd();
  return isReady;
}

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}