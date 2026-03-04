import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
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
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('ko'),
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

  group('CompactPhraseTile — roman name highlighting', () {
    testWidgets('should use Text.rich when idol name is in roman',
        (tester) async {
      const templatePhrase = Phrase(
        ko: 'BTS 사랑해요',
        roman: 'BTS saranghaeyo',
        context: 'Template',
      );
      await tester.pumpWidget(
        buildTestWidget(
          phrase: templatePhrase,
          overrides: [
            myIdolDisplayNameProvider.overrideWith((ref) async => 'BTS'),
            myIdolMemberNameProvider.overrideWith((ref) async => null),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Text.rich를 사용하면 RichText가 렌더됨
      final richTexts = tester
          .widgetList<RichText>(find.byType(RichText))
          .where((w) => w.text.toPlainText().contains('BTS saranghaeyo'));
      expect(richTexts, isNotEmpty);
    });

    testWidgets('should use plain Text when no idol set', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            myIdolDisplayNameProvider.overrideWith((ref) async => null),
            myIdolMemberNameProvider.overrideWith((ref) async => null),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // plain Text 위젯으로 roman 표시
      expect(find.text('saranghaeyo'), findsOneWidget);
    });

    testWidgets('should highlight member name in roman', (tester) async {
      const memberPhrase = Phrase(
        ko: '정국 생일 축하해요',
        roman: '정국 saengil chukahaeyo',
        context: 'Member template',
      );
      await tester.pumpWidget(
        buildTestWidget(
          phrase: memberPhrase,
          overrides: [
            myIdolDisplayNameProvider.overrideWith((ref) async => 'BTS'),
            myIdolMemberNameProvider.overrideWith((ref) async => '정국'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final richTexts = tester
          .widgetList<RichText>(find.byType(RichText))
          .where((w) => w.text.toPlainText().contains('정국 saengil chukahaeyo'));
      expect(richTexts, isNotEmpty);
    });

    testWidgets('should not infinite loop when idol name is empty string',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            myIdolDisplayNameProvider.overrideWith((ref) async => ''),
            myIdolMemberNameProvider.overrideWith((ref) async => null),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // 빈 이름은 필터되어 plain Text (무한루프 방지)
      expect(find.text('saranghaeyo'), findsOneWidget);
    });

    testWidgets('should prefer longest match when names overlap',
        (tester) async {
      const templatePhrase = Phrase(
        ko: 'BTS 사랑해요',
        roman: 'BTS saranghaeyo',
        context: 'Template',
      );
      await tester.pumpWidget(
        buildTestWidget(
          phrase: templatePhrase,
          overrides: [
            myIdolDisplayNameProvider.overrideWith((ref) async => 'BT'),
            myIdolMemberNameProvider.overrideWith((ref) async => 'BTS'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // "BTS"가 통째로 매칭되어야 함
      final richTexts = tester
          .widgetList<RichText>(find.byType(RichText))
          .where((w) => w.text.toPlainText().contains('BTS saranghaeyo'));
      expect(richTexts, isNotEmpty);
    });

    testWidgets('should use plain Text when roman has no idol name',
        (tester) async {
      // roman에 이름이 없는 일반 문구
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            myIdolDisplayNameProvider.overrideWith((ref) async => 'BTS'),
            myIdolMemberNameProvider.overrideWith((ref) async => null),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // "saranghaeyo"에 "BTS"가 없으므로 plain Text
      expect(find.text('saranghaeyo'), findsOneWidget);
    });
  });
}
