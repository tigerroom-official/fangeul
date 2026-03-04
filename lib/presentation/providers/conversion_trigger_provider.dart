import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/remote_config_providers.dart';

part 'conversion_trigger_provider.g.dart';

/// 전환 트리거 팝업 표시 조건 provider.
///
/// 다음 모든 조건 충족 시 true:
/// - Day 14+ (설치 후 14일 이상 경과)
/// - 보상형 광고 3회 소진
/// - 즐겨찾기 슬롯 포화
/// - 아직 IAP 구매 없음
@riverpod
bool shouldShowConversionTrigger(ShouldShowConversionTriggerRef ref) {
  final state = ref.watch(monetizationNotifierProvider).valueOrNull;
  if (state == null) return false;

  final installDate = state.installDate;
  if (installDate == null) return false;

  // 설치 후 경과 일수 계산 — malformed 데이터 방어
  final int daysSince;
  try {
    final parts = installDate.split('-');
    final install = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    daysSince = DateTime.now().difference(install).inDays;
  } catch (_) {
    return false;
  }

  // 즐겨찾기 수
  final favCount =
      ref.watch(favoritePhrasesNotifierProvider).valueOrNull?.length ?? 0;

  final config = ref.watch(remoteConfigValuesProvider);

  return daysSince >= config.honeymoonDays &&
      state.adWatchCount >= config.conversionTriggerAdCount &&
      state.favoriteSlotLimit > 0 &&
      favCount >= state.favoriteSlotLimit &&
      state.purchasedPackIds.isEmpty;
}
