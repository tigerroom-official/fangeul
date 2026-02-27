// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'converter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$converterNotifierHash() => r'94085a0a6e03879d4f97e180154a071eb4a2f89c';

/// 변환기 상태 관리.
///
/// [KeyboardConverter]와 [Romanizer] 엔진을 래핑하여
/// 입력 텍스트를 선택된 모드로 변환한다.
///
/// Copied from [ConverterNotifier].
@ProviderFor(ConverterNotifier)
final converterNotifierProvider =
    AutoDisposeNotifierProvider<ConverterNotifier, ConverterState>.internal(
  ConverterNotifier.new,
  name: r'converterNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$converterNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConverterNotifier = AutoDisposeNotifier<ConverterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
