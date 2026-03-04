import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/core/entities/kpop_event.dart';
import 'package:fangeul/presentation/providers/calendar_providers.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';

part 'dday_gift_provider.g.dart';

/// D-day 선물 대상 이벤트.
///
/// 오늘 유저의 마이 아이돌에 해당하는 이벤트가 있고,
/// 해당 이벤트에 대한 D-day 해금을 아직 수령하지 않은 경우
/// 해당 [KpopEvent]를 반환한다. 없으면 null.
///
/// 이 provider를 watch하여 값이 non-null이면 [showDdayGiftPopup]을 호출한다.
@riverpod
Future<KpopEvent?> ddayGiftEvent(DdayGiftEventRef ref) async {
  final events = await ref.watch(todayEventsProvider.future);
  if (events.isEmpty) return null;

  final idolName = await ref.watch(myIdolDisplayNameProvider.future);
  if (idolName == null) return null;

  // 마이 아이돌 관련 이벤트만 필터링
  final idolEvents =
      events.where((e) => e.group == idolName || e.artist == idolName).toList();
  if (idolEvents.isEmpty) return null;

  // 이미 수령한 이벤트 제외
  final monetizationState =
      await ref.watch(monetizationNotifierProvider.future);
  final claimedKeys = monetizationState.ddayUnlockedDates;

  final today = DateTime.now();
  final dateStr =
      '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  for (final event in idolEvents) {
    final key = MonetizationNotifier.ddayKey(dateStr, event.artist, event.type);
    if (!claimedKeys.contains(key)) {
      return event;
    }
  }

  return null;
}
