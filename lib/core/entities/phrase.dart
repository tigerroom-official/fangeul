import 'package:freezed_annotation/freezed_annotation.dart';

part 'phrase.freezed.dart';
part 'phrase.g.dart';

/// 단일 팬 문구.
///
/// K-pop 팬이 아이돌에게 보낼 수 있는 한국어 문구 하나를 표현한다.
/// [ko] 한글 원문, [roman] 로마자 발음, [translations] 다국어 번역을 포함.
@freezed
class Phrase with _$Phrase {
  const factory Phrase({
    /// 한글 원문 (예: "사랑해요")
    required String ko,

    /// 로마자 발음 (예: "saranghaeyo")
    required String roman,

    /// 문구 사용 맥락 설명 (예: "General love expression, polite form")
    required String context,

    /// 분류 태그 (예: ["love", "daily"])
    @Default([]) List<String> tags,

    /// 다국어 번역 — 키: 언어 코드, 값: 번역문
    @Default({}) Map<String, String> translations,

    /// 상황 태그 (birthday / comeback / concert / daily / support)
    String? situation,

    /// 템플릿 문구 여부. true이면 {{group_name}} 등 치환 슬롯 포함.
    @JsonKey(name: 'is_template') @Default(false) bool isTemplate,
  }) = _Phrase;

  factory Phrase.fromJson(Map<String, dynamic> json) => _$PhraseFromJson(json);
}
