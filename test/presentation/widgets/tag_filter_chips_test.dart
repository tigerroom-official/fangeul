import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/widgets/tag_filter_chips.dart';

void main() {
  const tags = ['love', 'cheer', 'daily'];

  Widget buildTestWidget({
    String? selectedTag,
    ValueChanged<String?>? onTagSelected,
    bool showMemberChip = false,
    bool isMemberSelected = false,
    VoidCallback? onMemberSelected,
    String memberLabel = '♡ TestMember',
    bool showMyIdolChip = false,
    bool isMyIdolSelected = false,
    VoidCallback? onMyIdolSelected,
    String myIdolLabel = '♡ TestIdol',
  }) {
    return MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      locale: const Locale('ko'),
      home: Scaffold(
        body: TagFilterChips(
          tags: tags,
          selectedTag: selectedTag,
          onTagSelected: onTagSelected ?? (_) {},
          showMemberChip: showMemberChip,
          isMemberSelected: isMemberSelected,
          onMemberSelected: onMemberSelected,
          memberLabel: memberLabel,
          showMyIdolChip: showMyIdolChip,
          isMyIdolSelected: isMyIdolSelected,
          onMyIdolSelected: onMyIdolSelected,
          myIdolLabel: myIdolLabel,
        ),
      ),
    );
  }

  group('TagFilterChips — myIdol chip', () {
    testWidgets('should show myIdol chip when showMyIdolChip is true',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(showMyIdolChip: true));
      await tester.pumpAndSettle();
      expect(find.text('\u2661 TestIdol'), findsOneWidget);
    });

    testWidgets('should not show myIdol chip when showMyIdolChip is false',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('\u2661 TestIdol'), findsNothing);
    });

    testWidgets('should highlight myIdol chip when isMyIdolSelected is true',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        showMyIdolChip: true,
        isMyIdolSelected: true,
      ));
      await tester.pumpAndSettle();
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final myIdolChip = chips.first;
      expect(myIdolChip.selected, isTrue);
    });

    testWidgets('should not highlight 전체 when myIdol is selected',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        showMyIdolChip: true,
        isMyIdolSelected: true,
      ));
      await tester.pumpAndSettle();
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final allChip = chips.elementAt(1); // 0=myIdol, 1=전체
      expect(allChip.selected, isFalse);
    });

    testWidgets('should highlight 전체 when myIdol not selected and tag is null',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(showMyIdolChip: true));
      await tester.pumpAndSettle();
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final allChip = chips.elementAt(1);
      expect(allChip.selected, isTrue);
    });

    testWidgets('should call onMyIdolSelected on myIdol chip tap',
        (tester) async {
      var called = false;
      await tester.pumpWidget(buildTestWidget(
        showMyIdolChip: true,
        onMyIdolSelected: () => called = true,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('\u2661 TestIdol'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('should place myIdol chip before 전체 chip', (tester) async {
      await tester.pumpWidget(buildTestWidget(showMyIdolChip: true));
      await tester.pumpAndSettle();
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      expect(chips.length, 5); // 1(myIdol) + 1(전체) + 3(tags)
    });

    testWidgets('should not highlight tag chips when myIdol is selected',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        showMyIdolChip: true,
        isMyIdolSelected: true,
        selectedTag: 'love',
      ));
      await tester.pumpAndSettle();
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      // tag chips should not be selected when myIdol is active
      for (final chip in chips.skip(2)) {
        expect(chip.selected, isFalse);
      }
    });
  });

  group('TagFilterChips — member chip', () {
    testWidgets('should show member chip when showMemberChip is true',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        showMemberChip: true,
        showMyIdolChip: true,
      ));
      await tester.pumpAndSettle();
      expect(find.text('♡ TestMember'), findsOneWidget);
    });

    testWidgets('should not show member chip when showMemberChip is false',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(showMyIdolChip: true));
      await tester.pumpAndSettle();
      expect(find.text('♡ TestMember'), findsNothing);
    });

    testWidgets('should place member chip before idol chip', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        showMemberChip: true,
        showMyIdolChip: true,
      ));
      await tester.pumpAndSettle();

      // Member chip should be at index 0, idol at index 1
      final memberCenter = tester.getCenter(find.text('♡ TestMember'));
      final idolCenter = tester.getCenter(find.text('♡ TestIdol'));
      expect(memberCenter.dx, lessThan(idolCenter.dx));
    });

    testWidgets('should call onMemberSelected when member chip tapped',
        (tester) async {
      var called = false;
      await tester.pumpWidget(buildTestWidget(
        showMemberChip: true,
        showMyIdolChip: true,
        onMemberSelected: () => called = true,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('♡ TestMember'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('should not highlight 전체 when member is selected',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        showMemberChip: true,
        isMemberSelected: true,
        showMyIdolChip: true,
      ));
      await tester.pumpAndSettle();
      final chips =
          tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
      // 0=member, 1=idol, 2=전체
      expect(chips[2].selected, isFalse);
    });

    testWidgets('should not highlight tag chips when member is selected',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        showMemberChip: true,
        isMemberSelected: true,
        showMyIdolChip: true,
        selectedTag: 'love',
      ));
      await tester.pumpAndSettle();
      final chips =
          tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
      // 0=member, 1=idol, 2=전체, 3+=tags — all tags unselected
      for (final chip in chips.skip(3)) {
        expect(chip.selected, isFalse);
      }
    });

    testWidgets('should highlight member chip when isMemberSelected is true',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        showMemberChip: true,
        isMemberSelected: true,
        showMyIdolChip: true,
      ));
      await tester.pumpAndSettle();
      final chips =
          tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
      expect(chips[0].selected, isTrue); // member chip
      expect(chips[1].selected, isFalse); // idol chip
    });
  });

  group('TagFilterChips — existing behavior', () {
    testWidgets('should show 전체 as selected when selectedTag is null',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final allChip = chips.first;
      expect(allChip.selected, isTrue);
    });

    testWidgets('should call onTagSelected with tag on chip tap',
        (tester) async {
      String? selected;
      await tester.pumpWidget(buildTestWidget(
        onTagSelected: (tag) => selected = tag,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UiStrings.tagLove));
      await tester.pumpAndSettle();
      expect(selected, 'love');
    });

    testWidgets('should call onTagSelected with null on 전체 tap',
        (tester) async {
      String? selected = 'love';
      await tester.pumpWidget(buildTestWidget(
        selectedTag: 'love',
        onTagSelected: (tag) => selected = tag,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UiStrings.tagAll));
      await tester.pumpAndSettle();
      expect(selected, isNull);
    });
  });
}
