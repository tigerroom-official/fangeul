import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/router/app_router.dart';
import 'package:fangeul/presentation/theme/fangeul_colors.dart';
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
    final userLocale = ref.watch(localeNotifierProvider);
    final seedColor = ref.watch(themeColorNotifierProvider);
    final textColor = seedColor != null
        ? ref.read(themeColorNotifierProvider.notifier).customTextColor
        : null;

    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: seedColor != null
            ? (isDark
                ? ColorScheme.fromSeed(
                        seedColor: seedColor, brightness: Brightness.dark)
                    .surface
                : ColorScheme.fromSeed(
                        seedColor: seedColor, brightness: Brightness.light)
                    .surface)
            : (isDark
                ? FangeulColors.darkBackground
                : FangeulColors.lightBackground),
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: MaterialApp.router(
        title: UiStrings.appName,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: userLocale, // null → 시스템 언어 자동감지
        theme: seedColor != null
            ? FangeulTheme.dynamicLight(seedColor, customTextColor: textColor)
            : FangeulTheme.light(),
        darkTheme: seedColor != null
            ? FangeulTheme.dynamicDark(seedColor, customTextColor: textColor)
            : FangeulTheme.dark(),
        themeMode: themeMode,
        routerConfig: router,
        scrollBehavior: const _NoStretchScrollBehavior(),
      ),
    );
  }
}
