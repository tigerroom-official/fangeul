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
      const config = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF4527A0),
        textColorOverride: Color(0xFFFFF8E1),
      );
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
      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
    });
  });
}
