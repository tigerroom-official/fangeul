// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compact_phrase_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredCompactPhrasesHash() =>
    r'f660fefa3273e20e74ffbb0b3f2c915eb2cf7f7e';

/// 현재 필터에 맞는 문구 목록.
///
/// - favorites: 즐겨찾기 ko Set + 전체 팩에서 Phrase 룩업.
/// - pack: 해당 팩의 phrases (잠금 팩은 빈 리스트).
///
/// Copied from [filteredCompactPhrases].
@ProviderFor(filteredCompactPhrases)
final filteredCompactPhrasesProvider =
    AutoDisposeFutureProvider<List<Phrase>>.internal(
  filteredCompactPhrases,
  name: r'filteredCompactPhrasesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredCompactPhrasesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredCompactPhrasesRef = AutoDisposeFutureProviderRef<List<Phrase>>;
String _$isSelectedPackLockedHash() =>
    r'92298c1c28d3c087271cfc0fd940cf71a39f1bb9';

/// 현재 선택된 팩이 잠금 상태인지.
///
/// Copied from [isSelectedPackLocked].
@ProviderFor(isSelectedPackLocked)
final isSelectedPackLockedProvider = AutoDisposeFutureProvider<bool>.internal(
  isSelectedPackLocked,
  name: r'isSelectedPackLockedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isSelectedPackLockedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsSelectedPackLockedRef = AutoDisposeFutureProviderRef<bool>;
String _$compactPhraseFilterNotifierHash() =>
    r'463fec86781a1734b631e05f80a9ca66df66727b';

/// 간편모드 문구 필터 Notifier.
///
/// Copied from [CompactPhraseFilterNotifier].
@ProviderFor(CompactPhraseFilterNotifier)
final compactPhraseFilterNotifierProvider = AutoDisposeNotifierProvider<
    CompactPhraseFilterNotifier, CompactPhraseFilter>.internal(
  CompactPhraseFilterNotifier.new,
  name: r'compactPhraseFilterNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$compactPhraseFilterNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CompactPhraseFilterNotifier
    = AutoDisposeNotifier<CompactPhraseFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
