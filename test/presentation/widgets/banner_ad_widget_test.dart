import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/core/entities/remote_config_values.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/onboarding_providers.dart';
import 'package:fangeul/presentation/providers/remote_config_providers.dart';
import 'package:fangeul/presentation/widgets/banner_ad_widget.dart';

/// 설치 N일 전 날짜 문자열 생성.
String _installDateDaysAgo(int days) {
  final date = DateTime.now().subtract(Duration(days: days));
  final y = date.year.toString();
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

void main() {
  /// 테스트용 위젯 빌더.
  ///
  /// BannerAd는 네이티브 SDK가 필요하므로 테스트 환경에서 로드 불가.
  /// Provider override로 조건부 표시 로직만 검증한다.
  Widget buildTestWidget({
    bool isOnboardingDone = true,
    int bannerDelayDays = 0,
    MonetizationState? monetizationState,
  }) {
    // 기본: 온보딩 완료 + 설치 10일 + 허니문 비활성 (배너 표시 상태)
    final monState = monetizationState ??
        MonetizationState(
          honeymoonActive: false,
          installDate: _installDateDaysAgo(10),
        );

    return ProviderScope(
      overrides: [
        isOnboardingDoneProvider.overrideWithValue(isOnboardingDone),
        remoteConfigValuesProvider.overrideWithValue(
          RemoteConfigValues(bannerDelayDays: bannerDelayDays),
        ),
        monetizationNotifierProvider.overrideWith(() {
          return _TestMonetizationNotifier(monState);
        }),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: BannerAdWidget(),
        ),
      ),
    );
  }

  // -- 헬퍼: SizedBox.shrink 존재 확인 ---------------------------------
  void expectShrink(WidgetTester tester) {
    final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
    final shrink = sizedBoxes.where(
      (sb) => sb.width == 0.0 && sb.height == 0.0,
    );
    expect(shrink, isNotEmpty);
  }

  // -- 헬퍼: 50dp placeholder 존재 확인 --------------------------------
  void expectPlaceholder(WidgetTester tester) {
    final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
    final placeholder = sizedBoxes.where(
      (sb) => sb.height == 50.0 && sb.width == null,
    );
    expect(placeholder, isNotEmpty);
  }

  group('BannerAdWidget — hide conditions', () {
    testWidgets(
      'should hide when onboarding is not done',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(isOnboardingDone: false),
        );
        await tester.pump();
        expectShrink(tester);
      },
    );

    testWidgets(
      'should hide when onboarding not done even with installDate set',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(
          isOnboardingDone: false,
          monetizationState: MonetizationState(
            honeymoonActive: false,
            installDate: _installDateDaysAgo(30),
          ),
        ));
        await tester.pump();
        expectShrink(tester);
      },
    );

    testWidgets(
      'should hide when daysSince < RC bannerDelayDays',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(
          bannerDelayDays: 5,
          monetizationState: MonetizationState(
            honeymoonActive: false,
            installDate: _installDateDaysAgo(3),
          ),
        ));
        await tester.pump();
        expectShrink(tester);
      },
    );

    testWidgets(
      'should hide when user has purchased theme picker IAP',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(
          monetizationState: MonetizationState(
            honeymoonActive: false,
            installDate: _installDateDaysAgo(10),
            hasThemePicker: true,
          ),
        ));
        await tester.pump();
        expectShrink(tester);
      },
    );

    testWidgets(
      'should hide when user has purchased theme slots IAP',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(
          monetizationState: MonetizationState(
            honeymoonActive: false,
            installDate: _installDateDaysAgo(10),
            hasThemeSlots: true,
          ),
        ));
        await tester.pump();
        expectShrink(tester);
      },
    );

    testWidgets(
      'should hide when multiple conditions combine',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(
          isOnboardingDone: false,
          monetizationState: MonetizationState(
            honeymoonActive: true,
            installDate: _installDateDaysAgo(2),
            hasThemeSlots: true,
          ),
        ));
        await tester.pump();
        expectShrink(tester);
      },
    );
  });

  group('BannerAdWidget — show conditions', () {
    testWidgets(
      'should show when onboarding done and RC delay 0',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();
        expectPlaceholder(tester);
      },
    );

    testWidgets(
      'should show when daysSince >= RC bannerDelayDays',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(
          bannerDelayDays: 3,
          monetizationState: MonetizationState(
            honeymoonActive: false,
            installDate: _installDateDaysAgo(5),
          ),
        ));
        await tester.pump();
        expectPlaceholder(tester);
      },
    );

    testWidgets(
      'should show when daysSince == RC bannerDelayDays',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(
          bannerDelayDays: 7,
          monetizationState: MonetizationState(
            honeymoonActive: false,
            installDate: _installDateDaysAgo(7),
          ),
        ));
        await tester.pump();
        expectPlaceholder(tester);
      },
    );

    testWidgets(
      'should show on Day 0 when onboarding done and RC delay is 0',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(
          monetizationState: MonetizationState(
            honeymoonActive: true,
            installDate: _installDateDaysAgo(0),
          ),
        ));
        await tester.pump();
        expectPlaceholder(tester);
      },
    );

    testWidgets(
      'should still show during theme trial (no longer hides banner)',
      (tester) async {
        final futureExpiry =
            DateTime.now().millisecondsSinceEpoch + (3 * 60 * 60 * 1000);
        await tester.pumpWidget(buildTestWidget(
          monetizationState: MonetizationState(
            honeymoonActive: false,
            installDate: _installDateDaysAgo(10),
            themeTrialExpiresAt: futureExpiry,
          ),
        ));
        await tester.pump();
        expectPlaceholder(tester);
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
