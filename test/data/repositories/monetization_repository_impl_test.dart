import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/data/datasources/monetization_local_datasource.dart';
import 'package:fangeul/data/repositories/monetization_repository_impl.dart';

class MockMonetizationLocalDataSource extends Mock
    implements MonetizationLocalDataSource {}

void main() {
  late MockMonetizationLocalDataSource mockDataSource;
  late MonetizationRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockMonetizationLocalDataSource();
    repository = MonetizationRepositoryImpl(mockDataSource);
  });

  setUpAll(() {
    registerFallbackValue(const MonetizationState());
  });

  group('MonetizationRepositoryImpl', () {
    test('should load monetization state from data source', () async {
      const state = MonetizationState(
        honeymoonActive: false,
        adWatchCount: 2,
        hasThemePicker: true,
      );
      when(() => mockDataSource.load()).thenAnswer((_) async => state);

      final result = await repository.load();

      expect(result, state);
      verify(() => mockDataSource.load()).called(1);
    });

    test('should save monetization state to data source', () async {
      const state = MonetizationState(
        honeymoonActive: false,
        ttsPlayCount: 5,
        themeTrialExpiresAt: 1709568000000,
      );
      when(() => mockDataSource.save(any())).thenAnswer((_) async {});

      await repository.save(state);

      verify(() => mockDataSource.save(state)).called(1);
    });
  });
}
