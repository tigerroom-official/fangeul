import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/phrase_pack.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/widgets/pack_filter_chips.dart';

void main() {
  final testPacks = [
    const PhrasePack(
      id: 'basic_love',
      name: 'Love & Support',
      nameKo: '사랑 & 응원',
    ),
    const PhrasePack(
      id: 'daily',
      name: 'Daily',
      nameKo: '일상',
    ),
    const PhrasePack(
      id: 'birthday',
      name: 'Birthday',
      nameKo: '생일',
      isFree: false,
      unlockType: 'rewarded_ad',
    ),
  ];

  Widget buildTestWidget({
    bool isFavoritesSelected = true,
    String? selectedPackId,
    VoidCallback? onFavoritesSelected,
    ValueChanged<String>? onPackSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PackFilterChips(
          packs: testPacks,
          isFavoritesSelected: isFavoritesSelected,
          selectedPackId: selectedPackId,
          onFavoritesSelected: onFavoritesSelected,
          onPackSelected: onPackSelected,
        ),
      ),
    );
  }

  group('PackFilterChips', () {
    testWidgets('should show favorites chip first', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.miniChipFavorites), findsOneWidget);
    });

    testWidgets('should show all pack names', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('사랑 & 응원'), findsOneWidget);
      expect(find.text('일상'), findsOneWidget);
    });

    testWidgets('should show lock icon for non-free packs', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('생일🔒'), findsOneWidget);
    });

    testWidgets('should call onFavoritesSelected on favorites chip tap',
        (tester) async {
      var called = false;
      await tester.pumpWidget(
        buildTestWidget(
          isFavoritesSelected: false,
          selectedPackId: 'basic_love',
          onFavoritesSelected: () => called = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(UiStrings.miniChipFavorites));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('should call onPackSelected with pack id', (tester) async {
      String? selectedId;
      await tester.pumpWidget(
        buildTestWidget(
          onPackSelected: (id) => selectedId = id,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('사랑 & 응원'));
      await tester.pumpAndSettle();

      expect(selectedId, 'basic_love');
    });

    testWidgets('should highlight selected pack chip', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          isFavoritesSelected: false,
          selectedPackId: 'daily',
        ),
      );
      await tester.pumpAndSettle();

      // FilterChip의 selected 상태를 확인 — 일상 칩이 selected여야 함
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final dailyChip = chips.elementAt(2); // 0=즐찾, 1=사랑, 2=일상
      expect(dailyChip.selected, isTrue);
    });
  });
}
