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
      const Phrase(
        ko: '{{member_name}} 생일 축하해요',
        roman: '{{member_name}} saengil chukahaeyo',
        context: 'Member template',
        isTemplate: true,
      ),
      const Phrase(
        ko: '{{group_name}} {{member_name}} 최고!',
        roman: '{{group_name}} {{member_name}} choego!',
        context: 'Group+Member template',
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
    test('should default to first pack when no saved data and no idol',
        () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      final filter =
          await container.read(compactPhraseFilterNotifierProvider.future);
      // 스마트 기본값: 즐찾(없음) → 아이돌(없음) → 첫 팩
      expect(filter, const CompactPhraseFilter.pack('basic_love'));
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
      // 잘못된 데이터 → 스마트 기본값: 첫 팩
      expect(filter, const CompactPhraseFilter.pack('basic_love'));
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
    test('should return empty list when favorites selected but none saved',
        () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // 스마트 기본값은 첫 팩이므로, 명시적으로 즐겨찾기 선택
      container.listen(compactPhraseFilterNotifierProvider, (_, __) {});
      await container.read(compactPhraseFilterNotifierProvider.future);
      await container
          .read(compactPhraseFilterNotifierProvider.notifier)
          .selectFavorites();

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

    test('should include member templates when memberName is set', () async {
      final container = ProviderContainer(
        overrides: [
          allPhrasesProvider.overrideWith((ref) async => _testPacks),
          myIdolDisplayNameProvider.overrideWith((ref) async => 'BTS'),
          myIdolMemberNameProvider.overrideWith((ref) async => '정국'),
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
      // 4 templates: member-first (2) + group-only (2)
      expect(phrases, hasLength(4));
      // 멤버 전용 문구가 앞에 배치 (member-first sorting)
      expect(phrases[0].ko, '정국 생일 축하해요');
      expect(phrases[1].ko, 'BTS 정국 최고!');
      // 그룹 전용 문구가 뒤에 배치
      expect(phrases[2].ko, 'BTS 사랑해요');
      expect(phrases[3].ko, 'BTS 화이팅!');
    });

    test('should exclude member templates when memberName is null', () async {
      final container = ProviderContainer(
        overrides: [
          allPhrasesProvider.overrideWith((ref) async => _testPacks),
          myIdolDisplayNameProvider.overrideWith((ref) async => 'BTS'),
          myIdolMemberNameProvider.overrideWith((ref) async => null),
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
      // Only 2 group-only templates, member templates excluded
      expect(phrases, hasLength(2));
      expect(phrases[0].ko, 'BTS 사랑해요');
      expect(phrases[1].ko, 'BTS 화이팅!');
      // No phrase should contain unreplaced {{member_name}}
      for (final p in phrases) {
        expect(p.ko, isNot(contains('{{member_name}}')));
      }
    });
  });

  group('filteredCompactPhrases — favorites template roman', () {
    test('should restore roman for favorited template phrase', () async {
      final container = ProviderContainer(
        overrides: [
          allPhrasesProvider.overrideWith((ref) async => _testPacks),
          myIdolDisplayNameProvider.overrideWith((ref) async => 'BTS'),
          myIdolMemberNameProvider.overrideWith((ref) async => null),
        ],
      );
      addTearDown(container.dispose);

      // 즐겨찾기에 치환된 ko 추가 (실제 앱에서 저장하는 형태)
      container.listen(favoritePhrasesNotifierProvider, (_, __) {});
      await container.read(favoritePhrasesNotifierProvider.future);
      await container
          .read(favoritePhrasesNotifierProvider.notifier)
          .toggle('BTS 사랑해요');

      final phrases =
          await container.read(filteredCompactPhrasesProvider.future);
      expect(phrases, hasLength(1));
      expect(phrases.first.ko, 'BTS 사랑해요');
      expect(phrases.first.roman, 'BTS saranghaeyo');
    });

    test('should restore roman for member template favorite', () async {
      final container = ProviderContainer(
        overrides: [
          allPhrasesProvider.overrideWith((ref) async => _testPacks),
          myIdolDisplayNameProvider.overrideWith((ref) async => 'BTS'),
          myIdolMemberNameProvider.overrideWith((ref) async => '정국'),
        ],
      );
      addTearDown(container.dispose);

      container.listen(favoritePhrasesNotifierProvider, (_, __) {});
      await container.read(favoritePhrasesNotifierProvider.future);
      await container
          .read(favoritePhrasesNotifierProvider.notifier)
          .toggle('정국 생일 축하해요');

      final phrases =
          await container.read(filteredCompactPhrasesProvider.future);
      expect(phrases, hasLength(1));
      expect(phrases.first.ko, '정국 생일 축하해요');
      expect(phrases.first.roman, '정국 saengil chukahaeyo');
    });

    test('should fallback to empty roman when idol not set', () async {
      final container = ProviderContainer(
        overrides: [
          allPhrasesProvider.overrideWith((ref) async => _testPacks),
          myIdolDisplayNameProvider.overrideWith((ref) async => null),
          myIdolMemberNameProvider.overrideWith((ref) async => null),
        ],
      );
      addTearDown(container.dispose);

      container.listen(favoritePhrasesNotifierProvider, (_, __) {});
      await container.read(favoritePhrasesNotifierProvider.future);
      // 치환된 ko로 저장됐지만 아이돌 미설정 → lookup 실패 → 폴백
      await container
          .read(favoritePhrasesNotifierProvider.notifier)
          .toggle('BTS 사랑해요');

      final phrases =
          await container.read(filteredCompactPhrasesProvider.future);
      expect(phrases, hasLength(1));
      expect(phrases.first.ko, 'BTS 사랑해요');
      expect(phrases.first.roman, '');
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
