import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/presentation/providers/theme_providers.dart';

part 'onboarding_providers.g.dart';

/// 온보딩 완료 여부를 SharedPreferences에서 읽는다.
///
/// 배너 광고 가드 조건으로 사용: 온보딩 미완료 시 배너 숨김.
/// `keepAlive: true` — 앱 실행 중 dispose 방지.
@Riverpod(keepAlive: true)
bool isOnboardingDone(IsOnboardingDoneRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('onboarding_done') ?? false;
}
