import 'package:fangeul/core/entities/phrase.dart';

/// 템플릿 문구의 슬롯을 실제 값으로 치환한다.
///
/// [phrase]의 [Phrase.isTemplate]이 false이면 원본을 그대로 반환한다.
/// true이면 [ko], [roman], [translations] 내의 `{{group_name}}`을
/// [groupName]으로 치환한 새 [Phrase]를 반환한다.
///
/// [memberName]이 주어지면 `{{member_name}}`도 함께 치환한다.
/// null이면 `{{member_name}}` 슬롯은 그대로 유지된다.
Phrase resolveTemplatePhrase(
  Phrase phrase,
  String groupName, {
  String? memberName,
}) {
  if (!phrase.isTemplate) return phrase;

  String replace(String text) {
    var result = text.replaceAll('{{group_name}}', groupName);
    if (memberName != null) {
      result = result.replaceAll('{{member_name}}', memberName);
    }
    return result;
  }

  return phrase.copyWith(
    ko: replace(phrase.ko),
    roman: replace(phrase.roman),
    translations: phrase.translations.map(
      (lang, text) => MapEntry(lang, replace(text)),
    ),
  );
}

/// 문구가 `{{member_name}}` 슬롯을 포함하는지 확인한다.
///
/// [ko] 필드에 `{{member_name}}`이 존재하면 true를 반환한다.
/// 비템플릿 문구나 그룹 전용 템플릿은 false를 반환한다.
bool needsMemberName(Phrase phrase) =>
    phrase.ko.contains('{{member_name}}');

/// 문구 리스트에서 템플릿 문구를 필터링/치환한다.
///
/// - [idolName]이 null이면 `isTemplate == true`인 문구를 제거한다.
/// - [idolName]이 있으면 `{{group_name}}`을 치환한다.
/// - [memberName]이 null이면 `{{member_name}}`을 포함하는 템플릿은 제외한다.
/// - [memberName]이 있으면 `{{member_name}}`도 함께 치환하여 모두 포함한다.
List<Phrase> filterAndResolveTemplates(
  List<Phrase> phrases,
  String? idolName, {
  String? memberName,
}) {
  if (idolName == null) {
    return phrases.where((p) => !p.isTemplate).toList();
  }

  return phrases
      .where((p) =>
          !p.isTemplate || !needsMemberName(p) || memberName != null)
      .map((p) => resolveTemplatePhrase(p, idolName, memberName: memberName))
      .toList();
}
