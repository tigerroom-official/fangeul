import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/kpop_event.dart';

void main() {
  group('KpopEvent', () {
    test('should create from JSON with all fields', () {
      final json = {
        'date': '03-09',
        'type': 'birthday',
        'artist': '슈가',
        'group': 'BTS',
        'situation': 'birthday',
      };

      final event = KpopEvent.fromJson(json);

      expect(event.date, '03-09');
      expect(event.type, 'birthday');
      expect(event.artist, '슈가');
      expect(event.group, 'BTS');
      expect(event.situation, 'birthday');
    });

    test('should round-trip through JSON', () {
      const original = KpopEvent(
        date: '06-13',
        type: 'debut_anniversary',
        artist: 'BTS',
        group: 'BTS',
        situation: 'comeback',
      );

      final jsonStr = jsonEncode(original.toJson());
      final restored =
          KpopEvent.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);

      expect(restored, original);
    });

    test('should have value equality', () {
      const a = KpopEvent(
        date: '01-11',
        type: 'birthday',
        artist: '정국',
        group: 'BTS',
        situation: 'birthday',
      );
      const b = KpopEvent(
        date: '01-11',
        type: 'birthday',
        artist: '정국',
        group: 'BTS',
        situation: 'birthday',
      );

      expect(a, b);
    });

    test('should not be equal with different values', () {
      const a = KpopEvent(
        date: '01-11',
        type: 'birthday',
        artist: '정국',
        group: 'BTS',
        situation: 'birthday',
      );
      const b = KpopEvent(
        date: '03-09',
        type: 'birthday',
        artist: '슈가',
        group: 'BTS',
        situation: 'birthday',
      );

      expect(a, isNot(b));
    });
  });
}
