/// 분석 서비스 추상 인터페이스.
///
/// Firebase Analytics, NoOp 등 구현체를 교체할 수 있도록
/// 추상 레이어를 제공한다. Provider를 통해 DI.
abstract interface class AnalyticsService {
  /// 이벤트를 기록한다.
  Future<void> logEvent(String name, [Map<String, Object>? params]);

  /// 사용자 속성을 설정한다.
  Future<void> setUserProperty(String name, String value);
}
