import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/color_pack.dart';
import 'package:fangeul/presentation/providers/color_pack_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// 테스트용 JSON 데이터.
  final testJson = jsonEncode({
    'packs': [
      {
        'id': 'test_pack',
        'name_ko': '테스트 팩',
        'name_en': 'Test Pack',
        'primary_color': '#FF0000',
        'secondary_color': '#CC0000',
        'sku_id': 'fangeul_test',
        'price_krw': 990,
        'phrase_count': 20,
        'pronunciation_count': 10,
        'iap_only': false,
      },
      {
        'id': 'premium_pack',
        'name_ko': '프리미엄 팩',
        'name_en': 'Premium Pack',
        'primary_color': '#A855F7',
        'secondary_color': '#7C3AED',
        'sku_id': 'fangeul_premium',
        'price_krw': 1900,
        'phrase_count': 50,
        'pronunciation_count': 30,
        'iap_only': true,
      },
    ],
  });

  setUp(() {
    // rootBundle mock 설정
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'flutter/assets',
      (message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        if (key == 'assets/color_packs/color_packs.json') {
          return Uint8List.fromList(utf8.encode(testJson)).buffer.asByteData();
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  group('colorPacksProvider', () {
    test('should load color packs from JSON asset', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // listen to keep auto-dispose provider alive
      container.listen(colorPacksProvider, (_, __) {});

      final packs = await container.read(colorPacksProvider.future);

      expect(packs, hasLength(2));
      expect(packs[0].id, 'test_pack');
      expect(packs[1].id, 'premium_pack');
    });

    test('should parse nameKo correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.listen(colorPacksProvider, (_, __) {});

      final packs = await container.read(colorPacksProvider.future);

      expect(packs[0].nameKo, '테스트 팩');
      expect(packs[1].nameKo, '프리미엄 팩');
    });

    test('should parse nameEn correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.listen(colorPacksProvider, (_, __) {});

      final packs = await container.read(colorPacksProvider.future);

      expect(packs[0].nameEn, 'Test Pack');
      expect(packs[1].nameEn, 'Premium Pack');
    });

    test('should parse price correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.listen(colorPacksProvider, (_, __) {});

      final packs = await container.read(colorPacksProvider.future);

      expect(packs[0].priceKrw, 990);
      expect(packs[1].priceKrw, 1900);
    });

    test('should parse phraseCount and pronunciationCount', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.listen(colorPacksProvider, (_, __) {});

      final packs = await container.read(colorPacksProvider.future);

      expect(packs[0].phraseCount, 20);
      expect(packs[0].pronunciationCount, 10);
      expect(packs[1].phraseCount, 50);
      expect(packs[1].pronunciationCount, 30);
    });

    test('should parse iapOnly flag', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.listen(colorPacksProvider, (_, __) {});

      final packs = await container.read(colorPacksProvider.future);

      expect(packs[0].iapOnly, false);
      expect(packs[1].iapOnly, true);
    });

    test('should parse color hex strings', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.listen(colorPacksProvider, (_, __) {});

      final packs = await container.read(colorPacksProvider.future);

      expect(packs[0].primaryColor, '#FF0000');
      expect(packs[0].secondaryColor, '#CC0000');
      expect(packs[1].primaryColor, '#A855F7');
      expect(packs[1].secondaryColor, '#7C3AED');
    });

    test('should parse skuId correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.listen(colorPacksProvider, (_, __) {});

      final packs = await container.read(colorPacksProvider.future);

      expect(packs[0].skuId, 'fangeul_test');
      expect(packs[1].skuId, 'fangeul_premium');
    });

    test('should return ColorPack instances', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.listen(colorPacksProvider, (_, __) {});

      final packs = await container.read(colorPacksProvider.future);

      expect(packs, isA<List<ColorPack>>());
      for (final pack in packs) {
        expect(pack, isA<ColorPack>());
      }
    });
  });
}
