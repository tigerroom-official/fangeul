import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// 축하 애니메이션 오버레이 — 스트릭 완료 시 confetti 표시.
///
/// 축소 모션 설정 시 Lottie 비활성 (접근성).
/// 애니메이션 완료 후 자동으로 [onComplete] 호출.
class CelebrationOverlay extends StatefulWidget {
  /// Creates a [CelebrationOverlay].
  const CelebrationOverlay({
    super.key,
    required this.assetPath,
    required this.onComplete,
  });

  /// Lottie JSON 에셋 경로.
  final String assetPath;

  /// 애니메이션 완료 시 콜백.
  final VoidCallback onComplete;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fireOnComplete() {
    if (_completed) return;
    _completed = true;
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    // 접근성: 축소 모션 설정 시 애니메이션 미표시
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      // 바로 완료 처리 (guard로 중복 호출 방지)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fireOnComplete();
      });
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Lottie.asset(
          widget.assetPath,
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().then((_) => _fireOnComplete());
          },
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
