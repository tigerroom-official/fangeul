import 'package:flutter/material.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';

/// 스트릭 배너 -- 현재 연속 학습일수 표시.
///
/// 완료 상태에 따라 아이콘 스타일과 배지가 변경된다.
class StreakBanner extends StatelessWidget {
  /// Creates the [StreakBanner] widget.
  const StreakBanner({
    super.key,
    required this.streak,
    this.isCompletedToday = false,
  });

  /// 현재 연속 스트릭 일수.
  final int streak;

  /// 오늘 완료 여부.
  final bool isCompletedToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isCompletedToday
                ? Icons.local_fire_department
                : Icons.local_fire_department_outlined,
            color: isCompletedToday
                ? theme.colorScheme.secondary
                : theme.colorScheme.onSurfaceVariant,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            UiStrings.streakDays(streak),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (isCompletedToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                UiStrings.complete,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
