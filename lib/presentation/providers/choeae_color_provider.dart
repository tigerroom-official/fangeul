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
    await _save('palette', packId);
    await _removeTextOverride();
    await _removeBrightnessOverride();
  }

  /// 커스텀 색상 설정.
  ///
  /// 기존 [brightnessOverride]를 보존한다 (custom 상태일 때).
  Future<void> setCustomColor(Color seed, {Color? textColor}) async {
    final existingBr = state is ChoeaeColorCustom
        ? (state as ChoeaeColorCustom).brightnessOverride
        : Brightness.dark;
    _previousConfig = state;
    _canUndo = true;
    state = ChoeaeColorConfig.custom(
      seedColor: seed,
      textColorOverride: textColor,
      brightnessOverride: existingBr,
    );
    final hex = seed.toARGB32().toRadixString(16).padLeft(8, '0');
    await _save('custom', hex);
    if (textColor != null) {
      await _saveTextOverride(textColor);
    } else {
      await _removeTextOverride();
    }
    await _saveBrightnessOverride(existingBr);
  }

  /// 커스텀 글자색만 변경 (seed color + brightnessOverride 유지).
  Future<void> setTextColorOverride(Color? color) async {
    final current = state;
    if (current is! ChoeaeColorCustom) return;
    _previousConfig = state;
    _canUndo = true;
    state = ChoeaeColorConfig.custom(
      seedColor: current.seedColor,
      textColorOverride: color,
      brightnessOverride: current.brightnessOverride,
    );
    if (color != null) {
      await _saveTextOverride(color);
    } else {
      await _removeTextOverride();
    }
  }

  /// Undo 기록 없이 설정을 복원한다 (프리뷰 복원용).
  Future<void> restoreConfig(ChoeaeColorConfig config) async {
    state = config;
    switch (config) {
      case ChoeaeColorPalette(:final packId):
        await _save('palette', packId);
        await _removeTextOverride();
        await _removeBrightnessOverride();
      case ChoeaeColorCustom(
          :final seedColor,
          :final textColorOverride,
          :final brightnessOverride,
        ):
        final hex = seedColor.toARGB32().toRadixString(16).padLeft(8, '0');
        await _save('custom', hex);
        if (textColorOverride != null) {
          await _saveTextOverride(textColorOverride);
        } else {
          await _removeTextOverride();
        }
        await _saveBrightnessOverride(brightnessOverride);
    }
  }

  /// 마지막 변경 되돌리기 (1단계).
  Future<void> undo() async {
    if (!_canUndo || _previousConfig == null) return;
    _canUndo = false;
    state = _previousConfig!;
    // Persist restored state.
    switch (_previousConfig!) {
      case ChoeaeColorPalette(:final packId):
        await _save('palette', packId);
        await _removeTextOverride();
        await _removeBrightnessOverride();
      case ChoeaeColorCustom(
          :final seedColor,
          :final textColorOverride,
          :final brightnessOverride,
        ):
        final hex = seedColor.toARGB32().toRadixString(16).padLeft(8, '0');
        await _save('custom', hex);
        if (textColorOverride != null) {
          await _saveTextOverride(textColorOverride);
        } else {
          await _removeTextOverride();
        }
        await _saveBrightnessOverride(brightnessOverride);
    }
  }

  Future<void> _save(String type, String value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_typeKey, type);
    await prefs.setString(_valueKey, value);
  }

  Color? _loadTextOverride(SharedPreferences prefs) {
    final hex = prefs.getString(_textKey);
    if (hex == null) return null;
    final value = int.tryParse(hex, radix: 16);
    return value != null ? Color(value) : null;
  }

  Future<void> _saveTextOverride(Color color) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(
      _textKey,
      color.toARGB32().toRadixString(16).padLeft(8, '0'),
    );
  }

  Future<void> _removeTextOverride() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_textKey);
  }

  /// Brightness 오버라이드 변경 (custom 상태에서만 동작).
  Future<void> setBrightnessOverride(Brightness br) async {
    final current = state;
    if (current is! ChoeaeColorCustom) return;
    _previousConfig = state;
    _canUndo = true;
    state = ChoeaeColorConfig.custom(
      seedColor: current.seedColor,
      textColorOverride: current.textColorOverride,
      brightnessOverride: br,
    );
    await _saveBrightnessOverride(br);
  }

  Future<void> _saveBrightnessOverride(Brightness br) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_brightnessKey, br.name);
  }

  Future<void> _removeBrightnessOverride() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_brightnessKey);
  }
}
