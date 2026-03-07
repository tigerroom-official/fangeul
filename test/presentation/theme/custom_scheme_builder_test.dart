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
  });
}
