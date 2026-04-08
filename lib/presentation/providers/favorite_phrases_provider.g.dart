// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_phrases_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$favoritePhrasesNotifierHash() =>
    r'8a71e65d8b8c4012593174fd4aaa8d333979f443';

/// 즐겨찾기 문구 Provider.
///
/// 사용자가 탭한 문구의 한글(ko)을 Set으로 관리한다.
/// SharedPreferences에서 비동기 로드하므로 AsyncNotifier로 구현.
/// 소비자는 `AsyncValue<Set<String>>`을 받아 로딩 완료를 자연스럽게 대기한다.
///
/// Copied from [FavoritePhrasesNotifier].
@ProviderFor(FavoritePhrasesNotifier)
final favoritePhrasesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    FavoritePhrasesNotifier, Set<String>>.internal(
  FavoritePhrasesNotifier.new,
  name: r'favoritePhrasesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoritePhrasesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FavoritePhrasesNotifier = AutoDisposeAsyncNotifier<Set<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
