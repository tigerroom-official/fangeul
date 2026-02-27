import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/screens/mini_converter_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const MiniConverterScreen(),
      ),
    );
  }

  /// 확장모드 테스트에서는 키보드까지 렌더링하므로 큰 화면이 필요하다.
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
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.miniTabFavorites), findsOneWidget);
      expect(find.text(UiStrings.miniTabRecent), findsOneWidget);
      expect(find.text(UiStrings.miniOpenConverter), findsOneWidget);
    });

    testWidgets('should show empty favorites message', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.miniFavoritesEmpty), findsOneWidget);
    });

    testWidgets('should switch to expanded mode on button tap',
        (tester) async {
      await setPhoneSize(tester);
      addTearDown(() => resetSize(tester));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text(UiStrings.miniOpenConverter));
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

      await tester.tap(find.text(UiStrings.miniOpenConverter));
      await tester.pumpAndSettle();

      await tester.tap(find.text(UiStrings.miniBackToCompact));
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.miniOpenConverter), findsOneWidget);
    });
  });
}
