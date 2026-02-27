import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';

/// 설정 화면 — 테마 모드 전환, 앱 정보.
class SettingsScreen extends ConsumerWidget {
  /// Creates the [SettingsScreen] widget.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(UiStrings.settingsTitle)),
      body: ListView(
        children: [
          // 테마 모드
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(UiStrings.themeLabel, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text(UiStrings.themeDark),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text(UiStrings.themeLight),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.settings_suggest_outlined),
                      label: Text(UiStrings.themeSystem),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (modes) {
                    ref
                        .read(themeModeNotifierProvider.notifier)
                        .setThemeMode(modes.first);
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          // 앱 정보
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text(UiStrings.appInfoTitle),
            subtitle: const Text(UiStrings.appInfoSubtitle),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: UiStrings.appName,
                applicationVersion: UiStrings.appVersion,
                applicationLegalese: UiStrings.appLegalese,
              );
            },
          ),
        ],
      ),
    );
  }
}
