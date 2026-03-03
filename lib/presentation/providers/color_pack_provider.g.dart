// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_pack_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$colorPacksHash() => r'6df8a21b0f847f8368f3db212edc2d3b9450c863';

/// 컬러 팩 목록을 JSON 에셋에서 로드하는 Provider.
///
/// `assets/color_packs/color_packs.json`에서 팩 정보를 읽어
/// [ColorPack] 목록으로 변환한다.
///
/// Copied from [colorPacks].
@ProviderFor(colorPacks)
final colorPacksProvider = AutoDisposeFutureProvider<List<ColorPack>>.internal(
  colorPacks,
  name: r'colorPacksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$colorPacksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ColorPacksRef = AutoDisposeFutureProviderRef<List<ColorPack>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
