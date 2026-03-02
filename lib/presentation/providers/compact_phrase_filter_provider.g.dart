// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compact_phrase_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredCompactPhrasesHash() =>
    r'49badc56d6d84a221726e79b70da36463c9fb54c';

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
    r'50f19126128bcb511ad700fad4a7a6528dc4f837';

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
    r'ca62ca7b503c3dc7944092542bedebf52425a8c5';

/// 간편모드 문구 필터 Notifier.
///
/// SharedPreferences에 마지막 선택 필터를 저장하여 재시작 시 복원한다.
/// 듀얼 FlutterEngine 환경에서 cross-engine sync를 위해 `prefs.reload()` 수행.
///
/// Copied from [CompactPhraseFilterNotifier].
@ProviderFor(CompactPhraseFilterNotifier)
final compactPhraseFilterNotifierProvider = AutoDisposeAsyncNotifierProvider<
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
    = AutoDisposeAsyncNotifier<CompactPhraseFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
