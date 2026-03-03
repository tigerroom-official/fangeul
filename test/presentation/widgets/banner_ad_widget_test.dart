import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/session_state_provider.dart';
import 'package:fangeul/presentation/widgets/banner_ad_widget.dart';

void main() {
  /// 테스트용 위젯 빌더.
  ///
  /// BannerAd는 네이티브 SDK가 필요하므로 테스트 환경에서 로드 불가.
  /// Provider override로 조건부 표시 로직만 검증한다.
  Widget buildTestWidget({
    bool isHoneymoon = false,
    bool isRewardedUnlockActive = false,
    bool sessionBannerHidden = false,
    MonetizationState? monetizationState,
  }) {
    final monState =
        monetizationState ?? const MonetizationState(honeymoonActive: false);

    return ProviderScope(
      overrides: [
        isHoneymoonProvider.overrideWithValue(isHoneymoon),
        isRewardedUnlockActiveProvider
            .overrideWithValue(isRewardedUnlockActive),
        sessionBannerHiddenProvider.overrideWith(() {
          final notifier = _TestSessionBannerHidden(sessionBannerHidden);
          return notifier;
        }),
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

  group('BannerAdWidget — hide conditions', () {
    testWidgets(
      'should render SizedBox.shrink when honeymoon is active',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(isHoneymoon: true));
        await tester.pump();

        // SizedBox.shrink has 0x0 dimensions
        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final shrink = sizedBoxes.where(
          (sb) => sb.width == 0.0 && sb.height == 0.0,
        );
        expect(shrink, isNotEmpty);
      },
    );

    testWidgets(
      'should render SizedBox.shrink when rewarded unlock is active',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(isRewardedUnlockActive: true),
        );
        await tester.pump();

        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final shrink = sizedBoxes.where(
          (sb) => sb.width == 0.0 && sb.height == 0.0,
        );
        expect(shrink, isNotEmpty);
      },
    );

    testWidgets(
      'should render SizedBox.shrink when session banner is hidden',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(sessionBannerHidden: true),
        );
        await tester.pump();

        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final shrink = sizedBoxes.where(
          (sb) => sb.width == 0.0 && sb.height == 0.0,
        );
        expect(shrink, isNotEmpty);
      },
    );

    testWidgets(
      'should render SizedBox.shrink when user has purchased a pack',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(
          monetizationState: const MonetizationState(
            honeymoonActive: false,
            purchasedPackIds: ['color_pack_01'],
          ),
        ));
        await tester.pump();

        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final shrink = sizedBoxes.where(
          (sb) => sb.width == 0.0 && sb.height == 0.0,
        );
        expect(shrink, isNotEmpty);
      },
    );

    testWidgets(
      'should render SizedBox.shrink when multiple hide conditions are true',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(
          isHoneymoon: true,
          sessionBannerHidden: true,
          monetizationState: const MonetizationState(
            honeymoonActive: true,
            purchasedPackIds: ['pack_01'],
          ),
        ));
        await tester.pump();

        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final shrink = sizedBoxes.where(
          (sb) => sb.width == 0.0 && sb.height == 0.0,
        );
        expect(shrink, isNotEmpty);
      },
    );
  });

  group('BannerAdWidget — show conditions', () {
    testWidgets(
      'should render 50dp placeholder when no hide condition and ad not loaded',
      (tester) async {
        // No hide conditions active, but BannerAd cannot load in test env
        // so we expect the placeholder SizedBox(height: 50)
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final placeholder = sizedBoxes.where(
          (sb) => sb.height == 50.0 && sb.width == null,
        );
        expect(placeholder, isNotEmpty);
      },
    );

    testWidgets(
      'should render 50dp placeholder when no purchases and no honeymoon',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(
          monetizationState: const MonetizationState(
            honeymoonActive: false,
            purchasedPackIds: [],
          ),
        ));
        await tester.pump();

        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final placeholder = sizedBoxes.where(
          (sb) => sb.height == 50.0 && sb.width == null,
        );
        expect(placeholder, isNotEmpty);
      },
    );
  });
}

/// 테스트용 SessionBannerHidden Notifier.
class _TestSessionBannerHidden extends SessionBannerHidden {
  _TestSessionBannerHidden(this._initialValue);

  final bool _initialValue;

  @override
  bool build() => _initialValue;
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
