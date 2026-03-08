import 'package:freezed_annotation/freezed_annotation.dart';

part 'monetization_state.freezed.dart';
part 'monetization_state.g.dart';

/// 수익화 상태 — 허니문, 광고, IAP, 해금 등 전체 수익화 관련 데이터.
///
/// 모든 필드에 기본값이 있어 빈 생성(`MonetizationState()`)이 가능하다.
/// JSON 직렬화를 지원하며, [MonetizationLocalDataSource]에서 HMAC 검증과
/// 결합하여 변조를 방어한다. [lastTimestamp]로 단조증가를 검증하여 시간 조작을 방어.
@freezed
class MonetizationState with _$MonetizationState {
  const factory MonetizationState({
    /// 앱 설치 날짜 (yyyy-MM-dd). null이면 아직 설정되지 않음.
    String? installDate,

    /// 허니문(무료 체험) 기간 활성 여부. 기본 true.
    @Default(true) bool honeymoonActive,

    /// 즐겨찾기 슬롯 제한. 0 = 무제한 (허니문/Pro), 3 = 기본 제한.
    @Default(0) int favoriteSlotLimit,

    /// 오늘 TTS 재생 횟수.
    @Default(0) int ttsPlayCount,

    /// TTS 횟수 마지막 리셋 날짜 (yyyy-MM-dd).
    String? ttsLastResetDate,

    /// 오늘 보상형 광고 시청 횟수.
    @Default(0) int adWatchCount,

    /// 광고 횟수 마지막 리셋 날짜 (yyyy-MM-dd).
    String? adLastResetDate,

    /// 마지막 광고 시청 타임스탬프 (ms since epoch). 5분 쿨다운 검증용.
    @Default(0) int lastAdWatchTimestamp,

    /// 테마 체험 만료 타임스탬프 (ms since epoch). 0 = 체험 없음.
    ///
    /// 보상형 광고 시청 시 프리미엄 테마 24시간 체험 기간.
    /// 구: unlockExpiresAt (4시간 기능 해금) → 피벗 후 테마 체험 전용.
    @Default(0) @JsonKey(name: 'unlockExpiresAt') int themeTrialExpiresAt,

    /// 구매 완료된 팩 ID 목록.
    @Default([]) List<String> purchasedPackIds,

    /// D-day 해금 날짜 목록 ('{date}_{artist}_{type}' 형식).
    @Default([]) List<String> ddayUnlockedDates,

    /// 자유 컬러 피커 IAP 구매 여부.
    @Default(false) bool hasThemePicker,

    /// 테마 슬롯 IAP 구매 여부.
    @Default(false) bool hasThemeSlots,

    /// 보상형 광고로 테마 팔레트 영구 해금 여부.
    @Default(false) bool themeUnlocked,

    /// 단조증가 타임스탬프 (밀리초). 시간 조작 방어용.
    @Default(0) int lastTimestamp,
  }) = _MonetizationState;

  /// JSON 역직렬화 팩토리.
  factory MonetizationState.fromJson(Map<String, dynamic> json) =>
      _$MonetizationStateFromJson(json);
}
