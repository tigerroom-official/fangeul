import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/presentation/theme/custom_scheme_builder.dart';

void main() {
  group('CustomSchemeBuilder', () {
    test('should preserve seed hue in dark surface', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.dark,
      );
      final surfaceHsl = HSLColor.fromColor(scheme.surface);
      final seedHsl = HSLColor.fromColor(const Color(0xFF4527A0));
      expect((surfaceHsl.hue - seedHsl.hue).abs(), lessThan(5));
    });

    test('should have higher surface saturation than fromSeed', () {
      const seed = Color(0xFF4527A0);
      final custom = CustomSchemeBuilder.build(
        seedColor: seed,
        brightness: Brightness.dark,
      );
      final fromSeedScheme = ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      );
      final customSat = HSLColor.fromColor(custom.surface).saturation;
      final fromSeedSat = HSLColor.fromColor(fromSeedScheme.surface).saturation;
      expect(customSat, greaterThan(fromSeedSat));
    });

    test('should auto-contrast to white on dark surface', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.dark,
      );
      expect(scheme.onSurface, Colors.white);
    });

    test('should auto-contrast to black87 on light surface', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.light,
      );
      expect(scheme.onSurface, Colors.black87);
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
      expect(HSLColor.fromColor(scheme.surface).lightness, greaterThan(0.9));
    });

    test('should handle high saturation seed', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFFFF0000),
        brightness: Brightness.dark,
      );
      expect(scheme.brightness, Brightness.dark);
      expect(HSLColor.fromColor(scheme.surface).saturation, greaterThan(0));
    });

    test('should handle low saturation seed', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF808080),
        brightness: Brightness.dark,
      );
      expect(scheme.brightness, Brightness.dark);
    });
  });
}
