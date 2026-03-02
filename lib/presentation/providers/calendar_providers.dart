import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/core/entities/kpop_event.dart';
import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/repositories/calendar_repository.dart';
import 'package:fangeul/core/usecases/get_today_events_usecase.dart';
import 'package:fangeul/data/datasources/calendar_local_datasource.dart';
import 'package:fangeul/data/repositories/calendar_repository_impl.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/providers/phrase_providers.dart';
import 'package:fangeul/presentation/providers/template_phrase_provider.dart';

part 'calendar_providers.g.dart';

@riverpod
CalendarLocalDataSource calendarLocalDataSource(
    CalendarLocalDataSourceRef ref) {
  return CalendarLocalDataSource();
}

@riverpod
CalendarRepository calendarRepository(CalendarRepositoryRef ref) {
  return CalendarRepositoryImpl(ref.read(calendarLocalDataSourceProvider));
}

@riverpod
GetTodayEventsUseCase getTodayEventsUseCase(GetTodayEventsUseCaseRef ref) {
  return GetTodayEventsUseCase(ref.read(calendarRepositoryProvider));
}

/// 오늘의 K-pop 이벤트 목록
@riverpod
Future<List<KpopEvent>> todayEvents(TodayEventsRef ref) {
  return ref.read(getTodayEventsUseCaseProvider).execute();
}

/// 오늘 이벤트 기반 추천 문구.
///
/// 마이 아이돌 설정 시 해당 그룹 이벤트만 필터링하고
/// 템플릿 문구의 `{{group_name}}`을 치환한다.
@riverpod
Future<List<Phrase>> todaySuggestedPhrases(TodaySuggestedPhrasesRef ref) async {
  final events = await ref.watch(todayEventsProvider.future);
  if (events.isEmpty) return [];

  final idolName = await ref.watch(myIdolDisplayNameProvider.future);

  // 마이 아이돌 설정 시 해당 그룹 이벤트만 필터링
  final filteredEvents = idolName != null
      ? events
          .where((e) => e.group == idolName || e.artist == idolName)
          .toList()
      : events;

  if (filteredEvents.isEmpty) return [];

  final situations = filteredEvents.map((e) => e.situation).toSet();
  final allPacks = await ref.watch(allPhrasesProvider.future);
  final phrases = allPacks
      .expand((p) => p.phrases)
      .where((p) => p.situation != null && situations.contains(p.situation))
      .toList();

  return filterAndResolveTemplates(phrases, idolName);
}
