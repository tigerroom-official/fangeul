import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';

/// 3탭 BottomNavigationBar 쉘.
///
/// [StatefulShellRoute.indexedStack]의 builder에서 사용.
/// 홈, 변환기, 문구 3개 탭을 제공한다.
///
/// 버블 엔진에서 변경된 SharedPreferences를 메인 엔진으로 동기화하기 위해
/// [WidgetsBindingObserver]를 사용하여 앱 resumed 시 provider를 invalidate한다.
class ShellScaffold extends ConsumerStatefulWidget {
  /// Creates the [ShellScaffold] widget.
  const ShellScaffold({super.key, required this.navigationShell});

  /// go_router가 주입하는 네비게이션 쉘.
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends ConsumerState<ShellScaffold>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncFromBubbleEngine();
    }
  }

  /// 버블 엔진에서 변경된 SharedPreferences 데이터를 메인 엔진으로 동기화한다.
  ///
  /// 듀얼 FlutterEngine 환경에서 버블 엔진이 즐겨찾기, 테마 등을 변경할 수 있다.
  /// 메인 앱으로 복귀 시 SharedPreferences 캐시를 reload한 뒤
  /// 관련 provider를 invalidate하여 최신 데이터를 반영한다.
  Future<void> _syncFromBubbleEngine() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.reload();
    if (!mounted) return;
    ref.invalidate(favoritePhrasesNotifierProvider);
    ref.invalidate(myIdolNotifierProvider);
    ref.invalidate(myIdolDisplayNameProvider);
    ref.invalidate(myIdolMemberNameProvider);
    ref.invalidate(themeModeNotifierProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: UiStrings.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.translate_outlined),
            selectedIcon: Icon(Icons.translate),
            label: UiStrings.navConverter,
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: UiStrings.navPhrases,
          ),
        ],
      ),
    );
  }
}
