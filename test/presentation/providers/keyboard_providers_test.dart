import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/providers/keyboard_providers.dart';

void main() {
  group('KeyboardNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should start with caps off', () {
      final state = container.read(keyboardNotifierProvider);
      expect(state.capsMode, CapsMode.off);
    });

    test('should toggle to oneShot on single tap', () {
      container.read(keyboardNotifierProvider.notifier).toggleCaps();
      expect(
        container.read(keyboardNotifierProvider).capsMode,
        CapsMode.oneShot,
      );
    });

    test('should toggle to locked on double tap', () {
      final notifier = container.read(keyboardNotifierProvider.notifier);
      notifier.toggleCaps(); // off → oneShot
      notifier.toggleCaps(); // oneShot → locked
      expect(
        container.read(keyboardNotifierProvider).capsMode,
        CapsMode.locked,
      );
    });

    test('should toggle off from locked', () {
      final notifier = container.read(keyboardNotifierProvider.notifier);
      notifier.toggleCaps(); // off → oneShot
      notifier.toggleCaps(); // oneShot → locked
      notifier.toggleCaps(); // locked → off
      expect(
        container.read(keyboardNotifierProvider).capsMode,
        CapsMode.off,
      );
    });

    test('should consume oneShot after key press', () {
      final notifier = container.read(keyboardNotifierProvider.notifier);
      notifier.toggleCaps(); // off → oneShot
      notifier.consumeOneShot();
      expect(
        container.read(keyboardNotifierProvider).capsMode,
        CapsMode.off,
      );
    });

    test('should not consume locked mode', () {
      final notifier = container.read(keyboardNotifierProvider.notifier);
      notifier.toggleCaps(); // oneShot
      notifier.toggleCaps(); // locked
      notifier.consumeOneShot();
      expect(
        container.read(keyboardNotifierProvider).capsMode,
        CapsMode.locked,
      );
    });

    test('should report isShifted correctly', () {
      final notifier = container.read(keyboardNotifierProvider.notifier);
      expect(container.read(keyboardNotifierProvider).isShifted, false);

      notifier.toggleCaps();
      expect(container.read(keyboardNotifierProvider).isShifted, true);

      notifier.toggleCaps();
      expect(
        container.read(keyboardNotifierProvider).isShifted,
        true,
      ); // locked

      notifier.toggleCaps();
      expect(container.read(keyboardNotifierProvider).isShifted, false); // off
    });
  });
}
