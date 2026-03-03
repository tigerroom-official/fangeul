import 'package:flutter/foundation.dart';

/// AdMob 광고 유닛 ID. 디버그 모드에서 Google 테스트 ID 자동 사용.
abstract final class AdIds {
  static const _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _testRewarded = 'ca-app-pub-3940256099942544/5224354917';

  // TODO(fangeul): AdMob 콘솔에서 프로덕션 ID 생성 후 교체
  static const _prodBanner = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const _prodRewarded = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  /// 배너 광고 유닛 ID.
  static String get bannerId => kDebugMode ? _testBanner : _prodBanner;

  /// 보상형 광고 유닛 ID.
  static String get rewardedId => kDebugMode ? _testRewarded : _prodRewarded;
}
