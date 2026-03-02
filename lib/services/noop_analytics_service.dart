import 'package:flutter/foundation.dart';

import 'package:fangeul/services/analytics_service.dart';

/// 분석 서비스 NoOp 구현.
///
/// Firebase가 초기화되지 않았거나 개발/테스트 환경에서 사용.
/// 디버그 모드에서는 이벤트를 콘솔에 출력한다.
class NoOpAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    if (kDebugMode) {
      debugPrint('[Analytics] $name ${params ?? ''}');
    }
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    if (kDebugMode) {
      debugPrint('[Analytics] userProperty: $name=$value');
    }
  }
}
