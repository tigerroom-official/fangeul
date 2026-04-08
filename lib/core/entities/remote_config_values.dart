/// Remote Config 값을 담는 순수 Dart 엔티티.
///
/// Firebase 의존성 없이 기본값만 포함한다.
/// 각 필드의 기본값은 현재 하드코딩된 수익화 수치와 동일하다.
class RemoteConfigValues {
  /// 기본 수익화 수치로 초기화된 Remote Config 값을 생성한다.
  const RemoteConfigValues({
    this.honeymoonDays = 14,
    this.defaultSlotLimit = 5,
    this.dailyAdLimit = 3,
    this.adCooldownMinutes = 5,
    this.unlockDurationHours = 24,
    this.dailyTtsLimit = 5,
    this.conversionTriggerAdCount = 3,
    this.bannerDelayDays = 0,
    this.ttsRewardedBonus = 2,
  });

  /// 허니문(무료 체험) 기간 일수. Day 0부터 시작.
  final int honeymoonDays;

  /// 허니문 종료 후 즐겨찾기 슬롯 제한.
  final int defaultSlotLimit;

  /// 일일 보상형 광고 시청 제한 횟수.
  final int dailyAdLimit;

  /// 광고 시청 간 쿨다운 (분).
  final int adCooldownMinutes;

  /// 테마 체험 지속 시간 (시간). 보상형 광고 시청 시 프리미엄 테마 체험 기간.
  final int unlockDurationHours;

  /// 일일 TTS 재생 제한 횟수.
  final int dailyTtsLimit;

  /// 전환 트리거 발동에 필요한 광고 시청 횟수.
  final int conversionTriggerAdCount;

  /// 배너 광고 노출 시작까지의 지연 일수.
  ///
  /// 기본값 0 = 온보딩 완료 후 즉시 배너 노출.
  /// Firebase Console에서 값을 올리면 Day N 지연으로 즉시 롤백 가능.
  final int bannerDelayDays;

  /// 보상형 광고 시청 시 추가되는 TTS 재생 횟수.
  final int ttsRewardedBonus;
}
