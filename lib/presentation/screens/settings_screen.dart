import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/platform/bubble_state.dart';
import 'package:fangeul/presentation/providers/bubble_providers.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';

/// 설정 화면 — 테마 모드 전환, 앱 정보.
class SettingsScreen extends ConsumerWidget {
  /// Creates the [SettingsScreen] widget.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final themeMode = ref.watch(themeModeNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          // 테마 모드
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.themeLabel, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_outlined),
                      label: Text(l.themeDark),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode_outlined),
                      label: Text(l.themeLight),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.settings_suggest_outlined),
                      label: Text(l.themeSystem),
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
          // 마이 아이돌
          const _MyIdolTile(),
          const Divider(),
          // 플로팅 버블
          const _BubbleToggleTile(),
          const Divider(),
          // 앱 정보
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.appInfoTitle),
            subtitle: Text(l.appInfoSubtitle(l.appVersion)),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: l.appName,
                applicationVersion: l.appVersion,
                applicationLegalese: l.appLegalese,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 마이 아이돌 설정 타일.
class _MyIdolTile extends ConsumerWidget {
  const _MyIdolTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final idolNameAsync = ref.watch(myIdolDisplayNameProvider);

    return ListTile(
      leading: const Icon(Icons.favorite_outline),
      title: Text(l.idolSettingLabel),
      subtitle: idolNameAsync.when(
        data: (name) => Text(
          name != null ? l.idolSettingCurrent(name) : l.idolSettingEmpty,
        ),
        loading: () => const Text('...'),
        error: (_, __) => Text(l.idolSettingEmpty),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/settings/idol-select'),
    );
  }
}

/// 플로팅 버블 온오프 토글 타일.
class _BubbleToggleTile extends ConsumerWidget {
  const _BubbleToggleTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final bubbleState = ref.watch(bubbleNotifierProvider);
    final isOn = bubbleState != BubbleState.off;

    return SwitchListTile(
      secondary: const Icon(Icons.bubble_chart_outlined),
      title: Text(l.bubbleLabel),
      subtitle: Text(l.bubbleDescription),
      value: isOn,
      onChanged: (value) async {
        if (value) {
          await _enableBubble(context, ref);
        } else {
          await ref.read(bubbleNotifierProvider.notifier).hide();
        }
      },
    );
  }

  Future<void> _enableBubble(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(bubbleNotifierProvider.notifier);
    final hasPermission = await notifier.checkPermission();

    if (hasPermission) {
      await notifier.show();
      if (context.mounted) await _checkBatteryOptimization(context, notifier);
      return;
    }

    if (!context.mounted) return;
    final l = L.of(context);
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dl = L.of(ctx);
        return AlertDialog(
          title: Text(dl.bubblePermissionTitle),
          content: Text(dl.bubblePermissionMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(dl.bubblePermissionDeny),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(dl.bubblePermissionAllow),
            ),
          ],
        );
      },
    );

    if (shouldRequest == true) {
      final granted = await notifier.requestPermission();
      if (granted) {
        await notifier.show();
        if (context.mounted) await _checkBatteryOptimization(context, notifier);
        return;
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.bubblePermissionDenied)),
      );
    }
  }

  /// 배터리 최적화가 적용 중이면 해제 안내 다이얼로그를 표시한다.
  Future<void> _checkBatteryOptimization(
    BuildContext context,
    BubbleNotifier notifier,
  ) async {
    final isDisabled = await notifier.isBatteryOptimizationDisabled();
    if (isDisabled) return;

    if (!context.mounted) return;
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dl = L.of(ctx);
        return AlertDialog(
          title: Text(dl.bubbleBatteryTitle),
          content: Text(dl.bubbleBatteryMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(dl.bubbleBatteryDeny),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(dl.bubbleBatteryAllow),
            ),
          ],
        );
      },
    );

    if (shouldOpen == true) {
      await notifier.requestIgnoreBatteryOptimization();
    }
  }
}
