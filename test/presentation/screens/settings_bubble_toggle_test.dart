import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/platform/bubble_state.dart';
import 'package:fangeul/platform/floating_bubble_channel.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/bubble_providers.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/screens/settings_screen.dart';

class MockFloatingBubbleChannel extends Mock implements FloatingBubbleChannel {}

void main() {
  late MockFloatingBubbleChannel mockChannel;
  late SharedPreferences prefs;
  late StreamController<BubbleState> eventController;

  setUp(() async {
    mockChannel = MockFloatingBubbleChannel();
    eventController = StreamController<BubbleState>.broadcast();
    when(() => mockChannel.getBubbleState())
        .thenAnswer((_) async => BubbleState.off);
    when(() => mockChannel.stateStream)
        .thenAnswer((_) => eventController.stream);
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() => eventController.close());

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        floatingBubbleChannelProvider.overrideWithValue(mockChannel),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(
        home: SettingsScreen(),
      ),
    );
  }

  group('Settings Bubble Toggle', () {
    testWidgets('should show bubble toggle with label and description',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.bubbleLabel), findsOneWidget);
      expect(find.text(UiStrings.bubbleDescription), findsOneWidget);
    });

    testWidgets('should show Switch widget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsOneWidget);
    });
  });
}
