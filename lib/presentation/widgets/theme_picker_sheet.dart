import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/ad_service_provider.dart';
import 'package:fangeul/presentation/providers/choeae_color_provider.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart'
    show contrastRatio;
import 'package:fangeul/presentation/theme/choeae_color_config.dart';
import 'package:fangeul/presentation/theme/palette_pack.dart';
import 'package:fangeul/presentation/theme/palette_registry.dart';

/// 테마 색상 선택 바텀시트.
///
/// 추천 팔레트 그리드, 커스텀 HCT 피커, 글자색 선택, 프리뷰 카드를 포함한다.
/// [ThemePickerSheet.show]로 호출.
class ThemePickerSheet extends ConsumerStatefulWidget {
  /// 바텀시트를 표시한다.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ThemePickerSheet._(),
    );
  }

  const ThemePickerSheet._();

  @override
  ConsumerState<ThemePickerSheet> createState() => _ThemePickerSheetState();
}

class _ThemePickerSheetState extends ConsumerState<ThemePickerSheet> {
  bool _customPickerExpanded = false;

  final _sheetController = DraggableScrollableController();
  final _customPickerKey = GlobalKey();

  // Hue-only slider ephemeral state (HCT 기반)
  double _hue = 180;

  bool _slidersInitialized = false;

  // 프리뷰 모드 (미구매자): 시트 닫힘 시 복원용 백업.
  ChoeaeColorConfig? _savedConfigBeforePreview;
  bool _isPreviewMode = false;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  /// 현재 슬라이더 hue로 선명한 중간 밝기 Color 생성 (HCT chroma 48, tone 50).
  Color get _pickerColor => Color(Hct.from(_hue, 48.0, 50.0).toInt());

  void _initSlidersFromConfig(ChoeaeColorConfig config) {
    if (_slidersInitialized) return;
    _slidersInitialized = true;

    final color = switch (config) {
      ChoeaeColorCustom(:final seedColor) => seedColor,
      ChoeaeColorPalette(:final packId) =>
        PaletteRegistry.get(packId).previewColor,
    };
    _hue = Hct.fromInt(color.toARGB32()).hue;
  }

  /// 커스텀 피커 IAP 해금 여부.
  bool _hasPickerAccess(MonetizationState? monState) {
    return monState?.hasThemePicker ?? false;
  }

  /// 프리뷰 모드 진입 — 현재 설정을 백업한다.
  void _enterPreviewMode() {
    if (_isPreviewMode) return;
    _isPreviewMode = true;
    _savedConfigBeforePreview = ref.read(choeaeColorNotifierProvider);
  }

  /// 프리뷰 모드 종료 — 백업 설정으로 복원한다 (undo 기록 없이).
  void _restoreFromPreview() {
    if (!_isPreviewMode) return;
    _isPreviewMode = false;
    final saved = _savedConfigBeforePreview;
    if (saved == null) return;
    ref.read(choeaeColorNotifierProvider.notifier).restoreConfig(saved);
  }

  @override
  Widget build(BuildContext context) {
    final choeaeColor = ref.watch(choeaeColorNotifierProvider);
    final monState =
        ref.watch(monetizationNotifierProvider).valueOrNull;
    final hasPickerIap = _hasPickerAccess(monState);
    _initSlidersFromConfig(choeaeColor);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (_isPreviewMode) {
          _restoreFromPreview();
        }
      },
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (context, scrollController) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const _HandleBar(),
              const SizedBox(height: 12),
              _TitleSection(
                canUndo: ref.read(choeaeColorNotifierProvider.notifier).canUndo,
                onUndo: () {
                  ref.read(choeaeColorNotifierProvider.notifier).undo();
                  setState(() => _slidersInitialized = false);
                },
              ),
              const SizedBox(height: 16),
              _DefaultThemeChip(
                isSelected: choeaeColor is ChoeaeColorPalette &&
                    choeaeColor.packId == PaletteRegistry.defaultId,
                onTap: () {
                  ref
                      .read(choeaeColorNotifierProvider.notifier)
                      .selectPalette(PaletteRegistry.defaultId);
                  setState(() {
                    _slidersInitialized = false;
                  });
                },
              ),
              const SizedBox(height: 16),
              _PaletteGrid(
                currentConfig: choeaeColor,
                onPaletteTap: (pack) {
                  ref
                      .read(choeaeColorNotifierProvider.notifier)
                      .selectPalette(pack.id);
                  setState(() {
                    _slidersInitialized = false;
                  });
                },
              ),
              const _ThemeUnlockButton(),
              const SizedBox(height: 16),
              _CustomPickerToggle(
                isExpanded: _customPickerExpanded,
                isLocked: !hasPickerIap,
                onToggle: () {
                  if (!hasPickerIap && !_customPickerExpanded) {
                    _enterPreviewMode();
                  }
                  setState(() {
                    _customPickerExpanded = !_customPickerExpanded;
                  });
                  if (_customPickerExpanded) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      _sheetController
                          .animateTo(
                        0.85,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      )
                          .then((_) {
                        if (!mounted) return;
                        final ctx = _customPickerKey.currentContext;
                        if (ctx != null) {
                          Scrollable.ensureVisible(
                            // ignore: use_build_context_synchronously
                            ctx,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    });
                  }
                },
              ),
              if (_customPickerExpanded) ...[
                SizedBox(key: _customPickerKey, height: 16),
                _HueSlider(
                  value: _hue,
                  onChanged: (v) {
                    setState(() => _hue = v);
                    final existing = choeaeColor is ChoeaeColorCustom
                        ? choeaeColor.textColorOverride
                        : null;
                    ref
                        .read(choeaeColorNotifierProvider.notifier)
                        .setCustomColor(_pickerColor, textColor: existing);
                  },
                ),
                const SizedBox(height: 16),
                _TextColorSelector(
                  currentTextColor: choeaeColor is ChoeaeColorCustom
                      ? choeaeColor.textColorOverride
                      : null,
                  onColorSelected: (color) {
                    ref
                        .read(choeaeColorNotifierProvider.notifier)
                        .setTextColorOverride(color);
                  },
                ),
                // 가독성 가드레일: 대비율 < 4.5:1 시 경고
                Builder(builder: (context) {
                  final textColor = choeaeColor is ChoeaeColorCustom
                      ? choeaeColor.textColorOverride
                      : null;
                  if (textColor == null) return const SizedBox.shrink();
                  final bgColor =
                      choeaeColor.buildColorScheme(theme.brightness).surface;
                  final ratio = contrastRatio(textColor, bgColor);
                  if (ratio >= 4.5) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Chip(
                      avatar: Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        L.of(context).themePickerLowContrast,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor:
                          theme.colorScheme.errorContainer,
                      side: BorderSide.none,
                    ),
                  );
                }),
                const SizedBox(height: 16),
                _PreviewCard(
                  choeaeColor: choeaeColor,
                  brightness: theme.brightness,
                ),
                if (!hasPickerIap) ...[
                  const SizedBox(height: 12),
                  Text(
                    L.of(context).themePickerPreviewHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(
                          SnackBar(
                            content:
                                Text(L.of(context).themePickerApplyLocked),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: 16,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(L.of(context).themePickerApplyLocked),
                      ],
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────

class _HandleBar extends StatelessWidget {
  const _HandleBar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(
                alpha: 0.4,
              ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection({
    required this.canUndo,
    this.onUndo,
  });

  final bool canUndo;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.themePickerTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                l.themePickerSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AnimatedOpacity(
          opacity: canUndo ? 1.0 : 0.25,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: IconButton(
            icon: const Icon(Icons.undo_rounded, size: 20),
            color: canUndo
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            onPressed: canUndo ? onUndo : null,
            tooltip: l.themePickerUndo,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ),
      ],
    );
  }
}

class _DefaultThemeChip extends StatelessWidget {
  const _DefaultThemeChip({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: PaletteRegistry.get(PaletteRegistry.defaultId)
                    .previewColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outline,
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l.paletteDefault,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaletteGrid extends ConsumerWidget {
  const _PaletteGrid({
    required this.currentConfig,
    required this.onPaletteTap,
  });

  final ChoeaeColorConfig currentConfig;
  final void Function(PalettePack) onPaletteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnlocked = ref.watch(isThemeUnlockedProvider);
    final packs = PaletteRegistry.all;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: packs.length,
      itemBuilder: (context, index) {
        final pack = packs[index];
        final isSelected = currentConfig is ChoeaeColorPalette &&
            (currentConfig as ChoeaeColorPalette).packId == pack.id;
        final isAccessible = !pack.isPremium || isUnlocked;

        return _PaletteItem(
          pack: pack,
          isSelected: isSelected,
          isLocked: !isAccessible,
          onTap: () {
            if (isAccessible) {
              onPaletteTap(pack);
            } else {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Text(L.of(context).themePickerLocked),
                    duration: const Duration(seconds: 2),
                  ),
                );
            }
          },
        );
      },
    );
  }
}

class _PaletteItem extends StatelessWidget {
  const _PaletteItem({
    required this.pack,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  final PalettePack pack;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);
    final name = _paletteName(l, pack.nameKey);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: pack.previewColor,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: theme.colorScheme.primary,
                          width: 2.5,
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: pack.previewColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
              if (isLocked)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 18,
                    color: Colors.white70,
                  ),
                ),
              if (isSelected && !isLocked)
                Icon(
                  Icons.check,
                  size: 20,
                  color: _contrastColor(pack.previewColor),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isLocked
                  ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                  : theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 배경 색상에 대비되는 체크 아이콘 색상.
  static Color _contrastColor(Color bg) {
    return bg.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }
}

class _CustomPickerToggle extends StatelessWidget {
  const _CustomPickerToggle({
    required this.isExpanded,
    required this.isLocked,
    required this.onToggle,
  });

  final bool isExpanded;
  final bool isLocked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.palette_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              l.themePickerCustom,
              style: theme.textTheme.labelLarge,
            ),
            const Spacer(),
            if (isLocked)
              Icon(
                Icons.lock_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            if (isLocked) const SizedBox(width: 4),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.expand_more,
                size: 22,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HueSlider extends StatelessWidget {
  const _HueSlider({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.themePickerHue,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF0000), // 0° red
                      Color(0xFFFFFF00), // 60° yellow
                      Color(0xFF00FF00), // 120° green
                      Color(0xFF00FFFF), // 180° cyan
                      Color(0xFF0000FF), // 240° blue
                      Color(0xFFFF00FF), // 300° magenta
                      Color(0xFFFF0000), // 360° red
                    ],
                  ),
                ),
              ),
              SliderTheme(
                data: _sliderThemeData(
                  context,
                  HSLColor.fromAHSL(1.0, value, 1.0, 0.5).toColor(),
                ),
                child: Slider(
                  value: value,
                  min: 0,
                  max: 360,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TextColorSelector extends StatelessWidget {
  const _TextColorSelector({
    required this.currentTextColor,
    required this.onColorSelected,
  });

  final Color? currentTextColor;
  final void Function(Color?) onColorSelected;

  /// 프리셋 글자색 목록.
  static const _presets = <Color>[
    Colors.white,
    Color(0xFFFFF8E1), // cream
    Color(0xFFE0E0E0), // light gray
    Color(0xFFB3E5FC), // light sky
    Color(0xFFE1BEE7), // light lavender
    Color(0xFFB2DFDB), // light mint
  ];

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.themePickerTextColor,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          l.themePickerTextColorDesc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // Auto contrast button
            _ColorCircle(
              color: null,
              isSelected: currentTextColor == null,
              label: l.themePickerTextColorAuto,
              onTap: () => onColorSelected(null),
            ),
            // Preset colors
            for (final color in _presets)
              _ColorCircle(
                color: color,
                isSelected: currentTextColor == color,
                onTap: () => onColorSelected(color),
              ),
          ],
        ),
      ],
    );
  }
}

class _ColorCircle extends StatelessWidget {
  const _ColorCircle({
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.label,
  });

  /// null이면 "Auto contrast" 버튼.
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (color == null) {
      // Auto contrast chip
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                : Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Center(
            child: Text(
              label ?? '',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2.5)
              : Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color!.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: 14,
                color: color!.computeLuminance() > 0.5
                    ? Colors.black87
                    : Colors.white,
              )
            : null,
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.choeaeColor,
    required this.brightness,
  });

  final ChoeaeColorConfig choeaeColor;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final parentTheme = Theme.of(context);

    // 프리뷰용 ColorScheme 생성 — ChoeaeColorConfig.buildColorScheme 사용.
    final previewScheme = choeaeColor.buildColorScheme(brightness);
    final customTextColor = choeaeColor is ChoeaeColorCustom
        ? (choeaeColor as ChoeaeColorCustom).textColorOverride
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.themePickerPreview,
          style: parentTheme.textTheme.labelMedium?.copyWith(
            color: parentTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        _KeyboardPreview(previewScheme: previewScheme),
        const SizedBox(height: 8),
        _PhrasePreview(
          previewScheme: previewScheme,
          customTextColor: customTextColor,
        ),
      ],
    );
  }
}

/// 미니 키보드 프리뷰 — 2행 × 5열 한글 자판.
class _KeyboardPreview extends StatelessWidget {
  const _KeyboardPreview({required this.previewScheme});

  final ColorScheme previewScheme;

  static const _row1 = ['ㅂ', 'ㅈ', 'ㄷ', 'ㄱ', 'ㅅ'];
  static const _row2 = ['ㅁ', 'ㄴ', 'ㅇ', 'ㄹ', 'ㅎ'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: previewScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: previewScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _buildRow(_row1),
          const SizedBox(height: 6),
          _buildRow(_row2),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys
          .map((k) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 28,
                  height: 36,
                  decoration: BoxDecoration(
                    color: previewScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    k,
                    style: TextStyle(
                      fontFamily: 'NotoSansKR',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: previewScheme.onSurface,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

/// 미니 문구 프리뷰 — 한글 + 로마자 + 번역.
class _PhrasePreview extends ConsumerWidget {
  const _PhrasePreview({
    required this.previewScheme,
    required this.customTextColor,
  });

  final ColorScheme previewScheme;
  final Color? customTextColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idolName = ref.watch(myIdolDisplayNameProvider).valueOrNull;
    final displayName = idolName ?? 'My Idol';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: previewScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: previewScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$displayName, 화이팅!',
            style: TextStyle(
              fontFamily: 'NotoSansKR',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: customTextColor ?? previewScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'hwaiting!',
            style: TextStyle(
              fontFamily: 'NotoSansKR',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: previewScheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Fighting!',
            style: TextStyle(
              fontFamily: 'NotoSansKR',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: previewScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeUnlockButton extends ConsumerWidget {
  const _ThemeUnlockButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnlocked = ref.watch(isThemeUnlockedProvider);
    if (isUnlocked) return const SizedBox.shrink();

    final l = L.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: FilledButton.tonal(
        onPressed: () async {
          final adService = ref.read(adServiceProvider);
          if (!adService.isRewardedReady) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(l.fanPassAdLoading),
                  duration: const Duration(seconds: 2),
                ),
              );
            return;
          }

          final notifier =
              ref.read(monetizationNotifierProvider.notifier);
          final recorded = await notifier.recordAdWatch();
          if (!recorded) return;

          await adService.showRewarded(
            onRewarded: () {
              notifier.unlockThemePalettes().ignore();
            },
          );
        },
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 44),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_open_rounded,
              size: 18,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l.themePickerUnlockAll,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

/// 팔레트 nameKey → l10n 문자열 변환.
String _paletteName(L l, String nameKey) {
  return switch (nameKey) {
    // ── 레거시 팔레트 (기존 l10n 키) ──
    'paletteOcean' => l.paletteOcean,
    'paletteForest' => l.paletteForest,
    'paletteSunset' => l.paletteSunset,
    'paletteStarryNight' => l.paletteStarryNight,
    'paletteDawn' => l.paletteDawn,
    'paletteDusk' => l.paletteDusk,
    'paletteJewel' => l.paletteJewel,
    // ── 최애색 팔레트 ──
    'paletteMidnight' => l.paletteMidnight,
    'palettePurpleDream' => l.palettePurpleDream,
    'paletteOceanBlue' => l.paletteOceanBlue,
    'paletteRoseGold' => l.paletteRoseGold,
    'paletteConcertEncore' => l.paletteConcertEncore,
    'paletteGoldenHour' => l.paletteGoldenHour,
    'paletteCherryBlossom' => l.paletteCherryBlossom,
    'paletteNeonNight' => l.paletteNeonNight,
    'paletteMintBreeze' => l.paletteMintBreeze,
    'paletteSunsetCafe' => l.paletteSunsetCafe,
    _ => nameKey,
  };
}

/// 슬라이더 테마 — 투명 트랙 + 컬러 Thumb.
SliderThemeData _sliderThemeData(BuildContext context, Color thumbColor) {
  return SliderThemeData(
    trackHeight: 0,
    activeTrackColor: Colors.transparent,
    inactiveTrackColor: Colors.transparent,
    thumbColor: thumbColor,
    overlayColor: thumbColor.withValues(alpha: 0.2),
    thumbShape: const _CircleThumbShape(radius: 10),
  );
}

/// 커스텀 원형 Thumb (흰 테두리 + 색상 채움).
class _CircleThumbShape extends SliderComponentShape {
  const _CircleThumbShape({required this.radius});

  final double radius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // White border
    canvas.drawCircle(
      center,
      radius + 1.5,
      Paint()..color = Colors.white,
    );

    // Colored fill
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = sliderTheme.thumbColor ?? Colors.white,
    );

    // Subtle shadow
    canvas.drawCircle(
      center,
      radius + 1.5,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }
}
