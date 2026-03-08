// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'choeae_color_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$choeaeColorNotifierHash() =>
    r'063d3aac0bd5a66094636cbde48561a3be2f954e';

/// 최애색 상태 관리.
///
/// `ChoeaeColorConfig.palette('midnight')`이 기본값.
/// SharedPreferences에 `choeae_type` + `choeae_value` + `choeae_text_override` 저장.
///
/// Copied from [ChoeaeColorNotifier].
@ProviderFor(ChoeaeColorNotifier)
final choeaeColorNotifierProvider =
    NotifierProvider<ChoeaeColorNotifier, ChoeaeColorConfig>.internal(
  ChoeaeColorNotifier.new,
  name: r'choeaeColorNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$choeaeColorNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChoeaeColorNotifier = Notifier<ChoeaeColorConfig>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
