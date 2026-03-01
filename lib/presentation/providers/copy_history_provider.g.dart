// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'copy_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$copyHistoryNotifierHash() =>
    r'3400be45b76003d4973e1cb6f9b7112e8d9fb01b';

/// 복사 이력 Provider.
///
/// 최근 복사한 텍스트를 시간순(최신 우선)으로 관리한다.
/// 최대 20개까지 유지하며, shared_preferences에 persist.
///
/// Copied from [CopyHistoryNotifier].
@ProviderFor(CopyHistoryNotifier)
final copyHistoryNotifierProvider =
    AutoDisposeNotifierProvider<CopyHistoryNotifier, List<String>>.internal(
  CopyHistoryNotifier.new,
  name: r'copyHistoryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$copyHistoryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CopyHistoryNotifier = AutoDisposeNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
