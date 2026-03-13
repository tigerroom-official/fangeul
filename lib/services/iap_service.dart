import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:fangeul/services/iap_products.dart';

/// IAP 구매 플로우 관리 서비스.
///
/// Google Play 일회성 구매(non-consumable)를 처리한다.
/// 구매 성공 시 [onPurchased] 콜백으로 SKU ID를 전달하고,
/// MonetizationNotifier의 해금 메서드와 연동한다.
class IapService {
  IapService({InAppPurchase? iap}) : _iap = iap ?? InAppPurchase.instance;

  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;

  /// 상품 정보 캐시.
  final Map<String, ProductDetails> _products = {};

  /// IAP 초기화.
  ///
  /// [onPurchased] 구매 성공 시 팩 ID 콜백 (await하여 상태 저장 보장).
  /// [onError] 구매 실패 시 에러 메시지 콜백.
  /// [onProductsLoaded] 상품 정보 로드 완료 시 콜백.
  Future<void> initialize({
    required Future<void> Function(String packId) onPurchased,
    required void Function(String error) onError,
    void Function()? onProductsLoaded,
  }) async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      debugPrint('[IapService] IAP not available');
      onProductsLoaded?.call();
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      (purchases) async {
        for (final purchase in purchases) {
          await _handlePurchase(
            purchase,
            onPurchased: onPurchased,
            onError: onError,
          );
        }
      },
      onError: (Object error) {
        debugPrint('[IapService] purchaseStream error: $error');
      },
    );

    await _loadProducts();
    onProductsLoaded?.call();
  }

  /// 상품 정보 로드.
  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails(
      IapProducts.allIds.toSet(),
    );

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
          '[IapService] not found SKUs: ${response.notFoundIDs.join(', ')}');
    }

    for (final product in response.productDetails) {
      _products[product.id] = product;
    }
  }

  /// 상품 정보 조회. null이면 로드 실패.
  ProductDetails? getProduct(String skuId) => _products[skuId];

  /// 로드된 모든 상품 목록.
  List<ProductDetails> get allProducts => _products.values.toList();

  /// IAP 사용 가능 여부.
  bool get isAvailable => _isAvailable;

  /// 구매 시작.
  ///
  /// [skuId]에 해당하는 상품을 구매 요청한다.
  /// 결과는 purchaseStream을 통해 [onPurchased] 또는 [onError]로 전달.
  Future<bool> buyPack(String skuId) async {
    final product = _products[skuId];
    if (product == null) {
      debugPrint('[IapService] product not found: $skuId');
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// 구매 복원 (기기 변경 대응).
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// 개별 구매 처리.
  Future<void> _handlePurchase(
    PurchaseDetails purchase, {
    required Future<void> Function(String packId) onPurchased,
    required void Function(String error) onError,
  }) async {
    switch (purchase.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // SKU allowlist 검증
        if (!IapProducts.allIds.contains(purchase.productID)) {
          debugPrint(
              '[IapService] unknown SKU: ${purchase.productID} — skipping');
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          return;
        }
        // 구매/복원 성공 — 상태 저장 먼저, completePurchase 후
        await onPurchased(purchase.productID);
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }

      case PurchaseStatus.error:
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        onError(purchase.error?.message ?? 'purchase_failed');

      case PurchaseStatus.pending:
        debugPrint('[IapService] purchase pending: ${purchase.productID}');

      case PurchaseStatus.canceled:
        debugPrint('[IapService] purchase canceled: ${purchase.productID}');
    }
  }

  /// 리소스 해제.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
