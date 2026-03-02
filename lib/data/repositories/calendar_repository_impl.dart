import 'package:fangeul/core/entities/kpop_event.dart';
import 'package:fangeul/core/repositories/calendar_repository.dart';
import 'package:fangeul/data/datasources/calendar_local_datasource.dart';

/// [CalendarRepository] 구현체 — 로컬 에셋 JSON 기반.
class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarLocalDataSource _dataSource;

  CalendarRepositoryImpl(this._dataSource);

  @override
  Future<List<KpopEvent>> getAllEvents() => _dataSource.getAllEvents();

  @override
  Future<List<KpopEvent>> getEventsByDate(String mmdd) =>
      _dataSource.getEventsByDate(mmdd);
}
