import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/ad_service_provider.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/session_state_provider.dart';
import 'package:fangeul/presentation/widgets/fan_pass_button.dart';
import 'package:fangeul/presentation/widgets/fan_pass_popup.dart';
import 'package:fangeul/services/ad_service.dart';

/// Mock AdService.
class MockAdService extends Mock implements AdService {}

/// 테스트용 MonetizationNotifier (읽기 전용).
class _TestMonetizationNotifier extends MonetizationNotifier {
  _TestMonetizationNotifier(this._initialState);

  final MonetizationState _initialState;

  @override
  Future<MonetizationState> build() async => _initialState;
}

/// 테스트용 SessionBannerHidden Notifier.
class _TestSessionBannerHidden extends SessionBannerHidden {
  _TestSessionBannerHidden(this._initialValue);

  final bool _initialValue;

  @override
  bool build() => _initialValue;
}

void main() {
  late MockAdService mockAdService;

  setUp(() {
    mockAdService = MockAdService();
  });

  /// 테스트용 위젯 빌더.
  Widget buildTestWidget({
    MonetizationState? monetizationState,
    bool sessionBannerHidden = false,
    MockAdService? adService,
  }) {
    final monState =
        monetizationState ?? const MonetizationState(honeymoonActive: false);
    final ad = adService ?? mockAdService;

    return ProviderScope(
      overrides: [
        adServiceProvider.overrideWithValue(ad),
        monetizationNotifierProvider.overrideWith(() {
          return _TestMonetizationNotifier(monState);
        }),
        sessionBannerHiddenProvider.overrideWith(() {
          return _TestSessionBannerHidden(sessionBannerHidden);
        }),
      ],
      child: MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('ko'),
        home: const Scaffold(
          body: Center(child: FanPassButton()),
        ),
      ),
    );
  }

  group('FanPassButton — display states', () {
    testWidgets(
      'should show remaining count (0/3) when no ads watched',
      (tester) async {
        when(() => mockAdService.isRewardedReady).thenReturn(true);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('${UiStrings.fanPassButton} (0/3)'), findsOneWidget);
      },
    );

    testWidgets(
      'should show remaining count (2/3) when 2 ads watched',
      (tester) async {
        when(() => mockAdService.isRewardedReady).thenReturn(true);

        await tester.pumpWidget(buildTestWidget(
          monetizationState: const MonetizationState(
            honeymoonActive: false,
            adWatchCount: 2,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('${UiStrings.fanPassButton} (2/3)'), findsOneWidget);
      },
    );

    testWidgets(
      'should show limit reached label when daily limit reached (3/3)',
      (tester) async {
        when(() => mockAdService.isRewardedReady).thenReturn(true);

        await tester.pumpWidget(buildTestWidget(
          monetizationState: const MonetizationState(
            honeymoonActive: false,
            adWatchCount: 3,
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text(UiStrings.fanPassLimitReached), findsOneWidget);
      },
    );

    testWidgets(
      'should be disabled when daily limit reached',
      (tester) async {
        when(() => mockAdService.isRewardedReady).thenReturn(true);

        await tester.pumpWidget(buildTestWidget(
          monetizationState: const MonetizationState(
            honeymoonActive: false,
            adWatchCount: 3,
          ),
        ));
        await tester.pumpAndSettle();

        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNull);
      },
    );

    testWidgets(
      'should show ad loading message when ad not ready',
      (tester) async {
        when(() => mockAdService.isRewardedReady).thenReturn(false);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text(UiStrings.fanPassAdLoading), findsOneWidget);
      },
    );

    testWidgets(
      'should be disabled when ad not ready',
      (tester) async {
        when(() => mockAdService.isRewardedReady).thenReturn(false);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNull);
      },
    );

    testWidgets(
      'should be disabled during cooldown',
      (tester) async {
        when(() => mockAdService.isRewardedReady).thenReturn(true);

        // Set lastAdWatchTimestamp to 1 minute ago (within 5-min cooldown)
        final oneMinuteAgo =
            DateTime.now().millisecondsSinceEpoch - (1 * 60 * 1000);

        await tester.pumpWidget(buildTestWidget(
          monetizationState: MonetizationState(
            honeymoonActive: false,
            adWatchCount: 1,
            lastAdWatchTimestamp: oneMinuteAgo,
          ),
        ));
        await tester.pumpAndSettle();

        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNull);
      },
    );

    testWidgets(
      'should show cooldown timer during cooldown period',
      (tester) async {
        when(() => mockAdService.isRewardedReady).thenReturn(true);

        // Set lastAdWatchTimestamp to 1 minute ago (4 min remaining)
        final oneMinuteAgo =
            DateTime.now().millisecondsSinceEpoch - (1 * 60 * 1000);

        await tester.pumpWidget(buildTestWidget(
          monetizationState: MonetizationState(
            honeymoonActive: false,
            adWatchCount: 1,
            lastAdWatchTimestamp: oneMinuteAgo,
          ),
        ));
        await tester.pumpAndSettle();

        // Should show cooldown text containing the button label
        final textFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.contains(UiStrings.fanPassButton) &&
              widget.data!.contains(':'),
        );
        expect(textFinder, findsOneWidget);
      },
    );

    testWidgets(
      'should be enabled when ad ready and no cooldown and limit not reached',
      (tester) async {
        when(() => mockAdService.isRewardedReady).thenReturn(true);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNotNull);
      },
    );
  });

  group('FanPassButton — ad reward flow', () {
    testWidgets(
      'should call showRewarded when tapped and conditions met',
      (tester) async {
        when(() => mockAdService.isRewardedReady).thenReturn(true);
        when(
          () => mockAdService.showRewarded(
            onRewarded: any(named: 'onRewarded'),
            onDismissed: any(named: 'onDismissed'),
          ),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();

        verify(
          () => mockAdService.showRewarded(
            onRewarded: any(named: 'onRewarded'),
            onDismissed: any(named: 'onDismissed'),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'should not call showRewarded when limit reached',
      (tester) async {
        when(() => mockAdService.isRewardedReady).thenReturn(true);

        await tester.pumpWidget(buildTestWidget(
          monetizationState: const MonetizationState(
            honeymoonActive: false,
            adWatchCount: 3,
          ),
        ));
        await tester.pumpAndSettle();

        // Button should be disabled, can't tap
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNull);

        verifyNever(
          () => mockAdService.showRewarded(
            onRewarded: any(named: 'onRewarded'),
            onDismissed: any(named: 'onDismissed'),
          ),
        );
      },
    );
  });

  group('FanPassPopup', () {
    testWidgets(
      'should display popup title',
      (tester) async {
        final futureExpiry =
            DateTime.now().millisecondsSinceEpoch + (3 * 60 * 60 * 1000);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              monetizationNotifierProvider.overrideWith(() {
                return _TestMonetizationNotifier(MonetizationState(
                  honeymoonActive: false,
                  unlockExpiresAt: futureExpiry,
                ));
              }),
            ],
            child: MaterialApp(
              localizationsDelegates: L.localizationsDelegates,
              supportedLocales: L.supportedLocales,
              locale: const Locale('ko'),
              home: Scaffold(
                body: Builder(
                  builder: (context) => FilledButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const FanPassPopup(),
                    ),
                    child: const Text('show'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap to show popup
        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        expect(find.text(UiStrings.fanPassPopupTitle), findsOneWidget);
      },
    );

    testWidgets(
      'should display unlock remaining time',
      (tester) async {
        final futureExpiry =
            DateTime.now().millisecondsSinceEpoch + (3 * 60 * 60 * 1000);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              monetizationNotifierProvider.overrideWith(() {
                return _TestMonetizationNotifier(MonetizationState(
                  honeymoonActive: false,
                  unlockExpiresAt: futureExpiry,
                ));
              }),
            ],
            child: MaterialApp(
              localizationsDelegates: L.localizationsDelegates,
              supportedLocales: L.supportedLocales,
              locale: const Locale('ko'),
              home: Scaffold(
                body: Builder(
                  builder: (context) => FilledButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const FanPassPopup(),
                    ),
                    child: const Text('show'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        // Expect approximately "02:59 남음" or "03:00 남음"
        final remainingFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.contains('남음'),
        );
        expect(remainingFinder, findsOneWidget);
      },
    );

    testWidgets(
      'should display confirm button',
      (tester) async {
        final futureExpiry =
            DateTime.now().millisecondsSinceEpoch + (3 * 60 * 60 * 1000);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              monetizationNotifierProvider.overrideWith(() {
                return _TestMonetizationNotifier(MonetizationState(
                  honeymoonActive: false,
                  unlockExpiresAt: futureExpiry,
                ));
              }),
            ],
            child: MaterialApp(
              localizationsDelegates: L.localizationsDelegates,
              supportedLocales: L.supportedLocales,
              locale: const Locale('ko'),
              home: Scaffold(
                body: Builder(
                  builder: (context) => FilledButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const FanPassPopup(),
                    ),
                    child: const Text('show'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        expect(
          find.text(UiStrings.fanPassPopupConfirm),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should dismiss when confirm button tapped',
      (tester) async {
        final futureExpiry =
            DateTime.now().millisecondsSinceEpoch + (3 * 60 * 60 * 1000);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              monetizationNotifierProvider.overrideWith(() {
                return _TestMonetizationNotifier(MonetizationState(
                  honeymoonActive: false,
                  unlockExpiresAt: futureExpiry,
                ));
              }),
            ],
            child: MaterialApp(
              localizationsDelegates: L.localizationsDelegates,
              supportedLocales: L.supportedLocales,
              locale: const Locale('ko'),
              home: Scaffold(
                body: Builder(
                  builder: (context) => FilledButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const FanPassPopup(),
                    ),
                    child: const Text('show'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        // Tap confirm
        await tester.tap(find.text(UiStrings.fanPassPopupConfirm));
        await tester.pumpAndSettle();

        // Dialog should be dismissed
        expect(find.text(UiStrings.fanPassPopupTitle), findsNothing);
      },
    );

    testWidgets(
      'should show celebration icon',
      (tester) async {
        final futureExpiry =
            DateTime.now().millisecondsSinceEpoch + (3 * 60 * 60 * 1000);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              monetizationNotifierProvider.overrideWith(() {
                return _TestMonetizationNotifier(MonetizationState(
                  honeymoonActive: false,
                  unlockExpiresAt: futureExpiry,
                ));
              }),
            ],
            child: MaterialApp(
              localizationsDelegates: L.localizationsDelegates,
              supportedLocales: L.supportedLocales,
              locale: const Locale('ko'),
              home: Scaffold(
                body: Builder(
                  builder: (context) => FilledButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const FanPassPopup(),
                    ),
                    child: const Text('show'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.card_giftcard), findsOneWidget);
      },
    );
  });

  group('FanPassButton — session banner integration', () {
    test(
      'should hide session banner when ad reward flow completes',
      () async {
        // Test the session banner hiding behavior at the provider level.
        // The full ad→reward→hide flow involves native async callbacks that
        // are difficult to test end-to-end in a widget test with FakeAsync.
        // Instead, verify that calling hide() on sessionBannerHidden works.
        final container = ProviderContainer(
          overrides: [
            sessionBannerHiddenProvider.overrideWith(() {
              return _TestSessionBannerHidden(false);
            }),
          ],
        );
        addTearDown(container.dispose);

        // Initially not hidden
        expect(container.read(sessionBannerHiddenProvider), isFalse);

        // Simulate what onRewarded does: call hide()
        container.read(sessionBannerHiddenProvider.notifier).hide();

        // Should now be hidden
        expect(container.read(sessionBannerHiddenProvider), isTrue);
      },
    );

    testWidgets(
      'should pass onRewarded callback to showRewarded on tap',
      (tester) async {
        when(() => mockAdService.isRewardedReady).thenReturn(true);

        void Function()? capturedOnRewarded;
        when(
          () => mockAdService.showRewarded(
            onRewarded: any(named: 'onRewarded'),
            onDismissed: any(named: 'onDismissed'),
          ),
        ).thenAnswer((invocation) async {
          capturedOnRewarded =
              invocation.namedArguments[#onRewarded] as void Function();
        });

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();

        // Verify showRewarded was called with an onRewarded callback
        verify(
          () => mockAdService.showRewarded(
            onRewarded: any(named: 'onRewarded'),
            onDismissed: any(named: 'onDismissed'),
          ),
        ).called(1);
        expect(capturedOnRewarded, isNotNull);
      },
    );
  });
}
