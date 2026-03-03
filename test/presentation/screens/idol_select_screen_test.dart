import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/core/entities/idol_group.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/screens/idol_select_screen.dart';

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

      // Enter member name
      await tester.enterText(
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

      // Clear the member text field (it was pre-populated)
      await tester.enterText(
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

      // Tap custom input tile
      await tester.tap(find.text(UiStrings.idolSelectOther));
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

      // Tap custom input tile
      await tester.tap(find.text(UiStrings.idolSelectOther));
      await tester.pumpAndSettle();

      // Enter custom group name
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == UiStrings.idolSelectOtherHint,
        ),
        'DaySix',
      );
      await tester.pumpAndSettle();

      // Enter member name
      await tester.enterText(
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

      // Tap custom input tile
      await tester.tap(find.text(UiStrings.idolSelectOther));
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
}
