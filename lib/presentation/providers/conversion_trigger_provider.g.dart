// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversion_trigger_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shouldShowConversionTriggerHash() =>
    r'beeed568857bc4df005ff6a8bb14ed89f5f6bb48';

/// 전환 트리거 팝업 표시 조건 provider.
///
/// 다음 모든 조건 충족 시 true:
/// - Day 14+ (설치 후 14일 이상 경과)
/// - 보상형 광고 3회 소진
/// - 즐겨찾기 슬롯 포화
/// - 아직 IAP 구매 없음
///
/// Copied from [shouldShowConversionTrigger].
@ProviderFor(shouldShowConversionTrigger)
final shouldShowConversionTriggerProvider = AutoDisposeProvider<bool>.internal(
  shouldShowConversionTrigger,
  name: r'shouldShowConversionTriggerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shouldShowConversionTriggerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShouldShowConversionTriggerRef = AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
