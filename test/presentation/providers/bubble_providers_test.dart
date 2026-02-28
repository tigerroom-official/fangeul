import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/platform/bubble_state.dart';
import 'package:fangeul/platform/floating_bubble_channel.dart';
import 'package:fangeul/presentation/providers/bubble_providers.dart';

class MockFloatingBubbleChannel extends Mock implements FloatingBubbleChannel {}

void main() {
  group('BubbleNotifier', () {
    late MockFloatingBubbleChannel mockChannel;
    late ProviderContainer container;
    late StreamController<BubbleState> eventController;

    setUp(() {
      mockChannel = MockFloatingBubbleChannel();
      eventController = StreamController<BubbleState>.broadcast();
      when(() => mockChannel.getBubbleState())
          .thenAnswer((_) async => BubbleState.off);
      when(() => mockChannel.stateStream)
          .thenAnswer((_) => eventController.stream);
      container = ProviderContainer(
        overrides: [
          floatingBubbleChannelProvider.overrideWithValue(mockChannel),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      eventController.close();
    });

    test('should start with BubbleState.off', () {
      final state = container.read(bubbleNotifierProvider);
      expect(state, BubbleState.off);
    });

    test('should transition to showing when showBubble succeeds', () async {
      when(() => mockChannel.showBubble()).thenAnswer((_) async => true);

      await container.read(bubbleNotifierProvider.notifier).show();

      expect(container.read(bubbleNotifierProvider), BubbleState.showing);
    });

    test('should stay off when showBubble fails', () async {
      when(() => mockChannel.showBubble()).thenAnswer((_) async => false);

      await container.read(bubbleNotifierProvider.notifier).show();

      expect(container.read(bubbleNotifierProvider), BubbleState.off);
    });

    test('should transition to off when hideBubble called', () async {
      when(() => mockChannel.showBubble()).thenAnswer((_) async => true);
      when(() => mockChannel.hideBubble()).thenAnswer((_) async => true);

      await container.read(bubbleNotifierProvider.notifier).show();
      await container.read(bubbleNotifierProvider.notifier).hide();

      expect(container.read(bubbleNotifierProvider), BubbleState.off);
    });

    test('should check permission correctly', () async {
      when(() => mockChannel.isOverlayPermissionGranted())
          .thenAnswer((_) async => true);

      final result = await container
          .read(bubbleNotifierProvider.notifier)
          .checkPermission();

      expect(result, isTrue);
    });

    test('should request permission and return result', () async {
      when(() => mockChannel.requestOverlayPermission())
          .thenAnswer((_) async => true);

      final result = await container
          .read(bubbleNotifierProvider.notifier)
          .requestPermission();

      expect(result, isTrue);
      verify(() => mockChannel.requestOverlayPermission()).called(1);
    });

    test('should sync state from native', () async {
      when(() => mockChannel.getBubbleState())
          .thenAnswer((_) async => BubbleState.showing);

      await container.read(bubbleNotifierProvider.notifier).sync();

      expect(container.read(bubbleNotifierProvider), BubbleState.showing);
    });

    test('should update state when EventChannel sends event', () async {
      // Provider를 listen으로 유지 (auto-dispose 방지)
      container.listen(bubbleNotifierProvider, (_, __) {});
      await Future<void>.delayed(Duration.zero);

      // EventChannel에서 상태 변경 전송
      eventController.add(BubbleState.showing);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(bubbleNotifierProvider), BubbleState.showing);
    });
  });
}
