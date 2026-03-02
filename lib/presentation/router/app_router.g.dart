// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$initialRouteOverrideHash() =>
    r'f8051f75f5766568b19a579696802bd6fdc2ab9b';

/// 첫 실행 시 온보딩 경로를 주입하기 위한 override.
///
/// Copied from [initialRouteOverride].
@ProviderFor(initialRouteOverride)
final initialRouteOverrideProvider = Provider<String?>.internal(
  initialRouteOverride,
  name: r'initialRouteOverrideProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initialRouteOverrideHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InitialRouteOverrideRef = ProviderRef<String?>;
String _$appRouterHash() => r'68dd2b1d5ec954ec28cf89978eba28a8dd3f739c';

/// 앱 라우터 Provider.
///
/// [StatefulShellRoute.indexedStack]로 3탭(홈/변환기/문구) 네비게이션 구성.
/// 설정 화면은 독립 라우트.
///
/// 미니 엔진에서는 [PlatformDispatcher.defaultRouteName]을 읽어
/// `/mini-converter`로 시작한다.
///
/// Copied from [appRouter].
@ProviderFor(appRouter)
final appRouterProvider = Provider<GoRouter>.internal(
  appRouter,
  name: r'appRouterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appRouterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppRouterRef = ProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
