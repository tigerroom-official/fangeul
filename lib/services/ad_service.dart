import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:fangeul/services/ad_ids.dart';

/// AdMob 광고 관리 서비스.
///
/// 배너: 결과 화면, 카드 획득 화면, 캘린더 하단에 표시.
/// 보상형: "팬 패스" 해금 4h (or 자정) 용.
class AdService {
  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;
  bool _isInitialized = false;

  /// AdMob SDK 초기화. 앱 시작 시 1회 호출.
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      // 광고 콘텐츠 등급 제한: T(Teen) — 성인 광고 차단.
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          maxAdContentRating: MaxAdContentRating.t,
        ),
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('AdService: init failed: $e');
    }
  }

  /// SDK 초기화 완료 여부.
  bool get isInitialized => _isInitialized;

  /// 보상형 광고 미리 로드.
  Future<void> preloadRewarded() async {
    if (_isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;

    await RewardedAd.load(
      adUnitId: AdIds.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: rewarded load failed: ${error.message}');
          _rewardedAd = null;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  /// 보상형 광고 로드 완료 여부.
  bool get isRewardedReady => _rewardedAd != null;

  /// 보상형 광고 표시.
  ///
  /// [onRewarded] 시청 완료 시 보상 지급 콜백.
  /// [onDismissed] 광고 닫힘 콜백 (선택).
  Future<void> showRewarded({
    required void Function() onRewarded,
    void Function()? onDismissed,
  }) async {
    final ad = _rewardedAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onDismissed?.call();
        preloadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: rewarded show failed: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        onDismissed?.call();
        preloadRewarded();
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) => onRewarded(),
    );
  }

  /// 리소스 해제.
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
