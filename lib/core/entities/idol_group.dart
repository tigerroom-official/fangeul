import 'package:freezed_annotation/freezed_annotation.dart';

part 'idol_group.freezed.dart';
part 'idol_group.g.dart';

/// K-pop 그룹 기본 정보.
///
/// 마이 아이돌 선택 및 템플릿 문구 치환에 사용되는 그룹 엔티티.
/// [id]는 고유 식별자, [nameEn]은 영문 표시명, [nameKo]는 한글 표시명.
@freezed
class IdolGroup with _$IdolGroup {
  const factory IdolGroup({
    /// 고유 식별자 (예: "bts")
    required String id,

    /// 영문 그룹명 (예: "BTS")
    @JsonKey(name: 'name_en') required String nameEn,

    /// 한글 그룹명 (예: "방탄소년단")
    @JsonKey(name: 'name_ko') required String nameKo,
  }) = _IdolGroup;

  factory IdolGroup.fromJson(Map<String, dynamic> json) =>
      _$IdolGroupFromJson(json);
}
