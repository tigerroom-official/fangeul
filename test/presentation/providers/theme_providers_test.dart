import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/providers/theme_providers.dart'
    show sharedPreferencesProvider, themeModeNotifierProvider, contrastRatio;

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

  group('contrastRatio', () {
    test('should return ~21.0 for white on black', () {
      final ratio = contrastRatio(Colors.white, Colors.black);
      expect(ratio, closeTo(21.0, 0.1));
    });

    test('should return 1.0 for same color', () {
      final ratio = contrastRatio(Colors.red, Colors.red);
      expect(ratio, closeTo(1.0, 0.01));
    });

    test('should detect low contrast', () {
      // Light gray on white
      const lightGray = Color(0xFFCCCCCC);
      final ratio = contrastRatio(lightGray, Colors.white);
      expect(ratio, lessThan(4.5));
    });

    test('should detect adequate contrast', () {
      // Dark text on light bg
      const darkText = Color(0xFF333333);
      final ratio = contrastRatio(darkText, Colors.white);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });
  });
}
