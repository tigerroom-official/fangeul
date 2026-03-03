import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/data/datasources/monetization_local_datasource.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

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

    group('slot limit', () {
      /// 지정된 [MonetizationState]를 저장소에 미리 세팅한 [MockFlutterSecureStorage]를 반환한다.
      MockFlutterSecureStorage mockStorageWithState(
          MonetizationState monetizationState) {
        final mockStorage = MockFlutterSecureStorage();
        final dataSource = MonetizationLocalDataSource(mockStorage);
        final dataStr = jsonEncode(monetizationState.toJson());
        final sig = dataSource.computeHmac(dataStr);

        when(() => mockStorage.read(
                key: MonetizationLocalDataSource.dataKey))
            .thenAnswer((_) async => dataStr);
        when(() =>
                mockStorage.read(key: MonetizationLocalDataSource.sigKey))
            .thenAnswer((_) async => sig);
        when(() => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'))).thenAnswer((_) async {});
        return mockStorage;
      }

      test('should reject adding when slot limit reached', () async {
        // 허니문 종료, 슬롯 제한 3, 구매 없음
        final mockStorage = mockStorageWithState(const MonetizationState(
          honeymoonActive: false,
          favoriteSlotLimit: 3,
        ));

        SharedPreferences.setMockInitialValues({
          'favorite_phrases': jsonEncode(['사랑해요', '화이팅', '보고싶어']),
        });

        final c = ProviderContainer(
          overrides: [
            monetizationStorageProvider.overrideWithValue(mockStorage),
          ],
        );
        addTearDown(c.dispose);

        c.listen(favoritePhrasesNotifierProvider, (_, __) {});
        // monetizationNotifier build 대기
        await c.read(monetizationNotifierProvider.future);
        await c.read(favoritePhrasesNotifierProvider.future);

        final notifier = c.read(favoritePhrasesNotifierProvider.notifier);
        // 4번째 추가 시도 → 거부
        final result = await notifier.toggle('잘 자요');
        expect(result, isFalse);

        final favorites =
            c.read(favoritePhrasesNotifierProvider).valueOrNull;
        expect(favorites, hasLength(3));
        expect(favorites, isNot(contains('잘 자요')));
      });

      test('should allow removing even at slot limit', () async {
        // 3개 즐겨찾기 + 슬롯 제한 3
        final mockStorage = mockStorageWithState(const MonetizationState(
          honeymoonActive: false,
          favoriteSlotLimit: 3,
        ));

        SharedPreferences.setMockInitialValues({
          'favorite_phrases': jsonEncode(['사랑해요', '화이팅', '보고싶어']),
        });

        final c = ProviderContainer(
          overrides: [
            monetizationStorageProvider.overrideWithValue(mockStorage),
          ],
        );
        addTearDown(c.dispose);

        c.listen(favoritePhrasesNotifierProvider, (_, __) {});
        await c.read(monetizationNotifierProvider.future);
        await c.read(favoritePhrasesNotifierProvider.future);

        final notifier = c.read(favoritePhrasesNotifierProvider.notifier);
        // 제거는 항상 허용
        final result = await notifier.toggle('사랑해요');
        expect(result, isTrue);

        final favorites =
            c.read(favoritePhrasesNotifierProvider).valueOrNull;
        expect(favorites, hasLength(2));
        expect(favorites, isNot(contains('사랑해요')));
      });

      test('should allow unlimited during honeymoon (limit=0)', () async {
        // 허니문 활성 → favoriteSlotLimit = 0 (무제한)
        final mockStorage = mockStorageWithState(const MonetizationState(
          honeymoonActive: true,
          favoriteSlotLimit: 0,
        ));

        SharedPreferences.setMockInitialValues({});

        final c = ProviderContainer(
          overrides: [
            monetizationStorageProvider.overrideWithValue(mockStorage),
          ],
        );
        addTearDown(c.dispose);

        c.listen(favoritePhrasesNotifierProvider, (_, __) {});
        await c.read(monetizationNotifierProvider.future);
        await c.read(favoritePhrasesNotifierProvider.future);

        final notifier = c.read(favoritePhrasesNotifierProvider.notifier);
        // 10개 이상 추가 → 모두 성공
        final phrases = List.generate(
            10, (i) => '문구$i');
        for (final p in phrases) {
          final result = await notifier.toggle(p);
          expect(result, isTrue, reason: '$p 추가가 허용되어야 함');
        }

        final favorites =
            c.read(favoritePhrasesNotifierProvider).valueOrNull;
        expect(favorites, hasLength(10));
      });

      test('should allow unlimited for Pro users', () async {
        // 슬롯 제한 3이지만 구매 기록 있음 → 무제한
        final mockStorage = mockStorageWithState(const MonetizationState(
          honeymoonActive: false,
          favoriteSlotLimit: 3,
          purchasedPackIds: ['color_pack_purple_dream'],
        ));

        SharedPreferences.setMockInitialValues({
          'favorite_phrases': jsonEncode(['사랑해요', '화이팅', '보고싶어']),
        });

        final c = ProviderContainer(
          overrides: [
            monetizationStorageProvider.overrideWithValue(mockStorage),
          ],
        );
        addTearDown(c.dispose);

        c.listen(favoritePhrasesNotifierProvider, (_, __) {});
        await c.read(monetizationNotifierProvider.future);
        await c.read(favoritePhrasesNotifierProvider.future);

        final notifier = c.read(favoritePhrasesNotifierProvider.notifier);
        // 이미 3개 있지만 Pro이므로 4번째 추가 성공
        final result = await notifier.toggle('잘 자요');
        expect(result, isTrue);

        final favorites =
            c.read(favoritePhrasesNotifierProvider).valueOrNull;
        expect(favorites, hasLength(4));
        expect(favorites, contains('잘 자요'));
      });

      test('should return true for toggle result on normal add', () async {
        // 제한 미도달 시 추가 성공 반환값 확인
        final mockStorage = mockStorageWithState(const MonetizationState(
          honeymoonActive: false,
          favoriteSlotLimit: 3,
        ));

        SharedPreferences.setMockInitialValues({});

        final c = ProviderContainer(
          overrides: [
            monetizationStorageProvider.overrideWithValue(mockStorage),
          ],
        );
        addTearDown(c.dispose);

        c.listen(favoritePhrasesNotifierProvider, (_, __) {});
        await c.read(monetizationNotifierProvider.future);
        await c.read(favoritePhrasesNotifierProvider.future);

        final notifier = c.read(favoritePhrasesNotifierProvider.notifier);
        final result = await notifier.toggle('사랑해요');
        expect(result, isTrue);
      });
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
