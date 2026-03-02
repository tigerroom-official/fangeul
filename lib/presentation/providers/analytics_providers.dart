import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/services/analytics_service.dart';
import 'package:fangeul/services/noop_analytics_service.dart';

part 'analytics_providers.g.dart';

/// [AnalyticsService] Provider.
///
/// 기본값은 [NoOpAnalyticsService]. Firebase 초기화 성공 시
/// `ProviderScope.overrides`로 [FirebaseAnalyticsService]를 주입한다.
@riverpod
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  return NoOpAnalyticsService();
}
