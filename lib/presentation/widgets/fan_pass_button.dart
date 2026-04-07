import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/ad_service_provider.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';

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
  bool _cooldownInitialized = false;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  /// 초기 쿨다운 상태를 확인한다. 첫 유효 상태 도착 시 1회만 실행.
  void _initCooldownIfNeeded(MonetizationState? monState) {
    if (_cooldownInitialized || monState == null) return;
    _cooldownInitialized = true;

    if (monState.lastAdWatchTimestamp > 0) {
      final elapsed =
          DateTime.now().millisecondsSinceEpoch - monState.lastAdWatchTimestamp;
      final remaining = MonetizationNotifier.cooldownMs - elapsed;
      if (remaining > 0) {
        _startCooldownTimer(remaining);
      }
    }
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

  /// 보상형 광고에서 보상을 받았는지 여부.
  @visibleForTesting
  bool rewardEarned = false;

  /// 보상형 광고 플로우를 실행한다.
  ///
  /// 플래그 기반 설계: onRewarded에서는 플래그만 설정하고,
  /// onDismissed 후 async 처리를 수행하여 fire-and-forget을 방지한다.
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

    rewardEarned = false;
    setState(() => isShowingAd = true);

    await adService.showRewarded(
      onRewarded: () {
        rewardEarned = true;
      },
      onDismissed: () {
        if (mounted) {
          setState(() => isShowingAd = false);
          if (rewardEarned) _processReward();
        }
      },
    );
  }

  /// 보상 지급을 처리한다. onDismissed 이후 호출되어 context가 유효하다.
  Future<void> _processReward() async {
    final notifier = ref.read(monetizationNotifierProvider.notifier);
    final success = await notifier.recordAdWatch();
    if (!success) return;

    await notifier.activateThemeTrial();

    if (!mounted) return;

    _startCooldownTimer(MonetizationNotifier.cooldownMs);
    await showFanPassPopup(context);
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(monetizationNotifierProvider);
    final monState = asyncState.valueOrNull;
    final adService = ref.watch(adServiceProvider);

    final watchCount = monState?.adWatchCount ?? 0;
    final isLimitReached = watchCount >= MonetizationNotifier.dailyAdLimit;
    final isAdReady = adService.isRewardedReady;

    // 초기 쿨다운 확인 (1회만)
    _initCooldownIfNeeded(monState);

    final isCooldown = cooldownSeconds > 0;
    final isDisabled =
        isLimitReached || isCooldown || !isAdReady || isShowingAd;

    // 버튼 레이블 결정
    final l = L.of(context);
    String label;
    if (isLimitReached) {
      label = l.fanPassLimitReached;
    } else if (isCooldown) {
      label = '${l.fanPassButton} ${_formatCooldown(cooldownSeconds)}';
    } else if (!isAdReady) {
      label = l.fanPassAdLoading;
    } else {
      label =
          '${l.fanPassButton} ${l.fanPassRemaining(watchCount, MonetizationNotifier.dailyAdLimit)}';
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
