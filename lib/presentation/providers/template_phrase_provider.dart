import 'package:fangeul/core/entities/phrase.dart';

/// 템플릿 문구의 `{{group_name}}`을 실제 그룹명으로 치환한다.
///
/// [phrase]의 [Phrase.isTemplate]이 false이면 원본을 그대로 반환한다.
/// true이면 [ko], [roman], [translations] 내의 `{{group_name}}`을
/// [groupName]으로 치환한 새 [Phrase]를 반환한다.
Phrase resolveTemplatePhrase(Phrase phrase, String groupName) {
  if (!phrase.isTemplate) return phrase;

  return phrase.copyWith(
    ko: phrase.ko.replaceAll('{{group_name}}', groupName),
    roman: phrase.roman.replaceAll('{{group_name}}', groupName),
    translations: phrase.translations.map(
      (lang, text) =>
          MapEntry(lang, text.replaceAll('{{group_name}}', groupName)),
    ),
  );
}

/// 문구 리스트에서 템플릿 문구를 필터링/치환한다.
///
/// - [idolName]이 null이면 `isTemplate == true`인 문구를 제거한다.
/// - [idolName]이 있으면 `{{group_name}}`을 치환하여 모든 문구를 포함한다.
List<Phrase> filterAndResolveTemplates(
  List<Phrase> phrases,
  String? idolName,
) {
  if (idolName == null) {
    return phrases.where((p) => !p.isTemplate).toList();
  }

  return phrases.map((p) => resolveTemplatePhrase(p, idolName)).toList();
}
