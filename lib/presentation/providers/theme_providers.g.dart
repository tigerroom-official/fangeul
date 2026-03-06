// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'd6ff5a76096f5cc5efc48aeb27532f2ca5ed6058';

/// SharedPreferences 인스턴스 -- main.dart에서 override 필수.
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = Provider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = ProviderRef<SharedPreferences>;
String _$themeModeNotifierHash() => r'6e0c948f34ceef3af34bb80f3c888901ef58e36c';

/// ThemeMode 상태 관리.
///
/// 기본값: [ThemeMode.dark] (패널 결정).
/// SharedPreferences에 'theme_mode' 키로 persist.
///
/// Copied from [ThemeModeNotifier].
@ProviderFor(ThemeModeNotifier)
final themeModeNotifierProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>.internal(
  ThemeModeNotifier.new,
  name: r'themeModeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeModeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ThemeModeNotifier = Notifier<ThemeMode>;
String _$localeNotifierHash() => r'93c4083d3d359e7f883a7097d4e598d89899cd08';

/// 앱 Locale 상태 관리.
///
/// `null` = 시스템 언어 자동감지, `Locale('ko')` 등 = 명시적 오버라이드.
/// SharedPreferences에 'user_locale' 키로 persist.
///
/// Copied from [LocaleNotifier].
@ProviderFor(LocaleNotifier)
final localeNotifierProvider =
    NotifierProvider<LocaleNotifier, Locale?>.internal(
  LocaleNotifier.new,
  name: r'localeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocaleNotifier = Notifier<Locale?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
