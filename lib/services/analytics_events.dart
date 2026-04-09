/// 분석 이벤트 이름 상수.
///
/// Firebase Analytics 이벤트 네이밍 규칙(snake_case, 40자 이내) 준수.
class AnalyticsEvents {
  AnalyticsEvents._();

  /// 앱 시작.
  static const appOpen = 'app_open';

  /// 버블 세션 시작 (버블 표시).
  static const bubbleSessionStart = 'bubble_session_start';

  /// 버블 세션 종료 (버블 숨김).
  static const bubbleSessionEnd = 'bubble_session_end';

  /// 문구 복사.
  static const phraseCopy = 'phrase_copy';

  /// 문구 즐겨찾기 토글.
  static const phraseFavorite = 'phrase_favorite';

  /// 필터 변경 (간편모드 팩/즐겨찾기 전환).
  static const filterChange = 'filter_change';

  /// 캘린더 이벤트 조회.
  static const calendarEventView = 'calendar_event_view';

  // 수익화 — 광고
  /// 배너 광고 노출.
  static const adBannerImpression = 'ad_banner_impression';

  /// 보상형 광고 시작.
  static const adRewardedStart = 'ad_rewarded_start';

  /// 보상형 광고 완료.
  static const adRewardedComplete = 'ad_rewarded_complete';

  /// 보상형 광고 실패.
  static const adRewardedFailed = 'ad_rewarded_failed';

  /// 팬 패스 활성화.
  static const fanPassActivated = 'fan_pass_activated';

  /// 팬 패스 만료.
  static const fanPassExpired = 'fan_pass_expired';

  // 수익화 — IAP
  /// 샵 화면 진입.
  static const iapViewShop = 'iap_view_shop';

  /// 구매 시작.
  static const iapStartPurchase = 'iap_start_purchase';

  /// 구매 성공.
  static const iapPurchaseSuccess = 'iap_purchase_success';

  /// 구매 실패.
  static const iapPurchaseFailed = 'iap_purchase_failed';

  /// 구매 복원.
  static const iapRestorePurchase = 'iap_restore_purchase';

  // 수익화 — 제한 & 전환
  /// 즐겨찾기 슬롯 포화.
  static const favLimitReached = 'fav_limit_reached';

  /// TTS 일일 제한 도달.
  static const ttsLimitReached = 'tts_limit_reached';

  /// 전환 트리거 팝업 표시.
  static const conversionTriggerShown = 'conversion_trigger_shown';

  /// 전환 트리거 CTA 클릭.
  static const conversionTriggerClicked = 'conversion_trigger_clicked';

  /// D-day 선물 활성화.
  static const ddayGiftActivated = 'dday_gift_activated';

  /// 허니문 종료.
  static const honeymoonEnded = 'honeymoon_ended';

  // TTS
  /// TTS 재생.
  static const ttsPlay = 'tts_play';

  /// TTS 보상형 광고 시청.
  static const ttsRewardedWatch = 'tts_rewarded_watch';
}

/// 분석 파라미터 키 상수.
class AnalyticsParams {
  AnalyticsParams._();

  static const packId = 'pack_id';
  static const situation = 'situation';
  static const source = 'source';
  static const action = 'action';
  static const filterType = 'filter_type';
  static const durationSec = 'duration_sec';
  static const eventType = 'event_type';
  static const artist = 'artist';

  // 수익화 파라미터
  static const skuId = 'sku_id';
  static const revenue = 'revenue';
  static const unlockDurationMin = 'unlock_duration_min';
  static const daysSinceInstall = 'days_since_install';
  static const audioId = 'audio_id';
}
