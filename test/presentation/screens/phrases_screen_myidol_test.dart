import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/phrase.dart';

void main() {
  group('Template filtering', () {
    test('should not include template phrases in tag-filtered results', () {
      final phrases = [
        const Phrase(
          ko: '사랑해요',
          roman: 'saranghaeyo',
          context: 'love',
          tags: ['love'],
          translations: {'en': 'I love you'},
          situation: 'daily',
        ),
        const Phrase(
          ko: '{{group_name}} 사랑해요!',
          roman: '{{group_name}} saranghaeyo!',
          context: 'template',
          tags: ['love'],
          translations: {'en': 'I love {{group_name}}!'},
          situation: 'daily',
          isTemplate: true,
        ),
      ];

      final filtered = phrases.where((p) => !p.isTemplate).toList();
      expect(filtered.length, 1);
      expect(filtered.first.ko, '사랑해요');
      expect(filtered.any((p) => p.ko.contains('{{group_name}}')), isFalse);
    });
  });
}
