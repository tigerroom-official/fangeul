import 'dart:ui';

import 'package:fangeul/presentation/theme/choeae_color_config.dart';
import 'package:fangeul/presentation/theme/palette_registry.dart';

/// 테마 슬롯 — 이름 + ChoeaeColorConfig 직렬화.
///
/// SharedPreferences에 JSON 배열로 저장된다.
class ThemeSlot {
  const ThemeSlot({
    required this.name,
    required this.type,
    required this.value,
    this.textOverride,
    this.brightnessOverride,
  });

  /// 사용자 지정 이름.
  final String name;

  /// 'palette' 또는 'custom'.
  final String type;

  /// palette: packId, custom: hex 문자열.
  final String value;

  /// custom 전용: 글자색 hex 또는 null.
  final String? textOverride;

  /// custom 전용: 'dark' | 'light' | null.
  final String? brightnessOverride;

  /// JSON 직렬화.
  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'value': value,
        if (textOverride != null) 'textOverride': textOverride,
        if (brightnessOverride != null)
          'brightnessOverride': brightnessOverride,
      };

  /// JSON 역직렬화.
  factory ThemeSlot.fromJson(Map<String, dynamic> json) => ThemeSlot(
        name: json['name'] as String? ?? '',
        type: json['type'] as String? ?? 'palette',
        value: json['value'] as String? ?? PaletteRegistry.defaultId,
        textOverride: json['textOverride'] as String?,
        brightnessOverride: json['brightnessOverride'] as String?,
      );

  /// [ChoeaeColorConfig]로 변환한다.
  ChoeaeColorConfig toConfig() {
    if (type == 'custom') {
      final seedInt = int.tryParse(value, radix: 16);
      final seedColor =
          seedInt != null ? Color(seedInt) : const Color(0xFF00BCD4);
      Color? textColor;
      if (textOverride != null) {
        final textInt = int.tryParse(textOverride!, radix: 16);
        if (textInt != null) textColor = Color(textInt);
      }
      return ChoeaeColorConfig.custom(
        seedColor: seedColor,
        textColorOverride: textColor,
        brightnessOverride:
            brightnessOverride == 'light' ? Brightness.light : Brightness.dark,
      );
    }
    // palette
    try {
      PaletteRegistry.get(value);
      return ChoeaeColorConfig.palette(value);
    } catch (_) {
      return const ChoeaeColorConfig.palette('midnight');
    }
  }

  /// [ChoeaeColorConfig]에서 ThemeSlot을 생성한다.
  factory ThemeSlot.fromConfig(String name, ChoeaeColorConfig config) {
    return switch (config) {
      ChoeaeColorPalette(:final packId) => ThemeSlot(
          name: name,
          type: 'palette',
          value: packId,
        ),
      ChoeaeColorCustom(
        :final seedColor,
        :final textColorOverride,
        :final brightnessOverride,
      ) =>
        ThemeSlot(
          name: name,
          type: 'custom',
          value: seedColor.toARGB32().toRadixString(16).padLeft(8, '0'),
          textOverride:
              textColorOverride?.toARGB32().toRadixString(16).padLeft(8, '0'),
          brightnessOverride: brightnessOverride.name,
        ),
    };
  }
}
