import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/core/entities/remote_config_values.dart';
import 'package:fangeul/data/datasources/monetization_local_datasource.dart';
import 'package:fangeul/presentation/models/theme_slot.dart';
import 'package:fangeul/presentation/providers/choeae_color_provider.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/remote_config_providers.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart'
    show sharedPreferencesProvider;
import 'package:fangeul/presentation/providers/theme_slot_provider.dart';
import 'package:fangeul/presentation/theme/choeae_color_config.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late ProviderContainer container;
  late MockFlutterSecureStorage mockStorage;

  /// 특정 MonetizationState로 컨테이너를 초기화한다.
  Future<void> setUpWithMonetization(MonetizationState monState) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    mockStorage = MockFlutterSecureStorage();
    final dataSource = MonetizationLocalDataSource(mockStorage);
    final dataStr = jsonEncode(monState.toJson());
    final sig = dataSource.computeHmac(dataStr);

    when(() => mockStorage.read(key: MonetizationLocalDataSource.dataKey))
        .thenAnswer((_) async => dataStr);
    when(() => mockStorage.read(key: MonetizationLocalDataSource.sigKey))
        .thenAnswer((_) async => sig);
    when(() => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});

    container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      monetizationStorageProvider.overrideWithValue(mockStorage),
      remoteConfigValuesProvider
          .overrideWithValue(const RemoteConfigValues()),
    ]);

    // 모든 provider를 활성화한다.
    container.listen(themeSlotNotifierProvider, (_, __) {});
    container.listen(choeaeColorNotifierProvider, (_, __) {});
    await container.read(monetizationNotifierProvider.future);
  }

  tearDown(() => container.dispose());

  group('P0-2: saveToSlot IAP 검증', () {
    test('should reject custom slot save when hasThemePicker is false',
        () async {
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-03-01',
        hasThemePicker: false,
        hasThemeSlots: true,
      ));

      final notifier = container.read(themeSlotNotifierProvider.notifier);
      const customSlot = ThemeSlot(
        name: 'My Custom',
        type: 'custom',
        value: 'ff00bcd4',
      );

      final result = await notifier.saveToSlot(0, customSlot);

      expect(result, false);
      // 슬롯 내용이 변경되지 않았는지 확인
      final slots = container.read(themeSlotNotifierProvider);
      expect(slots[0].type, isNot('custom'));
    });

    test('should allow custom slot save when hasThemePicker is true',
        () async {
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-03-01',
        hasThemePicker: true,
      ));

      final notifier = container.read(themeSlotNotifierProvider.notifier);
      const customSlot = ThemeSlot(
        name: 'My Custom',
        type: 'custom',
        value: 'ff00bcd4',
      );

      final result = await notifier.saveToSlot(0, customSlot);

      expect(result, true);
      final slots = container.read(themeSlotNotifierProvider);
      expect(slots[0].type, 'custom');
      expect(slots[0].value, 'ff00bcd4');
    });

    test('should allow palette slot save regardless of IAP', () async {
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-03-01',
        hasThemePicker: false,
      ));

      final notifier = container.read(themeSlotNotifierProvider.notifier);
      const paletteSlot = ThemeSlot(
        name: 'Palette',
        type: 'palette',
        value: 'purple_dream',
      );

      final result = await notifier.saveToSlot(0, paletteSlot);

      expect(result, true);
      final slots = container.read(themeSlotNotifierProvider);
      expect(slots[0].type, 'palette');
    });
  });

  group('P0-3: applySlot 엔타이틀먼트 교차 검증', () {
    test('should fallback to palette when custom slot + no hasThemePicker',
        () async {
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-03-01',
        hasThemePicker: false,
      ));

      // 기존 저장된 custom 슬롯을 직접 SharedPrefs에 주입
      final prefs = container.read(sharedPreferencesProvider);
      final slotJson = jsonEncode([
        {
          'name': 'Custom Slot',
          'type': 'custom',
          'value': 'ff00bcd4',
          'brightnessOverride': 'dark',
        },
      ]);
      await prefs.setString('theme_slots', slotJson);

      // 슬롯 provider를 재로드
      container.invalidate(themeSlotNotifierProvider);
      container.listen(themeSlotNotifierProvider, (_, __) {});

      final notifier = container.read(themeSlotNotifierProvider.notifier);
      await notifier.applySlot(0);

      // custom이 아닌 기본 palette로 폴백
      final choeae = container.read(choeaeColorNotifierProvider);
      expect(choeae, const ChoeaeColorConfig.palette('midnight'));
    });

    test('should apply custom slot when hasThemePicker is true', () async {
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-03-01',
        hasThemePicker: true,
      ));

      final prefs = container.read(sharedPreferencesProvider);
      final slotJson = jsonEncode([
        {
          'name': 'Custom Slot',
          'type': 'custom',
          'value': 'ff00bcd4',
          'brightnessOverride': 'dark',
        },
      ]);
      await prefs.setString('theme_slots', slotJson);

      container.invalidate(themeSlotNotifierProvider);
      container.listen(themeSlotNotifierProvider, (_, __) {});

      final notifier = container.read(themeSlotNotifierProvider.notifier);
      await notifier.applySlot(0);

      final choeae = container.read(choeaeColorNotifierProvider);
      expect(choeae, isA<ChoeaeColorCustom>());
    });
  });

  group('P0-1: setCustomColor persist 게이트', () {
    test('should not persist when persist: false', () async {
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-03-01',
      ));

      final notifier = container.read(choeaeColorNotifierProvider.notifier);

      // persist: false로 커스텀 색상 설정
      await notifier.setCustomColor(
        const Color(0xFF00BCD4),
        persist: false,
      );

      // in-memory 상태는 변경됨
      final current = container.read(choeaeColorNotifierProvider);
      expect(current, isA<ChoeaeColorCustom>());

      // SharedPreferences에는 저장되지 않음 (기존 palette 유지)
      final prefs = container.read(sharedPreferencesProvider);
      final storedType = prefs.getString('choeae_type');
      // type이 null이거나 'palette'여야 함 (custom이 아님)
      expect(storedType, isNot('custom'));
    });

    test('should persist when persist: true (default)', () async {
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-03-01',
      ));

      final notifier = container.read(choeaeColorNotifierProvider.notifier);

      await notifier.setCustomColor(const Color(0xFF00BCD4));

      final prefs = container.read(sharedPreferencesProvider);
      final storedType = prefs.getString('choeae_type');
      expect(storedType, 'custom');
    });

    test('should not persist text color when persist: false', () async {
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-03-01',
      ));

      final notifier = container.read(choeaeColorNotifierProvider.notifier);

      // 먼저 커스텀 상태 진입 (persist: true로 기반 설정)
      await notifier.setCustomColor(const Color(0xFF00BCD4));

      // 그 다음 글자색만 persist: false로 변경
      await notifier.setTextColorOverride(
        const Color(0xFFFFFFFF),
        persist: false,
      );

      // in-memory에는 글자색 설정됨
      final current = container.read(choeaeColorNotifierProvider);
      expect(current, isA<ChoeaeColorCustom>());
      expect((current as ChoeaeColorCustom).textColorOverride,
          const Color(0xFFFFFFFF));

      // SharedPreferences에 글자색은 저장되지 않음
      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('choeae_text_override'), isNull);
    });
  });

  group('P0-4: 구매→저장→환불(mock)→applySlot→팔레트 폴백', () {
    test(
        'should fallback to palette after refund (purchase→save→revoke→apply)',
        () async {
      // 1. 구매 상태로 시작
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-03-01',
        hasThemePicker: true,
        hasThemeSlots: true,
        honeymoonActive: false,
        favoriteSlotLimit: 5,
      ));

      final slotNotifier =
          container.read(themeSlotNotifierProvider.notifier);
      final monNotifier =
          container.read(monetizationNotifierProvider.notifier);

      // 2. 커스텀 슬롯에 저장 (구매 상태이므로 성공)
      const customSlot = ThemeSlot(
        name: 'My Concert Theme',
        type: 'custom',
        value: 'ff00bcd4',
        brightnessOverride: 'dark',
      );
      final saveResult = await slotNotifier.saveToSlot(0, customSlot);
      expect(saveResult, true);

      // 저장 확인
      final savedSlots = container.read(themeSlotNotifierProvider);
      expect(savedSlots[0].type, 'custom');

      // 3. 환불 (mock) — 두 IAP 모두 취소
      await monNotifier.revokeThemePicker();
      await monNotifier.revokeThemeSlots();

      // 환불 후 상태 확인
      final monState =
          container.read(monetizationNotifierProvider).valueOrNull!;
      expect(monState.hasThemePicker, false);
      expect(monState.hasThemeSlots, false);

      // 4. applySlot → 기본 팔레트 폴백
      await slotNotifier.applySlot(0);

      final choeae = container.read(choeaeColorNotifierProvider);
      expect(choeae, const ChoeaeColorConfig.palette('midnight'));
    });

    test('should preserve slot data after refund (soft lock)', () async {
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-03-01',
        hasThemePicker: true,
        hasThemeSlots: true,
      ));

      final slotNotifier =
          container.read(themeSlotNotifierProvider.notifier);
      final monNotifier =
          container.read(monetizationNotifierProvider.notifier);

      // 저장
      const customSlot = ThemeSlot(
        name: 'My Theme',
        type: 'custom',
        value: 'ff00bcd4',
        brightnessOverride: 'dark',
      );
      await slotNotifier.saveToSlot(0, customSlot);

      // 환불
      await monNotifier.revokeThemePicker();
      await monNotifier.revokeThemeSlots();

      // 슬롯 데이터는 유지됨 (소프트 락)
      final slots = container.read(themeSlotNotifierProvider);
      expect(slots[0].type, 'custom');
      expect(slots[0].value, 'ff00bcd4');
      expect(slots[0].name, 'My Theme');
    });

    test('should restore custom slot after re-purchase', () async {
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-03-01',
        hasThemePicker: true,
        hasThemeSlots: true,
      ));

      final slotNotifier =
          container.read(themeSlotNotifierProvider.notifier);
      final monNotifier =
          container.read(monetizationNotifierProvider.notifier);

      // 저장 → 환불 → 재구매
      const customSlot = ThemeSlot(
        name: 'Concert',
        type: 'custom',
        value: 'ff00bcd4',
        brightnessOverride: 'dark',
      );
      await slotNotifier.saveToSlot(0, customSlot);
      await monNotifier.revokeThemePicker();

      // 환불 후 apply → 팔레트 폴백
      await slotNotifier.applySlot(0);
      expect(container.read(choeaeColorNotifierProvider),
          const ChoeaeColorConfig.palette('midnight'));

      // 재구매
      await monNotifier.unlockThemePicker();

      // 재구매 후 apply → 커스텀 복원
      await slotNotifier.applySlot(0);
      final restored = container.read(choeaeColorNotifierProvider);
      expect(restored, isA<ChoeaeColorCustom>());
    });
  });

  group('환불 후 즐겨찾기 무제한 해제', () {
    test('should re-enforce favorites limit after all IAPs revoked',
        () async {
      // Day 14+ 상태에서 IAP 구매 상태로 시작
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-02-01',
        honeymoonActive: false,
        favoriteSlotLimit: 5,
        hasThemePicker: true,
        hasThemeSlots: true,
      ));

      // hasAnyIap = true 확인
      expect(container.read(hasAnyIapProvider), true);

      // 환불 — 두 IAP 모두 취소
      final monNotifier =
          container.read(monetizationNotifierProvider.notifier);
      await monNotifier.revokeThemePicker();
      await monNotifier.revokeThemeSlots();

      // hasAnyIap = false → 즐겨찾기 제한 재적용
      expect(container.read(hasAnyIapProvider), false);

      // favoriteSlotLimit은 여전히 5 (허니문 종료 후 기본값)
      expect(container.read(favoriteSlotLimitProvider), 5);
    });

    test('should still enforce limit if only one IAP revoked', () async {
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-02-01',
        honeymoonActive: false,
        favoriteSlotLimit: 5,
        hasThemePicker: true,
        hasThemeSlots: true,
      ));

      final monNotifier =
          container.read(monetizationNotifierProvider.notifier);

      // 피커만 환불, 슬롯은 유지
      await monNotifier.revokeThemePicker();

      // 슬롯 IAP가 남아있으므로 hasAnyIap = true → 즐겨찾기 무제한 유지
      expect(container.read(hasAnyIapProvider), true);
    });
  });

  group('P0-5: undo() 프리뷰 persist 우회 방지', () {
    test('should not persist undo result when persist: false', () async {
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-03-01',
        hasThemePicker: false,
      ));

      final notifier = container.read(choeaeColorNotifierProvider.notifier);
      final prefs = container.read(sharedPreferencesProvider);

      // 기본: midnight palette
      expect(prefs.getString('choeae_type'), isNull);

      // 색상 A 설정 (persist: false — 프리뷰)
      await notifier.setCustomColor(
        const Color(0xFFFF0000),
        persist: false,
      );
      // 색상 B 설정 (persist: false — 프리뷰)
      await notifier.setCustomColor(
        const Color(0xFF00FF00),
        persist: false,
      );

      // undo → _previousConfig = custom(A), persist: false
      await notifier.undo(persist: false);

      // in-memory는 custom(A)
      final current = container.read(choeaeColorNotifierProvider);
      expect(current, isA<ChoeaeColorCustom>());

      // SharedPrefs에는 custom이 저장되지 않아야 함
      expect(prefs.getString('choeae_type'), isNot('custom'));
    });

    test('should persist undo result when persist: true (purchased)', () async {
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-03-01',
        hasThemePicker: true,
      ));

      final notifier = container.read(choeaeColorNotifierProvider.notifier);
      final prefs = container.read(sharedPreferencesProvider);

      // 구매자: persist: true로 색상 설정
      await notifier.setCustomColor(const Color(0xFFFF0000));
      await notifier.setCustomColor(const Color(0xFF00FF00));

      // undo (기본 persist: true)
      await notifier.undo();

      // SharedPrefs에 custom(A)가 저장됨
      expect(prefs.getString('choeae_type'), 'custom');
    });
  });

  group('revoke 메서드', () {
    test('revokeThemePicker should set hasThemePicker to false', () async {
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-03-01',
        hasThemePicker: true,
      ));

      final notifier =
          container.read(monetizationNotifierProvider.notifier);
      await notifier.revokeThemePicker();

      final state =
          container.read(monetizationNotifierProvider).valueOrNull!;
      expect(state.hasThemePicker, false);
    });

    test('revokeThemeSlots should set hasThemeSlots to false', () async {
      await setUpWithMonetization(const MonetizationState(
        installDate: '2026-03-01',
        hasThemeSlots: true,
      ));

      final notifier =
          container.read(monetizationNotifierProvider.notifier);
      await notifier.revokeThemeSlots();

      final state =
          container.read(monetizationNotifierProvider).valueOrNull!;
      expect(state.hasThemeSlots, false);
    });
  });
}
