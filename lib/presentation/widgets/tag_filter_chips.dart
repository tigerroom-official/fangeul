import 'package:flutter/material.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';

/// 태그 필터 칩 -- 문구 카테고리 필터링.
///
/// 수평 스크롤 칩 목록으로, '전체' + 개별 태그를 선택할 수 있다.
/// [showMemberChip]이 true이면 멤버 칩이 가장 앞에 표시된다.
/// [showMyIdolChip]이 true이면 마이아이돌 칩이 멤버 칩 뒤, '전체' 앞에 표시된다.
class TagFilterChips extends StatelessWidget {
  /// Creates the [TagFilterChips] widget.
  const TagFilterChips({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
    this.showMemberChip = false,
    this.isMemberSelected = false,
    this.onMemberSelected,
    this.memberLabel,
    this.showMyIdolChip = false,
    this.isMyIdolSelected = false,
    this.onMyIdolSelected,
    this.myIdolLabel,
  });

  /// 사용 가능한 태그 목록.
  final List<String> tags;

  /// 현재 선택된 태그. null이면 '전체' 선택.
  final String? selectedTag;

  /// 태그 선택 콜백. null을 전달하면 '전체' 선택.
  final ValueChanged<String?> onTagSelected;

  /// 멤버 칩 표시 여부.
  final bool showMemberChip;

  /// 멤버 칩 선택 상태.
  final bool isMemberSelected;

  /// 멤버 칩 탭 콜백.
  final VoidCallback? onMemberSelected;

  /// 멤버 칩 레이블. 예: '♡ 정국'.
  final String? memberLabel;

  /// 마이아이돌 칩 표시 여부.
  final bool showMyIdolChip;

  /// 마이아이돌 칩 선택 상태.
  final bool isMyIdolSelected;

  /// 마이아이돌 칩 탭 콜백.
  final VoidCallback? onMyIdolSelected;

  /// 마이아이돌 칩 레이블. 예: '♡ BTS'.
  final String? myIdolLabel;

  static const _tagLabels = {
    'love': UiStrings.tagLove,
    'cheer': UiStrings.tagCheer,
    'daily': UiStrings.tagDaily,
    'greeting': UiStrings.tagGreeting,
    'emotional': UiStrings.tagEmotional,
    'praise': UiStrings.tagPraise,
    'fandom': UiStrings.tagFandom,
    'birthday': UiStrings.tagBirthday,
    'comeback': UiStrings.tagComeback,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // 멤버 칩 (가장 앞에 배치)
          if (showMemberChip)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                context,
                label: memberLabel ?? UiStrings.idolMemberLabel,
                selected: isMemberSelected,
                onSelected: (_) => onMemberSelected?.call(),
                primary: primary,
                theme: theme,
              ),
            ),
          // 마이아이돌 칩 (멤버 칩 뒤, 전체 앞에 배치)
          if (showMyIdolChip)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                context,
                label: myIdolLabel ?? UiStrings.idolSettingLabel,
                selected: isMyIdolSelected,
                onSelected: (_) => onMyIdolSelected?.call(),
                primary: primary,
                theme: theme,
              ),
            ),
          // 전체 칩
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildChip(
              context,
              label: UiStrings.tagAll,
              selected:
                  !isMyIdolSelected && !isMemberSelected && selectedTag == null,
              onSelected: (_) => onTagSelected(null),
              primary: primary,
              theme: theme,
            ),
          ),
          // 태그 칩들
          ...tags.map(
            (tag) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                context,
                label: _tagLabels[tag] ?? tag,
                selected: !isMyIdolSelected &&
                    !isMemberSelected &&
                    selectedTag == tag,
                onSelected: (_) => onTagSelected(tag),
                primary: primary,
                theme: theme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    required Color primary,
    required ThemeData theme,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: primary,
      backgroundColor: theme.colorScheme.surfaceContainer,
      checkmarkColor: theme.colorScheme.onPrimary,
      showCheckmark: false,
      side: selected
          ? BorderSide.none
          : BorderSide(color: theme.colorScheme.outlineVariant),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
