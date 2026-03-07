import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/presentation/theme/choeae_color_config.dart';

void main() {
  group('ChoeaeColorConfig', () {
    test('should hold packId when palette variant', () {
      const config = ChoeaeColorConfig.palette('purple_dream');
      expect(config, isA<ChoeaeColorPalette>());
      expect((config as ChoeaeColorPalette).packId, 'purple_dream');
    });

    test('should hold seedColor when custom variant', () {
      const config = ChoeaeColorConfig.custom(seedColor: Color(0xFF4527A0));
      expect(config, isA<ChoeaeColorCustom>());
      expect(
        (config as ChoeaeColorCustom).seedColor,
        const Color(0xFF4527A0),
      );
    });

    test('should hold textColorOverride when custom variant with override', () {
      const config = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF4527A0),
        textColorOverride: Color(0xFFFFFFFF),
      );
      expect(
        (config as ChoeaeColorCustom).textColorOverride,
        const Color(0xFFFFFFFF),
      );
    });

    test('should default textColorOverride to null when not provided', () {
      const config = ChoeaeColorConfig.custom(seedColor: Color(0xFF4527A0));
      expect((config as ChoeaeColorCustom).textColorOverride, isNull);
    });

    test('should build dark ColorScheme when palette with dark brightness', () {
      const config = ChoeaeColorConfig.palette('midnight');
      final scheme = config.buildColorScheme(Brightness.dark);
      expect(scheme.brightness, Brightness.dark);
      expect(scheme.primary, const Color(0xFF4ECDC4));
    });

    test(
      'should build light ColorScheme when palette with light brightness',
      () {
        const config = ChoeaeColorConfig.palette('midnight');
        final scheme = config.buildColorScheme(Brightness.light);
        expect(scheme.brightness, Brightness.light);
      },
    );

    test('should build dark ColorScheme when custom with dark brightness', () {
      const config = ChoeaeColorConfig.custom(seedColor: Color(0xFF4527A0));
      final scheme = config.buildColorScheme(Brightness.dark);
      expect(scheme.brightness, Brightness.dark);
      // CustomSchemeBuilder tints surfaces — verify saturation > 0
      final surfaceHsl = HSLColor.fromColor(scheme.surface);
      expect(surfaceHsl.saturation, greaterThan(0.05));
    });

    test(
      'should build light ColorScheme when custom with light brightnessOverride',
      () {
        const config = ChoeaeColorConfig.custom(
          seedColor: Color(0xFF4527A0),
          brightnessOverride: Brightness.light,
        );
        final scheme = config.buildColorScheme(Brightness.dark);
        expect(scheme.brightness, Brightness.light);
      },
    );

    test(
      'should apply textColorOverride to onSurface when custom with override',
      () {
        const override = Color(0xFFFF0000);
        const config = ChoeaeColorConfig.custom(
          seedColor: Color(0xFF4527A0),
          textColorOverride: override,
        );
        final scheme = config.buildColorScheme(Brightness.dark);
        expect(scheme.onSurface, override);
      },
    );

    test('should throw ArgumentError when palette with unknown id', () {
      const config = ChoeaeColorConfig.palette('nonexistent_palette');
      expect(
        () => config.buildColorScheme(Brightness.dark),
        throwsArgumentError,
      );
    });

    test('should be equal when palette variants have same packId', () {
      const a = ChoeaeColorConfig.palette('midnight');
      const b = ChoeaeColorConfig.palette('midnight');
      expect(a, equals(b));
    });

    test('should not be equal when palette variants have different packId', () {
      const a = ChoeaeColorConfig.palette('midnight');
      const b = ChoeaeColorConfig.palette('purple_dream');
      expect(a, isNot(equals(b)));
    });

    test('should be equal when custom variants have same seedColor', () {
      const a = ChoeaeColorConfig.custom(seedColor: Color(0xFF4527A0));
      const b = ChoeaeColorConfig.custom(seedColor: Color(0xFF4527A0));
      expect(a, equals(b));
    });

    test(
      'should not be equal when custom variants have different seedColor',
      () {
        const a = ChoeaeColorConfig.custom(seedColor: Color(0xFF4527A0));
        const b = ChoeaeColorConfig.custom(seedColor: Color(0xFFFF0000));
        expect(a, isNot(equals(b)));
      },
    );

    test(
      'should not be equal when palette and custom variants compared',
      () {
        const palette = ChoeaeColorConfig.palette('midnight');
        const custom = ChoeaeColorConfig.custom(seedColor: Color(0xFF4527A0));
        expect(palette, isNot(equals(custom)));
      },
    );

    test('should have consistent hashCode when equal', () {
      const a = ChoeaeColorConfig.palette('midnight');
      const b = ChoeaeColorConfig.palette('midnight');
      expect(a.hashCode, equals(b.hashCode));
    });

    test('custom brightnessOverride should override passed brightness', () {
      const config = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF4527A0),
        brightnessOverride: Brightness.dark,
      );
      final scheme = config.buildColorScheme(Brightness.light);
      expect(scheme.brightness, Brightness.dark);
    });

    test('custom with light override should produce light scheme', () {
      const config = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF4527A0),
        brightnessOverride: Brightness.light,
      );
      final scheme = config.buildColorScheme(Brightness.dark);
      expect(scheme.brightness, Brightness.light);
    });

    test('custom default brightnessOverride should be dark', () {
      const config = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF4527A0),
      );
      expect(
        (config as ChoeaeColorCustom).brightnessOverride,
        Brightness.dark,
      );
    });
  });
}
