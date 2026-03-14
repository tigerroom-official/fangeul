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
    show contrastRatio, sharedPreferencesProvider;
import 'package:fangeul/presentation/theme/choeae_color_config.dart';
import 'package:fangeul/presentation/theme/palette_pack.dart';
import 'package:fangeul/presentation/theme/palette_registry.dart';
import 'package:fangeul/presentation/models/theme_slot.dart';
import 'package:fangeul/presentation/providers/iap_provider.dart';
import 'package:fangeul/presentation/providers/theme_slot_provider.dart';
import 'package:fangeul/services/iap_products.dart';
import 'package:fangeul/presentation/widgets/hct_color_picker.dart';
import 'package:fangeul/presentation/widgets/text_color_picker_dialog.dart';

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

  // 피커 ephemeral state — 현재 피커에 표시 중인 색상.
  Color _pickerColor = const Color(0xFF009688); // Teal default

  bool _slidersInitialized = false;
  int _pickerResetCount = 0;

  /// 인라인 슬롯 이름 변경 중인 인덱스. null이면 비활성.
  int? _editingSlotIndex;

  // 프리뷰 모드 (미구매자): 시트 닫힘 시 복원용 백업.
  ChoeaeColorConfig? _savedConfigBeforePreview;
  bool _isPreviewMode = false;

  static const _slotHintShownKey = 'theme_slot_hint_shown';

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  /// 슬롯 첫 저장 시 롱프레스 힌트 스낵바를 1회 표시한다.
  void _showSlotSaveHint(BuildContext ctx) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getBool(_slotHintShownKey) ?? false) return;
    prefs.setBool(_slotHintShownKey, true);
    ScaffoldMessenger.of(ctx)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(L.of(ctx).themePickerSlotLongPressHint),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _initSlidersFromConfig(ChoeaeColorConfig config) {
    if (_slidersInitialized) return;
    _slidersInitialized = true;

    _pickerColor = switch (config) {
      ChoeaeColorCustom(:final seedColor) => seedColor,
      ChoeaeColorPalette(:final packId) =>
        PaletteRegistry.get(packId).previewColor,
    };
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
    final monState = ref.watch(monetizationNotifierProvider).valueOrNull;
    final hasPickerIap = _hasPickerAccess(monState);
    final hasSlotIap = monState?.hasThemeSlots ?? false;
    final slotList = ref.watch(themeSlotNotifierProvider);
    final slotNotifier = ref.read(themeSlotNotifierProvider.notifier);
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
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              children: [
                const _HandleBar(),
                const SizedBox(height: 12),
                // canUndo는 notifier side-property — ref.read는 의도적.
                // 인접 setState 호출이 리빌드를 보장한다.
                _TitleSection(
                  canUndo:
                      ref.read(choeaeColorNotifierProvider.notifier).canUndo,
                  onUndo: () {
                    ref
                        .read(choeaeColorNotifierProvider.notifier)
                        .undo(persist: hasPickerIap);
                    setState(() {
                      _slidersInitialized = false;
                      _pickerResetCount++;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _ThemeSlotRow(
                  slots: slotList,
                  activeIndex: slotNotifier.activeIndex,
                  maxSlots: slotNotifier.availableSlots(hasSlotIap),
                  hasSlotIap: hasSlotIap,
                  onSlotTap: (index) {
                    slotNotifier.applySlot(index);
                    setState(() {
                      _slidersInitialized = false;
                      _pickerResetCount++;
                      _editingSlotIndex = null;
                    });
                  },
                  onSlotSave: (index) async {
                    final slot = ThemeSlot.fromConfig(
                      slotList.length > index
                          ? slotList[index].name
                          : 'Slot ${index + 1}',
                      choeaeColor,
                    );
                    final saved =
                        await slotNotifier.saveToSlot(index, slot);
                    if (!context.mounted) return;
                    if (saved) {
                      _showSlotSaveHint(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              L.of(context).themePickerCustomSaveLocked),
                        ),
                      );
                    }
                  },
                  onRenameRequested: (index) {
                    setState(() => _editingSlotIndex = index);
                    // 시트를 최대로 펼쳐 키보드+카드 공간 확보.
                    _sheetController.animateTo(
                      0.85,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                ),
                if (_editingSlotIndex != null &&
                    _editingSlotIndex! < slotList.length)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _InlineRenameCard(
                      initialName: slotList[_editingSlotIndex!].name,
                      onSubmit: (name) {
                        slotNotifier.renameSlot(_editingSlotIndex!, name);
                        setState(() => _editingSlotIndex = null);
                      },
                      onCancel: () {
                        setState(() => _editingSlotIndex = null);
                      },
                    ),
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
                      _pickerResetCount++;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _PaletteGrid(
                  currentConfig: choeaeColor,
                  onPaletteTap: (pack) {
                    ref
                        .read(choeaeColorNotifierProvider.notifier)
                        .selectPalette(pack.id);
                    setState(() {
                      _slidersInitialized = false;
                      _pickerResetCount++;
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
                  HctColorPicker(
                    key: ValueKey(_pickerResetCount),
                    initialColor: _pickerColor,
                    onColorChanged: (color) {
                      setState(() => _pickerColor = color);
                      final existing = choeaeColor is ChoeaeColorCustom
                          ? choeaeColor.textColorOverride
                          : null;
                      ref
                          .read(choeaeColorNotifierProvider.notifier)
                          .setCustomColor(
                            color,
                            textColor: existing,
                            persist: hasPickerIap,
                          );
                    },
                  ),
                  const SizedBox(height: 16),
                  Builder(builder: (context) {
                    // custom: seed tone에서 brightness 자동 유도
                    final Brightness effectiveBrightness;
                    if (choeaeColor is ChoeaeColorCustom) {
                      final t =
                          Hct.fromInt(choeaeColor.seedColor.toARGB32()).tone;
                      effectiveBrightness =
                          t < 50 ? Brightness.dark : Brightness.light;
                    } else {
                      effectiveBrightness = theme.brightness;
                    }
                    return Column(
                      children: [
                        _TextColorSelector(
                          currentTextColor: choeaeColor is ChoeaeColorCustom
                              ? choeaeColor.textColorOverride
                              : null,
                          backgroundColor: choeaeColor
                              .buildColorScheme(effectiveBrightness)
                              .surface,
                          onColorSelected: (color) {
                            ref
                                .read(choeaeColorNotifierProvider.notifier)
                                .setTextColorOverride(
                                  color,
                                  persist: hasPickerIap,
                                );
                          },
                        ),
                        // 가독성 가드레일: surface + surfaceContainerHigh(Dialog 배경) 대비 체크
                        Builder(builder: (context) {
                          final textColor = choeaeColor is ChoeaeColorCustom
                              ? choeaeColor.textColorOverride
                              : null;
                          if (textColor == null) {
                            return const SizedBox.shrink();
                          }
                          final scheme =
                              choeaeColor.buildColorScheme(effectiveBrightness);
                          final surfaceRatio =
                              contrastRatio(textColor, scheme.surface);
                          final containerHighRatio = contrastRatio(
                              textColor, scheme.surfaceContainerHigh);
                          final ratio = surfaceRatio < containerHighRatio
                              ? surfaceRatio
                              : containerHighRatio;
                          if (ratio >= 4.5) {
                            return const SizedBox.shrink();
                          }
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
                              backgroundColor: theme.colorScheme.errorContainer,
                              side: BorderSide.none,
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        _PreviewCard(
                          choeaeColor: choeaeColor,
                          brightness: effectiveBrightness,
                        ),
                      ],
                    );
                  }),
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
                _IapPurchaseSection(
                  hasThemePicker: hasPickerIap,
                  hasThemeSlots: hasSlotIap,
                ),
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
                color:
                    PaletteRegistry.get(PaletteRegistry.defaultId).previewColor,
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
    final isTrialActive = ref.watch(isThemeTrialActiveProvider);
    final packs = PaletteRegistry.all;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 2,
        crossAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: packs.length,
      itemBuilder: (context, index) {
        final pack = packs[index];
        final isSelected = currentConfig is ChoeaeColorPalette &&
            (currentConfig as ChoeaeColorPalette).packId == pack.id;
        final isAccessible =
            !pack.isPremium || isUnlocked || isTrialActive;

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

class _ThemeSlotRow extends StatelessWidget {
  const _ThemeSlotRow({
    required this.slots,
    required this.activeIndex,
    required this.maxSlots,
    required this.hasSlotIap,
    required this.onSlotTap,
    required this.onSlotSave,
    required this.onRenameRequested,
  });

  final List<ThemeSlot> slots;
  final int activeIndex;
  final int maxSlots;
  final bool hasSlotIap;
  final void Function(int) onSlotTap;
  final void Function(int) onSlotSave;
  final void Function(int) onRenameRequested;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.themePickerSlots,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: maxSlots,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final isLocked = index >= 1 && !hasSlotIap;
              final hasSlot = index < slots.length;
              final slot = hasSlot ? slots[index] : null;
              final isActive = index == activeIndex && hasSlot;

              // 슬롯 프리뷰 색상
              Color? previewColor;
              if (slot != null) {
                final config = slot.toConfig();
                previewColor = switch (config) {
                  ChoeaeColorCustom(:final seedColor) => seedColor,
                  ChoeaeColorPalette(:final packId) =>
                    PaletteRegistry.get(packId).previewColor,
                };
              }

              return Semantics(
                onLongPressHint: hasSlot && !isLocked
                    ? l.themePickerSlotLongPressHint
                    : null,
                child: GestureDetector(
                onTap: () {
                  if (isLocked) {
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(l.themePickerSlotLocked),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    return;
                  }
                  if (hasSlot) {
                    onSlotTap(index);
                  } else {
                    onSlotSave(index);
                  }
                },
                onLongPressStart: isLocked || !hasSlot
                    ? null
                    : (details) => _showSlotMenu(
                          context,
                          index,
                          slot!,
                          details.globalPosition,
                        ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isLocked
                                  ? theme.colorScheme.surfaceContainerHigh
                                  : previewColor ??
                                      theme.colorScheme.surfaceContainerHigh,
                              shape: BoxShape.circle,
                              border: isActive
                                  ? Border.all(
                                      color: theme.colorScheme.primary,
                                      width: 2.5,
                                    )
                                  : Border.all(
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                            ),
                            child: isLocked
                                ? Icon(
                                    Icons.lock_rounded,
                                    size: 18,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  )
                                : !hasSlot
                                    ? Icon(
                                        Icons.add,
                                        size: 20,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      )
                                    : isActive
                                        ? Icon(
                                            Icons.check,
                                            size: 18,
                                            color: previewColor != null &&
                                                    previewColor
                                                            .computeLuminance() >
                                                        0.5
                                                ? Colors.black87
                                                : Colors.white,
                                          )
                                        : null,
                          ),
                          // ⋮ 힌트: 채워진 슬롯에 롱프레스 메뉴 어포던스
                          if (hasSlot && !isLocked)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Icon(
                                Icons.more_vert,
                                size: 12,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 52,
                      child: Text(
                        isLocked ? '' : slot?.name ?? l.themePickerSlotSave,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 슬롯 액션 팝업 메뉴 — 저장/이름변경.
  ///
  /// 모달 중첩(showModalBottomSheet 안에서 showDialog/showModalBottomSheet)은
  /// GoRouter root Navigator Overlay에서 _dependents.isEmpty assertion을
  /// 유발하므로, PopupMenu + 인라인 rename 카드로 대체한다.
  void _showSlotMenu(
    BuildContext context,
    int index,
    ThemeSlot slot,
    Offset globalPosition,
  ) {
    final l = L.of(context);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx,
        globalPosition.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'save',
          child: Row(
            children: [
              const Icon(Icons.save_rounded, size: 20),
              const SizedBox(width: 12),
              Text(l.themePickerSlotSave),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              const Icon(Icons.edit_rounded, size: 20),
              const SizedBox(width: 12),
              Text(l.themePickerSlotName),
            ],
          ),
        ),
      ],
    ).then((action) {
      if (!context.mounted || action == null) return;
      if (action == 'save') {
        onSlotSave(index);
      } else if (action == 'rename') {
        onRenameRequested(index);
      }
    });
  }
}

class _TextColorSelector extends StatelessWidget {
  const _TextColorSelector({
    required this.currentTextColor,
    required this.onColorSelected,
    required this.backgroundColor,
  });

  final Color? currentTextColor;
  final void Function(Color?) onColorSelected;
  final Color backgroundColor;

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
    final recommended = suggestTextColors(backgroundColor);

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
        // WCAG 추천
        if (recommended.isNotEmpty) ...[
          Text(
            l.themePickerRecommended,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final color in recommended)
                _ColorCircle(
                  color: color,
                  isSelected: currentTextColor == color,
                  onTap: () => onColorSelected(color),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
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
            // "+" 자유 피커 버튼
            GestureDetector(
              onTap: () async {
                final result = await TextColorPickerDialog.show(
                  context,
                  backgroundColor: backgroundColor,
                  initialColor: currentTextColor,
                );
                if (result != null) onColorSelected(result);
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surfaceContainerHigh,
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
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

// _BrightnessToggle 제거 — brightness는 seed tone에서 자동 유도.

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
        // AppBar + 화면 통합 프리뷰 — 실제 적용 결과를 시각화.
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              // 미니 AppBar
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: previewScheme.surfaceContainerLow,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: previewScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fangeul',
                      style: TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: previewScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              // 본문 영역
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: previewScheme.surface,
                child: Column(
                  children: [
                    _KeyboardPreview(previewScheme: previewScheme),
                    const SizedBox(height: 8),
                    _PhrasePreview(
                      previewScheme: previewScheme,
                      customTextColor: customTextColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
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

          final notifier = ref.read(monetizationNotifierProvider.notifier);
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

/// IAP 구매 섹션 — 3-SKU 버튼과 번들 할인 표시.
///
/// 피커/슬롯 미구매 시에만 표시. 둘 다 구매 시 숨김.
class _IapPurchaseSection extends ConsumerWidget {
  const _IapPurchaseSection({
    required this.hasThemePicker,
    required this.hasThemeSlots,
  });

  final bool hasThemePicker;
  final bool hasThemeSlots;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 둘 다 구매 완료 → 숨김
    if (hasThemePicker && hasThemeSlots) return const SizedBox.shrink();

    final l = L.of(context);
    final theme = Theme.of(context);
    // 상품 로딩 완료 시 리빌드 → 로컬라이즈 가격 반영
    ref.watch(iapProductsLoadedProvider);
    final iapSvc = ref.watch(iapServiceProvider);
    final showBundle = !hasThemePicker && !hasThemeSlots;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 커스텀 피커 미구매
          if (!hasThemePicker)
            _IapButton(
              icon: Icons.palette_outlined,
              label: l.iapThemeCustomColor,
              subtitle: l.iapThemeCustomColorSub,
              price: iapSvc.getProduct(IapProducts.themeCustomColor)?.price,
              onTap: iapSvc.getProduct(IapProducts.themeCustomColor) != null
                  ? () => iapSvc.buyPack(IapProducts.themeCustomColor)
                  : null,
              theme: theme,
            ),
          // 슬롯 미구매
          if (!hasThemeSlots) ...[
            if (!hasThemePicker) const SizedBox(height: 8),
            _IapButton(
              icon: Icons.grid_view_rounded,
              label: l.iapThemeSlots,
              subtitle: l.iapThemeSlotsSub,
              price: iapSvc.getProduct(IapProducts.themeSlots)?.price,
              onTap: iapSvc.getProduct(IapProducts.themeSlots) != null
                  ? () => iapSvc.buyPack(IapProducts.themeSlots)
                  : null,
              theme: theme,
            ),
          ],
          // 번들 — 둘 다 미구매 시에만
          if (showBundle) ...[
            const SizedBox(height: 8),
            _IapButton(
              icon: Icons.auto_awesome,
              label: l.iapThemeBundle,
              subtitle: l.iapThemeBundleSave,
              badge: l.themePickerRecommended,
              isHighlighted: true,
              price: iapSvc.getProduct(IapProducts.themeBundle)?.price,
              onTap: iapSvc.getProduct(IapProducts.themeBundle) != null
                  ? () => iapSvc.buyPack(IapProducts.themeBundle)
                  : null,
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }
}

/// 개별 IAP 구매 버튼.
class _IapButton extends StatelessWidget {
  const _IapButton({
    required this.icon,
    required this.label,
    required this.theme,
    this.onTap,
    this.price,
    this.subtitle,
    this.badge,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String label;
  final String? price;
  final String? subtitle;
  final String? badge;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final borderColor = isHighlighted
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;
    final bgColor = isHighlighted
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
        : theme.colorScheme.surfaceContainerHigh;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isHighlighted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isHighlighted
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (price != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  price!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isHighlighted
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
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

/// 인라인 슬롯 이름 변경 카드.
///
/// StatefulWidget으로 TextEditingController 생명주기를 자체 관리한다.
/// 모달 중첩 없이 부모 시트 안에서 직접 표시.
class _InlineRenameCard extends StatefulWidget {
  const _InlineRenameCard({
    required this.initialName,
    required this.onSubmit,
    required this.onCancel,
  });

  final String initialName;
  final ValueChanged<String> onSubmit;
  final VoidCallback onCancel;

  @override
  State<_InlineRenameCard> createState() => _InlineRenameCardState();
}

class _InlineRenameCardState extends State<_InlineRenameCard> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    // 포커스 요청 후 키보드가 올라오면 카드가 보이도록 자동 스크롤.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
      // 시트 확장 + 키보드 애니메이션 완료 후 ensureVisible 호출.
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Scrollable.ensureVisible(
          context,
          alignment: 0.3,
          duration: const Duration(milliseconds: 250),
        );
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onSubmit(name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = L.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.done,
                maxLength: 20,
                keyboardType: TextInputType.visiblePassword,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: l.themePickerSlotName,
                  counterText: '',
                  isDense: true,
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close, size: 20),
              tooltip: MaterialLocalizations.of(context).cancelButtonLabel,
              style: IconButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            FilledButton(
              onPressed: _submit,
              child: Text(l.complete),
            ),
          ],
        ),
      ),
    );
  }
}
