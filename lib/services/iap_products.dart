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

  /// 전체 SKU 목록.
  static const allIds = [
    starterPack,
    purpleDream,
    goldenHour,
    concertSky,
    dawnLightstick,
  ];
}
