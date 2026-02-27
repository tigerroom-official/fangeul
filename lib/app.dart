import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/router/app_router.dart';
import 'package:fangeul/presentation/theme/fangeul_theme.dart';

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
    );
  }
}
