import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/services/iap_products.dart';

void main() {
  group('IapProducts', () {
    test('should define all SKU IDs', () {
      expect(IapProducts.starterPack, 'fangeul_color_starter');
      expect(IapProducts.purpleDream, 'fangeul_color_purple_dream');
      expect(IapProducts.goldenHour, 'fangeul_color_golden_hour');
      expect(IapProducts.concertSky, 'fangeul_color_concert_sky');
      expect(IapProducts.dawnLightstick, 'fangeul_color_dawn_lightstick');
    });

    test('should have all IDs in allIds list', () {
      expect(IapProducts.allIds, hasLength(5));
      expect(IapProducts.allIds, contains(IapProducts.starterPack));
      expect(IapProducts.allIds, contains(IapProducts.purpleDream));
      expect(IapProducts.allIds, contains(IapProducts.goldenHour));
      expect(IapProducts.allIds, contains(IapProducts.concertSky));
      expect(IapProducts.allIds, contains(IapProducts.dawnLightstick));
    });

    test('should have unique SKU IDs', () {
      final ids = IapProducts.allIds.toSet();
      expect(ids.length, IapProducts.allIds.length);
    });

    test('should use fangeul_color_ prefix', () {
      for (final id in IapProducts.allIds) {
        expect(id, startsWith('fangeul_color_'));
      }
    });
  });
}
