import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/providers/choeae_color_provider.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart'
    show sharedPreferencesProvider;
import 'package:fangeul/presentation/theme/choeae_color_config.dart';

void main() {
  group('ChoeaeColorNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
    });

    tearDown(() => container.dispose());

    test('should default to midnight palette', () {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      final config = container.read(choeaeColorNotifierProvider);
      expect(config, const ChoeaeColorConfig.palette('midnight'));
    });

    test('should switch palette', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      final notifier = container.read(choeaeColorNotifierProvider.notifier);
      await notifier.selectPalette('purple_dream');
      expect(
        container.read(choeaeColorNotifierProvider),
        const ChoeaeColorConfig.palette('purple_dream'),
      );
    });

    test('should set custom color', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      final notifier = container.read(choeaeColorNotifierProvider.notifier);
      await notifier.setCustomColor(const Color(0xFF4527A0));
      final config = container.read(choeaeColorNotifierProvider);
      expect(config, isA<ChoeaeColorCustom>());
    });

    test('should set custom color with text override', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      final notifier = container.read(choeaeColorNotifierProvider.notifier);
      await notifier.setCustomColor(
        const Color(0xFF4527A0),
        textColor: const Color(0xFFFFFFFF),
      );
      final config =
          container.read(choeaeColorNotifierProvider) as ChoeaeColorCustom;
      expect(config.textColorOverride, const Color(0xFFFFFFFF));
    });

    test('should persist and restore palette', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      await container
          .read(choeaeColorNotifierProvider.notifier)
          .selectPalette('ocean_blue');

      final prefs = await SharedPreferences.getInstance();
      final container2 = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
      container2.listen(choeaeColorNotifierProvider, (_, __) {});
      expect(
        container2.read(choeaeColorNotifierProvider),
        const ChoeaeColorConfig.palette('ocean_blue'),
      );
      container2.dispose();
    });

    test('should persist and restore custom color', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      await container.read(choeaeColorNotifierProvider.notifier).setCustomColor(
            const Color(0xFF4527A0),
            textColor: const Color(0xFFFFF8E1),
          );

      final prefs = await SharedPreferences.getInstance();
      final container2 = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
      container2.listen(choeaeColorNotifierProvider, (_, __) {});
      final restored =
          container2.read(choeaeColorNotifierProvider) as ChoeaeColorCustom;
      expect(restored.seedColor, const Color(0xFF4527A0));
      expect(restored.textColorOverride, const Color(0xFFFFF8E1));
      container2.dispose();
    });

    test('should support undo after selectPalette', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      final notifier = container.read(choeaeColorNotifierProvider.notifier);
      await notifier.selectPalette('purple_dream');
      await notifier.selectPalette('ocean_blue');
      expect(notifier.canUndo, true);
      await notifier.undo();
      expect(
        container.read(choeaeColorNotifierProvider),
        const ChoeaeColorConfig.palette('purple_dream'),
      );
      expect(notifier.canUndo, false);
    });

    test('canUndo should be false initially', () {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      expect(
        container.read(choeaeColorNotifierProvider.notifier).canUndo,
        false,
      );
    });

    test('should support undo after setCustomColor', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      final notifier = container.read(choeaeColorNotifierProvider.notifier);
      await notifier.selectPalette('midnight');
      await notifier.setCustomColor(const Color(0xFF4527A0));
      expect(notifier.canUndo, true);
      await notifier.undo();
      expect(
        container.read(choeaeColorNotifierProvider),
        const ChoeaeColorConfig.palette('midnight'),
      );
    });

    test('should update text color override only', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      final notifier = container.read(choeaeColorNotifierProvider.notifier);
      await notifier.setCustomColor(const Color(0xFF4527A0));
      await notifier.setTextColorOverride(const Color(0xFFFFF8E1));
      final config =
          container.read(choeaeColorNotifierProvider) as ChoeaeColorCustom;
      expect(config.seedColor, const Color(0xFF4527A0));
      expect(config.textColorOverride, const Color(0xFFFFF8E1));
    });

    test('setTextColorOverride should no-op when in palette mode', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      final notifier = container.read(choeaeColorNotifierProvider.notifier);
      await notifier.setTextColorOverride(const Color(0xFFFFFFFF));
      // Should still be palette, not custom
      expect(
        container.read(choeaeColorNotifierProvider),
        const ChoeaeColorConfig.palette('midnight'),
      );
    });

    test('should fall back to midnight for unknown palette id', () async {
      SharedPreferences.setMockInitialValues({
        'choeae_type': 'palette',
        'choeae_value': 'nonexistent_palette',
      });
      final prefs = await SharedPreferences.getInstance();
      final c = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
      c.listen(choeaeColorNotifierProvider, (_, __) {});
      expect(
        c.read(choeaeColorNotifierProvider),
        const ChoeaeColorConfig.palette('midnight'),
      );
      c.dispose();
    });

    test('should fall back to midnight for invalid hex in custom', () async {
      SharedPreferences.setMockInitialValues({
        'choeae_type': 'custom',
        'choeae_value': 'not_a_hex',
      });
      final prefs = await SharedPreferences.getInstance();
      final c = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
      c.listen(choeaeColorNotifierProvider, (_, __) {});
      expect(
        c.read(choeaeColorNotifierProvider),
        const ChoeaeColorConfig.palette('midnight'),
      );
      c.dispose();
    });

    test('undo should persist restored state', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      final notifier = container.read(choeaeColorNotifierProvider.notifier);
      await notifier.selectPalette('purple_dream');
      await notifier.selectPalette('ocean_blue');
      await notifier.undo();

      // Verify persistence by creating a new container
      final prefs = await SharedPreferences.getInstance();
      final container2 = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
      container2.listen(choeaeColorNotifierProvider, (_, __) {});
      expect(
        container2.read(choeaeColorNotifierProvider),
        const ChoeaeColorConfig.palette('purple_dream'),
      );
      container2.dispose();
    });

    test('should clear text override when switching to palette', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      final notifier = container.read(choeaeColorNotifierProvider.notifier);
      await notifier.setCustomColor(
        const Color(0xFF4527A0),
        textColor: const Color(0xFFFFFFFF),
      );
      await notifier.selectPalette('midnight');

      // Text override should be removed from prefs
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('choeae_text_override'), isNull);
    });

    test('should ignore invalid palette id in selectPalette', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      final notifier = container.read(choeaeColorNotifierProvider.notifier);

      await notifier.selectPalette('purple_dream');
      expect(container.read(choeaeColorNotifierProvider),
          const ChoeaeColorConfig.palette('purple_dream'));

      // Invalid ID should be silently ignored — state unchanged
      await notifier.selectPalette('nonexistent_palette');
      expect(container.read(choeaeColorNotifierProvider),
          const ChoeaeColorConfig.palette('purple_dream'));
      expect(notifier.canUndo, true); // undo still from previous valid change
    });
  });
}
