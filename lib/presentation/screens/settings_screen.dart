import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/core/entities/user_progress.dart';
import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/platform/bubble_state.dart';
import 'package:fangeul/presentation/providers/bubble_providers.dart';
import 'package:fangeul/presentation/providers/choeae_color_provider.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/providers/progress_providers.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/theme/choeae_color_config.dart';
import 'package:fangeul/presentation/theme/palette_registry.dart';
import 'package:fangeul/presentation/widgets/theme_picker_sheet.dart';

/// 개인정보처리방침 URL — 호스팅 후 실제 URL로 교체.
const _privacyPolicyUrl = 'https://tigerroom-official.github.io/fangeul/privacy-policy.html';

/// 이용약관 URL — 호스팅 후 실제 URL로 교체.
const _termsUrl = 'https://tigerroom-official.github.io/fangeul/terms.html';

/// 지원 언어 목록 — null은 시스템 기본.
const _supportedLocaleOptions = <Locale?>[
  null,
  Locale('ko'),
  Locale('en'),
  Locale('es'),
  Locale('id'),
  Locale('ja'),
  Locale('pt'),
  Locale('th'),
  Locale('vi'),
];

/// 네이티브 언어명 매핑 (하드코딩 — 번역 불필요).
const _localeNativeNames = <String, String>{
  'ko': '한국어',
  'en': 'English',
  'es': 'Español',
  'id': 'Bahasa Indonesia',
  'ja': '日本語',
  'pt': 'Português',
  'th': 'ภาษาไทย',
  'vi': 'Tiếng Việt',
};

/// 설정 화면 — 테마, 언어, 리뷰/문의, 앱 정보.
class SettingsScreen extends ConsumerWidget {
  /// Creates the [SettingsScreen] widget.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final themeMode = ref.watch(themeModeNotifierProvider);
    final userLocale = ref.watch(localeNotifierProvider);
    final choeaeColor = ref.watch(choeaeColorNotifierProvider);
    final hasOverride = choeaeColor is ChoeaeColorCustom;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          // 1. 테마 모드
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
                  onSelectionChanged: hasOverride
                      ? null
                      : (modes) {
                          ref
                              .read(themeModeNotifierProvider.notifier)
                              .setThemeMode(modes.first);
                        },
                ),
                if (hasOverride)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l.themeModeLocked,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          // 2. 테마 색상
          ListTile(
            leading:
                Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
            title: Text(l.settingsThemeColor),
            subtitle: Text(l.settingsThemeColorDesc),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: switch (choeaeColor) {
                  ChoeaeColorCustom(:final seedColor) => seedColor,
                  ChoeaeColorPalette(:final packId) =>
                    PaletteRegistry.get(packId).previewColor,
                },
                shape: BoxShape.circle,
              ),
            ),
            onTap: () => ThemePickerSheet.show(context),
          ),
          const Divider(),
          // 3. 언어 설정
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.languageLabel),
            trailing: DropdownButton<Locale?>(
              value: userLocale,
              underline: const SizedBox.shrink(),
              onChanged: (locale) {
                ref.read(localeNotifierProvider.notifier).setLocale(locale);
              },
              items: _supportedLocaleOptions.map((locale) {
                final label = locale == null
                    ? l.languageSystem
                    : _localeNativeNames[locale.languageCode] ??
                        locale.languageCode;
                return DropdownMenuItem(value: locale, child: Text(label));
              }).toList(),
            ),
          ),
          const Divider(),
          // 4. 마이 아이돌
          const _MyIdolTile(),
          const Divider(),
          // 5. 플로팅 버블
          const _BubbleToggleTile(),
          const Divider(),
          // 6. 리뷰하기
          ListTile(
            leading: const Icon(Icons.rate_review_outlined),
            title: Text(l.reviewLabel),
            subtitle: Text(l.reviewSubtitle),
            onTap: () async {
              final inAppReview = InAppReview.instance;
              if (await inAppReview.isAvailable()) {
                await inAppReview.requestReview();
              }
            },
          ),
          const Divider(),
          // 7. 문의하기
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(l.contactLabel),
            subtitle: Text(l.contactSubtitle),
            onTap: () {
              launchUrl(
                Uri.parse('mailto:tigerroom.official@gmail.com'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          const Divider(),
          // 8. 개인정보처리방침
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l.privacyPolicyLabel),
            subtitle: Text(l.privacyPolicySubtitle),
            onTap: () {
              launchUrl(
                Uri.parse(_privacyPolicyUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          const Divider(),
          // 9. 이용약관
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l.termsLabel),
            subtitle: Text(l.termsSubtitle),
            onTap: () {
              launchUrl(
                Uri.parse(_termsUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          const Divider(),
          // 10. 앱 정보 — 런타임 버전 표시 (pubspec.yaml version)
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? l.appVersion;
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l.appInfoTitle),
                subtitle: Text(l.appInfoSubtitle(version)),
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l.appName),
                      content: Text(
                        'v$version\n${l.appLegalese}',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(l.complete),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          // 디버그 전용 테스트 패널
          if (kDebugMode) ...[
            const Divider(thickness: 3),
            const _DebugProgressPanel(),
            const Divider(thickness: 2),
            const _DebugMonetizationPanel(),
          ],
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

/// 디버그 전용 — 스트릭/진행상황 조작 패널.
///
/// kDebugMode에서만 표시. 데일리 카드 Done 버튼 테스트 등에 사용.
class _DebugProgressPanel extends ConsumerWidget {
  const _DebugProgressPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'DEBUG: Progress / Streak',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.redAccent,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: progressAsync.when(
            data: (p) => Text(
              'streak: ${p.streak} | total: ${p.totalStreakDays}\n'
              'lastCompleted: ${p.lastCompletedDate ?? "never"}\n'
              'lastTimestamp: ${p.lastTimestamp}\n'
              'freezeCount: ${p.freezeCount}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            loading: () => const Text('Loading...'),
            error: (e, _) => Text('Error: $e',
                style: const TextStyle(color: Colors.red)),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _DebugChip(
                label: 'Reset Today',
                onTap: () => _resetToday(ref),
              ),
              _DebugChip(
                label: 'Set Streak 5',
                onTap: () => _setStreak(ref, 5),
              ),
              _DebugChip(
                label: 'Set Streak 0',
                onTap: () => _setStreak(ref, 0),
              ),
              _DebugChip(
                label: 'Clear All Progress',
                color: Colors.red,
                onTap: () => _clearAll(ref),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// 오늘 완료 기록만 제거 — Done 버튼을 다시 보이게 한다.
  Future<void> _resetToday(WidgetRef ref) async {
    final repo = ref.read(userProgressRepositoryProvider);
    final progress = await repo.getProgress();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final y = yesterday.year.toString();
    final m = yesterday.month.toString().padLeft(2, '0');
    final d = yesterday.day.toString().padLeft(2, '0');
    await repo.saveProgress(progress.copyWith(
      lastCompletedDate: '$y-$m-$d',
    ));
    ref.invalidate(userProgressProvider);
  }

  /// 스트릭을 특정 값으로 설정.
  Future<void> _setStreak(WidgetRef ref, int streak) async {
    final repo = ref.read(userProgressRepositoryProvider);
    final progress = await repo.getProgress();
    await repo.saveProgress(progress.copyWith(
      streak: streak,
      totalStreakDays: streak,
    ));
    ref.invalidate(userProgressProvider);
  }

  /// 전체 진행 상황 초기화.
  Future<void> _clearAll(WidgetRef ref) async {
    final repo = ref.read(userProgressRepositoryProvider);
    await repo.saveProgress(const UserProgress());
    ref.invalidate(userProgressProvider);
  }
}

/// 디버그 전용 — 수익화 상태 조작 패널.
///
/// kDebugMode에서만 표시되며, 릴리즈 빌드에서는 tree-shake 제거됨.
class _DebugMonetizationPanel extends ConsumerWidget {
  const _DebugMonetizationPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(monetizationNotifierProvider);
    final monState = asyncState.valueOrNull;
    final isHoneymoon = ref.watch(isHoneymoonProvider);
    final isUnlocked = ref.watch(isThemeTrialActiveProvider);
    final theme = Theme.of(context);

    final installDate = monState?.installDate ?? 'not set';
    final daysSince = monState?.installDate != null
        ? DateTime.now()
            .difference(DateTime.parse(monState!.installDate!))
            .inDays
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'DEBUG: Monetization',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.redAccent,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'installDate: $installDate (Day $daysSince)\n'
            'honeymoon: $isHoneymoon | trial: $isUnlocked\n'
            'hasThemePicker: ${monState?.hasThemePicker ?? false}\n'
            'hasThemeSlots: ${monState?.hasThemeSlots ?? false}\n'
            'favSlotLimit: ${monState?.favoriteSlotLimit ?? 0} (0=unlimited)\n'
            'adWatchCount: ${monState?.adWatchCount ?? 0}/3',
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 설치일 시뮬레이션
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _DebugChip(
                label: 'Day 0',
                onTap: () => _setInstallDaysAgo(ref, 0),
              ),
              _DebugChip(
                label: 'Day 7',
                onTap: () => _setInstallDaysAgo(ref, 7),
              ),
              _DebugChip(
                label: 'Day 14 (limit)',
                onTap: () => _setInstallDaysAgo(ref, 14),
              ),
              _DebugChip(
                label: 'Day 21',
                onTap: () => _setInstallDaysAgo(ref, 21),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // 기능 토글
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _DebugChip(
                label: isUnlocked ? 'Trial: ON' : 'Trial: OFF',
                color: isUnlocked ? Colors.green : null,
                onTap: () => _toggleThemeTrial(ref, !isUnlocked),
              ),
              _DebugChip(
                label: monState?.hasThemePicker == true
                    ? 'Picker IAP: ON'
                    : 'Picker IAP: OFF',
                color: monState?.hasThemePicker == true ? Colors.green : null,
                onTap: () => _toggleThemePicker(ref),
              ),
              _DebugChip(
                label: monState?.hasThemeSlots == true
                    ? 'Slots IAP: ON'
                    : 'Slots IAP: OFF',
                color: monState?.hasThemeSlots == true ? Colors.green : null,
                onTap: () => _toggleThemeSlots(ref),
              ),
              _DebugChip(
                label: monState?.themeUnlocked == true
                    ? 'Theme Unlock: ON'
                    : 'Theme Unlock: OFF',
                color: monState?.themeUnlocked == true ? Colors.green : null,
                onTap: () => _toggleThemeUnlocked(ref),
              ),
              _DebugChip(
                label: isHoneymoon ? 'Honeymoon: ON' : 'Honeymoon: OFF',
                color: isHoneymoon ? Colors.orange : null,
                onTap: () => _toggleHoneymoon(ref, isHoneymoon),
              ),
              _DebugChip(
                label: 'Reset All',
                color: Colors.red,
                onTap: () => _resetAll(ref),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _setInstallDaysAgo(WidgetRef ref, int days) async {
    try {
      await ref.read(monetizationNotifierProvider.future);
    } catch (_) {}
    final current = ref.read(monetizationNotifierProvider).valueOrNull;
    if (current == null) return;

    final date = DateTime.now().subtract(Duration(days: days));
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final dateStr = '$y-$m-$d';

    // honeymoonActive는 Day 14 기준으로 자동 조정
    final honeymoonActive = days < 14;
    final slotLimit =
        honeymoonActive ? 0 : MonetizationNotifier.defaultSlotLimit;

    final repo = ref.read(monetizationRepositoryProvider);
    final updated = current.copyWith(
      installDate: dateStr,
      honeymoonActive: honeymoonActive,
      favoriteSlotLimit: slotLimit,
    );
    await repo.save(updated);
    ref.invalidate(monetizationNotifierProvider);
  }

  Future<void> _toggleThemeTrial(WidgetRef ref, bool activate) async {
    if (activate) {
      await ref
          .read(monetizationNotifierProvider.notifier)
          .activateThemeTrial();
    } else {
      try {
        await ref.read(monetizationNotifierProvider.future);
      } catch (_) {}
      final current = ref.read(monetizationNotifierProvider).valueOrNull;
      if (current == null) return;
      final repo = ref.read(monetizationRepositoryProvider);
      await repo.save(current.copyWith(themeTrialExpiresAt: 0));
      ref.invalidate(monetizationNotifierProvider);
    }
  }

  Future<void> _toggleThemePicker(WidgetRef ref) async {
    try {
      await ref.read(monetizationNotifierProvider.future);
    } catch (_) {}
    final current = ref.read(monetizationNotifierProvider).valueOrNull;
    if (current == null) return;
    final repo = ref.read(monetizationRepositoryProvider);
    await repo.save(current.copyWith(hasThemePicker: !current.hasThemePicker));
    ref.invalidate(monetizationNotifierProvider);
  }

  Future<void> _toggleThemeSlots(WidgetRef ref) async {
    try {
      await ref.read(monetizationNotifierProvider.future);
    } catch (_) {}
    final current = ref.read(monetizationNotifierProvider).valueOrNull;
    if (current == null) return;
    final repo = ref.read(monetizationRepositoryProvider);
    await repo.save(current.copyWith(hasThemeSlots: !current.hasThemeSlots));
    ref.invalidate(monetizationNotifierProvider);
  }

  Future<void> _toggleThemeUnlocked(WidgetRef ref) async {
    try {
      await ref.read(monetizationNotifierProvider.future);
    } catch (_) {}
    final current = ref.read(monetizationNotifierProvider).valueOrNull;
    if (current == null) return;
    final repo = ref.read(monetizationRepositoryProvider);
    await repo.save(current.copyWith(themeUnlocked: !current.themeUnlocked));
    ref.invalidate(monetizationNotifierProvider);
  }

  Future<void> _toggleHoneymoon(WidgetRef ref, bool currentlyActive) async {
    if (currentlyActive) {
      await ref.read(monetizationNotifierProvider.notifier).endHoneymoon();
    } else {
      try {
        await ref.read(monetizationNotifierProvider.future);
      } catch (_) {}
      final current = ref.read(monetizationNotifierProvider).valueOrNull;
      if (current == null) return;
      final repo = ref.read(monetizationRepositoryProvider);
      await repo.save(current.copyWith(
        honeymoonActive: true,
        favoriteSlotLimit: 0,
      ));
      ref.invalidate(monetizationNotifierProvider);
    }
  }

  Future<void> _resetAll(WidgetRef ref) async {
    final repo = ref.read(monetizationRepositoryProvider);
    await repo.save(const MonetizationState());
    ref.invalidate(monetizationNotifierProvider);
  }
}

/// 디버그 조작용 칩 버튼.
class _DebugChip extends StatelessWidget {
  const _DebugChip({
    required this.label,
    required this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      side: color != null ? BorderSide(color: color!) : null,
    );
  }
}
