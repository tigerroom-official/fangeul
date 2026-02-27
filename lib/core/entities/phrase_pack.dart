import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:fangeul/core/entities/phrase.dart';

part 'phrase_pack.freezed.dart';
part 'phrase_pack.g.dart';

/// 문구 팩 — 카테고리별로 묶인 [Phrase] 컬렉션.
///
/// 예: "Love & Support" 팩, "Birthday Messages" 팩.
/// [isFree]가 false이면 보상형 광고 등으로 해금해야 사용 가능.
@freezed
class PhrasePack with _$PhrasePack {
  const factory PhrasePack({
    /// 팩 고유 식별자 (예: "basic_love")
    required String id,

    /// 영문 팩 이름 (예: "Love & Support")
    required String name,

    /// 한국어 팩 이름 (예: "사랑 & 응원")
    required String nameKo,

    /// 무료 여부. false이면 [unlockType]으로 해금 필요.
    @Default(true) bool isFree,

    /// 해금 방식 (예: "rewarded_ad"). [isFree]가 true이면 null.
    String? unlockType,

    /// 팩에 포함된 문구 목록
    @Default([]) List<Phrase> phrases,
  }) = _PhrasePack;

  factory PhrasePack.fromJson(Map<String, dynamic> json) =>
      _$PhrasePackFromJson(json);
}
