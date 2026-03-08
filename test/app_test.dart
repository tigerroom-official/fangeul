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
      const darkConfig = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF4527A0),
        textColorOverride: Color(0xFFFFF8E1),
        brightnessOverride: Brightness.dark,
      );
      const lightConfig = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF4527A0),
        textColorOverride: Color(0xFFFFF8E1),
        brightnessOverride: Brightness.light,
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

      // Matches the logic in app.dart AnnotatedRegion — uses surfaceContainerLowest
      expect(darkScheme.surfaceContainerLowest, isNotNull);
      expect(lightScheme.surfaceContainerLowest, isNotNull);
      expect(
        darkScheme.surfaceContainerLowest,
        isNot(equals(lightScheme.surfaceContainerLowest)),
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

      await container
          .read(choeaeColorNotifierProvider.notifier)
          .setCustomColor(const Color(0xFFE91E63));
      final config = container.read(choeaeColorNotifierProvider);

      // Custom config defaults to brightnessOverride: dark, so both
      // FangeulTheme.build calls produce dark themes.
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: config,
      );
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);

      // Verify light override works too.
      final notifier = container.read(choeaeColorNotifierProvider.notifier);
      await notifier.setBrightnessOverride(Brightness.light);
      final lightConfig = container.read(choeaeColorNotifierProvider);
      final lightTheme = FangeulTheme.build(
        brightness: Brightness.light,
        choeaeColor: lightConfig,
      );
      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.colorScheme.brightness, Brightness.light);
    });
  });

  group('app.dart brightness override routing', () {
    test(
        'should force identical light/dark themes when brightnessOverride is set',
        () {
      // Mirrors app.dart lines 65-74: when brightOverride != null,
      // both lightTheme and darkTheme slots get the same ThemeData.
      const config = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF4527A0),
        brightnessOverride: Brightness.dark,
      );

      final ChoeaeColorCustom custom = config as ChoeaeColorCustom;
      final brightOverride = custom.brightnessOverride;
      expect(brightOverride, Brightness.dark);

      // Both slots get the same theme
      final overriddenTheme = FangeulTheme.build(
        brightness: brightOverride,
        choeaeColor: config,
      );
      final effectiveThemeMode =
          brightOverride == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

      expect(effectiveThemeMode, ThemeMode.dark);
      expect(overriddenTheme.brightness, Brightness.dark);
      expect(overriddenTheme.colorScheme.brightness, Brightness.dark);
    });

    test('should respect system ThemeMode when palette config has no override',
        () {
      const config = ChoeaeColorConfig.palette('midnight');

      final brightOverride =
          config is ChoeaeColorCustom ? config.brightnessOverride : null;
      expect(brightOverride, isNull);

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

    test('should use brightnessOverride for AnnotatedRegion nav bar color', () {
      const config = ChoeaeColorConfig.custom(
        seedColor: Color(0xFFE91E63),
        brightnessOverride: Brightness.light,
      );

      // Mirrors app.dart lines 92-95: light override → effectiveDark = false
      final scheme = config.buildColorScheme(Brightness.light);
      expect(scheme.brightness, Brightness.light);
      expect(scheme.surfaceContainerLowest, isNotNull);
    });

    test('should set effectiveThemeMode to light when light override', () {
      const config = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF00BCD4),
        brightnessOverride: Brightness.light,
      );

      final brightOverride = (config as ChoeaeColorCustom).brightnessOverride;
      final effectiveThemeMode =
          brightOverride == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

      expect(effectiveThemeMode, ThemeMode.light);

      final theme = FangeulTheme.build(
        brightness: brightOverride,
        choeaeColor: config,
      );
      expect(theme.brightness, Brightness.light);
    });
  });
}
