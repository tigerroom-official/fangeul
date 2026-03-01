import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';

void main() {
  group('FavoritePhrasesNotifier', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('should start with empty set after load', () async {
      container.listen(favoritePhrasesNotifierProvider, (_, __) {});
      final favorites =
          await container.read(favoritePhrasesNotifierProvider.future);
      expect(favorites, isEmpty);
    });

    test('should add phrase to favorites', () async {
      container.listen(favoritePhrasesNotifierProvider, (_, __) {});
      await container.read(favoritePhrasesNotifierProvider.future);

      final notifier = container.read(favoritePhrasesNotifierProvider.notifier);
      await notifier.toggle('사랑해요');

      final favorites =
          container.read(favoritePhrasesNotifierProvider).valueOrNull;
      expect(favorites, contains('사랑해요'));
    });

    test('should remove phrase when toggled again', () async {
      container.listen(favoritePhrasesNotifierProvider, (_, __) {});
      await container.read(favoritePhrasesNotifierProvider.future);

      final notifier = container.read(favoritePhrasesNotifierProvider.notifier);
      await notifier.toggle('사랑해요');
      await notifier.toggle('사랑해요');

      final favorites =
          container.read(favoritePhrasesNotifierProvider).valueOrNull;
      expect(favorites, isEmpty);
    });

    test('should report isFavorite correctly', () async {
      container.listen(favoritePhrasesNotifierProvider, (_, __) {});
      await container.read(favoritePhrasesNotifierProvider.future);

      final notifier = container.read(favoritePhrasesNotifierProvider.notifier);
      await notifier.toggle('사랑해요');

      expect(notifier.isFavorite('사랑해요'), isTrue);
      expect(notifier.isFavorite('화이팅'), isFalse);
    });

    test('should manage multiple favorites', () async {
      container.listen(favoritePhrasesNotifierProvider, (_, __) {});
      await container.read(favoritePhrasesNotifierProvider.future);

      final notifier = container.read(favoritePhrasesNotifierProvider.notifier);
      await notifier.toggle('사랑해요');
      await notifier.toggle('화이팅');
      await notifier.toggle('보고싶어');

      final favorites =
          container.read(favoritePhrasesNotifierProvider).valueOrNull;
      expect(favorites, hasLength(3));
      expect(favorites, containsAll(['사랑해요', '화이팅', '보고싶어']));
    });

    group('persistence', () {
      test('should load saved favorites on build', () async {
        SharedPreferences.setMockInitialValues({
          'favorite_phrases': jsonEncode(['사랑해요', '화이팅']),
        });
        final c = ProviderContainer();
        addTearDown(c.dispose);

        c.listen(favoritePhrasesNotifierProvider, (_, __) {});
        final favorites = await c.read(favoritePhrasesNotifierProvider.future);
        expect(favorites, containsAll(['사랑해요', '화이팅']));
        expect(favorites, hasLength(2));
      });

      test('should preserve in-flight toggles after load', () async {
        SharedPreferences.setMockInitialValues({
          'favorite_phrases': jsonEncode(['사랑해요']),
        });
        final c = ProviderContainer();
        addTearDown(c.dispose);

        c.listen(favoritePhrasesNotifierProvider, (_, __) {});
        await c.read(favoritePhrasesNotifierProvider.future);

        // 로드 후 toggle — await로 build() 완료 후 반영 보장
        final notifier = c.read(favoritePhrasesNotifierProvider.notifier);
        await notifier.toggle('화이팅');

        final favorites = c.read(favoritePhrasesNotifierProvider).valueOrNull;
        // 저장된 '사랑해요' + 새로 추가된 '화이팅' 모두 존재해야 함
        expect(favorites, containsAll(['사랑해요', '화이팅']));
      });
    });
  });
}
