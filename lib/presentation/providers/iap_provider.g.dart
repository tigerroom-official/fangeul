// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iap_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$iapStartingPriceHash() => r'353e5f9903701ab233f45461e2bb97529337541d';

/// 최저 테마 IAP 가격 (로컬라이즈된 문자열).
///
/// 즐겨찾기 제한 메시지에서 "₩990부터" 대신 `ProductDetails.price` 사용.
/// 상품 미로딩 시 null 반환.
///
/// Copied from [iapStartingPrice].
@ProviderFor(iapStartingPrice)
final iapStartingPriceProvider = AutoDisposeProvider<String?>.internal(
  iapStartingPrice,
  name: r'iapStartingPriceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$iapStartingPriceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IapStartingPriceRef = AutoDisposeProviderRef<String?>;
String _$iapServiceHash() => r'ea5866b1a877b4b9a3609244becc4345291c1e0b';

/// IapService 인스턴스 Provider.
///
/// 앱 시작 시 초기화. 구매 성공 시 SKU별 분기하여 MonetizationNotifier 연동.
/// 테스트에서 mock으로 override 가능.
///
/// Copied from [iapService].
@ProviderFor(iapService)
final iapServiceProvider = Provider<IapService>.internal(
  iapService,
  name: r'iapServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$iapServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IapServiceRef = ProviderRef<IapService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
