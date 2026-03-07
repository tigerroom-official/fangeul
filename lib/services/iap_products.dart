/// Google Play IAP SKU 정의.
///
/// 감성 컬러 팩 일회성 구매 상품. 구독은 Phase 7+.
abstract final class IapProducts {
  /// 첫 만남 팩 (₩990).
  static const starterPack = 'fangeul_color_starter';

  /// 퍼플 드림 팩 (₩1,900).
  static const purpleDream = 'fangeul_color_purple_dream';

  /// 골든 아워 팩 (₩1,900).
  static const goldenHour = 'fangeul_color_golden_hour';

  /// 그날 콘서트 하늘 팩 (₩1,900).
  static const concertSky = 'fangeul_color_concert_sky';

  /// 새벽 응원봉 잔광 팩 (₩1,900).
  static const dawnLightstick = 'fangeul_color_dawn_lightstick';

  /// 테마 배경·글자색 자유선택 (₩990).
  static const themeCustomColor = 'fangeul_theme_custom_color';

  /// 테마 슬롯 3개 추가 (₩990).
  static const themeSlots = 'fangeul_theme_slots';

  /// 테마 전체 번들 — 피커 + 슬롯 (₩1,500).
  static const themeBundle = 'fangeul_theme_bundle';

  /// 테마 SKU 목록.
  static const themeSkuIds = [themeCustomColor, themeSlots, themeBundle];

  /// 컬러 팩 SKU 목록.
  static const colorPackIds = [
    starterPack,
    purpleDream,
    goldenHour,
    concertSky,
    dawnLightstick,
  ];

  /// 전체 SKU 목록.
  static const allIds = [
    ...colorPackIds,
    ...themeSkuIds,
  ];
}
