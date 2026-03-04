import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:fangeul/services/analytics_service.dart';

/// Firebase Analytics 구현체.
///
/// 프로덕션 환경에서 사용. [FirebaseAnalytics] 인스턴스를 주입받아
/// 이벤트 기록 및 사용자 속성 설정을 Firebase 서버에 전송한다.
class FirebaseAnalyticsService implements AnalyticsService {
  /// Firebase Analytics 인스턴스를 주입받아 생성한다.
  ///
  /// [instance]가 null이면 싱글턴 인스턴스를 사용한다.
  FirebaseAnalyticsService([FirebaseAnalytics? instance])
      : _analytics = instance ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    await _analytics.logEvent(
      name: name,
      parameters: params,
    );
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}
