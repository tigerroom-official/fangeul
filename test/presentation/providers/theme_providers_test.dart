import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/theme/theme_palettes.dart';

void main() {
  group('ThemeModeNotifier', () {
    test('should default to dark mode when no saved preference', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeNotifierProvider), ThemeMode.dark);
    });

    test('should load saved light mode', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeNotifierProvider), ThemeMode.light);
    });

    test('should load saved system mode', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'system'});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeNotifierProvider), ThemeMode.system);
    });

    test('should fall back to dark for invalid saved value', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'invalid'});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeNotifierProvider), ThemeMode.dark);
    });

    test('should persist theme mode change', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      await container
          .read(themeModeNotifierProvider.notifier)
          .setThemeMode(ThemeMode.light);

      expect(container.read(themeModeNotifierProvider), ThemeMode.light);
      expect(prefs.getString('theme_mode'), 'light');
    });
  });

  group('ThemeColorNotifier', () {
    late ProviderContainer container;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
    });

    tearDown(() => container.dispose());

    test('should return null by default (teal theme)', () {
      container.listen(themeColorNotifierProvider, (_, __) {});
      final color = container.read(themeColorNotifierProvider);
      expect(color, isNull);
    });

    test('should save and restore seed color', () async {
      container.listen(themeColorNotifierProvider, (_, __) {});
      final notifier = container.read(themeColorNotifierProvider.notifier);

      await notifier.setSeedColor(const Color(0xFF4527A0));
      expect(
          container.read(themeColorNotifierProvider), const Color(0xFF4527A0));

      // SharedPreferences에 저장 확인
      expect(prefs.getString('theme_seed_color'), isNotNull);
    });

    test('should reset to null when resetToDefault called', () async {
      container.listen(themeColorNotifierProvider, (_, __) {});
      final notifier = container.read(themeColorNotifierProvider.notifier);

      await notifier.setSeedColor(const Color(0xFF4527A0));
      await notifier.resetToDefault();
      expect(container.read(themeColorNotifierProvider), isNull);
    });

    test('should apply palette seed color', () async {
      container.listen(themeColorNotifierProvider, (_, __) {});
      final notifier = container.read(themeColorNotifierProvider.notifier);

      await notifier.applyPalette(ThemePalettes.ocean);
      expect(container.read(themeColorNotifierProvider),
          ThemePalettes.ocean.seedColor);
    });

    test('should save and restore custom text color', () async {
      container.listen(themeColorNotifierProvider, (_, __) {});
      final notifier = container.read(themeColorNotifierProvider.notifier);

      await notifier.setSeedColor(const Color(0xFF4527A0));
      await notifier.setCustomTextColor(const Color(0xFFFFFFFF));

      expect(notifier.customTextColor, const Color(0xFFFFFFFF));
    });

    test('should clear custom text color on reset', () async {
      container.listen(themeColorNotifierProvider, (_, __) {});
      final notifier = container.read(themeColorNotifierProvider.notifier);

      await notifier.setSeedColor(const Color(0xFF4527A0));
      await notifier.setCustomTextColor(const Color(0xFFFFFFFF));
      await notifier.resetToDefault();

      expect(notifier.customTextColor, isNull);
    });
  });
}
