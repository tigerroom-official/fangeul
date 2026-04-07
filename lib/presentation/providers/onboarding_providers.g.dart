// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isOnboardingDoneHash() => r'fa87574bcf8f5b709cc78dbc02481356ced9c7be';

/// 온보딩 완료 여부를 SharedPreferences에서 읽는다.
///
/// 배너 광고 가드 조건으로 사용: 온보딩 미완료 시 배너 숨김.
/// `keepAlive: true` — 앱 실행 중 dispose 방지.
///
/// Copied from [isOnboardingDone].
@ProviderFor(isOnboardingDone)
final isOnboardingDoneProvider = Provider<bool>.internal(
  isOnboardingDone,
  name: r'isOnboardingDoneProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isOnboardingDoneHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsOnboardingDoneRef = ProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
