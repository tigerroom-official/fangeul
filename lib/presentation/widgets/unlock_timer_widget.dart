import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';

/// 테마 체험 남은 시간 카운트다운 위젯.
///
/// [monetizationNotifierProvider]의 `themeTrialExpiresAt`을 기반으로
/// 매초 남은 시간을 갱신하여 표시한다.
/// 체험이 비활성이거나 만료되었으면 [SizedBox.shrink]을 반환한다.
///
/// 타이머 콜백에서 반드시 [mounted] 가드를 사용한다
/// (Sprint 1 교훈: OverlayEntry 타이머 cleanup 크래시 방지).
class UnlockTimerWidget extends ConsumerStatefulWidget {
  /// Creates the [UnlockTimerWidget].
  const UnlockTimerWidget({super.key});

  @override
  ConsumerState<UnlockTimerWidget> createState() => _UnlockTimerWidgetState();
}

class _UnlockTimerWidgetState extends ConsumerState<UnlockTimerWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {}); // 새 시각으로 리빌드
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeTrialExpiresAt =
        ref.watch(monetizationNotifierProvider).valueOrNull?.themeTrialExpiresAt ??
            0;

    if (themeTrialExpiresAt == 0) return const SizedBox.shrink();

    final now = clock.now().millisecondsSinceEpoch;
    final remainingMs = themeTrialExpiresAt - now;

    if (remainingMs <= 0) return const SizedBox.shrink();

    // 남은 시간 계산
    final duration = Duration(milliseconds: remainingMs);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    // 자정 만료 여부 확인 (만료 시각이 자정 기준 1분 이내)
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(themeTrialExpiresAt);
    final isMidnight = expiryTime.hour == 0 && expiryTime.minute < 1;

    final timeStr = hours > 0
        ? '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer_outlined,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          isMidnight
              ? L.of(context).unlockMidnightExpiry(timeStr)
              : L.of(context).unlockRemaining(timeStr),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
