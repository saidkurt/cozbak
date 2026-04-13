import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }

    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }

    throw UnsupportedError('Desteklenmeyen platform');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    }

    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }

    throw UnsupportedError('Desteklenmeyen platform');
  }
}