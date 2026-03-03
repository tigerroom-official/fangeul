import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/ad_service_provider.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/session_state_provider.dart';
import 'package:fangeul/presentation/widgets/fan_pass_popup.dart';

/// 보상형 "팬 패스" 버튼.
///
/// 일일 시청 횟수(N/3), 쿨다운 타이머, 광고 로딩 상태를 표시한다.
/// 탭 시 보상형 광고를 표시하고, 완료 시 해금을 활성화한다.
class FanPassButton extends ConsumerStatefulWidget {
  /// 보상형 "팬 패스" 버튼을 생성한다.
  const FanPassButton({super.key});

  @override
  ConsumerState<FanPassButton> createState() => FanPassButtonState();
}

/// [FanPassButton]의 State.
///
/// 쿨다운 타이머는 위젯 고유의 ephemeral state이므로 setState 사용이 적합하다.
/// 광고 로딩 상태도 마찬가지.
@visibleForTesting
class FanPassButtonState extends ConsumerState<FanPassButton> {
  /// 쿨다운 남은 초.
  @visibleForTesting
  int cooldownSeconds = 0;

  /// 광고 표시 중 여부 (중복 탭 방지).
  @visibleForTesting
  bool isShowingAd = false;

  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  /// 쿨다운 타이머를 시작한다.
  void _startCooldownTimer(int remainingMs) {
    _cooldownTimer?.cancel();
    if (remainingMs <= 0) {
      if (mounted) setState(() => cooldownSeconds = 0);
      return;
    }

    setState(() => cooldownSeconds = (remainingMs / 1000).ceil());

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        cooldownSeconds--;
        if (cooldownSeconds <= 0) {
          cooldownSeconds = 0;
          timer.cancel();
        }
      });
    });
  }

  /// 쿨다운 남은 시간을 "M:SS" 형식으로 반환한다.
  String _formatCooldown(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }

  /// 보상형 광고 플로우를 실행한다.
  Future<void> _onTap() async {
    if (isShowingAd) return;

    final adService = ref.read(adServiceProvider);
    if (!adService.isRewardedReady) return;

    final notifier = ref.read(monetizationNotifierProvider.notifier);
    if (notifier.isAdLimitReached) return;

    // 쿨다운 확인
    final monState = ref.read(monetizationNotifierProvider).valueOrNull;
    if (monState != null && monState.lastAdWatchTimestamp > 0) {
      final elapsed =
          DateTime.now().millisecondsSinceEpoch - monState.lastAdWatchTimestamp;
      if (elapsed < MonetizationNotifier.cooldownMs) return;
    }

    setState(() => isShowingAd = true);

    await adService.showRewarded(
      onRewarded: () async {
        final success = await notifier.recordAdWatch();
        if (success) {
          await notifier.activateRewardedUnlock();
          ref.read(sessionBannerHiddenProvider.notifier).hide();

          if (mounted) {
            // 쿨다운 타이머 시작
            _startCooldownTimer(MonetizationNotifier.cooldownMs);

            // 축하 팝업 표시
            await showFanPassPopup(context, ref);
          }
        }
      },
      onDismissed: () {
        if (mounted) setState(() => isShowingAd = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(monetizationNotifierProvider);
    final monState = asyncState.valueOrNull;
    final adService = ref.watch(adServiceProvider);

    final watchCount = monState?.adWatchCount ?? 0;
    final isLimitReached = watchCount >= MonetizationNotifier.dailyAdLimit;
    final isAdReady = adService.isRewardedReady;

    // 쿨다운 확인 (초기 렌더 시)
    if (monState != null &&
        cooldownSeconds == 0 &&
        _cooldownTimer == null &&
        monState.lastAdWatchTimestamp > 0) {
      final elapsed =
          DateTime.now().millisecondsSinceEpoch - monState.lastAdWatchTimestamp;
      final remaining = MonetizationNotifier.cooldownMs - elapsed;
      if (remaining > 0) {
        // Schedule timer start after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _startCooldownTimer(remaining);
        });
      }
    }

    final isCooldown = cooldownSeconds > 0;
    final isDisabled =
        isLimitReached || isCooldown || !isAdReady || isShowingAd;

    // 버튼 레이블 결정
    String label;
    if (isLimitReached) {
      label = UiStrings.fanPassLimitReached;
    } else if (isCooldown) {
      label = '${UiStrings.fanPassButton} ${_formatCooldown(cooldownSeconds)}';
    } else if (!isAdReady) {
      label = UiStrings.fanPassAdLoading;
    } else {
      label =
          '${UiStrings.fanPassButton} ${UiStrings.fanPassRemaining(watchCount, MonetizationNotifier.dailyAdLimit)}';
    }

    final theme = Theme.of(context);

    return FilledButton.icon(
      onPressed: isDisabled ? null : _onTap,
      icon: const Icon(Icons.card_giftcard, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        disabledBackgroundColor: theme.colorScheme.surfaceContainerHigh,
        disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
