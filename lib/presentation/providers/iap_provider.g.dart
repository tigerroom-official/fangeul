// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iap_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$iapServiceHash() => r'8d628a351b9af77d158528d92ae876239f8c2442';

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
