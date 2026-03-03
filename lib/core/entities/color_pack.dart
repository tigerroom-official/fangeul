import 'package:freezed_annotation/freezed_annotation.dart';

part 'color_pack.freezed.dart';
part 'color_pack.g.dart';

/// 감성 컬러 팩 — 색상 테마 + 문구/발음 번들.
///
/// IP 제한으로 아이돌/팬덤명 사용 불가 → 색상+감성 조합 이름 사용.
/// [iapOnly]가 true이면 보상형 광고로 해금 불가 (구매 전용).
@freezed
class ColorPack with _$ColorPack {
  const factory ColorPack({
    /// 팩 고유 식별자 (예: "purple_dream").
    required String id,

    /// 한국어 이름 (예: "퍼플 드림").
    required String nameKo,

    /// 영문 이름 (예: "Purple Dream").
    required String nameEn,

    /// 메인 컬러 hex (예: "#A855F7").
    required String primaryColor,

    /// 보조 컬러 hex (예: "#7C3AED").
    required String secondaryColor,

    /// Google Play SKU ID.
    required String skuId,

    /// 가격 (원).
    required int priceKrw,

    /// 포함 문구 수.
    @Default(50) int phraseCount,

    /// 포함 발음 수.
    @Default(30) int pronunciationCount,

    /// true이면 IAP 전용 (보상형 해금 불가).
    @Default(false) bool iapOnly,
  }) = _ColorPack;

  factory ColorPack.fromJson(Map<String, dynamic> json) =>
      _$ColorPackFromJson(json);
}
