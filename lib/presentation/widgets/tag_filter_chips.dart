import 'package:flutter/material.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';

/// 태그 필터 칩 -- 문구 카테고리 필터링.
///
/// 수평 스크롤 칩 목록으로, '전체' + 개별 태그를 선택할 수 있다.
class TagFilterChips extends StatelessWidget {
  /// Creates the [TagFilterChips] widget.
  const TagFilterChips({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
  });

  /// 사용 가능한 태그 목록.
  final List<String> tags;

  /// 현재 선택된 태그. null이면 '전체' 선택.
  final String? selectedTag;

  /// 태그 선택 콜백. null을 전달하면 '전체' 선택.
  final ValueChanged<String?> onTagSelected;

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
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildChip(
              context,
              label: UiStrings.tagAll,
              selected: selectedTag == null,
              onSelected: (_) => onTagSelected(null),
              primary: primary,
              theme: theme,
            ),
          ),
          ...tags.map(
            (tag) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                context,
                label: _tagLabels[tag] ?? tag,
                selected: selectedTag == tag,
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
