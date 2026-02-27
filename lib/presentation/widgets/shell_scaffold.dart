import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 3탭 BottomNavigationBar 쉘.
///
/// [StatefulShellRoute.indexedStack]의 builder에서 사용.
/// 홈, 변환기, 문구 3개 탭을 제공한다.
class ShellScaffold extends StatelessWidget {
  /// Creates the [ShellScaffold] widget.
  const ShellScaffold({super.key, required this.navigationShell});

  /// go_router가 주입하는 네비게이션 쉘.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.translate_outlined),
            selectedIcon: Icon(Icons.translate),
            label: '변환기',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: '문구',
          ),
        ],
      ),
    );
  }
}
