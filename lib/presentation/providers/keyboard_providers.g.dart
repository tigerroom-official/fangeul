// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$keyboardNotifierHash() => r'1cf2a941043ee84e210792e0101edc6db6f4348d';

/// 키보드 상태 관리 Notifier.
///
/// CAPS 토글과 원샷 소비를 담당한다.
/// [KoreanKeyboard] 위젯과 변환기 화면에서 사용한다.
///
/// Copied from [KeyboardNotifier].
@ProviderFor(KeyboardNotifier)
final keyboardNotifierProvider =
    AutoDisposeNotifierProvider<KeyboardNotifier, KeyboardState>.internal(
  KeyboardNotifier.new,
  name: r'keyboardNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$keyboardNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$KeyboardNotifier = AutoDisposeNotifier<KeyboardState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
