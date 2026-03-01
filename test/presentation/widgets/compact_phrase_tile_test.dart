import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/widgets/compact_phrase_tile.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testPhrase = Phrase(
    ko: '사랑해요',
    roman: 'saranghaeyo',
    context: 'Love',
  );

  Widget buildTestWidget({
    Phrase phrase = testPhrase,
    VoidCallback? onCopied,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(
          body: CompactPhraseTile(
            phrase: phrase,
            onCopied: onCopied,
          ),
        ),
      ),
    );
  }

  group('CompactPhraseTile', () {
    testWidgets('should display ko and roman text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('사랑해요'), findsOneWidget);
      expect(find.text('saranghaeyo'), findsOneWidget);
    });

    testWidgets('should not display roman when empty', (tester) async {
      const noRoman = Phrase(ko: '테스트', roman: '', context: '');
      await tester.pumpWidget(buildTestWidget(phrase: noRoman));
      await tester.pumpAndSettle();

      expect(find.text('테스트'), findsOneWidget);
      // subtitle should not exist
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && w.data == '',
        ),
        findsNothing,
      );
    });

    testWidgets('should show unfilled star when not favorite', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
    });

    testWidgets('should show filled star when favorite', (tester) async {
      // 즐겨찾기에 미리 추가
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // ★ 버튼 탭
      await tester.tap(find.byIcon(Icons.star_border_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('should toggle favorite on star tap', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 추가
      await tester.tap(find.byIcon(Icons.star_border_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);

      // 제거
      await tester.tap(find.byIcon(Icons.star_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
    });

    testWidgets('should have copy button with tooltip', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byTooltip(UiStrings.copyTooltip), findsOneWidget);
    });

    testWidgets('should call onCopied after copy tap', (tester) async {
      var copied = false;
      await tester.pumpWidget(
        buildTestWidget(onCopied: () => copied = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pumpAndSettle();

      expect(copied, isTrue);
    });
  });
}
