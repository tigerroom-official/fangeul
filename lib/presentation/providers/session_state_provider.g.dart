// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionBannerHiddenHash() =>
    r'947c4d1b45b7d772da777037e0b39e8bdc9f969d';

/// 세션 동안 배너 광고 숨김 여부.
///
/// 보상형 광고 1회 시청 시 true로 전환. 앱 프로세스 종료 시 리셋.
///
/// Copied from [SessionBannerHidden].
@ProviderFor(SessionBannerHidden)
final sessionBannerHiddenProvider =
    AutoDisposeNotifierProvider<SessionBannerHidden, bool>.internal(
  SessionBannerHidden.new,
  name: r'sessionBannerHiddenProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionBannerHiddenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionBannerHidden = AutoDisposeNotifier<bool>;
String _$sessionConversionShownHash() =>
    r'74e49bf5417367658edafd3e3da3aa327db73948';

/// 전환 트리거 팝업 이번 세션에서 표시 여부.
///
/// 세션 당 1회만 표시.
///
/// Copied from [SessionConversionShown].
@ProviderFor(SessionConversionShown)
final sessionConversionShownProvider =
    AutoDisposeNotifierProvider<SessionConversionShown, bool>.internal(
  SessionConversionShown.new,
  name: r'sessionConversionShownProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionConversionShownHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionConversionShown = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
