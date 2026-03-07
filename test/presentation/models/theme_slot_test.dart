import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/presentation/models/theme_slot.dart';
import 'package:fangeul/presentation/theme/choeae_color_config.dart';

void main() {
  group('ThemeSlot', () {
    group('JSON serialization', () {
      test('should serialize palette slot to JSON', () {
        const slot = ThemeSlot(
          name: 'My Theme',
          type: 'palette',
          value: 'midnight',
        );
        final json = slot.toJson();
        expect(json['name'], 'My Theme');
        expect(json['type'], 'palette');
        expect(json['value'], 'midnight');
        expect(json.containsKey('textOverride'), false);
      });

      test('should serialize custom slot with textOverride to JSON', () {
        const slot = ThemeSlot(
          name: 'Custom',
          type: 'custom',
          value: 'ff4527a0',
          textOverride: 'ffffffff',
        );
        final json = slot.toJson();
        expect(json['name'], 'Custom');
        expect(json['type'], 'custom');
        expect(json['value'], 'ff4527a0');
        expect(json['textOverride'], 'ffffffff');
      });

      test('should deserialize palette slot from JSON', () {
        final slot = ThemeSlot.fromJson({
          'name': 'Slot 1',
          'type': 'palette',
          'value': 'purple_dream',
        });
        expect(slot.name, 'Slot 1');
        expect(slot.type, 'palette');
        expect(slot.value, 'purple_dream');
        expect(slot.textOverride, isNull);
      });

      test('should deserialize custom slot from JSON', () {
        final slot = ThemeSlot.fromJson({
          'name': 'Custom',
          'type': 'custom',
          'value': 'ff00bcd4',
          'textOverride': 'ffffffff',
        });
        expect(slot.name, 'Custom');
        expect(slot.type, 'custom');
        expect(slot.value, 'ff00bcd4');
        expect(slot.textOverride, 'ffffffff');
      });

      test('should handle missing fields with defaults', () {
        final slot = ThemeSlot.fromJson({});
        expect(slot.name, '');
        expect(slot.type, 'palette');
        expect(slot.value, 'midnight');
        expect(slot.textOverride, isNull);
      });

      test('should round-trip palette slot', () {
        const original = ThemeSlot(
          name: 'Test',
          type: 'palette',
          value: 'ocean_blue',
        );
        final restored = ThemeSlot.fromJson(original.toJson());
        expect(restored.name, original.name);
        expect(restored.type, original.type);
        expect(restored.value, original.value);
        expect(restored.textOverride, original.textOverride);
      });

      test('should round-trip custom slot with text override', () {
        const original = ThemeSlot(
          name: 'My Custom',
          type: 'custom',
          value: 'ff123456',
          textOverride: 'ffabcdef',
        );
        final restored = ThemeSlot.fromJson(original.toJson());
        expect(restored.name, original.name);
        expect(restored.type, original.type);
        expect(restored.value, original.value);
        expect(restored.textOverride, original.textOverride);
      });
    });

    group('toConfig', () {
      test('should convert palette slot to ChoeaeColorPalette', () {
        const slot = ThemeSlot(
          name: 'Test',
          type: 'palette',
          value: 'midnight',
        );
        final config = slot.toConfig();
        expect(config, isA<ChoeaeColorPalette>());
        expect((config as ChoeaeColorPalette).packId, 'midnight');
      });

      test('should convert custom slot to ChoeaeColorCustom', () {
        const slot = ThemeSlot(
          name: 'Custom',
          type: 'custom',
          value: 'ff00bcd4',
        );
        final config = slot.toConfig();
        expect(config, isA<ChoeaeColorCustom>());
        final custom = config as ChoeaeColorCustom;
        expect(custom.seedColor, const Color(0xFF00BCD4));
        expect(custom.textColorOverride, isNull);
      });

      test('should convert custom slot with text override', () {
        const slot = ThemeSlot(
          name: 'Custom',
          type: 'custom',
          value: 'ff4527a0',
          textOverride: 'ffffffff',
        );
        final config = slot.toConfig();
        expect(config, isA<ChoeaeColorCustom>());
        final custom = config as ChoeaeColorCustom;
        expect(custom.textColorOverride, const Color(0xFFFFFFFF));
      });

      test('should fallback to midnight for unknown palette id', () {
        const slot = ThemeSlot(
          name: 'Bad',
          type: 'palette',
          value: 'nonexistent_palette',
        );
        final config = slot.toConfig();
        expect(config, isA<ChoeaeColorPalette>());
        expect((config as ChoeaeColorPalette).packId, 'midnight');
      });
    });

    group('fromConfig', () {
      test('should create slot from palette config', () {
        const config = ChoeaeColorConfig.palette('purple_dream');
        final slot = ThemeSlot.fromConfig('My Slot', config);
        expect(slot.name, 'My Slot');
        expect(slot.type, 'palette');
        expect(slot.value, 'purple_dream');
        expect(slot.textOverride, isNull);
      });

      test('should create slot from custom config', () {
        final config = ChoeaeColorConfig.custom(
          seedColor: const Color(0xFF4527A0),
        );
        final slot = ThemeSlot.fromConfig('Custom', config);
        expect(slot.name, 'Custom');
        expect(slot.type, 'custom');
        // hex value should contain the color
        expect(int.tryParse(slot.value, radix: 16), isNotNull);
      });

      test('should create slot from custom config with text override', () {
        final config = ChoeaeColorConfig.custom(
          seedColor: const Color(0xFF4527A0),
          textColorOverride: const Color(0xFFFFFFFF),
        );
        final slot = ThemeSlot.fromConfig('Custom Text', config);
        expect(slot.type, 'custom');
        expect(slot.textOverride, isNotNull);
        expect(int.tryParse(slot.textOverride!, radix: 16), isNotNull);
      });

      test('should round-trip config through slot', () {
        const config = ChoeaeColorConfig.palette('ocean_blue');
        final slot = ThemeSlot.fromConfig('Test', config);
        final restored = slot.toConfig();
        expect(restored, config);
      });
    });
  });
}
