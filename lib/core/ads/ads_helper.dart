import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }

    throw UnsupportedError('Desteklenmeyen platform');
  }

  static String get rewardedAdUnitId {
  if (Platform.isAndroid) {
    return 'ca-app-pub-8221922808926620/3000849883';
  }
  throw UnsupportedError('Desteklenmeyen platform');
}
}