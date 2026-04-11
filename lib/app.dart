import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/choeae_color_provider.dart';
import 'package:fangeul/presentation/providers/iap_provider.dart';
import 'package:fangeul/presentation/router/app_router.dart';
import 'package:fangeul/presentation/widgets/iap_error_dialog.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/theme/choeae_color_config.dart';
import 'package:fangeul/presentation/theme/fangeul_theme.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

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

    // Determine effective brightness.
    // custom: seed tone이 brightness를 자동 결정 (시스템 모드 무시).
    // palette: ThemeMode 설정에 따름.
    final bool effectiveDark;
    final ThemeMode effectiveThemeMode;
    final ThemeData lightTheme;
    final ThemeData darkTheme;

    if (choeaeColor is ChoeaeColorCustom) {
      // Seed tone < 50 → dark, >= 50 → light
      final seedTone = Hct.fromInt(choeaeColor.seedColor.toARGB32()).tone;
      effectiveDark = seedTone < 50;
      final derivedBrightness =
          effectiveDark ? Brightness.dark : Brightness.light;
      final singleTheme = FangeulTheme.build(
        brightness: derivedBrightness,
        choeaeColor: choeaeColor,
      );
      lightTheme = singleTheme;
      darkTheme = singleTheme;
      effectiveThemeMode = effectiveDark ? ThemeMode.dark : ThemeMode.light;
    } else {
      effectiveDark = themeMode == ThemeMode.dark ||
          (themeMode == ThemeMode.system &&
              MediaQuery.platformBrightnessOf(context) == Brightness.dark);
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
            .surface,
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
        builder: (context, child) => _IapErrorListener(child: child!),
      ),
    );
  }
}

/// MaterialApp 내부에서 IAP 에러를 감지하여 다이얼로그를 표시한다.
///
/// [MaterialApp.builder]로 삽입된다.
/// [rootNavigatorKey.currentContext]로 Navigator 아래 context를 확보.
/// [useRootNavigator: false]로 GoRouter의 Navigator에서 직접 dialog를 표시.
class _IapErrorListener extends ConsumerWidget {
  const _IapErrorListener({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(iapErrorProvider, (prev, next) {
      if (next == null) return;
      ref.read(iapErrorProvider.notifier).state = null;
      final navContext = rootNavigatorKey.currentContext;
      if (navContext != null && navContext.mounted) {
        showIapErrorDialog(navContext);
      }
    });
    return child;
  }
}
