import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/providers/my_idol_provider.dart';

void main() {
  group('MyIdolNotifier', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('should return null when no idol selected', () async {
      final result = await container.read(myIdolNotifierProvider.future);
      expect(result, isNull);
    });

    test('should return group id after select', () async {
      final notifier = container.read(myIdolNotifierProvider.notifier);
      // build 완료 대기
      await container.read(myIdolNotifierProvider.future);

      await notifier.select('bts');
      final result = await container.read(myIdolNotifierProvider.future);
      expect(result, 'bts');
    });

    test('should persist selection to SharedPreferences', () async {
      final notifier = container.read(myIdolNotifierProvider.notifier);
      await container.read(myIdolNotifierProvider.future);

      await notifier.select('blackpink');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('my_idol_group_id'), 'blackpink');
    });

    test('should return null after clear', () async {
      final notifier = container.read(myIdolNotifierProvider.notifier);
      await container.read(myIdolNotifierProvider.future);

      await notifier.select('bts');
      await notifier.clear();

      final result = await container.read(myIdolNotifierProvider.future);
      expect(result, isNull);
    });

    test('should load persisted selection on rebuild', () async {
      SharedPreferences.setMockInitialValues({'my_idol_group_id': 'seventeen'});

      final container2 = ProviderContainer();
      addTearDown(() => container2.dispose());

      final result = await container2.read(myIdolNotifierProvider.future);
      expect(result, 'seventeen');
    });
  });
}
