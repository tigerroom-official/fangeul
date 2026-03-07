import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import 'package:fangeul/presentation/theme/custom_scheme_builder.dart';

void main() {
  group('CustomSchemeBuilder', () {
    test('should preserve seed hue in dark surface (HCT)', () {
      const seed = Color(0xFF4527A0);
      final scheme = CustomSchemeBuilder.build(
        seedColor: seed,
        brightness: Brightness.dark,
      );
      final surfaceHct = Hct.fromInt(scheme.surface.toARGB32());
      final seedHct = Hct.fromInt(seed.toARGB32());
      // HCT preserves hue faithfully — within 3 degrees
      expect((surfaceHct.hue - seedHct.hue).abs(), lessThan(3));
    });

    test('should have higher surface chroma than fromSeed', () {
      const seed = Color(0xFF4527A0);
      final custom = CustomSchemeBuilder.build(
        seedColor: seed,
        brightness: Brightness.dark,
      );
      final fromSeedScheme = ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      );
      final customChroma = Hct.fromInt(custom.surface.toARGB32()).chroma;
      final fromSeedChroma =
          Hct.fromInt(fromSeedScheme.surface.toARGB32()).chroma;
      // neutral chroma 24 vs fromSeed ~6
      expect(customChroma, greaterThan(fromSeedChroma));
    });

    test('should auto-contrast to light text on dark surface', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.dark,
      );
      // DynamicScheme generates high-luminance onSurface for dark mode
      expect(scheme.onSurface.computeLuminance(), greaterThan(0.5));
    });

    test('should auto-contrast to dark text on light surface', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.light,
      );
      expect(scheme.onSurface.computeLuminance(), lessThan(0.3));
    });

    test('should apply text color override', () {
      const textColor = Color(0xFFFFF8E1);
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.dark,
        textColorOverride: textColor,
      );
      expect(scheme.onSurface, textColor);
    });

    test('should include all required ColorScheme fields', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF1565C0),
        brightness: Brightness.dark,
      );
      expect(scheme.primary, isNotNull);
      expect(scheme.surface, isNotNull);
      expect(scheme.surfaceContainer, isNotNull);
      expect(scheme.surfaceContainerHigh, isNotNull);
      expect(scheme.outline, isNotNull);
      expect(scheme.outlineVariant, isNotNull);
    });

    test('should generate light scheme correctly', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFFF8BBD0),
        brightness: Brightness.light,
      );
      expect(scheme.brightness, Brightness.light);
      // Light surface should be high tone (bright) — shifted to 96
      final tone = Hct.fromInt(scheme.surface.toARGB32()).tone;
      expect(tone, greaterThan(85));
    });

    test('should have bold surface color with high chroma seed', () {
      // 유저가 빨간색 선택 → 배경이 확실히 빨간 톤이어야 함
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFFFF0000),
        brightness: Brightness.dark,
      );
      expect(scheme.brightness, Brightness.dark);
      final surfaceChroma = Hct.fromInt(scheme.surface.toARGB32()).chroma;
      // neutral chroma 24 → surface should have visible chroma
      expect(surfaceChroma, greaterThan(15));
    });

    test('yellow seed should produce visibly yellow surface', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFFFFEB3B),
        brightness: Brightness.dark,
      );
      final surfaceHct = Hct.fromInt(scheme.surface.toARGB32());
      final seedHct = Hct.fromInt(const Color(0xFFFFEB3B).toARGB32());
      // HCT preserves yellow hue accurately
      expect(surfaceHct.hue, closeTo(seedHct.hue, 5));
      // Visible chroma
      expect(surfaceHct.chroma, greaterThan(15));
    });

    test('should handle low saturation seed', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF808080),
        brightness: Brightness.dark,
      );
      expect(scheme.brightness, Brightness.dark);
    });

    test('should handle white seed without crash', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: Colors.white,
        brightness: Brightness.dark,
      );
      expect(scheme.brightness, Brightness.dark);
      expect(scheme.surface, isNotNull);
    });

    test('should handle black seed without crash', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: Colors.black,
        brightness: Brightness.dark,
      );
      expect(scheme.brightness, Brightness.dark);
      expect(scheme.surface, isNotNull);
    });

    test('textOverride onSurfaceVariant should preserve RGB channels', () {
      const textColor = Color(0xFFFF8800); // orange
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.dark,
        textColorOverride: textColor,
      );
      final variant = scheme.onSurfaceVariant;
      // RGB channels must match the override, only alpha reduced
      expect(variant.r, closeTo(textColor.r, 0.01));
      expect(variant.g, closeTo(textColor.g, 0.01));
      expect(variant.b, closeTo(textColor.b, 0.01));
      expect(variant.a, closeTo(textColor.a * 0.78, 0.02));
    });

    test('textOverride onSurfaceVariant white should be near-white', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.dark,
        textColorOverride: Colors.white,
      );
      final variant = scheme.onSurfaceVariant;
      // Must NOT be near-black (regression from Color.r float misuse)
      expect(variant.computeLuminance(), greaterThan(0.4));
    });

    test('light mode textOverride should work correctly', () {
      const textColor = Color(0xFF1A237E); // dark blue
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFFF8BBD0),
        brightness: Brightness.light,
        textColorOverride: textColor,
      );
      expect(scheme.onSurface, textColor);
      final variant = scheme.onSurfaceVariant;
      expect(variant.r, closeTo(textColor.r, 0.01));
      expect(variant.g, closeTo(textColor.g, 0.01));
      expect(variant.b, closeTo(textColor.b, 0.01));
    });

    test('HCT hue fidelity: surface hue matches seed within 3 degrees', () {
      const seeds = <Color>[
        Color(0xFFFF0000), // red
        Color(0xFFFFEB3B), // yellow
        Color(0xFF00FF00), // green
        Color(0xFF00BCD4), // cyan
        Color(0xFF2196F3), // blue
        Color(0xFF9C27B0), // purple
      ];
      for (final seed in seeds) {
        final scheme = CustomSchemeBuilder.build(
          seedColor: seed,
          brightness: Brightness.dark,
        );
        final seedHue = Hct.fromInt(seed.toARGB32()).hue;
        final surfaceHue = Hct.fromInt(scheme.surface.toARGB32()).hue;
        final diff = (surfaceHue - seedHue).abs();
        // Handle wraparound (e.g. 359 vs 1)
        final hueDiff = diff > 180 ? 360 - diff : diff;
        expect(
          hueDiff,
          lessThan(3),
          reason: 'seed ${seed.toARGB32().toRadixString(16)}',
        );
      }
    });

    test('HCT chroma presence: surface chroma >= 15', () {
      const seeds = <Color>[
        Color(0xFFFF0000),
        Color(0xFF2196F3),
        Color(0xFF9C27B0),
      ];
      for (final seed in seeds) {
        final scheme = CustomSchemeBuilder.build(
          seedColor: seed,
          brightness: Brightness.dark,
        );
        final chroma = Hct.fromInt(scheme.surface.toARGB32()).chroma;
        expect(chroma, greaterThanOrEqualTo(15),
            reason: 'seed ${seed.toARGB32().toRadixString(16)}');
      }
    });

    test('dark surface tone should be higher than M3 default (6)', () {
      const seeds = <Color>[
        Color(0xFFFF0000),
        Color(0xFF2196F3),
        Color(0xFF9C27B0),
        Color(0xFF00BCD4),
      ];
      for (final seed in seeds) {
        final scheme = CustomSchemeBuilder.build(
          seedColor: seed,
          brightness: Brightness.dark,
        );
        final tone = Hct.fromInt(scheme.surface.toARGB32()).tone;
        expect(tone, greaterThanOrEqualTo(12),
            reason: 'seed ${seed.toARGB32().toRadixString(16)} surface tone');
      }
    });

    test(
        'dark surface hierarchy: lowest < surface < container < high < highest',
        () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF9C27B0),
        brightness: Brightness.dark,
      );
      final lowest = Hct.fromInt(scheme.surfaceContainerLowest.toARGB32()).tone;
      final surface = Hct.fromInt(scheme.surface.toARGB32()).tone;
      final container = Hct.fromInt(scheme.surfaceContainer.toARGB32()).tone;
      final high = Hct.fromInt(scheme.surfaceContainerHigh.toARGB32()).tone;
      final highest =
          Hct.fromInt(scheme.surfaceContainerHighest.toARGB32()).tone;
      expect(lowest, lessThan(surface));
      expect(surface, lessThan(container));
      expect(container, lessThan(high));
      expect(high, lessThan(highest));
    });

    test(
        'light surface hierarchy: highest < high < container < surface < lowest',
        () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF9C27B0),
        brightness: Brightness.light,
      );
      final lowest = Hct.fromInt(scheme.surfaceContainerLowest.toARGB32()).tone;
      final surface = Hct.fromInt(scheme.surface.toARGB32()).tone;
      final container = Hct.fromInt(scheme.surfaceContainer.toARGB32()).tone;
      final high = Hct.fromInt(scheme.surfaceContainerHigh.toARGB32()).tone;
      final highest =
          Hct.fromInt(scheme.surfaceContainerHighest.toARGB32()).tone;
      expect(highest, lessThan(high));
      expect(high, lessThan(container));
      expect(container, lessThan(surface));
      expect(surface, lessThanOrEqualTo(lowest));
    });

    test('textOverride should NOT override onPrimary', () {
      const textColor = Color(0xFFFF0000);
      final withOverride = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.dark,
        textColorOverride: textColor,
      );
      final without = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.dark,
      );
      expect(withOverride.onPrimary, equals(without.onPrimary));
    });

    test('textOverride should NOT override onError', () {
      const textColor = Color(0xFFFF0000);
      final withOverride = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.dark,
        textColorOverride: textColor,
      );
      final without = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.dark,
      );
      expect(withOverride.onError, equals(without.onError));
    });

    group('WCAG contrast ratio', () {
      /// WCAG 2.1 relative luminance contrast ratio.
      double contrastRatio(Color a, Color b) {
        final la = a.computeLuminance();
        final lb = b.computeLuminance();
        final lighter = la > lb ? la : lb;
        final darker = la > lb ? lb : la;
        return (lighter + 0.05) / (darker + 0.05);
      }

      // Test all major hues for WCAG AA compliance (4.5:1 for body text)
      const majorHues = <String, Color>{
        'red': Color(0xFFFF0000),
        'yellow': Color(0xFFFFEB3B),
        'green': Color(0xFF00FF00),
        'cyan': Color(0xFF00BCD4),
        'blue': Color(0xFF2196F3),
        'purple': Color(0xFF9C27B0),
      };

      for (final entry in majorHues.entries) {
        test('dark onSurface contrast >= 4.5:1 for ${entry.key} seed', () {
          final scheme = CustomSchemeBuilder.build(
            seedColor: entry.value,
            brightness: Brightness.dark,
          );
          final ratio = contrastRatio(scheme.onSurface, scheme.surface);
          expect(ratio, greaterThanOrEqualTo(4.5),
              reason: '${entry.key} surface vs onSurface');
        });

        test('dark onSurfaceVariant contrast >= 4.5:1 for ${entry.key} seed',
            () {
          final scheme = CustomSchemeBuilder.build(
            seedColor: entry.value,
            brightness: Brightness.dark,
          );
          final ratio = contrastRatio(scheme.onSurfaceVariant, scheme.surface);
          expect(ratio, greaterThanOrEqualTo(4.5),
              reason: '${entry.key} surface vs onSurfaceVariant');
        });

        test(
            'dark surfaceContainerHigh onSurface contrast >= 3:1 for ${entry.key}',
            () {
          final scheme = CustomSchemeBuilder.build(
            seedColor: entry.value,
            brightness: Brightness.dark,
          );
          // AppBar uses surfaceContainerHigh — large text needs 3:1
          final ratio =
              contrastRatio(scheme.onSurface, scheme.surfaceContainerHigh);
          expect(ratio, greaterThanOrEqualTo(3.0),
              reason:
                  '${entry.key} surfaceContainerHigh vs onSurface (large text)');
        });
      }

      test('light mode WCAG AA for all major hues', () {
        for (final entry in majorHues.entries) {
          final scheme = CustomSchemeBuilder.build(
            seedColor: entry.value,
            brightness: Brightness.light,
          );
          final ratio = contrastRatio(scheme.onSurface, scheme.surface);
          expect(ratio, greaterThanOrEqualTo(4.5),
              reason: '${entry.key} light surface vs onSurface');
        }
      });
    });
  });
}
