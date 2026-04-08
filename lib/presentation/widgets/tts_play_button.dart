import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/remote_config_providers.dart';
import 'package:fangeul/presentation/providers/tts_provider.dart';

/// TTS 재생 버튼 -- 탭하면 audioId의 음성을 재생한다.
///
/// 재생 중 펄스 애니메이션으로 시각 피드백을 제공한다.
/// [playTtsProvider]가 false를 반환하면 [onLimitReached]를 호출한다.
///
/// [freePlay]가 true이면 일일 재생 카운트를 소모하지 않고
/// [TtsService.playById]를 직접 호출한다 (데일리 카드 등 무료 재생용).
class TtsPlayButton extends ConsumerStatefulWidget {
  /// Creates a [TtsPlayButton].
  const TtsPlayButton({
    super.key,
    required this.audioId,
    this.onLimitReached,
    this.size = 20.0,
    this.freePlay = false,
  });

  /// TTS 오디오 ID.
  final String audioId;

  /// 일일 제한 도달 시 콜백.
  final VoidCallback? onLimitReached;

  /// 아이콘 크기.
  final double size;

  /// true이면 일일 카운트를 소모하지 않고 직접 재생한다.
  final bool freePlay;

  @override
  ConsumerState<TtsPlayButton> createState() => _TtsPlayButtonState();
}

class _TtsPlayButtonState extends ConsumerState<TtsPlayButton>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);
    _pulseController.repeat(reverse: true);

    try {
      if (widget.freePlay) {
        // 카운트 없이 직접 재생 (데일리 카드 등 무료 재생)
        await ref.read(ttsServiceProvider).playById(widget.audioId);
        sessionPlayedIds.add(widget.audioId);
      } else {
        final success = await ref.read(playTtsProvider(widget.audioId).future);
        if (!success && mounted) {
          widget.onLimitReached?.call();
        }
      }
    } catch (e) {
      debugPrint('[TtsPlayButton] play error: $e');
    }

    if (mounted) {
      _pulseController.stop();
      _pulseController.reset();
      setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final monState = ref.watch(monetizationNotifierProvider).valueOrNull;
    final isHoneymoon = ref.watch(isHoneymoonProvider);
    final hasIap = ref.watch(hasAnyIapProvider);
    final showCounter = !widget.freePlay && !isHoneymoon && !hasIap;

    final limit = ref.watch(remoteConfigValuesProvider).dailyTtsLimit;
    final used = monState?.ttsPlayCount ?? 0;
    final remaining = (limit - used).clamp(0, 99);

    final hasPlayed = hasPlayedInSession(widget.audioId);
    final iconColor = (showCounter && remaining == 0 && !hasPlayed)
        ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
        : _isPlaying
            ? theme.colorScheme.primary
            : hasPlayed
                ? theme.colorScheme.primary.withValues(alpha: 0.7)
                : theme.colorScheme.onSurfaceVariant;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.15);
        final iconButton = IconButton(
          icon: Transform.scale(
            scale: _isPlaying ? scale : 1.0,
            child: Icon(
              (_isPlaying || hasPlayed)
                  ? Icons.volume_up
                  : Icons.volume_up_outlined,
              size: widget.size,
              color: iconColor,
            ),
          ),
          tooltip: 'Play',
          onPressed: _play,
          visualDensity: VisualDensity.compact,
        );

        if (!showCounter) return iconButton;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            iconButton,
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: remaining > 0
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints:
                    const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$remaining',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: remaining > 0
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
