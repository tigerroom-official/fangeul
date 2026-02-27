import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/presentation/screens/converter_screen.dart';
import 'package:fangeul/presentation/screens/home_screen.dart';
import 'package:fangeul/presentation/screens/phrases_screen.dart';
import 'package:fangeul/presentation/screens/settings_screen.dart';
import 'package:fangeul/presentation/widgets/shell_scaffold.dart';

part 'app_router.g.dart';

/// 앱 라우터 Provider.
///
/// [StatefulShellRoute.indexedStack]로 3탭(홈/변환기/문구) 네비게이션 구성.
/// 설정 화면은 독립 라우트.
@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/home',
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
    ],
  );
}
