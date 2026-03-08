// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_slot_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeSlotNotifierHash() => r'346bcf57323176a293c75d88cff344ad749537a9';

/// 테마 슬롯 상태 관리.
///
/// 4개 슬롯(1 기본 + 3 구매). SharedPreferences에 JSON 배열로 저장.
///
/// Copied from [ThemeSlotNotifier].
@ProviderFor(ThemeSlotNotifier)
final themeSlotNotifierProvider =
    NotifierProvider<ThemeSlotNotifier, List<ThemeSlot>>.internal(
  ThemeSlotNotifier.new,
  name: r'themeSlotNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeSlotNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ThemeSlotNotifier = Notifier<List<ThemeSlot>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
