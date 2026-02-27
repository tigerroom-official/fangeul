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
  });
}
