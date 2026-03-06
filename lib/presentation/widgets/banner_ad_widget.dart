import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/session_state_provider.dart';
import 'package:fangeul/services/ad_ids.dart';

/// installDate 기반 설치 후 경과 일수. 파싱 실패 시 0 (방어적 코딩).
int _daysSinceInstall(MonetizationState? state) {
  final dateStr = state?.installDate;
  if (dateStr == null) return 0;
  try {
    return DateTime.now().difference(DateTime.parse(dateStr)).inDays;
  } on FormatException {
    return 0;
  }
}

/// 조건부 배너 광고 위젯.
///
/// Day 7 미만, 보상형 해금, 세션 숨김, IAP 구매 시 자동 숨김.
/// 높이 50dp 고정 (AdMob 배너 표준).
class BannerAdWidget extends ConsumerStatefulWidget {
  /// 조건부 배너 광고 위젯을 생성한다.
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => BannerAdWidgetState();
}

/// [BannerAdWidget]의 State.
///
/// 광고 로딩 상태는 위젯 고유의 ephemeral state이므로 setState 사용이 적합하다.
@visibleForTesting
class BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  /// 현재 로드된 배너 광고. null이면 아직 로드되지 않았거나 실패.
  @visibleForTesting
  BannerAd? bannerAd;

  /// 광고가 성공적으로 로드되었는지 여부.
  @visibleForTesting
  bool isLoaded = false;

  bool _adLoadAttempted = false;

  @override
  void initState() {
    super.initState();
    // 광고 로딩은 첫 build 후 조건 확인 후 실행 (불필요한 네트워크 요청 방지).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tryLoadAdIfNeeded();
    });
  }

  /// 조건 충족 시 배너 광고를 로드한다. Day 7 미만/해금/구매 시 로드 생략.
  void _tryLoadAdIfNeeded() {
    if (_adLoadAttempted) return;
    _adLoadAttempted = true;

    final monState = ref.read(monetizationNotifierProvider).valueOrNull;
    final daysSince = _daysSinceInstall(monState);
    final isUnlocked = ref.read(isRewardedUnlockActiveProvider);
    final sessionHidden = ref.read(sessionBannerHiddenProvider);
    final hasPurchase = monState?.purchasedPackIds.isNotEmpty ?? false;

    if (daysSince < 7 || isUnlocked || sessionHidden || hasPurchase) return;

    _loadAd();
  }

  void _loadAd() {
    bannerAd = BannerAd(
      adUnitId: AdIds.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAdWidget: load failed: ${error.message}');
          ad.dispose();
          bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monState = ref.watch(monetizationNotifierProvider).valueOrNull;
    final isUnlocked = ref.watch(isRewardedUnlockActiveProvider);
    final sessionHidden = ref.watch(sessionBannerHiddenProvider);
    final hasPurchase = monState?.purchasedPackIds.isNotEmpty ?? false;

    // Day 7 미만이면 배너 숨김 (허니문 중 배너 미노출)
    final daysSince = _daysSinceInstall(monState);
    if (daysSince < 7) {
      return const SizedBox.shrink();
    }

    // 보상형 해금 / 세션 숨김 / IAP 구매 시 배너 숨김
    if (isUnlocked || sessionHidden || hasPurchase) {
      return const SizedBox.shrink();
    }

    if (!isLoaded || bannerAd == null) {
      return const SizedBox(height: 50); // 광고 로딩 전 플레이스홀더
    }

    return SizedBox(
      height: 50,
      child: AdWidget(ad: bannerAd!),
    );
  }
}
