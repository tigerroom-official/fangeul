// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$remoteConfigServiceHash() =>
    r'f613fb53fbbc0e25674839ec4baad3a0055d1783';

/// Remote Config 서비스 Provider.
///
/// main.dart에서 override하여 Firebase 또는 NoOp 구현체를 주입한다.
///
/// Copied from [remoteConfigService].
@ProviderFor(remoteConfigService)
final remoteConfigServiceProvider = Provider<RemoteConfigService>.internal(
  remoteConfigService,
  name: r'remoteConfigServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$remoteConfigServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RemoteConfigServiceRef = ProviderRef<RemoteConfigService>;
String _$remoteConfigValuesHash() =>
    r'300c27f9d6459d0ff1c08a7aa84140b9d934726b';

/// Remote Config 값 편의 Provider.
///
/// 서비스에서 현재 값을 읽어 반환한다.
///
/// Copied from [remoteConfigValues].
@ProviderFor(remoteConfigValues)
final remoteConfigValuesProvider =
    AutoDisposeProvider<RemoteConfigValues>.internal(
  remoteConfigValues,
  name: r'remoteConfigValuesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$remoteConfigValuesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RemoteConfigValuesRef = AutoDisposeProviderRef<RemoteConfigValues>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
