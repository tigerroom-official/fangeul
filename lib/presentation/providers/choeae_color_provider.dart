import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/theme/choeae_color_config.dart';
import 'package:fangeul/presentation/theme/palette_registry.dart';

part 'choeae_color_provider.g.dart';

/// 최애색 상태 관리.
///
/// `ChoeaeColorConfig.palette('midnight')`이 기본값.
/// SharedPreferences에 `choeae_type` + `choeae_value` + `choeae_text_override` 저장.
@Riverpod(keepAlive: true)
class ChoeaeColorNotifier extends _$ChoeaeColorNotifier {
  static const _typeKey = 'choeae_type';
  static const _valueKey = 'choeae_value';
  static const _textKey = 'choeae_text_override';
  static const _brightnessKey = 'choeae_brightness_override';

  ChoeaeColorConfig? _previousConfig;
  bool _canUndo = false;

  /// SharedPreferences 쓰기 직렬화 — 겹치는 mutation의 race condition 방지.
  Future<void> _writeChain = Future.value();

  /// Undo 가능 여부.
  bool get canUndo => _canUndo;

  @override
  ChoeaeColorConfig build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final type = prefs.getString(_typeKey);
    final value = prefs.getString(_valueKey);

    if (type == 'custom' && value != null) {
      final seedInt = int.tryParse(value, radix: 16);
      if (seedInt != null) {
        final brStr = prefs.getString(_brightnessKey);
        final br = brStr == 'light' ? Brightness.light : Brightness.dark;
        return ChoeaeColorConfig.custom(
          seedColor: Color(seedInt),
          textColorOverride: _loadTextOverride(prefs),
          brightnessOverride: br,
        );
      }
    }

    if (type == 'palette' && value != null) {
      // Validate the palette ID exists — throws ArgumentError if unknown.
      try {
        PaletteRegistry.get(value);
        return ChoeaeColorConfig.palette(value);
      } catch (_) {
        // Fall through to default
      }
    }

    return const ChoeaeColorConfig.palette('midnight');
  }

  /// 팔레트 선택.
  ///
  /// [packId]가 [PaletteRegistry]에 존재하지 않으면 무시한다.
  Future<void> selectPalette(String packId) async {
    try {
      PaletteRegistry.get(packId);
    } catch (_) {
      return; // 존재하지 않는 팔레트 ID — 무시
    }
    _previousConfig = state;
    _canUndo = true;
    state = ChoeaeColorConfig.palette(packId);
    await _persistCurrentState();
  }

  /// 커스텀 색상 설정.
  ///
  /// brightness는 seed tone에서 자동 유도 — 별도 설정 불필요.
  /// [persist]가 false이면 in-memory 상태만 변경하고 SharedPreferences에 쓰지 않는다.
  /// 프리뷰 모드(IAP 미구매)에서 앱 킬 시 커스텀 색상이 영구 잔류하는 버그 방지.
  Future<void> setCustomColor(
    Color seed, {
    Color? textColor,
    bool persist = true,
  }) async {
    _previousConfig = state;
    _canUndo = true;
    state = ChoeaeColorConfig.custom(
      seedColor: seed,
      textColorOverride: textColor,
    );
    if (persist) {
      await _persistCurrentState();
    }
  }

  /// 커스텀 글자색만 변경 (seed color + brightnessOverride 유지).
  ///
  /// [persist]가 false이면 in-memory 상태만 변경 (프리뷰 모드용).
  Future<void> setTextColorOverride(Color? color, {bool persist = true}) async {
    final current = state;
    if (current is! ChoeaeColorCustom) return;
    _previousConfig = state;
    _canUndo = true;
    state = ChoeaeColorConfig.custom(
      seedColor: current.seedColor,
      textColorOverride: color,
      brightnessOverride: current.brightnessOverride,
    );
    if (persist) {
      await _persistCurrentState();
    }
  }

  /// Undo 기록 없이 설정을 복원한다 (프리뷰 복원용).
  Future<void> restoreConfig(ChoeaeColorConfig config) async {
    state = config;
    await _persistCurrentState();
  }

  /// 마지막 변경 되돌리기 (1단계).
  ///
  /// [persist]가 false이면 in-memory 상태만 변경 (프리뷰 모드용).
  /// 프리뷰 중 undo가 custom 상태를 영구 저장하는 IAP 우회 방지.
  Future<void> undo({bool persist = true}) async {
    if (!_canUndo || _previousConfig == null) return;
    _canUndo = false;
    state = _previousConfig!;
    if (persist) {
      await _persistCurrentState();
    }
  }

  // setBrightnessOverride 제거 — brightness는 seed tone에서 자동 유도.

  Color? _loadTextOverride(SharedPreferences prefs) {
    final hex = prefs.getString(_textKey);
    if (hex == null) return null;
    final value = int.tryParse(hex, radix: 16);
    return value != null ? Color(value) : null;
  }

  /// 현재 in-memory state를 SharedPreferences에 직렬화하여 저장한다.
  ///
  /// [_writeChain]으로 직렬화되어 겹치는 호출의 race condition을 방지한다.
  /// 각 호출 시점의 최신 [state]를 저장하므로 이전 mutation이 이후 값을
  /// 덮어쓰지 않는다.
  Future<void> _persistCurrentState() {
    _writeChain = _writeChain.then((_) => _doWriteState());
    return _writeChain;
  }

  Future<void> _doWriteState() async {
    final current = state;
    final prefs = ref.read(sharedPreferencesProvider);
    switch (current) {
      case ChoeaeColorPalette(:final packId):
        await prefs.setString(_typeKey, 'palette');
        await prefs.setString(_valueKey, packId);
        await prefs.remove(_textKey);
        await prefs.remove(_brightnessKey);
      case ChoeaeColorCustom(
          :final seedColor,
          :final textColorOverride,
          :final brightnessOverride,
        ):
        final hex = seedColor.toARGB32().toRadixString(16).padLeft(8, '0');
        await prefs.setString(_typeKey, 'custom');
        await prefs.setString(_valueKey, hex);
        if (textColorOverride != null) {
          final textHex =
              textColorOverride.toARGB32().toRadixString(16).padLeft(8, '0');
          await prefs.setString(_textKey, textHex);
        } else {
          await prefs.remove(_textKey);
        }
        await prefs.setString(_brightnessKey, brightnessOverride.name);
    }
  }
}
