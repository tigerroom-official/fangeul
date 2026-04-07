import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/presentation/providers/session_state_provider.dart';

void main() {
  group('SessionConversionShown', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('should default to false', () {
      expect(container.read(sessionConversionShownProvider), false);
    });

    test('should become true after markShown()', () {
      container.read(sessionConversionShownProvider.notifier).markShown();

      expect(container.read(sessionConversionShownProvider), true);
    });

    test('should remain true after multiple markShown() calls', () {
      final notifier = container.read(sessionConversionShownProvider.notifier);

      notifier.markShown();
      notifier.markShown();

      expect(container.read(sessionConversionShownProvider), true);
    });
  });
}
