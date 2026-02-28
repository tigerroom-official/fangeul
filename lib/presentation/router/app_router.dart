import 'dart:ui';

import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/presentation/screens/converter_screen.dart';
import 'package:fangeul/presentation/screens/home_screen.dart';
import 'package:fangeul/presentation/screens/mini_converter_screen.dart';
import 'package:fangeul/presentation/screens/phrases_screen.dart';
import 'package:fangeul/presentation/screens/settings_screen.dart';
import 'package:fangeul/presentation/widgets/shell_scaffold.dart';

part 'app_router.g.dart';

/// Kotlin [setInitialRoute]에서 설정된 경로 중 유효한 것만 사용.
const _validInitialRoutes = {'/home', '/mini-converter'};

/// 앱 라우터 Provider.
///
/// [StatefulShellRoute.indexedStack]로 3탭(홈/변환기/문구) 네비게이션 구성.
/// 설정 화면은 독립 라우트.
///
/// 미니 엔진에서는 [PlatformDispatcher.defaultRouteName]을 읽어
/// `/mini-converter`로 시작한다.
@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final platformRoute = PlatformDispatcher.instance.defaultRouteName;
  final initialLocation =
      _validInitialRoutes.contains(platformRoute) ? platformRoute : '/home';

  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ShellScaffold(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/converter',
                builder: (context, state) => const ConverterScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/phrases',
                builder: (context, state) => const PhrasesScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/mini-converter',
        builder: (context, state) => const MiniConverterScreen(),
      ),
    ],
  );
}
