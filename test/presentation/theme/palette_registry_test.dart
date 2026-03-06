import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/presentation/theme/palette_registry.dart';

void main() {
  group('PaletteRegistry', () {
    test('should have exactly 10 palettes', () {
      expect(PaletteRegistry.all.length, 10);
    });

    test('should have 4 free and 6 premium', () {
      expect(PaletteRegistry.free.length, 4);
      expect(PaletteRegistry.premium.length, 6);
    });

    test('should find palette by id', () {
      final pack = PaletteRegistry.get('midnight');
      expect(pack.id, 'midnight');
    });

    test('should throw on unknown id', () {
      expect(() => PaletteRegistry.get('unknown'), throwsArgumentError);
    });

    test('should have valid light and dark schemes for each palette', () {
      for (final pack in PaletteRegistry.all) {
        expect(
          pack.darkScheme.brightness,
          Brightness.dark,
          reason: '${pack.id} dark',
        );
        expect(
          pack.lightScheme.brightness,
          Brightness.light,
          reason: '${pack.id} light',
        );
      }
    });

    test('should have midnight as default palette', () {
      expect(PaletteRegistry.defaultId, 'midnight');
    });

    test('schemeFor should return correct brightness', () {
      final pack = PaletteRegistry.get('purple_dream');
      expect(pack.schemeFor(Brightness.dark).brightness, Brightness.dark);
      expect(pack.schemeFor(Brightness.light).brightness, Brightness.light);
    });

    test('midnight palette should use FangeulColors tokens', () {
      final pack = PaletteRegistry.get('midnight');
      expect(pack.darkScheme.primary, const Color(0xFF4ECDC4));
      expect(pack.darkScheme.surface, const Color(0xFF1E1E2E));
    });

    test('should have unique ids for all palettes', () {
      final ids = PaletteRegistry.all.map((p) => p.id).toSet();
      expect(ids.length, PaletteRegistry.all.length);
    });

    test('premium palettes should have isPremium true', () {
      for (final pack in PaletteRegistry.premium) {
        expect(pack.isPremium, true, reason: '${pack.id} isPremium');
      }
    });

    test('free palettes should have isPremium false', () {
      for (final pack in PaletteRegistry.free) {
        expect(pack.isPremium, false, reason: '${pack.id} isPremium');
      }
    });

    test('each palette should have a non-empty nameKey', () {
      for (final pack in PaletteRegistry.all) {
        expect(pack.nameKey, isNotEmpty, reason: '${pack.id} nameKey');
      }
    });

    test('each palette should have a non-transparent previewColor', () {
      for (final pack in PaletteRegistry.all) {
        expect(
          pack.previewColor.a,
          greaterThan(0.0),
          reason: '${pack.id} previewColor',
        );
      }
    });

    test('surface colors should be tinted for each palette', () {
      // Verify that dark surfaces are NOT neutral gray — they should have
      // the palette's hue tint. We check that at least one of R/G/B channels
      // differs from a pure neutral (where R==G==B).
      for (final pack in PaletteRegistry.all) {
        final s = pack.darkScheme.surface;
        final isNeutralGray = s.r == s.g && s.g == s.b;
        expect(
          isNeutralGray,
          false,
          reason: '${pack.id} dark surface should be tinted, not neutral gray '
              '(${s.r}, ${s.g}, ${s.b})',
        );
      }
    });
  });
}
