import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/data/models/color_pack.dart';

void main() {
  group('ColorPack', () {
    test('should create with required fields and defaults', () {
      const pack = ColorPack(
        id: 'purple_dream',
        nameKo: '퍼플 드림',
        nameEn: 'Purple Dream',
        primaryColor: '#A855F7',
        secondaryColor: '#7C3AED',
        skuId: 'fangeul_color_purple_dream',
        priceKrw: 1900,
      );

      expect(pack.id, 'purple_dream');
      expect(pack.nameKo, '퍼플 드림');
      expect(pack.nameEn, 'Purple Dream');
      expect(pack.primaryColor, '#A855F7');
      expect(pack.secondaryColor, '#7C3AED');
      expect(pack.skuId, 'fangeul_color_purple_dream');
      expect(pack.priceKrw, 1900);
      expect(pack.phraseCount, 50);
      expect(pack.pronunciationCount, 30);
      expect(pack.iapOnly, false);
    });

    test('should serialize to JSON and back', () {
      const pack = ColorPack(
        id: 'golden_hour',
        nameKo: '골든 아워',
        nameEn: 'Golden Hour',
        primaryColor: '#F59E0B',
        secondaryColor: '#D97706',
        skuId: 'fangeul_color_golden_hour',
        priceKrw: 1900,
        phraseCount: 50,
        pronunciationCount: 30,
        iapOnly: false,
      );

      final json = pack.toJson();
      final restored = ColorPack.fromJson(json);
      expect(restored, pack);
    });

    test('should handle iapOnly flag', () {
      const pack = ColorPack(
        id: 'concert_sky',
        nameKo: '그날 콘서트 하늘',
        nameEn: 'Concert Sky',
        primaryColor: '#3B82F6',
        secondaryColor: '#1D4ED8',
        skuId: 'fangeul_color_concert_sky',
        priceKrw: 1900,
        iapOnly: true,
      );

      expect(pack.iapOnly, true);
    });

    test('should parse from JSON with custom counts', () {
      const jsonStr = '{'
          '"id":"starter_pack",'
          '"name_ko":"첫 만남",'
          '"name_en":"First Meet",'
          '"primary_color":"#22C55E",'
          '"secondary_color":"#15803D",'
          '"sku_id":"fangeul_color_starter",'
          '"price_krw":990,'
          '"phrase_count":20,'
          '"pronunciation_count":10,'
          '"iap_only":false'
          '}';

      final pack = ColorPack.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );

      expect(pack.id, 'starter_pack');
      expect(pack.priceKrw, 990);
      expect(pack.phraseCount, 20);
      expect(pack.pronunciationCount, 10);
    });

    test('should parse color_packs.json format', () {
      // 실제 JSON 파일 형식 검증
      const packsJson = '{"packs":['
          '{"id":"purple_dream","name_ko":"퍼플 드림","name_en":"Purple Dream",'
          '"primary_color":"#A855F7","secondary_color":"#7C3AED",'
          '"sku_id":"fangeul_color_purple_dream","price_krw":1900,'
          '"phrase_count":50,"pronunciation_count":30,"iap_only":false}'
          ']}';

      final decoded = jsonDecode(packsJson) as Map<String, dynamic>;
      final packList = (decoded['packs'] as List)
          .map((e) => ColorPack.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(packList, hasLength(1));
      expect(packList.first.id, 'purple_dream');
      expect(packList.first.skuId, 'fangeul_color_purple_dream');
    });

    test('should support equality', () {
      const pack1 = ColorPack(
        id: 'test',
        nameKo: '테스트',
        nameEn: 'Test',
        primaryColor: '#000000',
        secondaryColor: '#111111',
        skuId: 'sku_test',
        priceKrw: 100,
      );
      const pack2 = ColorPack(
        id: 'test',
        nameKo: '테스트',
        nameEn: 'Test',
        primaryColor: '#000000',
        secondaryColor: '#111111',
        skuId: 'sku_test',
        priceKrw: 100,
      );

      expect(pack1, pack2);
      expect(pack1.hashCode, pack2.hashCode);
    });
  });
}
