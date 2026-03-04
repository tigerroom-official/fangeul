import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/core/entities/idol_group.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/screens/idol_select_screen.dart';
import 'package:fangeul/presentation/widgets/multi_mode_keyboard.dart';

const _testGroups = [
  IdolGroup(id: 'bts', nameEn: 'BTS', nameKo: '방탄소년단'),
  IdolGroup(id: 'blackpink', nameEn: 'BLACKPINK', nameKo: '블랙핑크'),
];

Widget _buildTestWidget({
  bool isOnboarding = false,
  Map<String, Object> initialPrefs = const {},
}) {
  SharedPreferences.setMockInitialValues(initialPrefs);
  return ProviderScope(
    overrides: [
      availableGroupsProvider.overrideWith((_) async => _testGroups),
    ],
    child: MaterialApp(
      home: IdolSelectScreen(isOnboarding: isOnboarding),
    ),
  );
}

/// readOnly TextField에 controller로 직접 텍스트를 설정하는 헬퍼.
void _setTextFieldValue(WidgetTester tester, Finder finder, String text) {
  final textField = tester.widget<TextField>(finder);
  textField.controller?.text = text;
}

void main() {
  group('IdolSelectScreen member input', () {
    testWidgets('should not show member input before group selected',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Member input should not be visible
      expect(find.text(UiStrings.idolMemberHint), findsNothing);
      // Confirm button should not be visible either
      expect(
        find.widgetWithText(FilledButton, UiStrings.idolSelectConfirm),
        findsNothing,
      );
    });

    testWidgets('should show member input after group selected',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Tap BTS group
      await tester.tap(find.text('BTS'));
      await tester.pumpAndSettle();

      // Member input should now be visible
      expect(find.text(UiStrings.idolMemberHint), findsOneWidget);
    });

    testWidgets('should show confirm button after group selected',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Tap BTS group
      await tester.tap(find.text('BTS'));
      await tester.pumpAndSettle();

      // Confirm button should now be visible
      expect(
        find.widgetWithText(FilledButton, UiStrings.idolSelectConfirm),
        findsOneWidget,
      );
    });

    testWidgets('should not immediately navigate on group tap (non-onboarding)',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Tap BTS group — should NOT navigate away
      await tester.tap(find.text('BTS'));
      await tester.pumpAndSettle();

      // Still on the same screen
      expect(find.byType(IdolSelectScreen), findsOneWidget);
    });

    testWidgets('should save member name when entered and confirmed',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Tap BTS group
      await tester.tap(find.text('BTS'));
      await tester.pumpAndSettle();

      // Set member name via controller (readOnly TextField)
      _setTextFieldValue(
        tester,
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == UiStrings.idolMemberHint,
        ),
        '정국',
      );
      await tester.pumpAndSettle();

      // Tap confirm button
      await tester.tap(
        find.widgetWithText(FilledButton, UiStrings.idolSelectConfirm),
      );
      await tester.pumpAndSettle();

      // Verify member name was saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('my_idol_member_name'), '정국');
      expect(prefs.getString('my_idol_group_id'), 'bts');
    });

    testWidgets('should clear member name when confirmed without input',
        (tester) async {
      // Start with a pre-existing member name
      await tester.pumpWidget(_buildTestWidget(
        initialPrefs: {
          'my_idol_group_id': 'bts',
          'my_idol_member_name': '정국',
        },
      ));
      await tester.pumpAndSettle();

      // Tap BTS group
      await tester.tap(find.text('BTS'));
      await tester.pumpAndSettle();

      // Clear the member text field via controller
      _setTextFieldValue(
        tester,
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == UiStrings.idolMemberHint,
        ),
        '',
      );
      await tester.pumpAndSettle();

      // Tap confirm button
      await tester.tap(
        find.widgetWithText(FilledButton, UiStrings.idolSelectConfirm),
      );
      await tester.pumpAndSettle();

      // Verify member name was cleared
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('my_idol_member_name'), isNull);
    });

    testWidgets('should pre-populate member name from prefs', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        initialPrefs: {
          'my_idol_group_id': 'bts',
          'my_idol_member_name': '원필',
        },
      ));
      await tester.pumpAndSettle();

      // Select BTS to show the member input
      await tester.tap(find.text('BTS'));
      await tester.pumpAndSettle();

      // The member TextField should be pre-populated
      final textField = tester.widget<TextField>(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == UiStrings.idolMemberHint,
        ),
      );
      expect(textField.controller?.text, '원필');
    });

    testWidgets('should show member input when custom input selected',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Tap custom input tile → 키보드 표시됨
      await tester.tap(find.text(UiStrings.idolSelectOther));
      await tester.pumpAndSettle();

      // 키보드 닫아서 ListView 전체 보이게
      await tester.tap(find.text(UiStrings.keyboardDone));
      await tester.pumpAndSettle();

      // Member input should be visible
      expect(find.text(UiStrings.idolMemberHint), findsOneWidget);
      // Confirm button should be visible
      expect(
        find.widgetWithText(FilledButton, UiStrings.idolSelectConfirm),
        findsOneWidget,
      );
    });

    testWidgets('should save custom group with member name', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Tap custom input tile → 키보드 표시됨
      await tester.tap(find.text(UiStrings.idolSelectOther));
      await tester.pumpAndSettle();

      // 키보드 닫고 controller 직접 설정 (테스트 편의)
      await tester.tap(find.text(UiStrings.keyboardDone));
      await tester.pumpAndSettle();

      // Set custom group name via controller
      _setTextFieldValue(
        tester,
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == UiStrings.idolSelectOtherHint,
        ),
        'DaySix',
      );

      // Set member name via controller
      _setTextFieldValue(
        tester,
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == UiStrings.idolMemberHint,
        ),
        '원필',
      );
      await tester.pumpAndSettle();

      // Tap confirm button
      await tester.tap(
        find.widgetWithText(FilledButton, UiStrings.idolSelectConfirm),
      );
      await tester.pumpAndSettle();

      // Verify both saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('my_idol_group_id'), 'custom:DaySix');
      expect(prefs.getString('my_idol_member_name'), '원필');
    });

    testWidgets('should not confirm custom input with empty group name',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Tap custom input tile → 키보드 표시됨
      await tester.tap(find.text(UiStrings.idolSelectOther));
      await tester.pumpAndSettle();

      // 키보드 닫아서 확인 버튼 접근 가능하게
      await tester.tap(find.text(UiStrings.keyboardDone));
      await tester.pumpAndSettle();

      // Don't enter group name — just tap confirm
      await tester.tap(
        find.widgetWithText(FilledButton, UiStrings.idolSelectConfirm),
      );
      await tester.pumpAndSettle();

      // Should still be on the screen (no navigation)
      expect(find.byType(IdolSelectScreen), findsOneWidget);

      // Nothing should be saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('my_idol_group_id'), isNull);
    });

    testWidgets('should show member input with person icon', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Tap BTS group
      await tester.tap(find.text('BTS'));
      await tester.pumpAndSettle();

      // Should have person outline icon as prefix
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets(
        'should show skip button in onboarding mode with member input visible',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(isOnboarding: true));
      await tester.pumpAndSettle();

      // Tap BTS group
      await tester.tap(find.text('BTS'));
      await tester.pumpAndSettle();

      // Skip button should still be visible
      expect(find.text(UiStrings.idolSelectSkip), findsOneWidget);
      // Confirm button should also be visible
      expect(
        find.widgetWithText(FilledButton, UiStrings.idolSelectConfirm),
        findsOneWidget,
      );
    });
  });

  group('IdolSelectScreen state restoration', () {
    testWidgets('should restore custom group name from prefs', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        initialPrefs: {
          'my_idol_group_id': 'custom:DaySix',
        },
      ));
      await tester.pumpAndSettle();

      // 커스텀 입력 타일이 활성화되고 그룹명이 복원됨
      final textField = tester.widget<TextField>(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == UiStrings.idolSelectOtherHint,
        ),
      );
      expect(textField.controller?.text, 'DaySix');
    });

    testWidgets('should restore preset group selection from prefs',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        initialPrefs: {
          'my_idol_group_id': 'bts',
        },
      ));
      await tester.pumpAndSettle();

      // BTS가 선택 상태 (체크 아이콘 표시)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      // 멤버 입력/확인 버튼 표시
      expect(find.text(UiStrings.idolMemberHint), findsOneWidget);
    });

    testWidgets('should restore both custom group and member from prefs',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        initialPrefs: {
          'my_idol_group_id': 'custom:DaySix',
          'my_idol_member_name': '원필',
        },
      ));
      await tester.pumpAndSettle();

      // 커스텀 그룹명 복원
      final customField = tester.widget<TextField>(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == UiStrings.idolSelectOtherHint,
        ),
      );
      expect(customField.controller?.text, 'DaySix');

      // 멤버명 복원
      final memberField = tester.widget<TextField>(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == UiStrings.idolMemberHint,
        ),
      );
      expect(memberField.controller?.text, '원필');
    });
  });

  group('IdolSelectScreen keyboard integration', () {
    testWidgets('should show keyboard when custom input tapped',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // 키보드 없음
      expect(find.byType(MultiModeKeyboard), findsNothing);

      // 커스텀 입력 탭
      await tester.tap(find.text(UiStrings.idolSelectOther));
      await tester.pumpAndSettle();

      // 키보드 표시됨
      expect(find.byType(MultiModeKeyboard), findsOneWidget);
    });

    testWidgets('should show keyboard when member field tapped',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // 그룹 선택
      await tester.tap(find.text('BTS'));
      await tester.pumpAndSettle();

      // 멤버 필드 탭
      await tester.tap(find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            w.decoration?.hintText == UiStrings.idolMemberHint,
      ));
      await tester.pumpAndSettle();

      // 키보드 표시됨
      expect(find.byType(MultiModeKeyboard), findsOneWidget);
    });

    testWidgets('should hide keyboard when preset group selected',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // 커스텀 입력 → 키보드 표시
      await tester.tap(find.text(UiStrings.idolSelectOther));
      await tester.pumpAndSettle();
      expect(find.byType(MultiModeKeyboard), findsOneWidget);

      // 프리셋 그룹 선택 → 키보드 해제
      await tester.tap(find.text('BTS'));
      await tester.pumpAndSettle();
      expect(find.byType(MultiModeKeyboard), findsNothing);
    });

    testWidgets('should hide keyboard when done button tapped',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // 커스텀 입력 → 키보드 표시
      await tester.tap(find.text(UiStrings.idolSelectOther));
      await tester.pumpAndSettle();
      expect(find.byType(MultiModeKeyboard), findsOneWidget);

      // 완료 버튼 탭 → 키보드 해제
      await tester.tap(find.text(UiStrings.keyboardDone));
      await tester.pumpAndSettle();
      expect(find.byType(MultiModeKeyboard), findsNothing);
    });

    testWidgets('should make TextFields readOnly', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // 커스텀 입력 탭
      await tester.tap(find.text(UiStrings.idolSelectOther));
      await tester.pumpAndSettle();

      // 커스텀 필드는 readOnly
      final customField = tester.widget<TextField>(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == UiStrings.idolSelectOtherHint,
        ),
      );
      expect(customField.readOnly, true);

      // 멤버 필드도 readOnly
      final memberField = tester.widget<TextField>(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == UiStrings.idolMemberHint,
        ),
      );
      expect(memberField.readOnly, true);
    });

    testWidgets(
        'should preserve existing text when field tapped then done without edit',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        initialPrefs: {
          'my_idol_group_id': 'custom:DaySix',
          'my_idol_member_name': '원필',
        },
      ));
      await tester.pumpAndSettle();

      // 커스텀 필드 탭 → 키보드 표시
      await tester.tap(find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            w.decoration?.hintText == UiStrings.idolSelectOtherHint,
      ));
      await tester.pumpAndSettle();

      // 아무것도 입력하지 않고 완료
      await tester.tap(find.text(UiStrings.keyboardDone));
      await tester.pumpAndSettle();

      // 텍스트 보존 확인
      final customField = tester.widget<TextField>(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == UiStrings.idolSelectOtherHint,
        ),
      );
      expect(customField.controller?.text, 'DaySix');

      // 멤버 필드도 보존
      final memberField = tester.widget<TextField>(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == UiStrings.idolMemberHint,
        ),
      );
      expect(memberField.controller?.text, '원필');
    });
  });
}
