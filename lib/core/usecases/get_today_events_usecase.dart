import 'package:fangeul/core/entities/kpop_event.dart';
import 'package:fangeul/core/repositories/calendar_repository.dart';

/// 오늘(또는 지정 날짜)의 K-pop 이벤트를 조회하는 유스케이스.
///
/// [DateTime]을 MM-DD 문자열로 변환하여 매칭한다.
class GetTodayEventsUseCase {
  final CalendarRepository _repository;

  GetTodayEventsUseCase(this._repository);

  /// [date]가 null이면 오늘 날짜 기준으로 이벤트를 반환한다.
  Future<List<KpopEvent>> execute({DateTime? date}) async {
    final now = date ?? DateTime.now();
    final mmdd =
        '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _repository.getEventsByDate(mmdd);
  }
}
