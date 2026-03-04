import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/widgets/dday_gift_popup.dart';

/// 테스트용 MonetizationNotifier (읽기 전용 + activateDdayUnlock 추적).
class _TestMonetizationNotifier extends MonetizationNotifier {
  _TestMonetizationNotifier(this._initialState);

  final MonetizationState _initialState;

  /// activateDdayUnlock 호출 기록.
  final List<({String date, String artist, String eventType})>
      ddayUnlockCalls = [];

  @override
  Future<MonetizationState> build() async => _initialState;

  @override
  Future<bool> activateDdayUnlock({
    required String date,
    required String artist,
    required String eventType,
  }) async {
    ddayUnlockCalls.add((date: date, artist: artist, eventType: eventType));
    return true;
  }
}

void main() {
  const testEventName = '슈가 생일';
  const testDate = '2026-03-09';
  const testArtist = 'suga';
  const testEventType = 'birthday';

  /// 테스트용 위젯 빌더. 버튼 탭으로 팝업을 표시한다.
  Widget buildTestWidget({
    MonetizationState? monetizationState,
    _TestMonetizationNotifier? notifier,
  }) {
    final monState =
        monetizationState ?? const MonetizationState(honeymoonActive: false);
    final testNotifier = notifier ?? _TestMonetizationNotifier(monState);

    return ProviderScope(
      overrides: [
        monetizationNotifierProvider.overrideWith(() => testNotifier),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => showDdayGiftPopup(
                context,
                eventName: testEventName,
                date: testDate,
                artist: testArtist,
                eventType: testEventType,
              ),
              child: const Text('show'),
            ),
          ),
        ),
      ),
    );
  }

  group('DdayGiftPopup — display', () {
    testWidgets(
      'should display gift icon',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.card_giftcard), findsOneWidget);
      },
    );

    testWidgets(
      'should display event name in title',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        expect(
          find.text(UiStrings.ddayGiftTitle(testEventName)),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display gift message',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        expect(find.text(UiStrings.ddayGiftMessage), findsOneWidget);
      },
    );

    testWidgets(
      'should display accept button',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        expect(find.text(UiStrings.ddayGiftButton), findsOneWidget);
      },
    );

    testWidgets(
      'should have secondary color icon with size 48',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        final icon = tester.widget<Icon>(find.byIcon(Icons.card_giftcard));
        expect(icon.size, 48);
      },
    );
  });

  group('DdayGiftPopup — interaction', () {
    testWidgets(
      'should call activateDdayUnlock with correct params when accept tapped',
      (tester) async {
        final notifier = _TestMonetizationNotifier(
          const MonetizationState(honeymoonActive: false),
        );

        await tester.pumpWidget(buildTestWidget(notifier: notifier));
        await tester.pumpAndSettle();

        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        await tester.tap(find.text(UiStrings.ddayGiftButton));
        await tester.pumpAndSettle();

        expect(notifier.ddayUnlockCalls, hasLength(1));
        expect(notifier.ddayUnlockCalls.first.date, testDate);
        expect(notifier.ddayUnlockCalls.first.artist, testArtist);
        expect(notifier.ddayUnlockCalls.first.eventType, testEventType);
      },
    );

    testWidgets(
      'should dismiss dialog after accept tapped',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        // Verify dialog is showing
        expect(
          find.text(UiStrings.ddayGiftTitle(testEventName)),
          findsOneWidget,
        );

        await tester.tap(find.text(UiStrings.ddayGiftButton));
        await tester.pumpAndSettle();

        // Dialog should be dismissed
        expect(
          find.text(UiStrings.ddayGiftTitle(testEventName)),
          findsNothing,
        );
      },
    );

    testWidgets(
      'should not dismiss on barrier tap (barrierDismissible: false)',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        // Tap outside the dialog (on the barrier)
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        // Dialog should still be showing
        expect(
          find.text(UiStrings.ddayGiftTitle(testEventName)),
          findsOneWidget,
        );
      },
    );
  });

  group('DdayGiftPopup — animation', () {
    testWidgets(
      'should have scale and fade transitions wrapping AlertDialog',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('show'));
        // Pump a single frame to catch mid-animation state
        await tester.pump(const Duration(milliseconds: 100));

        // Verify that the AlertDialog is wrapped in FadeTransition + ScaleTransition
        // by finding transitions that are ancestors of the AlertDialog.
        expect(
          find.ancestor(
            of: find.byType(AlertDialog),
            matching: find.byType(FadeTransition),
          ),
          findsWidgets,
        );
        expect(
          find.ancestor(
            of: find.byType(AlertDialog),
            matching: find.byType(ScaleTransition),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should complete animation and show full dialog',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        // After animation completes, dialog content should be visible
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          find.text(UiStrings.ddayGiftTitle(testEventName)),
          findsOneWidget,
        );
      },
    );
  });

  group('showDdayGiftPopup', () {
    testWidgets(
      'should show dialog via showDdayGiftPopup function',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        expect(find.byType(DdayGiftPopup), findsOneWidget);
      },
    );
  });
}
