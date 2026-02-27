import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/router/app_router.dart';
import 'package:fangeul/presentation/theme/fangeul_theme.dart';

/// Android 12+의 stretch 오버스크롤을 글로우 효과로 대체한다.
///
/// 카드/텍스트가 고무줄처럼 늘어나는 것을 방지하기 위함.
class _NoStretchScrollBehavior extends ScrollBehavior {
  const _NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: Theme.of(context).colorScheme.primary,
      child: child,
    );
  }
}

/// Fangeul 앱의 루트 위젯.
class FangeulApp extends ConsumerWidget {
  /// Creates the root [FangeulApp] widget.
  const FangeulApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);

    return MaterialApp.router(
      title: 'Fangeul',
      debugShowCheckedModeBanner: false,
      theme: FangeulTheme.light(),
      darkTheme: FangeulTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      scrollBehavior: const _NoStretchScrollBehavior(),
    );
  }
}
