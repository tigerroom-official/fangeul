import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/entities/phrase_pack.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/phrase_providers.dart';
import 'package:fangeul/presentation/screens/mini_converter_screen.dart';

/// 테스트용 PhrasePack 목록.
final _testPacks = [
  PhrasePack(
    id: 'basic_love',
    name: 'Love & Support',
    nameKo: '사랑 & 응원',
    phrases: [
      const Phrase(ko: '사랑해요', roman: 'saranghaeyo', context: 'Love'),
      const Phrase(ko: '화이팅', roman: 'hwaiting', context: 'Cheer'),
    ],
  ),
];

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestWidget({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        allPhrasesProvider.overrideWith((ref) async => _testPacks),
        ...overrides,
      ],
      child: MaterialApp(
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: const Locale('ko'),
        home: const MiniConverterScreen(),
      ),
    );
  }

  Future<void> setPhoneSize(WidgetTester tester) async {
    const phoneSize = Size(412, 915);
    await tester.binding.setSurfaceSize(phoneSize);
    tester.view.physicalSize = phoneSize;
    tester.view.devicePixelRatio = 1.0;
  }

  Future<void> resetSize(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(null);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  group('MiniConverterScreen', () {
    testWidgets('should show compact mode by default', (tester) async {
      await setPhoneSize(tester);
      addTearDown(() => resetSize(tester));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.miniTabPhrases), findsOneWidget);
      expect(find.text(UiStrings.miniTabRecent), findsOneWidget);
    });

    testWidgets('should show favorites chip and empty message', (tester) async {
      await setPhoneSize(tester);
      addTearDown(() => resetSize(tester));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.miniChipFavorites), findsOneWidget);
      expect(find.text(UiStrings.miniFavoritesEmpty), findsOneWidget);
    });

    testWidgets('should show pack filter chips', (tester) async {
      await setPhoneSize(tester);
      addTearDown(() => resetSize(tester));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('사랑 & 응원'), findsOneWidget);
    });

    testWidgets('should expand to converter on drag handle swipe up',
        (tester) async {
      await setPhoneSize(tester);
      addTearDown(() => resetSize(tester));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 드래그 핸들 영역에서 위로 스와이프 (빠른 fling)
      final handle = find.byKey(const ValueKey('drag_handle'));
      expect(handle, findsOneWidget);

      await tester.fling(handle, const Offset(0, -200), 500);
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.miniBackToCompact), findsOneWidget);
      expect(find.text(UiStrings.miniConverterTitle), findsOneWidget);
      expect(find.text(UiStrings.converterTabEngToKor), findsOneWidget);
    });

    testWidgets('should collapse back to compact mode', (tester) async {
      await setPhoneSize(tester);
      addTearDown(() => resetSize(tester));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 위로 스와이프하여 확장
      final handle = find.byKey(const ValueKey('drag_handle'));
      await tester.fling(handle, const Offset(0, -200), 500);
      await tester.pumpAndSettle();

      // 간편모드 버튼으로 복귀
      await tester.tap(find.text(UiStrings.miniBackToCompact));
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.miniTabPhrases), findsOneWidget);
    });

    testWidgets('should show horizontal swiper for pack phrases',
        (tester) async {
      await setPhoneSize(tester);
      addTearDown(() => resetSize(tester));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 팩 칩 선택
      await tester.tap(find.text('사랑 & 응원'));
      await tester.pumpAndSettle();

      // 첫 문구 카드 표시 + 페이지 인디케이터
      expect(find.text('사랑해요'), findsOneWidget);
      expect(find.text('saranghaeyo'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);
    });

    testWidgets('should not show open converter button', (tester) async {
      await setPhoneSize(tester);
      addTearDown(() => resetSize(tester));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // "변환기 열기" 버튼이 없어야 함
      expect(find.text(UiStrings.miniOpenConverter), findsNothing);
    });
  });
}
