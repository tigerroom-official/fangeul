import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/services/iap_products.dart';
import 'package:fangeul/services/iap_service.dart';

part 'iap_provider.g.dart';

/// IapService 인스턴스 Provider.
///
/// 앱 시작 시 초기화. 구매 성공 시 SKU별 분기하여 MonetizationNotifier 연동.
/// 테스트에서 mock으로 override 가능.
@Riverpod(keepAlive: true)
IapService iapService(IapServiceRef ref) {
  final service = IapService();
  service.initialize(
    onPurchased: (productId) async {
      debugPrint('[IapProvider] purchased: $productId');
      final notifier = ref.read(monetizationNotifierProvider.notifier);
      switch (productId) {
        case IapProducts.themeCustomColor:
          await notifier.unlockThemePicker();
        case IapProducts.themeSlots:
          await notifier.unlockThemeSlots();
        case IapProducts.themeBundle:
          await notifier.unlockThemeBundle();
        default:
          await notifier.addPurchasedPack(productId);
      }
    },
    onError: (error) {
      debugPrint('[IapProvider] error: $error');
    },
  );

  ref.onDispose(service.dispose);
  return service;
}
