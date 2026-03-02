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
}
