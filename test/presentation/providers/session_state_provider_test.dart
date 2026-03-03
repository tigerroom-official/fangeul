import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/presentation/providers/session_state_provider.dart';

void main() {
  group('SessionBannerHidden', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('should default to false', () {
      expect(container.read(sessionBannerHiddenProvider), false);
    });

    test('should become true after hide()', () {
      container.read(sessionBannerHiddenProvider.notifier).hide();

      expect(container.read(sessionBannerHiddenProvider), true);
    });

    test('should remain true after multiple hide() calls', () {
      final notifier = container.read(sessionBannerHiddenProvider.notifier);

      notifier.hide();
      notifier.hide();

      expect(container.read(sessionBannerHiddenProvider), true);
    });
  });

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

  group('Session state isolation', () {
    test('should have independent state between providers', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sessionBannerHiddenProvider.notifier).hide();

      expect(container.read(sessionBannerHiddenProvider), true);
      expect(container.read(sessionConversionShownProvider), false);
    });

    test('should have independent state between containers (sessions)', () {
      final container1 = ProviderContainer();
      final container2 = ProviderContainer();
      addTearDown(container1.dispose);
      addTearDown(container2.dispose);

      container1.read(sessionBannerHiddenProvider.notifier).hide();

      expect(container1.read(sessionBannerHiddenProvider), true);
      expect(container2.read(sessionBannerHiddenProvider), false);
    });
  });
}
