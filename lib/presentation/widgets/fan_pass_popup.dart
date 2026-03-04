import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';

/// 팬 패스 획득 축하 팝업을 표시한다.
///
/// [showDialog]로 모달 다이얼로그를 표시하며, 해금 남은 시간과
/// 간단한 scale/fade 애니메이션을 포함한다.
Future<void> showFanPassPopup(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const FanPassPopup(),
  );
}

/// 팬 패스 획득 축하 다이얼로그.
///
/// 해금 남은 시간(hh:mm 형식)과 확인 버튼을 표시한다.
/// 간단한 scale+fade 진입 애니메이션을 포함한다.
class FanPassPopup extends ConsumerStatefulWidget {
  /// 팬 패스 획득 축하 다이얼로그를 생성한다.
  const FanPassPopup({super.key});

  @override
  ConsumerState<FanPassPopup> createState() => _FanPassPopupState();
}

class _FanPassPopupState extends ConsumerState<FanPassPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 해금 만료까지 남은 시간을 "hh:mm" 형식으로 반환한다.
  String _formatRemainingTime(int expiresAtMs) {
    final remaining = expiresAtMs - DateTime.now().millisecondsSinceEpoch;
    if (remaining <= 0) return '00:00';

    final duration = Duration(milliseconds: remaining);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(monetizationNotifierProvider);
    final expiresAt = asyncState.valueOrNull?.unlockExpiresAt ?? 0;
    final remainingText = _formatRemainingTime(expiresAt);
    final theme = Theme.of(context);
    final l = L.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.card_giftcard,
                size: 48,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                l.fanPassPopupTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.fanPassUnlockRemaining(remainingText),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.fanPassPopupConfirm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
