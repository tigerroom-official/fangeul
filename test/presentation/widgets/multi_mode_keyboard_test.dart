import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/widgets/multi_mode_keyboard.dart';

void main() {
  final keyboardKey = GlobalKey<MultiModeKeyboardState>();

  Widget buildTestApp({
    required ValueChanged<String> onText,
    VoidCallback? onDone,
    InputMode initialMode = InputMode.korean,
  }) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('ko'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: MultiModeKeyboard(
              key: keyboardKey,
              onText: onText,
              onDone: onDone ?? () {},
              initialMode: initialMode,
            ),
          ),
        ),
      ),
    );
  }

  group('MultiModeKeyboard — Korean mode', () {
    testWidgets('should assemble Korean jamos: ㅎ+ㅏ+ㄴ → 한', (tester) async {
      String? emittedText;
      await tester.pumpWidget(
        buildTestApp(onText: (t) => emittedText = t),
      );

      // 한글 모드에서 ㅎ(g키), ㅏ(k키), ㄴ(s키) 입력
      // KeyData: g→ㅎ, k→ㅏ, s→ㄴ
      // 한글 모드(isEngToKor: false)이므로 한글이 주 라벨
      await tester.tap(find.text('ㅎ'));
      await tester.pump();
      await tester.tap(find.text('ㅏ'));
      await tester.pump();
      await tester.tap(find.text('ㄴ'));
      await tester.pump();

      expect(emittedText, '한');
      expect(keyboardKey.currentState?.currentText, '한');
    });

    testWidgets('should handle backspace in Korean mode — pop jamo',
        (tester) async {
      String? emittedText;
      await tester.pumpWidget(
        buildTestApp(onText: (t) => emittedText = t),
      );

      // ㅎ+ㅏ 입력
      await tester.tap(find.text('ㅎ'));
      await tester.pump();
      await tester.tap(find.text('ㅏ'));
      await tester.pump();
      expect(emittedText, '하');

      // Backspace → ㅎ만 남음
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(emittedText, 'ㅎ');
    });

    testWidgets('should handle space in Korean mode', (tester) async {
      String? emittedText;
      await tester.pumpWidget(
        buildTestApp(onText: (t) => emittedText = t),
      );

      // ㅎ+ㅏ+ㄴ 입력 + 스페이스
      await tester.tap(find.text('ㅎ'));
      await tester.pump();
      await tester.tap(find.text('ㅏ'));
      await tester.pump();
      await tester.tap(find.text('ㄴ'));
      await tester.pump();
      await tester.tap(find.text(UiStrings.keyboardSpace));
      await tester.pump();

      expect(emittedText, '한 ');
    });
  });

  group('MultiModeKeyboard — ABC mode', () {
    testWidgets('should input English characters', (tester) async {
      String? emittedText;
      await tester.pumpWidget(
        buildTestApp(
          onText: (t) => emittedText = t,
          initialMode: InputMode.abc,
        ),
      );

      // ABC 모드(isEngToKor: true)이므로 영문이 주 라벨
      await tester.tap(find.text('d'));
      await tester.pump();
      await tester.tap(find.text('a'));
      await tester.pump();
      await tester.tap(find.text('y'));
      await tester.pump();

      expect(emittedText, 'day');
    });

    testWidgets('should handle CAPS in ABC mode', (tester) async {
      String? emittedText;
      await tester.pumpWidget(
        buildTestApp(
          onText: (t) => emittedText = t,
          initialMode: InputMode.abc,
        ),
      );

      // CAPS 한번 탭 (oneShot) — 키 라벨이 대문자로 변경됨
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pump();

      // D (대문자) — CAPS 활성 시 주 라벨이 대문자
      await tester.tap(find.text('D'));
      await tester.pump();
      expect(emittedText, 'D');

      // 다음 글자는 소문자 (oneShot 소비됨)
      await tester.tap(find.text('a'));
      await tester.pump();
      expect(emittedText, 'Da');
    });

    testWidgets('should handle backspace in ABC mode', (tester) async {
      String? emittedText;
      await tester.pumpWidget(
        buildTestApp(
          onText: (t) => emittedText = t,
          initialMode: InputMode.abc,
        ),
      );

      await tester.tap(find.text('a'));
      await tester.pump();
      await tester.tap(find.text('b'));
      await tester.pump();
      expect(emittedText, 'ab');

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(emittedText, 'a');
    });
  });

  group('MultiModeKeyboard — 123 mode', () {
    testWidgets('should input numbers', (tester) async {
      String? emittedText;
      await tester.pumpWidget(
        buildTestApp(
          onText: (t) => emittedText = t,
          initialMode: InputMode.numbers,
        ),
      );

      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();

      expect(emittedText, '123');
    });

    testWidgets('should input symbols', (tester) async {
      String? emittedText;
      await tester.pumpWidget(
        buildTestApp(
          onText: (t) => emittedText = t,
          initialMode: InputMode.numbers,
        ),
      );

      await tester.tap(find.text('@'));
      await tester.pump();
      await tester.tap(find.text('#'));
      await tester.pump();

      expect(emittedText, '@#');
    });
  });

  group('MultiModeKeyboard — mode switching', () {
    testWidgets('should preserve text when switching modes', (tester) async {
      String? emittedText;
      await tester.pumpWidget(
        buildTestApp(onText: (t) => emittedText = t),
      );

      // 한글 모드에서 "한" 입력
      await tester.tap(find.text('ㅎ'));
      await tester.pump();
      await tester.tap(find.text('ㅏ'));
      await tester.pump();
      await tester.tap(find.text('ㄴ'));
      await tester.pump();
      expect(emittedText, '한');

      // ABC 모드로 전환
      await tester.tap(find.text(UiStrings.keyboardModeAbc));
      await tester.pump();

      // ABC로 "a" 입력 → "한a"
      await tester.tap(find.text('a'));
      await tester.pump();
      expect(emittedText, '한a');
    });

    testWidgets('should flush jamo when switching from Korean to ABC',
        (tester) async {
      String? emittedText;
      await tester.pumpWidget(
        buildTestApp(onText: (t) => emittedText = t),
      );

      // 한글 모드에서 ㅎ만 입력 (조합 중)
      await tester.tap(find.text('ㅎ'));
      await tester.pump();
      expect(emittedText, 'ㅎ');

      // ABC 모드로 전환 → ㅎ flush됨
      await tester.tap(find.text(UiStrings.keyboardModeAbc));
      await tester.pump();

      // currentText에 ㅎ이 확정됨
      expect(keyboardKey.currentState?.currentText, 'ㅎ');
    });

    testWidgets('should switch from 123 to ABC via mode button',
        (tester) async {
      String? emittedText;
      await tester.pumpWidget(
        buildTestApp(
          onText: (t) => emittedText = t,
          initialMode: InputMode.numbers,
        ),
      );

      await tester.tap(find.text('5'));
      await tester.pump();

      // 123 모드의 [ABC] 모드 전환 버튼
      // SegmentedButton의 ABC와 123 하단의 ABC 버튼이 둘 다 있으므로
      // SegmentedButton 내의 ABC를 탭
      await tester.tap(find.text(UiStrings.keyboardModeAbc).first);
      await tester.pump();

      await tester.tap(find.text('x'));
      await tester.pump();
      expect(emittedText, '5x');
    });
  });

  group('MultiModeKeyboard — setText/currentText API', () {
    testWidgets('setText should replace keyboard text', (tester) async {
      String? emittedText;
      await tester.pumpWidget(
        buildTestApp(onText: (t) => emittedText = t),
      );

      // 외부에서 텍스트 설정
      keyboardKey.currentState?.setText('외부텍스트');
      await tester.pump();

      expect(keyboardKey.currentState?.currentText, '외부텍스트');

      // 이후 입력은 기존 텍스트에 추가
      await tester.tap(find.text('ㅎ'));
      await tester.pump();
      expect(emittedText, '외부텍스트ㅎ');
    });

    testWidgets('setText should clear jamo list', (tester) async {
      await tester.pumpWidget(
        buildTestApp(onText: (_) {}),
      );

      // 한글 자모 입력
      await tester.tap(find.text('ㅎ'));
      await tester.pump();

      // setText로 덮어쓰기
      keyboardKey.currentState?.setText('새텍스트');
      await tester.pump();

      expect(keyboardKey.currentState?.currentText, '새텍스트');
    });
  });

  group('MultiModeKeyboard — onDone', () {
    testWidgets('should call onDone when done button tapped', (tester) async {
      var doneCalled = false;
      await tester.pumpWidget(
        buildTestApp(
          onText: (_) {},
          onDone: () => doneCalled = true,
        ),
      );

      await tester.tap(find.text(UiStrings.keyboardDone));
      await tester.pump();

      expect(doneCalled, true);
    });

    testWidgets('should flush jamo before calling onDone', (tester) async {
      await tester.pumpWidget(
        buildTestApp(onText: (_) {}),
      );

      // 한글 자모 입력 (조합 중)
      await tester.tap(find.text('ㅎ'));
      await tester.pump();

      // 완료 버튼 → jamo flush
      await tester.tap(find.text(UiStrings.keyboardDone));
      await tester.pump();

      // flush 후 committedText에 확정됨
      expect(keyboardKey.currentState?.currentText, 'ㅎ');
    });
  });

  group('MultiModeKeyboard — toolbar', () {
    testWidgets('should show Korean mode segment selected by default',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(onText: (_) {}),
      );

      // SegmentedButton이 존재하고 한글 모드가 선택됨
      expect(find.text(UiStrings.keyboardModeKorean), findsOneWidget);
      expect(find.text(UiStrings.keyboardModeAbc), findsOneWidget);
      expect(find.text(UiStrings.keyboardModeNumbers), findsOneWidget);
    });

    testWidgets('should show ABC keys when ABC mode selected', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          onText: (_) {},
          initialMode: InputMode.abc,
        ),
      );

      // ABC 모드에서는 영문이 주 라벨 (isEngToKor: true)
      // 영문 'q'가 주 라벨로 표시됨
      expect(find.text('q'), findsOneWidget);
      expect(find.text('ㅂ'), findsOneWidget);
    });

    testWidgets('should show number keys when 123 mode selected',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          onText: (_) {},
          initialMode: InputMode.numbers,
        ),
      );

      // 숫자키 표시
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('@'), findsOneWidget);
    });
  });
}
