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

    test('should start with empty set', () {
      final favorites = container.read(favoritePhrasesNotifierProvider);
      expect(favorites, isEmpty);
    });

    test('should add phrase to favorites', () {
      final notifier = container.read(favoritePhrasesNotifierProvider.notifier);
      notifier.toggle('사랑해요');

      final favorites = container.read(favoritePhrasesNotifierProvider);
      expect(favorites, contains('사랑해요'));
    });

    test('should remove phrase when toggled again', () {
      final notifier = container.read(favoritePhrasesNotifierProvider.notifier);
      notifier.toggle('사랑해요');
      notifier.toggle('사랑해요');

      final favorites = container.read(favoritePhrasesNotifierProvider);
      expect(favorites, isEmpty);
    });

    test('should report isFavorite correctly', () {
      final notifier = container.read(favoritePhrasesNotifierProvider.notifier);
      notifier.toggle('사랑해요');

      expect(notifier.isFavorite('사랑해요'), isTrue);
      expect(notifier.isFavorite('화이팅'), isFalse);
    });

    test('should manage multiple favorites', () {
      final notifier = container.read(favoritePhrasesNotifierProvider.notifier);
      notifier.toggle('사랑해요');
      notifier.toggle('화이팅');
      notifier.toggle('보고싶어');

      final favorites = container.read(favoritePhrasesNotifierProvider);
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

        // listen()으로 auto-dispose 방지
        c.listen(favoritePhrasesNotifierProvider, (_, __) {});
        // microtask 대기 — async _loadFromPrefs 완료
        await Future<void>.delayed(Duration.zero);

        final favorites = c.read(favoritePhrasesNotifierProvider);
        expect(favorites, containsAll(['사랑해요', '화이팅']));
        expect(favorites, hasLength(2));
      });

      test('should merge loaded data with in-flight toggles', () async {
        SharedPreferences.setMockInitialValues({
          'favorite_phrases': jsonEncode(['사랑해요']),
        });
        final c = ProviderContainer();
        addTearDown(c.dispose);

        c.listen(favoritePhrasesNotifierProvider, (_, __) {});

        // 로드 완료 전에 toggle 호출
        final notifier = c.read(favoritePhrasesNotifierProvider.notifier);
        notifier.toggle('화이팅');

        // 로드 완료 대기
        await Future<void>.delayed(Duration.zero);

        final favorites = c.read(favoritePhrasesNotifierProvider);
        // 저장된 '사랑해요' + 새로 추가된 '화이팅' 모두 존재해야 함
        expect(favorites, containsAll(['사랑해요', '화이팅']));
      });
    });
  });
}
