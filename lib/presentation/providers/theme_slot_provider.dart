import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/presentation/models/theme_slot.dart';
import 'package:fangeul/presentation/providers/choeae_color_provider.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/theme/choeae_color_config.dart';

part 'theme_slot_provider.g.dart';

/// 테마 슬롯 상태 관리.
///
/// 4개 슬롯(1 기본 + 3 구매). SharedPreferences에 JSON 배열로 저장.
@Riverpod(keepAlive: true)
class ThemeSlotNotifier extends _$ThemeSlotNotifier {
  static const _prefsKey = 'theme_slots';
  static const _activeKey = 'theme_slot_active';

  /// 최대 슬롯 수 (1 기본 + 3 IAP).
  static const maxSlots = 4;

  @override
  List<ThemeSlot> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final json = prefs.getString(_prefsKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List<dynamic>;
        return list
            .take(maxSlots)
            .map((e) => ThemeSlot.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // 파싱 실패 → 기본 슬롯
      }
    }

    // 현재 choeaeColor를 슬롯 0으로 설정
    final config = ref.read(choeaeColorNotifierProvider);
    return [ThemeSlot.fromConfig('Slot 1', config)];
  }

  /// 현재 테마를 슬롯에 저장한다.
  ///
  /// custom 타입 슬롯 저장 시 IAP(자유 컬러 피커) 구매 여부를 확인한다.
  /// 미구매 상태에서 custom 타입 저장 시도 시 거부하고 false 반환.
  Future<bool> saveToSlot(int index, ThemeSlot slot) async {
    // P0: custom 타입 + 피커 미구매 → 저장 거부
    if (slot.type == 'custom') {
      final hasThemePicker =
          ref.read(monetizationNotifierProvider).valueOrNull?.hasThemePicker ??
              false;
      if (!hasThemePicker) {
        return false;
      }
    }

    final slots = [...state];
    if (index < slots.length) {
      slots[index] = slot;
    } else if (index < maxSlots) {
      while (slots.length <= index) {
        slots.add(ThemeSlot(
          name: 'Slot ${slots.length + 1}',
          type: 'palette',
          value: 'midnight',
        ));
      }
      slots[index] = slot;
    } else {
      return false;
    }
    state = slots;
    await _persist(slots);
    return true;
  }

  /// 슬롯 이름을 변경한다.
  Future<void> renameSlot(int index, String name) async {
    if (index >= state.length) return;
    final slots = [...state];
    final old = slots[index];
    slots[index] = ThemeSlot(
      name: name,
      type: old.type,
      value: old.value,
      textOverride: old.textOverride,
      brightnessOverride: old.brightnessOverride,
    );
    state = slots;
    await _persist(slots);
  }

  /// 슬롯을 선택하고 ChoeaeColorNotifier에 적용한다.
  ///
  /// custom 타입 슬롯에서 피커 IAP 미구매 시 기본 팔레트로 폴백한다.
  /// 환불 후 기존 커스텀 슬롯 데이터는 유지하되 기능만 차단 (소프트 락).
  Future<void> applySlot(int index) async {
    if (index >= state.length) return;
    final slot = state[index];

    // P0: custom 타입 + 피커 미구매 → 기본 팔레트 폴백
    final ChoeaeColorConfig config;
    if (slot.type == 'custom') {
      final hasThemePicker =
          ref.read(monetizationNotifierProvider).valueOrNull?.hasThemePicker ??
              false;
      config = hasThemePicker
          ? slot.toConfig()
          : const ChoeaeColorConfig.palette('midnight');
    } else {
      config = slot.toConfig();
    }

    await ref.read(choeaeColorNotifierProvider.notifier).restoreConfig(config);

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_activeKey, index);
  }

  /// 현재 활성 슬롯 인덱스 (범위 클램핑).
  int get activeIndex {
    final prefs = ref.read(sharedPreferencesProvider);
    final raw = prefs.getInt(_activeKey) ?? 0;
    return raw.clamp(0, state.length - 1);
  }

  /// IAP 해금 여부에 따른 사용 가능 슬롯 수.
  int availableSlots(bool hasThemeSlots) => hasThemeSlots ? maxSlots : 1;

  Future<void> _persist(List<ThemeSlot> slots) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final json = jsonEncode(slots.map((s) => s.toJson()).toList());
    await prefs.setString(_prefsKey, json);
  }
}
