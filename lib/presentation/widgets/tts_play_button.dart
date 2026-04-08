import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/providers/tts_provider.dart';

/// TTS 재생 버튼 -- 탭하면 audioId의 음성을 재생한다.
///
/// 재생 중 펄스 애니메이션으로 시각 피드백을 제공한다.
/// [playTtsProvider]가 false를 반환하면 [onLimitReached]를 호출한다.
class TtsPlayButton extends ConsumerStatefulWidget {
  /// Creates a [TtsPlayButton].
  const TtsPlayButton({
    super.key,
    required this.audioId,
    this.onLimitReached,
    this.size = 20.0,
  });

  /// TTS 오디오 ID.
  final String audioId;

  /// 일일 제한 도달 시 콜백.
  final VoidCallback? onLimitReached;

  /// 아이콘 크기.
  final double size;

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
      final success = await ref.read(playTtsProvider(widget.audioId).future);
      if (!success && mounted) {
        widget.onLimitReached?.call();
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
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.15);
        return IconButton(
          icon: Transform.scale(
            scale: _isPlaying ? scale : 1.0,
            child: Icon(
              _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
              size: widget.size,
              color: _isPlaying
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          tooltip: 'Play',
          onPressed: _play,
          visualDensity: VisualDensity.compact,
        );
      },
    );
  }
}
