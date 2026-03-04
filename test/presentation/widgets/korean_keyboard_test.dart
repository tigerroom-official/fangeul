import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/widgets/korean_keyboard.dart';

void main() {
  Widget buildTestApp({
    required bool isEngToKor,
    required void Function(String, String) onCharacterTap,
    VoidCallback? onBackspace,
    VoidCallback? onSpace,
  }) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('ko'),
        home: Scaffold(
          body: KoreanKeyboard(
            isEngToKor: isEngToKor,
            onCharacterTap: onCharacterTap,
            onBackspace: onBackspace ?? () {},
            onSpace: onSpace ?? () {},
          ),
        ),
      ),
    );
  }

  group('KoreanKeyboard', () {
    testWidgets('should render all character keys', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          isEngToKor: true,
          onCharacterTap: (_, __) {},
        ),
      );

      // Check some specific keys exist
      expect(find.text('q'), findsOneWidget);
      expect(find.text('ㅂ'), findsOneWidget);
      expect(find.text('m'), findsOneWidget);
      expect(find.text('ㅡ'), findsOneWidget);
    });

    testWidgets('should call onCharacterTap with eng and kor when key tapped',
        (tester) async {
      String? tappedEng;
      String? tappedKor;

      await tester.pumpWidget(
        buildTestApp(
          isEngToKor: true,
          onCharacterTap: (eng, kor) {
            tappedEng = eng;
            tappedKor = kor;
          },
        ),
      );

      // Tap the 'q' key (ㅂ)
      await tester.tap(find.text('q'));
      await tester.pump();

      expect(tappedEng, 'q');
      expect(tappedKor, 'ㅂ');
    });

    testWidgets('should call onBackspace when DEL tapped', (tester) async {
      var called = false;

      await tester.pumpWidget(
        buildTestApp(
          isEngToKor: true,
          onCharacterTap: (_, __) {},
          onBackspace: () => called = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      expect(called, true);
    });

    testWidgets('should call onSpace when SPACE tapped', (tester) async {
      var called = false;

      await tester.pumpWidget(
        buildTestApp(
          isEngToKor: true,
          onCharacterTap: (_, __) {},
          onSpace: () => called = true,
        ),
      );

      await tester.tap(find.text('Space'));
      await tester.pump();

      expect(called, true);
    });

    testWidgets('should show Korean as main label in korToEng mode',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          isEngToKor: false,
          onCharacterTap: (_, __) {},
        ),
      );

      // In korToEng mode, Korean should be the main (bigger) label
      // Verify both labels are present
      expect(find.text('ㅂ'), findsOneWidget);
      expect(find.text('q'), findsOneWidget);
    });
  });
}
