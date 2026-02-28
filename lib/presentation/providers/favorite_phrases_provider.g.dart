// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_phrases_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$favoritePhrasesNotifierHash() =>
    r'2856bf92acadef1a1276df41483d3da85862c290';

/// 즐겨찾기 문구 Provider.
///
/// 사용자가 탭한 문구의 한글(ko)을 Set으로 관리한다.
/// shared_preferences에 persist.
///
/// Copied from [FavoritePhrasesNotifier].
@ProviderFor(FavoritePhrasesNotifier)
final favoritePhrasesNotifierProvider =
    AutoDisposeNotifierProvider<FavoritePhrasesNotifier, Set<String>>.internal(
  FavoritePhrasesNotifier.new,
  name: r'favoritePhrasesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoritePhrasesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FavoritePhrasesNotifier = AutoDisposeNotifier<Set<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
