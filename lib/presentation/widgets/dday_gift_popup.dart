import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';

/// D-day 선물 팝업을 표시한다.
///
/// 유저가 설정한 아이돌의 이벤트(생일, 데뷔 기념일 등)가 오늘인 경우
/// 24시간 전체 콘텐츠 해금을 선물로 제공하는 다이얼로그를 표시한다.
/// [eventName]은 이벤트 표시 이름, [date]/[artist]/[eventType]은
/// [MonetizationNotifier.activateDdayUnlock]에 전달되어 중복 해금을 방지한다.
Future<void> showDdayGiftPopup(
  BuildContext context, {
  required String eventName,
  required String date,
  required String artist,
  required String eventType,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => DdayGiftPopup(
      eventName: eventName,
      date: date,
      artist: artist,
      eventType: eventType,
    ),
  );
}

/// D-day 선물 다이얼로그.
///
/// 아이돌 이벤트 축하 메시지와 "선물 받기" 버튼을 표시한다.
/// 버튼 탭 시 24시간 해금을 활성화하고 다이얼로그를 닫는다.
/// [FanPassPopup]과 동일한 scale+fade 진입 애니메이션을 사용한다.
class DdayGiftPopup extends ConsumerStatefulWidget {
  /// D-day 선물 다이얼로그를 생성한다.
  const DdayGiftPopup({
    required this.eventName,
    required this.date,
    required this.artist,
    required this.eventType,
    super.key,
  });

  /// 이벤트 표시 이름 (예: "슈가 생일").
  final String eventName;

  /// 이벤트 날짜 (yyyy-MM-dd 형식).
  final String date;

  /// 이벤트 아티스트명.
  final String artist;

  /// 이벤트 타입 (birthday, debut 등).
  final String eventType;

  @override
  ConsumerState<DdayGiftPopup> createState() => _DdayGiftPopupState();
}

class _DdayGiftPopupState extends ConsumerState<DdayGiftPopup>
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

  /// "선물 받기" 버튼 탭 핸들러.
  ///
  /// D-day 해금을 활성화한 뒤 다이얼로그를 닫는다.
  Future<void> _onAccept() async {
    await ref.read(monetizationNotifierProvider.notifier).activateDdayUnlock(
          date: widget.date,
          artist: widget.artist,
          eventType: widget.eventType,
        );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                l.ddayGiftTitle(widget.eventName),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l.ddayGiftMessage,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onAccept,
                child: Text(l.ddayGiftButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
