import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/data/models/color_pack.dart';
import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/color_pack_provider.dart';
import 'package:fangeul/presentation/providers/iap_provider.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/screens/shop_screen.dart';
import 'package:fangeul/services/iap_service.dart';

class MockIapService extends Mock implements IapService {}

/// 테스트용 MonetizationNotifier.
class _TestMonetizationNotifier extends MonetizationNotifier {
  _TestMonetizationNotifier(this._initialState);
  final MonetizationState _initialState;

  @override
  Future<MonetizationState> build() async => _initialState;
}

/// 테스트용 컬러 팩 데이터 — 2개만 사용하여 그리드 한 줄에 모두 표시.
const _testPacks = [
  ColorPack(
    id: 'purple_dream',
    nameKo: '퍼플 드림',
    nameEn: 'Purple Dream',
    primaryColor: '#A855F7',
    secondaryColor: '#7C3AED',
    skuId: 'fangeul_color_purple_dream',
    priceKrw: 1900,
    phraseCount: 50,
    pronunciationCount: 30,
  ),
  ColorPack(
    id: 'golden_hour',
    nameKo: '골든 아워',
    nameEn: 'Golden Hour',
    primaryColor: '#F59E0B',
    secondaryColor: '#D97706',
    skuId: 'fangeul_color_golden_hour',
    priceKrw: 1900,
    phraseCount: 50,
    pronunciationCount: 30,
  ),
];

/// 테스트용 위젯 빌더.
Widget _buildTestWidget({
  List<ColorPack> packs = _testPacks,
  List<String> purchasedPackIds = const [],
  MockIapService? mockIap,
}) {
  final iap = mockIap ?? MockIapService();
  final monState = MonetizationState(
    honeymoonActive: false,
    purchasedPackIds: purchasedPackIds,
  );

  return ProviderScope(
    overrides: [
      colorPacksProvider.overrideWith((_) async => packs),
      iapServiceProvider.overrideWithValue(iap),
      monetizationNotifierProvider.overrideWith(() {
        return _TestMonetizationNotifier(monState);
      }),
    ],
    child: const MaterialApp(
      home: ShopScreen(),
    ),
  );
}

void main() {
  group('ShopScreen', () {
    testWidgets('should display shop title in AppBar', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.shopTitle), findsOneWidget);
    });

    testWidgets('should display restore button in AppBar', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.restore), findsOneWidget);
    });

    testWidgets('should display all color pack names', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('퍼플 드림'), findsOneWidget);
      expect(find.text('골든 아워'), findsOneWidget);
    });

    testWidgets('should display phrase count for each pack', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.shopPhraseCount(50)), findsNWidgets(2));
    });

    testWidgets('should display pronunciation count for each pack',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.shopPronunciationCount(30)), findsNWidgets(2));
    });

    testWidgets('should display price on unpurchased packs', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Both packs at ₩1,900
      expect(find.textContaining('1,900'), findsNWidgets(2));
    });

    testWidgets('should display purchased badge for purchased packs',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        purchasedPackIds: ['fangeul_color_purple_dream'],
      ));
      await tester.pumpAndSettle();

      // 구매 완료 badge should appear for the purchased pack
      expect(find.text(UiStrings.shopPurchased), findsOneWidget);
      // Check icon indicates purchased
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should not show buy button for purchased packs',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        purchasedPackIds: ['fangeul_color_purple_dream'],
      ));
      await tester.pumpAndSettle();

      // Should only have 1 buy button (golden_hour),
      // since purple_dream is purchased
      final filledButtons = find.byType(FilledButton);
      expect(filledButtons, findsOneWidget);
    });

    testWidgets('should call buyPack when buy button is tapped',
        (tester) async {
      final mockIap = MockIapService();
      when(() => mockIap.buyPack(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(_buildTestWidget(mockIap: mockIap));
      await tester.pumpAndSettle();

      // Tap the first buy button (₩1,900 for purple_dream)
      await tester.tap(find.textContaining('1,900').first);
      await tester.pumpAndSettle();

      verify(() => mockIap.buyPack('fangeul_color_purple_dream')).called(1);
    });

    testWidgets('should call restorePurchases when restore button is tapped',
        (tester) async {
      final mockIap = MockIapService();
      when(() => mockIap.restorePurchases()).thenAnswer((_) async {});

      await tester.pumpWidget(_buildTestWidget(mockIap: mockIap));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.restore));
      await tester.pumpAndSettle();

      verify(() => mockIap.restorePurchases()).called(1);
    });

    testWidgets('should show snackbar after restore', (tester) async {
      final mockIap = MockIapService();
      when(() => mockIap.restorePurchases()).thenAnswer((_) async {});

      await tester.pumpWidget(_buildTestWidget(mockIap: mockIap));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.restore));
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.shopRestoreSuccess), findsOneWidget);
    });

    testWidgets('should show loading indicator while packs are loading',
        (tester) async {
      final completer = Completer<List<ColorPack>>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            colorPacksProvider.overrideWith((_) => completer.future),
            iapServiceProvider.overrideWithValue(MockIapService()),
            monetizationNotifierProvider.overrideWith(() {
              return _TestMonetizationNotifier(
                const MonetizationState(honeymoonActive: false),
              );
            }),
          ],
          child: const MaterialApp(
            home: ShopScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to allow the test to clean up
      completer.complete(_testPacks);
      await tester.pumpAndSettle();
    });

    testWidgets('should show all packs as purchased when all are bought',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        purchasedPackIds: [
          'fangeul_color_purple_dream',
          'fangeul_color_golden_hour',
        ],
      ));
      await tester.pumpAndSettle();

      // All 2 packs purchased
      expect(find.text(UiStrings.shopPurchased), findsNWidgets(2));
      // No buy buttons
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('should display empty state gracefully with no packs',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(packs: []));
      await tester.pumpAndSettle();

      // Grid exists but empty
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should display grid with 2 columns', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 2);
    });

    testWidgets('should show different price for starter pack', (tester) async {
      const starterPack = ColorPack(
        id: 'starter_pack',
        nameKo: '첫 만남',
        nameEn: 'First Meet',
        primaryColor: '#22C55E',
        secondaryColor: '#15803D',
        skuId: 'fangeul_color_starter',
        priceKrw: 990,
        phraseCount: 20,
        pronunciationCount: 10,
      );

      await tester.pumpWidget(_buildTestWidget(packs: [starterPack]));
      await tester.pumpAndSettle();

      expect(find.text('첫 만남'), findsOneWidget);
      expect(find.textContaining('990'), findsOneWidget);
      expect(find.text(UiStrings.shopPhraseCount(20)), findsOneWidget);
      expect(find.text(UiStrings.shopPronunciationCount(10)), findsOneWidget);
    });
  });
}
