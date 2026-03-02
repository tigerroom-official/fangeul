import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/core/entities/kpop_event.dart';
import 'package:fangeul/core/repositories/calendar_repository.dart';
import 'package:fangeul/core/usecases/get_today_events_usecase.dart';

class MockCalendarRepository extends Mock implements CalendarRepository {}

void main() {
  late MockCalendarRepository mockRepository;
  late GetTodayEventsUseCase useCase;

  setUp(() {
    mockRepository = MockCalendarRepository();
    useCase = GetTodayEventsUseCase(mockRepository);
  });

  group('GetTodayEventsUseCase', () {
    test('should return events for March 9th as "03-09"', () async {
      const event = KpopEvent(
        date: '03-09',
        type: 'birthday',
        artist: '슈가',
        group: 'BTS',
        situation: 'birthday',
      );
      when(() => mockRepository.getEventsByDate('03-09'))
          .thenAnswer((_) async => [event]);

      final result = await useCase.execute(date: DateTime(2026, 3, 9));

      expect(result, hasLength(1));
      expect(result.first.artist, '슈가');
      verify(() => mockRepository.getEventsByDate('03-09')).called(1);
    });

    test('should pad single-digit month and day', () async {
      when(() => mockRepository.getEventsByDate('01-03'))
          .thenAnswer((_) async => []);

      await useCase.execute(date: DateTime(2026, 1, 3));

      verify(() => mockRepository.getEventsByDate('01-03')).called(1);
    });

    test('should return empty list when no events on date', () async {
      when(() => mockRepository.getEventsByDate('02-29'))
          .thenAnswer((_) async => []);

      final result = await useCase.execute(date: DateTime(2024, 2, 29));

      expect(result, isEmpty);
    });

    test('should return multiple events when same date', () async {
      const events = [
        KpopEvent(
          date: '09-01',
          type: 'birthday',
          artist: '정한',
          group: 'SEVENTEEN',
          situation: 'birthday',
        ),
        KpopEvent(
          date: '09-01',
          type: 'birthday',
          artist: '나연',
          group: 'TWICE',
          situation: 'birthday',
        ),
      ];
      when(() => mockRepository.getEventsByDate('09-01'))
          .thenAnswer((_) async => events);

      final result = await useCase.execute(date: DateTime(2026, 9, 1));

      expect(result, hasLength(2));
    });

    test('should use current date when date parameter is null', () async {
      final now = DateTime.now();
      final mmdd =
          '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      when(() => mockRepository.getEventsByDate(mmdd))
          .thenAnswer((_) async => []);

      await useCase.execute();

      verify(() => mockRepository.getEventsByDate(mmdd)).called(1);
    });
  });
}
