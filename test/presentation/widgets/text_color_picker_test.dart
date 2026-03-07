import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/presentation/providers/theme_providers.dart'
    show contrastRatio;
import 'package:fangeul/presentation/widgets/text_color_picker_dialog.dart';

void main() {
  group('suggestTextColors', () {
    test('should return non-empty list for dark background', () {
      const bg = Color(0xFF1A1A2E);
      final suggestions = suggestTextColors(bg);
      expect(suggestions, isNotEmpty);
    });

    test('should return non-empty list for light background', () {
      const bg = Color(0xFFF5F5DC);
      final suggestions = suggestTextColors(bg);
      expect(suggestions, isNotEmpty);
    });

    test('should return colors with WCAG 4.5:1 contrast for dark bg', () {
      const bg = Color(0xFF2D1B69);
      final suggestions = suggestTextColors(bg);
      for (final color in suggestions) {
        final ratio = contrastRatio(color, bg);
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason:
                'Color ${color.toARGB32().toRadixString(16)} has ratio $ratio');
      }
    });

    test('should return colors with WCAG 4.5:1 contrast for light bg', () {
      const bg = Color(0xFFFFE4B5);
      final suggestions = suggestTextColors(bg);
      for (final color in suggestions) {
        final ratio = contrastRatio(color, bg);
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason:
                'Color ${color.toARGB32().toRadixString(16)} has ratio $ratio');
      }
    });

    test('should return at most 5 suggestions', () {
      const bg = Color(0xFF4527A0);
      final suggestions = suggestTextColors(bg);
      expect(suggestions.length, lessThanOrEqualTo(5));
    });

    test('should not contain near-duplicate colors', () {
      const bg = Color(0xFF006064);
      final suggestions = suggestTextColors(bg);
      for (int i = 0; i < suggestions.length; i++) {
        for (int j = i + 1; j < suggestions.length; j++) {
          final a = suggestions[i];
          final b = suggestions[j];
          final dr = ((a.r - b.r) * 255);
          final dg = ((a.g - b.g) * 255);
          final db = ((a.b - b.b) * 255);
          final dist = (dr * dr + dg * dg + db * db);
          // distance squared must be >= 20^2 = 400
          expect(dist, greaterThanOrEqualTo(400),
              reason: 'Colors $i and $j are too similar');
        }
      }
    });

    test('should handle pure white background', () {
      const bg = Color(0xFFFFFFFF);
      final suggestions = suggestTextColors(bg);
      for (final color in suggestions) {
        final ratio = contrastRatio(color, bg);
        expect(ratio, greaterThanOrEqualTo(4.5));
      }
    });

    test('should handle pure black background', () {
      const bg = Color(0xFF000000);
      final suggestions = suggestTextColors(bg);
      for (final color in suggestions) {
        final ratio = contrastRatio(color, bg);
        expect(ratio, greaterThanOrEqualTo(4.5));
      }
    });

    test('should handle mid-gray background', () {
      const bg = Color(0xFF808080);
      final suggestions = suggestTextColors(bg);
      // Mid-gray might have fewer passing candidates
      for (final color in suggestions) {
        final ratio = contrastRatio(color, bg);
        expect(ratio, greaterThanOrEqualTo(4.5));
      }
    });

    test('should work with various hue backgrounds', () {
      // Test 6 major hues
      const backgrounds = [
        Color(0xFFB71C1C), // red
        Color(0xFF1B5E20), // green
        Color(0xFF0D47A1), // blue
        Color(0xFFF57F17), // yellow
        Color(0xFF4A148C), // purple
        Color(0xFF00838F), // teal
      ];
      for (final bg in backgrounds) {
        final suggestions = suggestTextColors(bg);
        for (final color in suggestions) {
          final ratio = contrastRatio(color, bg);
          expect(ratio, greaterThanOrEqualTo(4.5),
              reason:
                  'Failed for bg ${bg.toARGB32().toRadixString(16)}: '
                  'color ${color.toARGB32().toRadixString(16)} ratio $ratio');
        }
      }
    });
  });
}
