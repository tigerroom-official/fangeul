import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/services/iap_products.dart';

void main() {
  group('IapProducts', () {
    test('should define all theme SKU IDs', () {
      expect(IapProducts.themeCustomColor, 'fangeul_theme_custom_color');
      expect(IapProducts.themeSlots, 'fangeul_theme_slots');
      expect(IapProducts.themeBundle, 'fangeul_theme_bundle');
    });

    test('should have all IDs in allIds list', () {
      expect(IapProducts.allIds, hasLength(3));
      expect(IapProducts.allIds, contains(IapProducts.themeCustomColor));
      expect(IapProducts.allIds, contains(IapProducts.themeSlots));
      expect(IapProducts.allIds, contains(IapProducts.themeBundle));
    });

    test('should have unique SKU IDs', () {
      final ids = IapProducts.allIds.toSet();
      expect(ids.length, IapProducts.allIds.length);
    });

    test('should use fangeul_ prefix for all SKUs', () {
      for (final id in IapProducts.allIds) {
        expect(id, startsWith('fangeul_'));
      }
    });

    test('themeSkuIds should contain 3 theme SKUs', () {
      expect(IapProducts.themeSkuIds, hasLength(3));
      expect(IapProducts.themeSkuIds, contains(IapProducts.themeCustomColor));
      expect(IapProducts.themeSkuIds, contains(IapProducts.themeSlots));
      expect(IapProducts.themeSkuIds, contains(IapProducts.themeBundle));
    });

    test('allIds should equal themeSkuIds', () {
      expect(IapProducts.allIds, IapProducts.themeSkuIds);
    });
  });
}
