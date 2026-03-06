import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/presentation/theme/fangeul_theme.dart';

void main() {
  group('FangeulTheme dynamic', () {
    test('should generate dark theme from seed with correct brightness', () {
      final theme = FangeulTheme.dynamicDark(const Color(0xFF4527A0));
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('should generate light theme from seed with correct brightness', () {
      final theme = FangeulTheme.dynamicLight(const Color(0xFF4527A0));
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('should produce different themes for different seeds', () {
      final purple = FangeulTheme.dynamicDark(const Color(0xFF4527A0));
      final pink = FangeulTheme.dynamicDark(const Color(0xFFF8BBD0));
      expect(purple.colorScheme.primary, isNot(pink.colorScheme.primary));
    });

    test('should ensure text contrast on primary', () {
      final theme = FangeulTheme.dynamicDark(const Color(0xFFFFFF00));
      expect(theme.colorScheme.onPrimary, isNotNull);
      expect(
        theme.colorScheme.onPrimary,
        isNot(theme.colorScheme.primary),
      );
    });

    test('should override onSurface when customTextColor is set', () {
      const textColor = Color(0xFFE0E0E0);
      final theme = FangeulTheme.dynamicDark(
        const Color(0xFF4527A0),
        customTextColor: textColor,
      );
      expect(theme.colorScheme.onSurface, textColor);
      expect(theme.colorScheme.onPrimary, textColor);
    });

    test('should not override onSurface when customTextColor is null', () {
      final withoutCustom = FangeulTheme.dynamicDark(const Color(0xFF4527A0));
      final fromSeed = ColorScheme.fromSeed(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.dark,
      );
      expect(withoutCustom.colorScheme.onSurface, fromSeed.onSurface);
    });

    test('should override onSurface in light theme too', () {
      const textColor = Color(0xFF333333);
      final theme = FangeulTheme.dynamicLight(
        const Color(0xFF4527A0),
        customTextColor: textColor,
      );
      expect(theme.colorScheme.onSurface, textColor);
      expect(theme.colorScheme.onPrimary, textColor);
    });
  });
}
