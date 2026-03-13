import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/services/iap_products.dart';

/// 번들 노출/비노출 조건 테스트.
///
/// _IapPurchaseSection은 private이므로
/// 조건 로직을 유닛 테스트한다.
void main() {
  /// 번들 표시 여부를 결정하는 로직 (위젯과 동일).
  bool shouldShowBundle(bool hasPicker, bool hasSlots) =>
      !hasPicker && !hasSlots;

  /// 전체 섹션 표시 여부.
  bool shouldHideSection(bool hasPicker, bool hasSlots) =>
      hasPicker && hasSlots;

  group('IAP purchase section visibility', () {
    test('should show all 3 buttons when neither purchased', () {
      expect(shouldHideSection(false, false), false);
      expect(shouldShowBundle(false, false), true);
    });

    test('should hide bundle when picker already purchased', () {
      expect(shouldShowBundle(true, false), false);
      expect(shouldHideSection(true, false), false);
    });

    test('should hide bundle when slots already purchased', () {
      expect(shouldShowBundle(false, true), false);
      expect(shouldHideSection(false, true), false);
    });

    test('should hide entire section when both purchased', () {
      expect(shouldHideSection(true, true), true);
    });
  });

  group('IAP SKU constants', () {
    test('themeSkuIds should contain all 3 theme SKUs', () {
      expect(IapProducts.themeSkuIds, contains(IapProducts.themeCustomColor));
      expect(IapProducts.themeSkuIds, contains(IapProducts.themeSlots));
      expect(IapProducts.themeSkuIds, contains(IapProducts.themeBundle));
      expect(IapProducts.themeSkuIds.length, 3);
    });

    test('allIds should equal themeSkuIds', () {
      expect(IapProducts.allIds, IapProducts.themeSkuIds);
      expect(IapProducts.allIds.length, 3);
    });
  });
}
