/// Google Play IAP SKU 정의.
///
/// 테마 커스터마이징 일회성 구매 상품 3-SKU. 구독은 Phase 7+.
abstract final class IapProducts {
  /// 테마 배경·글자색 자유선택 (₩990).
  static const themeCustomColor = 'fangeul_theme_custom_color';

  /// 테마 슬롯 3개 추가 (₩990).
  static const themeSlots = 'fangeul_theme_slots';

  /// 테마 전체 번들 — 피커 + 슬롯 (₩1,500).
  static const themeBundle = 'fangeul_theme_bundle';

  /// 테마 SKU 목록.
  static const themeSkuIds = [themeCustomColor, themeSlots, themeBundle];

  /// 전체 SKU 목록.
  static const allIds = themeSkuIds;
}
