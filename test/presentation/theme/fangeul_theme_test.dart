import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import 'package:fangeul/presentation/theme/choeae_color_config.dart';
import 'package:fangeul/presentation/theme/fangeul_theme.dart';

void main() {
  group('FangeulTheme.build', () {
    test('should produce dark theme with palette', () {
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: const ChoeaeColorConfig.palette('midnight'),
      );
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, true);
    });

    test('should produce light theme with palette', () {
      final theme = FangeulTheme.build(
        brightness: Brightness.light,
        choeaeColor: const ChoeaeColorConfig.palette('midnight'),
      );
      expect(theme.brightness, Brightness.light);
    });

    test('should include component themes', () {
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: const ChoeaeColorConfig.palette('midnight'),
      );
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.navigationBarTheme.backgroundColor, isNotNull);
      expect(theme.chipTheme.showCheckmark, false);
      expect(theme.inputDecorationTheme.filled, true);
    });

    test('should work with custom config', () {
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: const ChoeaeColorConfig.custom(
          seedColor: Color(0xFF4527A0),
        ),
      );
      expect(theme.brightness, Brightness.dark);
      // HCT chroma — neutral 24 기반이므로 surface chroma가 충분히 높아야 함
      final chroma =
          Hct.fromInt(theme.colorScheme.surface.toARGB32()).chroma;
      expect(chroma, greaterThan(5));
    });

    test('should apply custom text color override', () {
      const textColor = Color(0xFFFFF8E1);
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: const ChoeaeColorConfig.custom(
          seedColor: Color(0xFF4527A0),
          textColorOverride: textColor,
        ),
      );
      expect(theme.colorScheme.onSurface, textColor);
    });

    test('should set scaffoldBackgroundColor from surfaceContainerLowest', () {
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: const ChoeaeColorConfig.palette('midnight'),
      );
      expect(theme.scaffoldBackgroundColor,
          theme.colorScheme.surfaceContainerLowest);
    });

    test('should work with all palette ids', () {
      for (final id in [
        'midnight',
        'purple_dream',
        'ocean_blue',
        'rose_gold',
        'concert_encore',
        'golden_hour',
        'cherry_blossom',
        'neon_night',
        'mint_breeze',
        'sunset_cafe',
      ]) {
        final theme = FangeulTheme.build(
          brightness: Brightness.dark,
          choeaeColor: ChoeaeColorConfig.palette(id),
        );
        expect(theme.brightness, Brightness.dark, reason: id);
      }
    });
  });

  group('FangeulTheme component themes detail', () {
    test('should include all 5 component themes for dark', () {
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: const ChoeaeColorConfig.palette('midnight'),
      );
      final cs = theme.colorScheme;

      // AppBar — uses surfaceContainerHigh for color differentiation
      expect(theme.appBarTheme.backgroundColor, cs.surfaceContainerHigh);
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

    test('should include all 5 component themes for light', () {
      final theme = FangeulTheme.build(
        brightness: Brightness.light,
        choeaeColor: const ChoeaeColorConfig.palette('midnight'),
      );
      final cs = theme.colorScheme;

      expect(theme.appBarTheme.foregroundColor, cs.onSurface);
      expect(theme.cardTheme.color, cs.surface);
      expect(theme.chipTheme.backgroundColor, cs.surfaceContainer);
      expect(theme.navigationBarTheme.backgroundColor, cs.surface);
      expect(theme.inputDecorationTheme.fillColor, cs.surfaceContainer);
    });

    test('dark indicator alpha should differ from light', () {
      final dark = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: const ChoeaeColorConfig.palette('midnight'),
      );
      final light = FangeulTheme.build(
        brightness: Brightness.light,
        choeaeColor: const ChoeaeColorConfig.palette('midnight'),
      );

      // Dark uses 0.30, light uses 0.35
      final darkAlpha = dark.navigationBarTheme.indicatorColor!.a;
      final lightAlpha = light.navigationBarTheme.indicatorColor!.a;
      expect(darkAlpha, lessThan(lightAlpha));
    });

    test('chip side should use outlineVariant from colorScheme', () {
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: const ChoeaeColorConfig.custom(
          seedColor: Color(0xFFF8BBD0),
        ),
      );
      final cs = theme.colorScheme;

      expect(theme.chipTheme.side, BorderSide(color: cs.outlineVariant));
    });

    test('custom text color should propagate through component themes', () {
      const textColor = Color(0xFFE0E0E0);
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: const ChoeaeColorConfig.custom(
          seedColor: Color(0xFF4527A0),
          textColorOverride: textColor,
        ),
      );

      // AppBar foreground uses cs.onSurface which is overridden
      expect(theme.appBarTheme.foregroundColor, textColor);
    });
  });
}
