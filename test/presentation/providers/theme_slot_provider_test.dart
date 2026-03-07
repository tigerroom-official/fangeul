import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/models/theme_slot.dart';
import 'package:fangeul/presentation/providers/choeae_color_provider.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart'
    show sharedPreferencesProvider;
import 'package:fangeul/presentation/providers/theme_slot_provider.dart';
import 'package:fangeul/presentation/theme/choeae_color_config.dart';

void main() {
  group('ThemeSlotNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
    });

    tearDown(() => container.dispose());

    test('should initialize with one slot from current choeaeColor', () {
      container.listen(themeSlotNotifierProvider, (_, __) {});
      final slots = container.read(themeSlotNotifierProvider);
      expect(slots.length, 1);
      expect(slots[0].name, 'Slot 1');
    });

    test('should load slots from SharedPreferences', () async {
      final prefs = container.read(sharedPreferencesProvider);
      final json = jsonEncode([
        {'name': 'Concert', 'type': 'palette', 'value': 'purple_dream'},
        {'name': 'Daily', 'type': 'palette', 'value': 'ocean_blue'},
      ]);
      await prefs.setString('theme_slots', json);

      // Recreate container to reload from prefs
      container.dispose();
      final prefs2 = await SharedPreferences.getInstance();
      container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs2),
      ]);
      container.listen(themeSlotNotifierProvider, (_, __) {});

      final slots = container.read(themeSlotNotifierProvider);
      expect(slots.length, 2);
      expect(slots[0].name, 'Concert');
      expect(slots[1].name, 'Daily');
    });

    test('should save to existing slot', () async {
      container.listen(themeSlotNotifierProvider, (_, __) {});
      final notifier = container.read(themeSlotNotifierProvider.notifier);

      const newSlot = ThemeSlot(
        name: 'Updated',
        type: 'palette',
        value: 'ocean_blue',
      );
      await notifier.saveToSlot(0, newSlot);

      final slots = container.read(themeSlotNotifierProvider);
      expect(slots[0].name, 'Updated');
      expect(slots[0].value, 'ocean_blue');
    });

    test('should save to new slot with padding', () async {
      container.listen(themeSlotNotifierProvider, (_, __) {});
      final notifier = container.read(themeSlotNotifierProvider.notifier);

      const newSlot = ThemeSlot(
        name: 'Slot 3',
        type: 'palette',
        value: 'rose_gold',
      );
      await notifier.saveToSlot(2, newSlot);

      final slots = container.read(themeSlotNotifierProvider);
      expect(slots.length, 3);
      expect(slots[2].name, 'Slot 3');
      expect(slots[2].value, 'rose_gold');
    });

    test('should not save beyond maxSlots', () async {
      container.listen(themeSlotNotifierProvider, (_, __) {});
      final notifier = container.read(themeSlotNotifierProvider.notifier);

      const newSlot = ThemeSlot(
        name: 'Too Far',
        type: 'palette',
        value: 'midnight',
      );
      await notifier.saveToSlot(5, newSlot);

      final slots = container.read(themeSlotNotifierProvider);
      expect(slots.length, 1); // unchanged
    });

    test('should rename slot', () async {
      container.listen(themeSlotNotifierProvider, (_, __) {});
      final notifier = container.read(themeSlotNotifierProvider.notifier);

      await notifier.renameSlot(0, 'My Concert Theme');

      final slots = container.read(themeSlotNotifierProvider);
      expect(slots[0].name, 'My Concert Theme');
    });

    test('should not rename slot beyond length', () async {
      container.listen(themeSlotNotifierProvider, (_, __) {});
      final notifier = container.read(themeSlotNotifierProvider.notifier);

      await notifier.renameSlot(5, 'Impossible');

      final slots = container.read(themeSlotNotifierProvider);
      expect(slots.length, 1);
      expect(slots[0].name, 'Slot 1');
    });

    test('should apply slot and update choeaeColor', () async {
      container.listen(themeSlotNotifierProvider, (_, __) {});
      container.listen(choeaeColorNotifierProvider, (_, __) {});

      final notifier = container.read(themeSlotNotifierProvider.notifier);

      // Save a second slot
      const slot2 = ThemeSlot(
        name: 'Purple',
        type: 'palette',
        value: 'purple_dream',
      );
      await notifier.saveToSlot(1, slot2);

      // Apply slot 1
      await notifier.applySlot(1);

      final choeae = container.read(choeaeColorNotifierProvider);
      expect(choeae, const ChoeaeColorConfig.palette('purple_dream'));
    });

    test('should persist active index', () async {
      container.listen(themeSlotNotifierProvider, (_, __) {});
      final notifier = container.read(themeSlotNotifierProvider.notifier);

      const slot2 = ThemeSlot(
        name: 'Slot 2',
        type: 'palette',
        value: 'ocean_blue',
      );
      await notifier.saveToSlot(1, slot2);
      await notifier.applySlot(1);

      expect(notifier.activeIndex, 1);
    });

    test('should return correct available slots count', () {
      container.listen(themeSlotNotifierProvider, (_, __) {});
      final notifier = container.read(themeSlotNotifierProvider.notifier);

      expect(notifier.availableSlots(false), 1);
      expect(notifier.availableSlots(true), 4);
    });

    test('should persist slots to SharedPreferences', () async {
      container.listen(themeSlotNotifierProvider, (_, __) {});
      final notifier = container.read(themeSlotNotifierProvider.notifier);

      const slot = ThemeSlot(
        name: 'Persisted',
        type: 'palette',
        value: 'midnight',
      );
      await notifier.saveToSlot(0, slot);

      final prefs = container.read(sharedPreferencesProvider);
      final stored = prefs.getString('theme_slots');
      expect(stored, isNotNull);
      final list = jsonDecode(stored!) as List<dynamic>;
      expect(list.length, 1);
      expect((list[0] as Map<String, dynamic>)['name'], 'Persisted');
    });
  });
}
