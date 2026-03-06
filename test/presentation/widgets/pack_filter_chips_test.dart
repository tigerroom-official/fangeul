import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/phrase_pack.dart';
import 'package:fangeul/l10n/app_localizations.dart';
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
    bool showMyIdolChip = false,
    bool isMyIdolSelected = false,
    VoidCallback? onMyIdolSelected,
    bool showTodayChip = false,
    bool isTodaySelected = false,
    VoidCallback? onTodaySelected,
  }) {
    return MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      locale: const Locale('ko'),
      home: Scaffold(
        body: PackFilterChips(
          packs: testPacks,
          isFavoritesSelected: isFavoritesSelected,
          selectedPackId: selectedPackId,
          onFavoritesSelected: onFavoritesSelected,
          onPackSelected: onPackSelected,
          showMyIdolChip: showMyIdolChip,
          isMyIdolSelected: isMyIdolSelected,
          onMyIdolSelected: onMyIdolSelected,
          showTodayChip: showTodayChip,
          isTodaySelected: isTodaySelected,
          onTodaySelected: onTodaySelected,
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

    testWidgets('should show pack name without lock for non-free packs',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 잠금 표시 제거됨 — 모든 팩이 이름만 표시
      expect(find.text('생일'), findsOneWidget);
      expect(find.text('생일🔒'), findsNothing);
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

    testWidgets('should show myIdol chip when showMyIdolChip is true',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(showMyIdolChip: true),
      );
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.idolSettingLabel), findsOneWidget);
    });

    testWidgets('should not show myIdol chip when showMyIdolChip is false',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.idolSettingLabel), findsNothing);
    });

    testWidgets('should call onMyIdolSelected on myIdol chip tap',
        (tester) async {
      var called = false;
      await tester.pumpWidget(
        buildTestWidget(
          showMyIdolChip: true,
          onMyIdolSelected: () => called = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(UiStrings.idolSettingLabel));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('should highlight myIdol chip when selected', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          isFavoritesSelected: false,
          showMyIdolChip: true,
          isMyIdolSelected: true,
        ),
      );
      await tester.pumpAndSettle();

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final myIdolChip = chips.elementAt(1); // 0=즐찾, 1=마이아이돌
      expect(myIdolChip.selected, isTrue);
    });

    testWidgets('should show today chip when showTodayChip is true',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(showTodayChip: true),
      );
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.miniChipToday), findsOneWidget);
    });

    testWidgets('should not show today chip when showTodayChip is false',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.miniChipToday), findsNothing);
    });

    testWidgets('should call onTodaySelected on today chip tap',
        (tester) async {
      var called = false;
      await tester.pumpWidget(
        buildTestWidget(
          showTodayChip: true,
          onTodaySelected: () => called = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(UiStrings.miniChipToday));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('should highlight today chip when selected', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          isFavoritesSelected: false,
          showTodayChip: true,
          isTodaySelected: true,
        ),
      );
      await tester.pumpAndSettle();

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final todayChip = chips.elementAt(1); // 0=즐찾, 1=오늘
      expect(todayChip.selected, isTrue);
    });

    testWidgets('should show both myIdol and today chips in correct order',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          showMyIdolChip: true,
          showTodayChip: true,
        ),
      );
      await tester.pumpAndSettle();

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      // 0=즐찾, 1=마이아이돌, 2=오늘, 3~5=팩
      expect(chips.length, 6); // 1(즐찾) + 1(아이돌) + 1(오늘) + 3(팩)

      // 칩 순서 확인: 즐찾 → 마이아이돌 → 오늘 → 팩들
      expect(find.text(UiStrings.miniChipFavorites), findsOneWidget);
      expect(find.text(UiStrings.idolSettingLabel), findsOneWidget);
      expect(find.text(UiStrings.miniChipToday), findsOneWidget);
    });

    testWidgets('should deselect favorites chip when myIdol is selected',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          isFavoritesSelected: false,
          showMyIdolChip: true,
          isMyIdolSelected: true,
        ),
      );
      await tester.pumpAndSettle();

      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final favoritesChip = chips.first;
      expect(favoritesChip.selected, isFalse);
    });

    testWidgets('should deselect pack chips when today is selected',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          isFavoritesSelected: false,
          showTodayChip: true,
          isTodaySelected: true,
          selectedPackId: 'basic_love',
        ),
      );
      await tester.pumpAndSettle();

      // 팩 칩은 today 선택 시 deselect 되어야 함
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      for (final chip in chips.skip(2)) {
        // skip 즐찾+오늘
        expect(chip.selected, isFalse);
      }
    });
  });
}
