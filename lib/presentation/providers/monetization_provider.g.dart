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
String _$monetizationRepositoryHash() =>
    r'a5d71795e1ba962e9c3256c08c7b5c8ea2ae17b9';

/// 수익화 Repository Provider.
///
/// presentation → core/ 인터페이스만 노출. data/ 구현은 여기서 조립.
/// 테스트에서 mock MonetizationRepository로 override 가능.
///
/// Copied from [monetizationRepository].
@ProviderFor(monetizationRepository)
final monetizationRepositoryProvider =
    Provider<MonetizationRepository>.internal(
  monetizationRepository,
  name: r'monetizationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monetizationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonetizationRepositoryRef = ProviderRef<MonetizationRepository>;
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
String _$isThemeTrialActiveHash() =>
    r'7f0c2040e4fd5cb9779dcbf1f0e70184cd7d6f7b';

/// 테마 체험 활성 여부 편의 Provider.
///
/// 체험 만료 시각에 자동 invalidation하여 배너 표시를 즉시 갱신한다.
///
/// Copied from [isThemeTrialActive].
@ProviderFor(isThemeTrialActive)
final isThemeTrialActiveProvider = AutoDisposeProvider<bool>.internal(
  isThemeTrialActive,
  name: r'isThemeTrialActiveProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isThemeTrialActiveHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsThemeTrialActiveRef = AutoDisposeProviderRef<bool>;
String _$isThemeUnlockedHash() => r'facc28554d8f0e800f48fff8c8680a8fa0476f35';

/// 보상형 광고로 테마 팔레트가 영구 해금되었는지 여부.
///
/// Copied from [isThemeUnlocked].
@ProviderFor(isThemeUnlocked)
final isThemeUnlockedProvider = AutoDisposeProvider<bool>.internal(
  isThemeUnlocked,
  name: r'isThemeUnlockedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isThemeUnlockedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsThemeUnlockedRef = AutoDisposeProviderRef<bool>;
String _$hasThemeSlotsHash() => r'1a8a3818b6b580a28a09319d9e7e9b22ac16e287';

/// 테마 슬롯 IAP 구매 여부 편의 Provider.
///
/// Copied from [hasThemeSlots].
@ProviderFor(hasThemeSlots)
final hasThemeSlotsProvider = AutoDisposeProvider<bool>.internal(
  hasThemeSlots,
  name: r'hasThemeSlotsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasThemeSlotsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasThemeSlotsRef = AutoDisposeProviderRef<bool>;
String _$hasThemePickerHash() => r'fb4d860cc075b5838c941fb5167e0317965b29d9';

/// 테마 피커 IAP 구매 여부 편의 Provider.
///
/// Copied from [hasThemePicker].
@ProviderFor(hasThemePicker)
final hasThemePickerProvider = AutoDisposeProvider<bool>.internal(
  hasThemePicker,
  name: r'hasThemePickerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasThemePickerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasThemePickerRef = AutoDisposeProviderRef<bool>;
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
    r'5d12c75ddd2751cecde1f47d89687fd1539fd076';

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
