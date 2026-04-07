// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionConversionShownHash() =>
    r'7d2ccdf65627b15b47efa4280895dfbd23dae97f';

/// 전환 트리거 팝업 이번 세션에서 표시 여부.
///
/// 세션 당 1회만 표시. keepAlive: 위젯 unmount 후에도 유지.
///
/// Copied from [SessionConversionShown].
@ProviderFor(SessionConversionShown)
final sessionConversionShownProvider =
    NotifierProvider<SessionConversionShown, bool>.internal(
  SessionConversionShown.new,
  name: r'sessionConversionShownProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionConversionShownHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionConversionShown = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
