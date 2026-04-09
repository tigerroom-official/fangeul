import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/presentation/providers/analytics_providers.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/services/analytics_events.dart';
import 'package:fangeul/services/iap_products.dart';
import 'package:fangeul/services/iap_service.dart';

part 'iap_provider.g.dart';

/// IAP 상품 정보 로드 완료 여부.
///
/// [iapServiceProvider] 초기화 시 상품 로드 완료되면 true로 전환.
/// 위젯에서 `ref.watch(iapProductsLoadedProvider)`로 리빌드 트리거.
final iapProductsLoadedProvider = StateProvider<bool>((ref) => false);

/// 최저 테마 IAP 가격 (로컬라이즈된 문자열).
///
/// 즐겨찾기 제한 메시지에서 "₩990부터" 대신 `ProductDetails.price` 사용.
/// 상품 미로딩 시 null 반환.
@riverpod
String? iapStartingPrice(IapStartingPriceRef ref) {
  // 로딩 완료 여부를 watch하여 로딩 후 리빌드 트리거
  final loaded = ref.watch(iapProductsLoadedProvider);
  if (!loaded) return null;

  final iap = ref.read(iapServiceProvider);
  return iap.getProduct(IapProducts.themeCustomColor)?.price;
}

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
      ref.read(analyticsServiceProvider).logEvent(
        AnalyticsEvents.iapPurchaseSuccess,
        {AnalyticsParams.skuId: productId},
      );
      final notifier = ref.read(monetizationNotifierProvider.notifier);
      switch (productId) {
        case IapProducts.themeCustomColor:
          await notifier.unlockThemePicker();
        case IapProducts.themeSlots:
          await notifier.unlockThemeSlots();
        case IapProducts.themeBundle:
          await notifier.unlockThemeBundle();
      }
    },
    onError: (error) {
      debugPrint('[IapProvider] error: $error');
      ref.read(analyticsServiceProvider).logEvent(
        AnalyticsEvents.iapPurchaseFailed,
      );
    },
    onProductsLoaded: () {
      ref.read(iapProductsLoadedProvider.notifier).state = true;
      // 상품 로드 완료 후 구매 복원 — 재설치/기기 변경 시 엔타이틀먼트 복구.
      // purchaseStream 리스너가 PurchaseStatus.restored를 처리한다.
      ref.read(analyticsServiceProvider).logEvent(
        AnalyticsEvents.iapRestorePurchase,
      );
      service.restorePurchases().catchError((Object e) {
        debugPrint('[IapProvider] auto-restore failed: $e');
      });
    },
  );

  ref.onDispose(service.dispose);
  return service;
}
