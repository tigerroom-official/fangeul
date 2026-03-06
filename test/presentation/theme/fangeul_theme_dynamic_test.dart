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

  group('FangeulTheme component themes', () {
    test('dynamicDark should include all 5 component themes', () {
      final theme = FangeulTheme.dynamicDark(const Color(0xFF4527A0));
      final cs = theme.colorScheme;

      // AppBar
      expect(theme.appBarTheme.backgroundColor, isNotNull);
      expect(theme.appBarTheme.foregroundColor, cs.onSurface);
      expect(theme.appBarTheme.elevation, 0);

      // Card
      expect(theme.cardTheme.color, cs.surface);
      expect(theme.cardTheme.elevation, 0);

      // Chip
      expect(theme.chipTheme.backgroundColor, cs.surfaceContainer);
      expect(theme.chipTheme.selectedColor, cs.primary);
      expect(theme.chipTheme.showCheckmark, false);

      // NavigationBar
      expect(theme.navigationBarTheme.backgroundColor, cs.surface);
      expect(theme.navigationBarTheme.indicatorColor, isNotNull);

      // InputDecoration
      expect(theme.inputDecorationTheme.filled, true);
      expect(theme.inputDecorationTheme.fillColor, cs.surfaceContainer);
    });

    test('dynamicLight should include all 5 component themes', () {
      final theme = FangeulTheme.dynamicLight(const Color(0xFF4527A0));
      final cs = theme.colorScheme;

      expect(theme.appBarTheme.foregroundColor, cs.onSurface);
      expect(theme.cardTheme.color, cs.surface);
      expect(theme.chipTheme.backgroundColor, cs.surfaceContainer);
      expect(theme.navigationBarTheme.backgroundColor, cs.surface);
      expect(theme.inputDecorationTheme.fillColor, cs.surfaceContainer);
    });

    test('customTextColor should propagate through component themes', () {
      const textColor = Color(0xFFE0E0E0);
      final theme = FangeulTheme.dynamicDark(
        const Color(0xFF4527A0),
        customTextColor: textColor,
      );

      // AppBar foreground uses cs.onSurface which is overridden
      expect(theme.appBarTheme.foregroundColor, textColor);
    });

    test('static dark() should have same component theme types', () {
      final theme = FangeulTheme.dark();
      final cs = theme.colorScheme;

      expect(theme.appBarTheme.elevation, 0);
      expect(theme.cardTheme.color, cs.surface);
      expect(theme.chipTheme.backgroundColor, cs.surfaceContainer);
      expect(theme.navigationBarTheme.backgroundColor, cs.surface);
      expect(theme.inputDecorationTheme.filled, true);
    });

    test('static light() should have same component theme types', () {
      final theme = FangeulTheme.light();
      final cs = theme.colorScheme;

      expect(theme.appBarTheme.elevation, 0);
      expect(theme.cardTheme.color, cs.surface);
      expect(theme.chipTheme.backgroundColor, cs.surfaceContainer);
      expect(theme.navigationBarTheme.backgroundColor, cs.surface);
      expect(theme.inputDecorationTheme.filled, true);
    });

    test('dark indicator alpha should differ from light', () {
      final dark = FangeulTheme.dynamicDark(const Color(0xFF4527A0));
      final light = FangeulTheme.dynamicLight(const Color(0xFF4527A0));

      // Dark uses 0.15, light uses 0.35
      final darkAlpha = dark.navigationBarTheme.indicatorColor!.a;
      final lightAlpha = light.navigationBarTheme.indicatorColor!.a;
      expect(darkAlpha, lessThan(lightAlpha));
    });

    test('chip side should use outlineVariant from colorScheme', () {
      final theme = FangeulTheme.dynamicDark(const Color(0xFFF8BBD0));
      final cs = theme.colorScheme;

      expect(theme.chipTheme.side, BorderSide(color: cs.outlineVariant));
    });
  });
}
