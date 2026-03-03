import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/widgets/conversion_trigger_popup.dart';

void main() {
  late bool shopCalled;

  setUp(() {
    shopCalled = false;
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => FilledButton(
            onPressed: () => showConversionTriggerPopup(
              context,
              onViewShop: () => shopCalled = true,
            ),
            child: const Text('trigger'),
          ),
        ),
      ),
    );
  }

  group('ConversionTriggerPopup — display', () {
    testWidgets('should display icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('should display title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.conversionTriggerTitle), findsOneWidget);
    });

    testWidgets('should display message', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.conversionTriggerMessage), findsOneWidget);
    });

    testWidgets('should display CTA button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.conversionTriggerButton), findsOneWidget);
    });

    testWidgets('should display dismiss button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.conversionTriggerDismiss), findsOneWidget);
    });
  });

  group('ConversionTriggerPopup — interaction', () {
    testWidgets('should call onViewShop when CTA tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(UiStrings.conversionTriggerButton));
      await tester.pumpAndSettle();

      expect(shopCalled, true);
    });

    testWidgets('should dismiss dialog when CTA tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(UiStrings.conversionTriggerButton));
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.conversionTriggerTitle), findsNothing);
    });

    testWidgets('should dismiss dialog when dismiss tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(UiStrings.conversionTriggerDismiss));
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.conversionTriggerTitle), findsNothing);
    });

    testWidgets('should not call onViewShop when dismiss tapped',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(UiStrings.conversionTriggerDismiss));
      await tester.pumpAndSettle();

      expect(shopCalled, false);
    });

    testWidgets('should dismiss on barrier tap', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      // Tap outside the dialog
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.conversionTriggerTitle), findsNothing);
    });
  });
}
