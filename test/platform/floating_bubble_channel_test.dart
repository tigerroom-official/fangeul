import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/platform/bubble_state.dart';
import 'package:fangeul/platform/floating_bubble_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FloatingBubbleChannel channel;
  late List<MethodCall> log;

  setUp(() {
    log = [];
    channel = FloatingBubbleChannel();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.tigerroom.fangeul/floating_bubble'),
      (call) async {
        log.add(call);
        switch (call.method) {
          case 'showBubble':
            return true;
          case 'hideBubble':
            return true;
          case 'isOverlayPermissionGranted':
            return true;
          case 'requestOverlayPermission':
            return null;
          case 'getBubbleState':
            return 'showing';
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.tigerroom.fangeul/floating_bubble'),
      null,
    );
  });

  group('FloatingBubbleChannel', () {
    test('should invoke showBubble and return result', () async {
      final result = await channel.showBubble();
      expect(result, isTrue);
      expect(log.last.method, 'showBubble');
    });

    test('should invoke hideBubble and return result', () async {
      final result = await channel.hideBubble();
      expect(result, isTrue);
      expect(log.last.method, 'hideBubble');
    });

    test('should check overlay permission', () async {
      final result = await channel.isOverlayPermissionGranted();
      expect(result, isTrue);
      expect(log.last.method, 'isOverlayPermissionGranted');
    });

    test('should request overlay permission', () async {
      await channel.requestOverlayPermission();
      expect(log.last.method, 'requestOverlayPermission');
    });

    test('should parse getBubbleState to BubbleState', () async {
      final result = await channel.getBubbleState();
      expect(result, BubbleState.showing);
      expect(log.last.method, 'getBubbleState');
    });

    test('should return false on PlatformException for showBubble', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.tigerroom.fangeul/floating_bubble'),
        (call) async {
          throw PlatformException(code: 'ERROR', message: 'test');
        },
      );

      final result = await channel.showBubble();
      expect(result, isFalse);
    });

    test(
        'should return BubbleState.off on PlatformException for getBubbleState',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.tigerroom.fangeul/floating_bubble'),
        (call) async {
          throw PlatformException(code: 'ERROR', message: 'test');
        },
      );

      final result = await channel.getBubbleState();
      expect(result, BubbleState.off);
    });
  });
}
