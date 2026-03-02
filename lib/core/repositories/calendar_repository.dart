import 'package:fangeul/core/entities/kpop_event.dart';

/// K-pop 캘린더 이벤트 데이터 접근 인터페이스.
///
/// 구현체는 `data/repositories/calendar_repository_impl.dart`에서 제공.
abstract interface class CalendarRepository {
  /// 모든 이벤트 조회.
  Future<List<KpopEvent>> getAllEvents();

  /// MM-DD 형식의 날짜로 이벤트 조회.
  Future<List<KpopEvent>> getEventsByDate(String mmdd);
}
