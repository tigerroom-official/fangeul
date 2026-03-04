import 'package:flutter/material.dart';

import 'package:fangeul/core/entities/phrase_pack.dart';
import 'package:fangeul/l10n/app_localizations.dart';

/// 팩 필터 칩 바 — 즐겨찾기 + 팩별 필터 칩 수평 스크롤.
///
/// 첫 칩은 항상 ★즐찾. 이후 [packs] 순서대로 표시.
/// 잠금 팩은 이름 뒤에 🔒 접미사 표시.
class PackFilterChips extends StatelessWidget {
  /// Creates a [PackFilterChips].
  const PackFilterChips({
    super.key,
    required this.packs,
    required this.isFavoritesSelected,
    this.selectedPackId,
    this.onFavoritesSelected,
    this.onPackSelected,
    this.isMyIdolSelected = false,
    this.onMyIdolSelected,
    this.showMyIdolChip = false,
    this.myIdolLabel,
    this.isTodaySelected = false,
    this.onTodaySelected,
    this.showTodayChip = false,
  });

  /// 표시할 팩 목록.
  final List<PhrasePack> packs;

  /// 즐겨찾기 칩이 선택 상태인지.
  final bool isFavoritesSelected;

  /// 현재 선택된 팩 ID. null이면 즐겨찾기 선택.
  final String? selectedPackId;

  /// 즐겨찾기 칩 탭 콜백.
  final VoidCallback? onFavoritesSelected;

  /// 팩 칩 탭 콜백.
  final ValueChanged<String>? onPackSelected;

  /// 마이 아이돌 칩 선택 상태.
  final bool isMyIdolSelected;

  /// 마이 아이돌 칩 탭 콜백.
  final VoidCallback? onMyIdolSelected;

  /// 마이 아이돌 칩 표시 여부 (아이돌 설정 유저만).
  final bool showMyIdolChip;

  /// 마이 아이돌 칩에 표시할 커스텀 레이블. null이면 기본 레이블 사용.
  final String? myIdolLabel;

  /// "오늘" 칩 선택 상태.
  final bool isTodaySelected;

  /// "오늘" 칩 탭 콜백.
  final VoidCallback? onTodaySelected;

  /// "오늘" 칩 표시 여부.
  final bool showTodayChip;

  @override
  Widget build(BuildContext context) {
    final extraChips = (showMyIdolChip ? 1 : 0) + (showTodayChip ? 1 : 0);
    final chipCount = packs.length + 1 + extraChips;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: chipCount,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          if (index == 0) return _buildFavoritesChip(context);
          var offset = 1;
          if (showMyIdolChip) {
            if (index == offset) return _buildMyIdolChip(context);
            offset++;
          }
          if (showTodayChip) {
            if (index == offset) return _buildTodayChip(context);
            offset++;
          }
          return _buildPackChip(context, packs[index - offset]);
        },
      ),
    );
  }

  Widget _buildFavoritesChip(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(
        L.of(context).miniChipFavorites,
        style: TextStyle(
          color: isFavoritesSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          fontWeight: isFavoritesSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isFavoritesSelected && !isMyIdolSelected && !isTodaySelected,
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surfaceContainer,
      checkmarkColor: theme.colorScheme.onPrimary,
      showCheckmark: false,
      side: isFavoritesSelected
          ? BorderSide.none
          : BorderSide(color: theme.colorScheme.outlineVariant),
      visualDensity: VisualDensity.compact,
      onSelected: (_) => onFavoritesSelected?.call(),
    );
  }

  Widget _buildMyIdolChip(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(
        myIdolLabel ?? L.of(context).idolSettingLabel,
        style: TextStyle(
          color: isMyIdolSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          fontWeight: isMyIdolSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isMyIdolSelected,
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surfaceContainer,
      checkmarkColor: theme.colorScheme.onPrimary,
      showCheckmark: false,
      side: isMyIdolSelected
          ? BorderSide.none
          : BorderSide(color: theme.colorScheme.outlineVariant),
      visualDensity: VisualDensity.compact,
      onSelected: (_) => onMyIdolSelected?.call(),
    );
  }

  Widget _buildTodayChip(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(
        L.of(context).miniChipToday,
        style: TextStyle(
          color: isTodaySelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          fontWeight: isTodaySelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isTodaySelected,
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surfaceContainer,
      checkmarkColor: theme.colorScheme.onPrimary,
      showCheckmark: false,
      side: isTodaySelected
          ? BorderSide.none
          : BorderSide(color: theme.colorScheme.outlineVariant),
      visualDensity: VisualDensity.compact,
      onSelected: (_) => onTodaySelected?.call(),
    );
  }

  Widget _buildPackChip(BuildContext context, PhrasePack pack) {
    final theme = Theme.of(context);
    final isSelected = !isFavoritesSelected &&
        !isMyIdolSelected &&
        !isTodaySelected &&
        selectedPackId == pack.id;
    final label = pack.isFree ? pack.nameKo : '${pack.nameKo}🔒';

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isSelected,
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surfaceContainer,
      checkmarkColor: theme.colorScheme.onPrimary,
      showCheckmark: false,
      side: isSelected
          ? BorderSide.none
          : BorderSide(color: theme.colorScheme.outlineVariant),
      visualDensity: VisualDensity.compact,
      onSelected: (_) => onPackSelected?.call(pack.id),
    );
  }
}
