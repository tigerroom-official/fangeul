import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/providers/copy_history_provider.dart';

void main() {
  group('CopyHistoryNotifier', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('should start with empty list', () {
      final history = container.read(copyHistoryNotifierProvider);
      expect(history, isEmpty);
    });

    test('should add entry to front of list', () {
      final notifier = container.read(copyHistoryNotifierProvider.notifier);
      notifier.addEntry('사랑해요');
      notifier.addEntry('화이팅');

      final history = container.read(copyHistoryNotifierProvider);
      expect(history.first, '화이팅');
      expect(history[1], '사랑해요');
    });

    test('should move existing entry to front on re-add', () {
      final notifier = container.read(copyHistoryNotifierProvider.notifier);
      notifier.addEntry('첫번째');
      notifier.addEntry('두번째');
      notifier.addEntry('첫번째');

      final history = container.read(copyHistoryNotifierProvider);
      expect(history.first, '첫번째');
      expect(history, hasLength(2));
    });

    test('should limit to 20 entries', () {
      final notifier = container.read(copyHistoryNotifierProvider.notifier);
      for (var i = 0; i < 25; i++) {
        notifier.addEntry('항목 $i');
      }

      final history = container.read(copyHistoryNotifierProvider);
      expect(history, hasLength(20));
      expect(history.first, '항목 24');
    });

    test('should clear all entries', () {
      final notifier = container.read(copyHistoryNotifierProvider.notifier);
      notifier.addEntry('사랑해요');
      notifier.addEntry('화이팅');
      notifier.clearAll();

      final history = container.read(copyHistoryNotifierProvider);
      expect(history, isEmpty);
    });

    test('should not add empty string', () {
      final notifier = container.read(copyHistoryNotifierProvider.notifier);
      notifier.addEntry('');

      final history = container.read(copyHistoryNotifierProvider);
      expect(history, isEmpty);
    });

    group('persistence', () {
      test('should load saved history on build', () async {
        SharedPreferences.setMockInitialValues({
          'copy_history': jsonEncode(['최근1', '최근2', '최근3']),
        });
        final c = ProviderContainer();
        addTearDown(c.dispose);

        c.listen(copyHistoryNotifierProvider, (_, __) {});
        await Future<void>.delayed(Duration.zero);

        final history = c.read(copyHistoryNotifierProvider);
        expect(history, ['최근1', '최근2', '최근3']);
      });

      test('should merge loaded data with in-flight entries', () async {
        SharedPreferences.setMockInitialValues({
          'copy_history': jsonEncode(['저장1', '저장2']),
        });
        final c = ProviderContainer();
        addTearDown(c.dispose);

        c.listen(copyHistoryNotifierProvider, (_, __) {});

        // 로드 완료 전에 addEntry 호출
        final notifier = c.read(copyHistoryNotifierProvider.notifier);
        notifier.addEntry('신규항목');

        // 로드 완료 대기
        await Future<void>.delayed(Duration.zero);

        final history = c.read(copyHistoryNotifierProvider);
        // 신규항목이 앞에, 저장된 항목이 뒤에 (중복 제거)
        expect(history.first, '신규항목');
        expect(history, contains('저장1'));
        expect(history, contains('저장2'));
      });
    });
  });
}
