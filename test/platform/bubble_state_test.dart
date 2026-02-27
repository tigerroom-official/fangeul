import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/platform/bubble_state.dart';

void main() {
  group('BubbleState', () {
    test('should have exactly 3 values', () {
      expect(BubbleState.values, hasLength(3));
    });

    test('should include off, showing, popup', () {
      expect(BubbleState.values, contains(BubbleState.off));
      expect(BubbleState.values, contains(BubbleState.showing));
      expect(BubbleState.values, contains(BubbleState.popup));
    });

    test('should parse from string correctly', () {
      expect(BubbleState.fromString('off'), BubbleState.off);
      expect(BubbleState.fromString('showing'), BubbleState.showing);
      expect(BubbleState.fromString('popup'), BubbleState.popup);
    });

    test('should return off for unknown string', () {
      expect(BubbleState.fromString('unknown'), BubbleState.off);
      expect(BubbleState.fromString(''), BubbleState.off);
    });
  });
}
