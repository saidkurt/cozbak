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

  Future<bool> prepareAdIfNeeded() async {
    if (isReady) return true;

    try {
      await loadAd();
      return isReady;
    } catch (e) {
      debugPrint('prepareAdIfNeeded error: $e');
      return false;
    }
  }

  Future<bool> showAdAndRewardUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Reward failed: currentUser is null');
      return false;
    }

    if (_rewardedAd == null) {
      debugPrint('Rewarded ad not ready');
      final ready = await prepareAdIfNeeded();
      if (!ready) return false;
    }

    final ad = _rewardedAd;
    if (ad == null) return false;

    final completer = Completer<bool>();
    bool rewardCallbackTriggered = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Rewarded ad dismissed');
        ad.dispose();
        _rewardedAd = null;

        Future.microtask(() async {
          try {
            await loadAd();
          } catch (_) {}
        });

        if (!rewardCallbackTriggered && !completer.isCompleted) {
          completer.complete(false);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;

        Future.microtask(() async {
          try {
            await loadAd();
          } catch (_) {}
        });

        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (ad, reward) async {
          rewardCallbackTriggered = true;

          try {
            final success = await _sendRewardToBackend();
            debugPrint('Reward backend result: $success');

            if (!completer.isCompleted) {
              completer.complete(success);
            }
          } catch (e) {
            debugPrint('onUserEarnedReward error: $e');
            if (!completer.isCompleted) {
              completer.complete(false);
            }
          }
        },
      );
    } catch (e) {
      debugPrint('ad.show error: $e');
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return completer.future;
  }

  Future<bool> _sendRewardToBackend() async {
    const url =
        'https://us-central1-cozbak-e7a9a.cloudfunctions.net/rewardUserForAd';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('rewardUserForAd: currentUser is null');
        return false;
      }

      final idToken = await user.getIdToken(true);

      final eventId =
          'reward_${user.uid}_${DateTime.now().millisecondsSinceEpoch}';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'eventId': eventId,
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

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      return data['success'] == true;
    } catch (e) {
      debugPrint('rewardUserForAd request error: $e');
      return false;
    }
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}