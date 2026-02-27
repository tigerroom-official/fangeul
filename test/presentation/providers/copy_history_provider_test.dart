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
  });
}
