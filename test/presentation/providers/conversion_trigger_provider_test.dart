import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/data/datasources/monetization_local_datasource.dart';
import 'package:fangeul/presentation/providers/conversion_trigger_provider.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late ProviderContainer container;
  late MockFlutterSecureStorage mockStorage;

  /// Day 14+ 지난 설치일 (30일 전).
  String oldInstallDate() {
    final date = DateTime.now().subtract(const Duration(days: 30));
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 트리거 조건 충족 상태: Day14+, 광고 3회, 슬롯 5/5, 미구매.
  MonetizationState triggerReadyState({int favSlotLimit = 5}) =>
      MonetizationState(
        installDate: oldInstallDate(),
        honeymoonActive: false,
        adWatchCount: 3,
        favoriteSlotLimit: favSlotLimit,
        purchasedPackIds: const [],
      );

  /// 즐겨찾기를 JSON 문자열로 초기화.
  void setupFavorites(int count) {
    final favList = List.generate(count, (i) => 'fav_$i');
    SharedPreferences.setMockInitialValues({
      'favorite_phrases': jsonEncode(favList),
    });
  }

  void setUpWithState(MonetizationState initialState, {int favCount = 3}) {
    mockStorage = MockFlutterSecureStorage();
    final dataSource = MonetizationLocalDataSource(mockStorage);
    final dataStr = jsonEncode(initialState.toJson());
    final sig = dataSource.computeHmac(dataStr);

    when(() => mockStorage.read(key: MonetizationLocalDataSource.dataKey))
        .thenAnswer((_) async => dataStr);
    when(() => mockStorage.read(key: MonetizationLocalDataSource.sigKey))
        .thenAnswer((_) async => sig);
    when(() => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});

    setupFavorites(favCount);

    container = ProviderContainer(
      overrides: [
        monetizationStorageProvider.overrideWithValue(mockStorage),
      ],
    );
  }

  tearDown(() => container.dispose());

  group('shouldShowConversionTriggerProvider', () {
    test('should return true when all conditions met', () async {
      setUpWithState(triggerReadyState(), favCount: 5);

      await container.read(monetizationNotifierProvider.future);
      await container.read(favoritePhrasesNotifierProvider.future);

      final sub = container
          .listen(shouldShowConversionTriggerProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(shouldShowConversionTriggerProvider), true);
    });

    test('should return false when Day < 14', () async {
      final now = DateTime.now();
      final recent =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      setUpWithState(
        triggerReadyState().copyWith(installDate: recent),
        favCount: 5,
      );

      await container.read(monetizationNotifierProvider.future);
      await container.read(favoritePhrasesNotifierProvider.future);

      final sub = container
          .listen(shouldShowConversionTriggerProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(shouldShowConversionTriggerProvider), false);
    });

    test('should return false when ad count < 3', () async {
      setUpWithState(
        triggerReadyState().copyWith(adWatchCount: 2),
        favCount: 5,
      );

      await container.read(monetizationNotifierProvider.future);
      await container.read(favoritePhrasesNotifierProvider.future);

      final sub = container
          .listen(shouldShowConversionTriggerProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(shouldShowConversionTriggerProvider), false);
    });

    test('should return false when favorite slots not full', () async {
      setUpWithState(triggerReadyState(), favCount: 1);

      await container.read(monetizationNotifierProvider.future);
      await container.read(favoritePhrasesNotifierProvider.future);

      final sub = container
          .listen(shouldShowConversionTriggerProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(shouldShowConversionTriggerProvider), false);
    });

    test('should return false when user already purchased', () async {
      setUpWithState(
        triggerReadyState()
            .copyWith(purchasedPackIds: ['fangeul_color_starter']),
        favCount: 3,
      );

      await container.read(monetizationNotifierProvider.future);
      await container.read(favoritePhrasesNotifierProvider.future);

      final sub = container
          .listen(shouldShowConversionTriggerProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(shouldShowConversionTriggerProvider), false);
    });

    test('should return false when honeymoon still active (slotLimit=0)',
        () async {
      // 설치 2일 전 — 허니문이 아직 활성이라 slotLimit=0 유지
      final recentDate = DateTime.now().subtract(const Duration(days: 2));
      final dateStr =
          '${recentDate.year.toString().padLeft(4, '0')}-${recentDate.month.toString().padLeft(2, '0')}-${recentDate.day.toString().padLeft(2, '0')}';
      setUpWithState(
        MonetizationState(
          installDate: dateStr,
          honeymoonActive: true,
          adWatchCount: 3,
          favoriteSlotLimit: 0,
          purchasedPackIds: const [],
        ),
        favCount: 5,
      );

      await container.read(monetizationNotifierProvider.future);
      await container.read(favoritePhrasesNotifierProvider.future);

      final sub = container
          .listen(shouldShowConversionTriggerProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(shouldShowConversionTriggerProvider), false);
    });
  });
}
