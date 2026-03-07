import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/choeae_color_provider.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/router/app_router.dart';
import 'package:fangeul/presentation/theme/choeae_color_config.dart';
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
    final choeaeColor = ref.watch(choeaeColorNotifierProvider);

    // Determine effective brightness — custom theme can override system setting
    final Brightness? brightOverride = choeaeColor is ChoeaeColorCustom
        ? choeaeColor.brightnessOverride
        : null;

    final bool effectiveDark;
    if (brightOverride != null) {
      effectiveDark = brightOverride == Brightness.dark;
    } else {
      effectiveDark = themeMode == ThemeMode.dark ||
          (themeMode == ThemeMode.system &&
              MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    }

    // Build themes — brightness override forces identical light/dark themes
    final ThemeMode effectiveThemeMode;
    final ThemeData lightTheme;
    final ThemeData darkTheme;

    if (brightOverride != null) {
      // Custom theme with brightness override: same theme for both slots
      final overriddenTheme = FangeulTheme.build(
        brightness: brightOverride,
        choeaeColor: choeaeColor,
      );
      lightTheme = overriddenTheme;
      darkTheme = overriddenTheme;
      effectiveThemeMode = brightOverride == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
    } else {
      lightTheme = FangeulTheme.build(
        brightness: Brightness.light,
        choeaeColor: choeaeColor,
      );
      darkTheme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: choeaeColor,
      );
      effectiveThemeMode = themeMode;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            effectiveDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: choeaeColor
            .buildColorScheme(
                effectiveDark ? Brightness.dark : Brightness.light)
            .surfaceContainerLowest,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            effectiveDark ? Brightness.light : Brightness.dark,
      ),
      child: MaterialApp.router(
        title: UiStrings.appName,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: L.supportedLocales,
        locale: userLocale, // null → 시스템 언어 자동감지
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: effectiveThemeMode,
        routerConfig: router,
        scrollBehavior: const _NoStretchScrollBehavior(),
      ),
    );
  }
}
