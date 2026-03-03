// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monetization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monetizationStorageHash() =>
    r'e14b9efaeb71f42adbc8a242384fc1cd5132b151';

/// FlutterSecureStorage 인스턴스 Provider.
///
/// 테스트에서 mock으로 override 가능.
///
/// Copied from [monetizationStorage].
@ProviderFor(monetizationStorage)
final monetizationStorageProvider = Provider<FlutterSecureStorage>.internal(
  monetizationStorage,
  name: r'monetizationStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monetizationStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonetizationStorageRef = ProviderRef<FlutterSecureStorage>;
String _$isHoneymoonHash() => r'0104d1e777a16b30613f769da683b7029a1833f3';

/// 허니문 기간 활성 여부 편의 Provider.
///
/// Copied from [isHoneymoon].
@ProviderFor(isHoneymoon)
final isHoneymoonProvider = AutoDisposeProvider<bool>.internal(
  isHoneymoon,
  name: r'isHoneymoonProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isHoneymoonHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsHoneymoonRef = AutoDisposeProviderRef<bool>;
String _$isRewardedUnlockActiveHash() =>
    r'b242a9b7ede181f5a8ea085d9af96f54eea1d8e6';

/// 보상형 해금 활성 여부 편의 Provider.
///
/// Copied from [isRewardedUnlockActive].
@ProviderFor(isRewardedUnlockActive)
final isRewardedUnlockActiveProvider = AutoDisposeProvider<bool>.internal(
  isRewardedUnlockActive,
  name: r'isRewardedUnlockActiveProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isRewardedUnlockActiveHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsRewardedUnlockActiveRef = AutoDisposeProviderRef<bool>;
String _$favoriteSlotLimitHash() => r'bb13de5baada37945b2a84f21a6ba1420284c437';

/// 즐겨찾기 슬롯 제한 편의 Provider.
///
/// Copied from [favoriteSlotLimit].
@ProviderFor(favoriteSlotLimit)
final favoriteSlotLimitProvider = AutoDisposeProvider<int>.internal(
  favoriteSlotLimit,
  name: r'favoriteSlotLimitProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoriteSlotLimitHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FavoriteSlotLimitRef = AutoDisposeProviderRef<int>;
String _$monetizationNotifierHash() =>
    r'c9ceaf55c9c8894a40dc04f37b986541705fbc97';

/// 수익화 상태를 관리하는 중앙 Notifier.
///
/// 허니문, 보상형 광고, IAP, D-day 해금, TTS 제한 등
/// 모든 수익화 관련 상태를 [MonetizationState]로 통합 관리한다.
/// SecureStorage + HMAC 기반으로 변조를 방어한다.
///
/// Copied from [MonetizationNotifier].
@ProviderFor(MonetizationNotifier)
final monetizationNotifierProvider =
    AsyncNotifierProvider<MonetizationNotifier, MonetizationState>.internal(
  MonetizationNotifier.new,
  name: r'monetizationNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monetizationNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MonetizationNotifier = AsyncNotifier<MonetizationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
