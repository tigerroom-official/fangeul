import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/core/entities/kpop_event.dart';
import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/repositories/calendar_repository.dart';
import 'package:fangeul/core/usecases/get_today_events_usecase.dart';
import 'package:fangeul/data/datasources/calendar_local_datasource.dart';
import 'package:fangeul/data/repositories/calendar_repository_impl.dart';
import 'package:fangeul/presentation/providers/phrase_providers.dart';

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

/// 오늘 이벤트 기반 추천 문구
@riverpod
Future<List<Phrase>> todaySuggestedPhrases(TodaySuggestedPhrasesRef ref) async {
  final events = await ref.watch(todayEventsProvider.future);
  if (events.isEmpty) return [];

  final situations = events.map((e) => e.situation).toSet();
  final allPacks = await ref.watch(allPhrasesProvider.future);
  return allPacks
      .expand((p) => p.phrases)
      .where((p) => p.situation != null && situations.contains(p.situation))
      .toList();
}
