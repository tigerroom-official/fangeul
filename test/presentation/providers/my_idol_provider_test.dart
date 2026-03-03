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

    test(
        'should keep select value when called before build completes '
        '(race condition)', () async {
      // 온보딩 시나리오: provider가 처음 접근되는 시점에 select()도 동시 호출
      // build()가 비동기로 실행 중인데 select()로 상태를 바꾸면
      // build() 완료 시 null로 덮어쓰는 race condition 재현
      final notifier = container.read(myIdolNotifierProvider.notifier);
      // build 완료를 기다리지 않고 바로 select (실제 UI 흐름)
      await notifier.select('custom:DaySix');

      // 모든 비동기 작업 완료 대기
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final result = await container.read(myIdolNotifierProvider.future);
      expect(result, 'custom:DaySix');
    });

    test('should not let build overwrite select with stale value', () async {
      // build()가 'old_value' 반환, select()가 'new_value' 설정
      // build() 완료 후에도 select()의 값이 유지되어야 함
      SharedPreferences.setMockInitialValues({'my_idol_group_id': 'old_value'});

      final container2 = ProviderContainer();
      addTearDown(() => container2.dispose());

      final notifier = container2.read(myIdolNotifierProvider.notifier);
      // build 완료를 기다리지 않고 바로 다른 값으로 select
      await notifier.select('custom:DaySix');

      // 마이크로태스크 소진 (build 완료 대기)
      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      final result = await container2.read(myIdolNotifierProvider.future);
      // build()가 'old_value'를 반환해도 select()의 'custom:DaySix'가 유지되어야 함
      expect(result, 'custom:DaySix');
    });

    test('should return custom display name for custom input', () async {
      // myIdolDisplayNameProvider가 'custom:DaySix'를 올바르게 처리하는지 검증
      final notifier = container.read(myIdolNotifierProvider.notifier);
      await container.read(myIdolNotifierProvider.future);
      await notifier.select('custom:DaySix');

      final displayName =
          await container.read(myIdolDisplayNameProvider.future);
      expect(displayName, 'DaySix');
    });

    group('Member name', () {
      test('should return null member name when not set', () async {
        final result =
            await container.read(myIdolMemberNameProvider.future);
        expect(result, isNull);
      });

      test('should save and return member name after selectMember', () async {
        final notifier = container.read(myIdolNotifierProvider.notifier);
        await container.read(myIdolNotifierProvider.future);
        await notifier.select('bts');
        await notifier.selectMember('정국');
        final result =
            await container.read(myIdolMemberNameProvider.future);
        expect(result, '정국');
      });

      test('should persist member name to SharedPreferences', () async {
        final notifier = container.read(myIdolNotifierProvider.notifier);
        await container.read(myIdolNotifierProvider.future);
        await notifier.select('bts');
        await notifier.selectMember('원필');
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('my_idol_member_name'), '원필');
      });

      test('should clear member name', () async {
        final notifier = container.read(myIdolNotifierProvider.notifier);
        await container.read(myIdolNotifierProvider.future);
        await notifier.select('bts');
        await notifier.selectMember('정국');
        await notifier.clearMember();
        final result =
            await container.read(myIdolMemberNameProvider.future);
        expect(result, isNull);
      });

      test('should clear member name when group is cleared', () async {
        final notifier = container.read(myIdolNotifierProvider.notifier);
        await container.read(myIdolNotifierProvider.future);
        await notifier.select('bts');
        await notifier.selectMember('정국');
        await notifier.clear();
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('my_idol_member_name'), isNull);
      });

      test('should return null member when group is not set', () async {
        SharedPreferences.setMockInitialValues({
          'my_idol_member_name': '정국',
        });
        final container2 = ProviderContainer();
        addTearDown(() => container2.dispose());
        final result =
            await container2.read(myIdolMemberNameProvider.future);
        expect(result, isNull);
      });

      test('should load persisted member name on rebuild', () async {
        SharedPreferences.setMockInitialValues({
          'my_idol_group_id': 'bts',
          'my_idol_member_name': '정국',
        });
        final container2 = ProviderContainer();
        addTearDown(() => container2.dispose());
        final result =
            await container2.read(myIdolMemberNameProvider.future);
        expect(result, '정국');
      });

      test('should not save member name without group set', () async {
        final notifier = container.read(myIdolNotifierProvider.notifier);
        await container.read(myIdolNotifierProvider.future);

        // 그룹 미설정 상태에서 멤버 저장 시도
        await notifier.selectMember('정국');

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('my_idol_member_name'), isNull);
      });
    });
  });
}
