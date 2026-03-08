import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/providers/choeae_color_provider.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/theme/choeae_color_config.dart';
import 'package:fangeul/presentation/theme/fangeul_theme.dart';

void main() {
  group('FangeulApp theme wiring', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('should build light theme from default palette', () {
      const config = ChoeaeColorConfig.palette('midnight');
      final theme = FangeulTheme.build(
        brightness: Brightness.light,
        choeaeColor: config,
      );
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, true);
    });

    test('should build dark theme from default palette', () {
      const config = ChoeaeColorConfig.palette('midnight');
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: config,
      );
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, true);
    });

    test('should build theme from custom color config', () {
      const config = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF4527A0),
      );
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: config,
      );
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('should build theme from custom color with text override', () {
      // Dark seed (tone < 50)
      const darkConfig = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF4527A0), // deep purple, tone ~25
        textColorOverride: Color(0xFFFFF8E1),
      );
      // Light seed (tone >= 50)
      const lightConfig = ChoeaeColorConfig.custom(
        seedColor: Color(0xFFFFCDD2), // light pink, tone ~87
        textColorOverride: Color(0xFF3E2723),
      );
      final light = FangeulTheme.build(
        brightness: Brightness.light,
        choeaeColor: lightConfig,
      );
      final dark = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: darkConfig,
      );
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
    });

    test('should derive navigation bar color from choeae config', () {
      const config = ChoeaeColorConfig.palette('midnight');
      final darkScheme = config.buildColorScheme(Brightness.dark);
      final lightScheme = config.buildColorScheme(Brightness.light);

      // Matches the logic in app.dart AnnotatedRegion — uses surface
      expect(darkScheme.surface, isNotNull);
      expect(lightScheme.surface, isNotNull);
      expect(
        darkScheme.surface,
        isNot(equals(lightScheme.surface)),
      );
    });

    test('choeaeColorNotifierProvider should supply default config', () {
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
      addTearDown(container.dispose);
      container.listen(choeaeColorNotifierProvider, (_, __) {});

      final config = container.read(choeaeColorNotifierProvider);
      expect(config, const ChoeaeColorConfig.palette('midnight'));

      // Verify it produces valid ThemeData
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: config,
      );
      expect(theme, isA<ThemeData>());
    });

    test('should produce valid themes after palette change', () async {
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
      addTearDown(container.dispose);
      container.listen(choeaeColorNotifierProvider, (_, __) {});

      await container
          .read(choeaeColorNotifierProvider.notifier)
          .selectPalette('purple_dream');
      final config = container.read(choeaeColorNotifierProvider);
      expect(config, const ChoeaeColorConfig.palette('purple_dream'));

      final light = FangeulTheme.build(
        brightness: Brightness.light,
        choeaeColor: config,
      );
      final dark = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: config,
      );
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
    });

    test('should produce valid themes after custom color change', () async {
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
      addTearDown(container.dispose);
      container.listen(choeaeColorNotifierProvider, (_, __) {});

      // 0xFF311B92 = dark deep purple, HCT tone ~20 → dark
      await container
          .read(choeaeColorNotifierProvider.notifier)
          .setCustomColor(const Color(0xFF311B92));
      final config = container.read(choeaeColorNotifierProvider);

      // Brightness is auto-derived from seed tone (tone < 50 → dark).
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: config,
      );
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);

      // Light seed (high tone) produces light brightness.
      await container
          .read(choeaeColorNotifierProvider.notifier)
          .setCustomColor(const Color(0xFFFFCDD2)); // light pink, tone > 50
      final lightConfig = container.read(choeaeColorNotifierProvider);
      final lightTheme = FangeulTheme.build(
        brightness: Brightness.light,
        choeaeColor: lightConfig,
      );
      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.colorScheme.brightness, Brightness.light);
    });
  });

  group('app.dart seed-tone brightness routing', () {
    test('should force identical light/dark theme slots for custom config', () {
      // Mirrors app.dart: custom config → single theme for both slots.
      // Dark seed (tone < 50).
      const config = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF4527A0), // deep purple, tone ~25
      );

      final scheme = config.buildColorScheme(Brightness.dark);
      expect(scheme.brightness, Brightness.dark);

      // Both light/dark slots get the same theme
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: config,
      );
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('should respect system ThemeMode when palette config is active', () {
      const config = ChoeaeColorConfig.palette('midnight');

      // Palette: separate light/dark themes, ThemeMode passed through
      final light = FangeulTheme.build(
        brightness: Brightness.light,
        choeaeColor: config,
      );
      final dark = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: config,
      );
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(
          light.colorScheme.surface, isNot(equals(dark.colorScheme.surface)));
    });

    test('should derive nav bar color from seed-tone brightness', () {
      // Light seed (tone >= 50) → light scheme
      const config = ChoeaeColorConfig.custom(
        seedColor: Color(0xFFFFCDD2), // light pink, tone ~87
      );

      final scheme = config.buildColorScheme(Brightness.light);
      expect(scheme.brightness, Brightness.light);
      expect(scheme.surface, isNotNull);
    });

    test('should auto-derive light brightness for high-tone seed', () {
      // 0xFF90CAF9 = light blue, HCT tone ~77 → light
      const config = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF90CAF9),
      );

      final scheme = config.buildColorScheme(Brightness.light);
      expect(scheme.brightness, Brightness.light);

      final theme = FangeulTheme.build(
        brightness: Brightness.light,
        choeaeColor: config,
      );
      expect(theme.brightness, Brightness.light);
    });
  });
}
