import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/widgets/phrase_card.dart';

void main() {
  group('PhraseCard — roman name color differentiation', () {
    Widget buildTestApp({
      required Phrase phrase,
      String? idolName,
      String? memberName,
    }) {
      return ProviderScope(
        overrides: [
          myIdolDisplayNameProvider.overrideWith((ref) async => idolName),
          myIdolMemberNameProvider.overrideWith((ref) async => memberName),
        ],
        child: MaterialApp(
          localizationsDelegates: L.localizationsDelegates,
          supportedLocales: L.supportedLocales,
          locale: const Locale('ko'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: PhraseCard(
                phrase: phrase,
                translationLang: 'en',
              ),
            ),
          ),
        ),
      );
    }

    /// Text.rich로 만들어진 위젯에서 자식 TextSpan 목록을 추출한다.
    ///
    /// Text.rich는 내부적으로 한 레벨 더 감싸므로 children[0].children을 탐색.
    List<TextSpan>? findRomanSpans(WidgetTester tester, String fullText) {
      final richTexts = tester.widgetList<RichText>(find.byType(RichText));
      for (final rt in richTexts) {
        final root = rt.text;
        if (root is! TextSpan) continue;
        // Text.rich: root.children[0] = 우리의 TextSpan(children: spans)
        final inner = root.children;
        if (inner == null || inner.isEmpty) continue;
        final wrapper = inner.first;
        if (wrapper is! TextSpan) continue;
        final spans = wrapper.children;
        if (spans == null || spans.isEmpty) continue;
        final joined = spans.map((s) => (s as TextSpan).text).join();
        if (joined == fullText) return spans.cast<TextSpan>();
      }
      return null;
    }

    testWidgets('should show roman as single text when no idol set',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        phrase: const Phrase(
          ko: 'BTS 사랑해요',
          roman: 'BTS saranghaeyo',
          context: 'Template',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('BTS saranghaeyo'), findsOneWidget);
    });

    testWidgets('should split roman into name and pronunciation spans',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        phrase: const Phrase(
          ko: 'BTS 사랑해요',
          roman: 'BTS saranghaeyo',
          context: 'Template',
        ),
        idolName: 'BTS',
      ));
      await tester.pumpAndSettle();
      // async provider 해소 후 리빌드 대기
      await tester.pump();

      final spans = findRomanSpans(tester, 'BTS saranghaeyo');
      expect(spans, isNotNull);
      expect(spans, hasLength(2));
      // "BTS" = name span (onSurfaceVariant), " saranghaeyo" = roman span (primary)
      expect(spans![0].text, 'BTS');
      expect(spans[1].text, ' saranghaeyo');
      // 색상이 다른지 확인
      expect(spans[0].style?.color, isNot(equals(spans[1].style?.color)));
    });

    testWidgets('should differentiate member name in roman', (tester) async {
      await tester.pumpWidget(buildTestApp(
        phrase: const Phrase(
          ko: '정국 생일 축하해요',
          roman: '정국 saengil chukahaeyo',
          context: 'Member template',
        ),
        idolName: 'BTS',
        memberName: '정국',
      ));
      await tester.pumpAndSettle();
      await tester.pump();

      final spans = findRomanSpans(tester, '정국 saengil chukahaeyo');
      expect(spans, isNotNull);
      expect(spans, hasLength(2));
      expect(spans![0].text, '정국');
      expect(spans[1].text, ' saengil chukahaeyo');
      expect(spans[0].style?.color, isNot(equals(spans[1].style?.color)));
    });

    testWidgets('should not infinite loop when idol name is empty string',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        phrase: const Phrase(
          ko: '사랑해요',
          roman: 'saranghaeyo',
          context: 'Love',
        ),
        idolName: '',
      ));
      await tester.pumpAndSettle();

      // 빈 이름은 필터되어 plain Text로 표시 (무한루프 방지)
      expect(find.text('saranghaeyo'), findsOneWidget);
    });

    testWidgets('should prefer longest match when names overlap',
        (tester) async {
      // "BT" vs "BTS" — "BTS saranghaeyo"에서 "BTS"를 매칭해야 함
      await tester.pumpWidget(buildTestApp(
        phrase: const Phrase(
          ko: 'BTS 사랑해요',
          roman: 'BTS saranghaeyo',
          context: 'Template',
        ),
        idolName: 'BT',
        memberName: 'BTS',
      ));
      await tester.pumpAndSettle();
      await tester.pump();

      final spans = findRomanSpans(tester, 'BTS saranghaeyo');
      expect(spans, isNotNull);
      // "BTS"가 통째로 매칭되어야 함 (3글자), "BT"+"S" 분리 아님
      expect(spans![0].text, 'BTS');
      expect(spans[1].text, ' saranghaeyo');
    });

    testWidgets('should show plain text when roman has no matching names',
        (tester) async {
      await tester.pumpWidget(buildTestApp(
        phrase: const Phrase(
          ko: '사랑해요',
          roman: 'saranghaeyo',
          context: 'Plain',
        ),
        idolName: 'BTS',
      ));
      await tester.pumpAndSettle();

      // 이름이 roman에 없으므로 단일 Text (Text.rich 아님)
      expect(find.text('saranghaeyo'), findsOneWidget);
      // 분리된 spans 없음
      final spans = findRomanSpans(tester, 'saranghaeyo');
      expect(spans, isNull);
    });
  });
}
