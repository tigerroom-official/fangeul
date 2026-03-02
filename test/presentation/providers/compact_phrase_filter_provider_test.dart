import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/entities/phrase_pack.dart';
import 'package:fangeul/presentation/providers/calendar_providers.dart';
import 'package:fangeul/presentation/providers/compact_phrase_filter_provider.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/providers/phrase_providers.dart';

/// 테스트용 PhrasePack 목록.
final _testPacks = [
  PhrasePack(
    id: 'basic_love',
    name: 'Love & Support',
    nameKo: '사랑 & 응원',
    phrases: [
      const Phrase(ko: '사랑해요', roman: 'saranghaeyo', context: 'Love'),
      const Phrase(ko: '화이팅', roman: 'hwaiting', context: 'Cheer'),
    ],
  ),
  PhrasePack(
    id: 'daily',
    name: 'Daily',
    nameKo: '일상',
    phrases: [
      const Phrase(ko: '안녕하세요', roman: 'annyeonghaseyo', context: 'Greeting'),
    ],
  ),
  PhrasePack(
    id: 'birthday',
    name: 'Birthday',
    nameKo: '생일',
    isFree: false,
    unlockType: 'rewarded_ad',
    phrases: [
      const Phrase(
        ko: '생일 축하해요',
        roman: 'saengil chukahaeyo',
        context: 'Birthday',
      ),
    ],
  ),
  PhrasePack(
    id: 'my_idol',
    name: 'My Idol',
    nameKo: '마이 아이돌',
    phrases: [
      const Phrase(
        ko: '{{group_name}} 사랑해요',
        roman: '{{group_name}} saranghaeyo',
        context: 'Template',
        isTemplate: true,
      ),
      const Phrase(
        ko: '{{group_name}} 화이팅!',
        roman: '{{group_name}} hwaiting!',
        context: 'Template',
        isTemplate: true,
      ),
    ],
  ),
];

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer createContainer({
    Map<String, Object>? prefsValues,
  }) {
    if (prefsValues != null) {
      SharedPreferences.setMockInitialValues(prefsValues);
    }
    return ProviderContainer(
      overrides: [
        allPhrasesProvider.overrideWith((ref) async => _testPacks),
      ],
    );
  }

  group('CompactPhraseFilterNotifier', () {
    test('should default to favorites when no saved data', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      final filter =
          await container.read(compactPhraseFilterNotifierProvider.future);
      expect(filter, const CompactPhraseFilter.favorites());
    });

    test('should load saved pack filter on build', () async {
      final container = createContainer(
        prefsValues: {'compact_phrase_filter': 'pack:basic_love'},
      );
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      final filter =
          await container.read(compactPhraseFilterNotifierProvider.future);
      expect(filter, const CompactPhraseFilter.pack('basic_love'));
    });

    test('should load saved favorites filter on build', () async {
      final container = createContainer(
        prefsValues: {'compact_phrase_filter': 'favorites'},
      );
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      final filter =
          await container.read(compactPhraseFilterNotifierProvider.future);
      expect(filter, const CompactPhraseFilter.favorites());
    });

    test('should handle invalid saved data gracefully', () async {
      final container = createContainer(
        prefsValues: {'compact_phrase_filter': 'garbage_data'},
      );
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      final filter =
          await container.read(compactPhraseFilterNotifierProvider.future);
      expect(filter, const CompactPhraseFilter.favorites());
    });

    test('should save pack selection to SharedPreferences', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectPack('basic_love');

      final filter =
          await container.read(compactPhraseFilterNotifierProvider.future);
      expect(filter, const CompactPhraseFilter.pack('basic_love'));

      // SharedPreferences에 저장 확인
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('compact_phrase_filter'), 'pack:basic_love');
    });

    test('should save favorites selection to SharedPreferences', () async {
      final container = createContainer(
        prefsValues: {'compact_phrase_filter': 'pack:daily'},
      );
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectFavorites();

      final filter =
          await container.read(compactPhraseFilterNotifierProvider.future);
      expect(filter, const CompactPhraseFilter.favorites());

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('compact_phrase_filter'), 'favorites');
    });

    test('should switch to pack filter', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectPack('basic_love');

      final filter =
          await container.read(compactPhraseFilterNotifierProvider.future);
      expect(filter, const CompactPhraseFilter.pack('basic_love'));
    });

    test('should switch back to favorites', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      final notifier =
          container.read(compactPhraseFilterNotifierProvider.notifier);
      await notifier.selectPack('daily');
      await notifier.selectFavorites();

      final filter =
          await container.read(compactPhraseFilterNotifierProvider.future);
      expect(filter, const CompactPhraseFilter.favorites());
    });
  });

  group('filteredCompactPhrasesProvider', () {
    test('should return empty list when no favorites', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final phrases =
          await container.read(filteredCompactPhrasesProvider.future);
      expect(phrases, isEmpty);
    });

    test('should return favorite phrases with Phrase data', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // auto-dispose 방지 + 초기 로드 대기
      container.listen(favoritePhrasesNotifierProvider, (_, __) {});
      await container.read(favoritePhrasesNotifierProvider.future);

      // 즐겨찾기 추가
      await container
          .read(favoritePhrasesNotifierProvider.notifier)
          .toggle('사랑해요');

      final phrases =
          await container.read(filteredCompactPhrasesProvider.future);
      expect(phrases, hasLength(1));
      expect(phrases.first.ko, '사랑해요');
      expect(phrases.first.roman, 'saranghaeyo');
    });

    test('should return fallback Phrase for unknown favorite ko', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // auto-dispose 방지 + 초기 로드 대기
      container.listen(favoritePhrasesNotifierProvider, (_, __) {});
      await container.read(favoritePhrasesNotifierProvider.future);

      await container
          .read(favoritePhrasesNotifierProvider.notifier)
          .toggle('없는문구');

      final phrases =
          await container.read(filteredCompactPhrasesProvider.future);
      expect(phrases, hasLength(1));
      expect(phrases.first.ko, '없는문구');
      expect(phrases.first.roman, '');
    });

    test('should return pack phrases when pack selected', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectPack('basic_love');

      final phrases =
          await container.read(filteredCompactPhrasesProvider.future);
      expect(phrases, hasLength(2));
      expect(phrases.first.ko, '사랑해요');
    });

    test('should return empty list for locked pack', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectPack('birthday');

      final phrases =
          await container.read(filteredCompactPhrasesProvider.future);
      expect(phrases, isEmpty);
    });

    test('should return empty list for nonexistent pack', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectPack('nonexistent');

      final phrases =
          await container.read(filteredCompactPhrasesProvider.future);
      expect(phrases, isEmpty);
    });
  });

  group('isSelectedPackLockedProvider', () {
    test('should return false for favorites filter', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final locked = await container.read(isSelectedPackLockedProvider.future);
      expect(locked, isFalse);
    });

    test('should return false for free pack', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectPack('basic_love');

      final locked = await container.read(isSelectedPackLockedProvider.future);
      expect(locked, isFalse);
    });

    test('should return true for locked pack', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectPack('birthday');

      final locked = await container.read(isSelectedPackLockedProvider.future);
      expect(locked, isTrue);
    });

    test('should return false for myIdol filter', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectMyIdol();

      final locked = await container.read(isSelectedPackLockedProvider.future);
      expect(locked, isFalse);
    });

    test('should return false for today filter', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectToday();

      final locked = await container.read(isSelectedPackLockedProvider.future);
      expect(locked, isFalse);
    });
  });

  group('CompactPhraseFilterNotifier — myIdol/today', () {
    test('should save myIdol selection to SharedPreferences', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectMyIdol();

      final filter =
          await container.read(compactPhraseFilterNotifierProvider.future);
      expect(filter, const CompactPhraseFilter.myIdol());

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('compact_phrase_filter'), 'my_idol');
    });

    test('should save today selection to SharedPreferences', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectToday();

      final filter =
          await container.read(compactPhraseFilterNotifierProvider.future);
      expect(filter, const CompactPhraseFilter.today());

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('compact_phrase_filter'), 'today');
    });

    test('should restore myIdol filter from SharedPreferences', () async {
      final container = createContainer(
        prefsValues: {'compact_phrase_filter': 'my_idol'},
      );
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      final filter =
          await container.read(compactPhraseFilterNotifierProvider.future);
      expect(filter, const CompactPhraseFilter.myIdol());
    });

    test('should restore today filter from SharedPreferences', () async {
      final container = createContainer(
        prefsValues: {'compact_phrase_filter': 'today'},
      );
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      final filter =
          await container.read(compactPhraseFilterNotifierProvider.future);
      expect(filter, const CompactPhraseFilter.today());
    });

    test('should switch from myIdol to favorites', () async {
      final container = createContainer(
        prefsValues: {'compact_phrase_filter': 'my_idol'},
      );
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectFavorites();

      final filter =
          await container.read(compactPhraseFilterNotifierProvider.future);
      expect(filter, const CompactPhraseFilter.favorites());
    });
  });

  group('filteredCompactPhrases — myIdol', () {
    test('should return template phrases resolved with idol name', () async {
      final container = ProviderContainer(
        overrides: [
          allPhrasesProvider.overrideWith((ref) async => _testPacks),
          myIdolDisplayNameProvider.overrideWith((ref) async => 'BTS'),
        ],
      );
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectMyIdol();

      final phrases =
          await container.read(filteredCompactPhrasesProvider.future);
      expect(phrases, hasLength(2));
      expect(phrases.first.ko, 'BTS 사랑해요');
      expect(phrases.first.roman, 'BTS saranghaeyo');
      expect(phrases[1].ko, 'BTS 화이팅!');
    });

    test('should return empty list when no idol selected', () async {
      final container = ProviderContainer(
        overrides: [
          allPhrasesProvider.overrideWith((ref) async => _testPacks),
          myIdolDisplayNameProvider.overrideWith((ref) async => null),
        ],
      );
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectMyIdol();

      final phrases =
          await container.read(filteredCompactPhrasesProvider.future);
      expect(phrases, isEmpty);
    });
  });

  group('filteredCompactPhrases — today', () {
    test('should return today suggested phrases', () async {
      final todayPhrases = [
        const Phrase(
            ko: '생일 축하해요', roman: 'saengil chukahaeyo', context: 'Bday'),
      ];

      final container = ProviderContainer(
        overrides: [
          allPhrasesProvider.overrideWith((ref) async => _testPacks),
          todaySuggestedPhrasesProvider
              .overrideWith((ref) async => todayPhrases),
        ],
      );
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectToday();

      final phrases =
          await container.read(filteredCompactPhrasesProvider.future);
      expect(phrases, hasLength(1));
      expect(phrases.first.ko, '생일 축하해요');
    });

    test('should return empty list when no today events', () async {
      final container = ProviderContainer(
        overrides: [
          allPhrasesProvider.overrideWith((ref) async => _testPacks),
          todaySuggestedPhrasesProvider.overrideWith((ref) async => <Phrase>[]),
        ],
      );
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);

      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectToday();

      final phrases =
          await container.read(filteredCompactPhrasesProvider.future);
      expect(phrases, isEmpty);
    });
  });
}
