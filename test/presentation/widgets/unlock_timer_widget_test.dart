import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/widgets/unlock_timer_widget.dart';

void main() {
  /// 테스트용 위젯 빌더.
  ///
  /// [unlockExpiresAt] 밀리초 타임스탬프로 해금 만료 시각을 설정한다.
  Widget buildTestWidget({int unlockExpiresAt = 0}) {
    final monState = MonetizationState(
      honeymoonActive: false,
      unlockExpiresAt: unlockExpiresAt,
    );

    return ProviderScope(
      overrides: [
        monetizationNotifierProvider.overrideWith(() {
          return _TestMonetizationNotifier(monState);
        }),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: UnlockTimerWidget(),
        ),
      ),
    );
  }

  group('UnlockTimerWidget', () {
    testWidgets(
      'should show remaining time when unlock is active',
      (tester) async {
        // 2시간 후 만료 (오후 시간대 — 자정이 아님)
        final twoHoursFromNow =
            DateTime.now().millisecondsSinceEpoch + (2 * 60 * 60 * 1000);

        await tester.pumpWidget(buildTestWidget(
          unlockExpiresAt: twoHoursFromNow,
        ));
        await tester.pump(); // AsyncNotifier 로드 대기

        // 타이머 아이콘 확인
        expect(find.byIcon(Icons.timer_outlined), findsOneWidget);

        // '남음' 텍스트 포함 확인
        expect(find.textContaining('남음'), findsOneWidget);

        // 시간 형식: h:mm:ss (1시간 이상이므로)
        expect(find.textContaining(':'), findsOneWidget);
      },
    );

    testWidgets(
      'should show hh:mm:ss format when more than 1 hour remaining',
      (tester) async {
        // 정확히 3시간 30분 15초 후 만료
        final expiresAt = DateTime.now().millisecondsSinceEpoch +
            (3 * 60 * 60 * 1000) +
            (30 * 60 * 1000) +
            (15 * 1000);

        await tester.pumpWidget(buildTestWidget(
          unlockExpiresAt: expiresAt,
        ));
        await tester.pump();

        // 3:30:xx 형태 텍스트 존재 확인 (초는 타이밍에 따라 달라질 수 있음)
        expect(find.textContaining('3:30:'), findsOneWidget);
      },
    );

    testWidgets(
      'should show mm:ss format when less than 1 hour remaining',
      (tester) async {
        // 정확히 42분 15초 후 만료
        final expiresAt = DateTime.now().millisecondsSinceEpoch +
            (42 * 60 * 1000) +
            (15 * 1000);

        await tester.pumpWidget(buildTestWidget(
          unlockExpiresAt: expiresAt,
        ));
        await tester.pump();

        // 42:1x 형태 확인 (1시간 미만이므로 시간 부분 없음)
        final textFinder = find.textContaining('42:');
        expect(textFinder, findsOneWidget);

        // '남음' 포함 확인
        expect(find.textContaining('남음'), findsOneWidget);
      },
    );

    testWidgets(
      'should show nothing when no unlock is active (unlockExpiresAt = 0)',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(unlockExpiresAt: 0));
        await tester.pump();

        // 타이머 아이콘 없음
        expect(find.byIcon(Icons.timer_outlined), findsNothing);

        // '남음' 텍스트 없음
        expect(find.textContaining('남음'), findsNothing);

        // SizedBox.shrink 확인
        final sizedBoxes =
            tester.widgetList<SizedBox>(find.byType(SizedBox));
        final shrink = sizedBoxes.where(
          (sb) => sb.width == 0.0 && sb.height == 0.0,
        );
        expect(shrink, isNotEmpty);
      },
    );

    testWidgets(
      'should show nothing when unlock has expired',
      (tester) async {
        // 1시간 전에 이미 만료
        final expiredAt =
            DateTime.now().millisecondsSinceEpoch - (60 * 60 * 1000);

        await tester.pumpWidget(buildTestWidget(unlockExpiresAt: expiredAt));
        await tester.pump();

        // 타이머 아이콘 없음
        expect(find.byIcon(Icons.timer_outlined), findsNothing);
        expect(find.textContaining('남음'), findsNothing);

        // SizedBox.shrink 확인
        final sizedBoxes =
            tester.widgetList<SizedBox>(find.byType(SizedBox));
        final shrink = sizedBoxes.where(
          (sb) => sb.width == 0.0 && sb.height == 0.0,
        );
        expect(shrink, isNotEmpty);
      },
    );

    testWidgets(
      'should update display when timer ticks',
      (tester) async {
        // 5초 후 만료 — 짧은 시간으로 테스트
        final expiresAt =
            DateTime.now().millisecondsSinceEpoch + (5 * 1000);

        await tester.pumpWidget(buildTestWidget(
          unlockExpiresAt: expiresAt,
        ));
        await tester.pump(); // AsyncNotifier 로드 대기

        // 초기 상태: 남은 시간 표시
        expect(find.textContaining('남음'), findsOneWidget);
        expect(find.byIcon(Icons.timer_outlined), findsOneWidget);

        // 3초 경과 (타이머 3번 tick)
        for (int i = 0; i < 3; i++) {
          await tester.pump(const Duration(seconds: 1));
        }

        // 아직 남은 시간 있음 (~2초)
        expect(find.textContaining('남음'), findsOneWidget);

        // 추가 3초 경과 → 만료 (총 6초 > 5초 만료)
        for (int i = 0; i < 3; i++) {
          await tester.pump(const Duration(seconds: 1));
        }

        // 만료 → 아무것도 표시 안 함
        expect(find.textContaining('남음'), findsNothing);
        expect(find.byIcon(Icons.timer_outlined), findsNothing);
      },
    );

    testWidgets(
      'should show midnight expiry label when unlock expires at midnight',
      (tester) async {
        // 다음 자정 (00:00:00) 만료
        final now = DateTime.now();
        final nextMidnight = DateTime(now.year, now.month, now.day + 1);
        final midnightMs = nextMidnight.millisecondsSinceEpoch;

        await tester.pumpWidget(buildTestWidget(
          unlockExpiresAt: midnightMs,
        ));
        await tester.pump();

        // 자정에 만료 레이블 포함 확인
        expect(
          find.textContaining(UiStrings.unlockMidnightLabel),
          findsOneWidget,
        );
        expect(find.textContaining('남음'), findsOneWidget);
      },
    );

    testWidgets(
      'should not show midnight label when unlock expires at non-midnight time',
      (tester) async {
        // 내일 오후 2시 만료
        final now = DateTime.now();
        final nonMidnight =
            DateTime(now.year, now.month, now.day + 1, 14, 30);
        final expiresAt = nonMidnight.millisecondsSinceEpoch;

        await tester.pumpWidget(buildTestWidget(
          unlockExpiresAt: expiresAt,
        ));
        await tester.pump();

        // 자정에 만료 레이블 없음
        expect(
          find.textContaining(UiStrings.unlockMidnightLabel),
          findsNothing,
        );
        // 일반 남음 텍스트는 있음
        expect(find.textContaining('남음'), findsOneWidget);
      },
    );
  });
}

/// 테스트용 MonetizationNotifier.
///
/// 네이티브 SecureStorage를 우회하여 즉시 상태를 반환한다.
class _TestMonetizationNotifier extends MonetizationNotifier {
  _TestMonetizationNotifier(this._initialState);

  final MonetizationState _initialState;

  @override
  Future<MonetizationState> build() async => _initialState;
}
