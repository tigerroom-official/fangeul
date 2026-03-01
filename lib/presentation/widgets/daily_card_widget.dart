import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fangeul/core/entities/daily_card.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/theme/fangeul_text_styles.dart';

/// 데일리 카드 -- 큰 한글 중앙 배치 + 발음 + 번역.
///
/// 완료/공유/복사 액션을 제공한다.
class DailyCardWidget extends StatelessWidget {
  /// Creates the [DailyCardWidget].
  const DailyCardWidget({
    super.key,
    required this.card,
    required this.translationLang,
    required this.isCompleted,
    this.onComplete,
    this.onShare,
  });

  /// 표시할 데일리 카드.
  final DailyCard card;

  /// 번역 언어 코드 (예: 'en').
  final String translationLang;

  /// 오늘 완료 여부.
  final bool isCompleted;

  /// 완료 콜백.
  final VoidCallback? onComplete;

  /// 공유 콜백.
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translation = card.phrase.translations[translationLang] ?? '';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // 한글 (주인공)
          Text(
            card.phrase.ko,
            style: FangeulTextStyles.koreanDisplay.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // 로마자 발음
          Text(
            card.phrase.roman,
            style: FangeulTextStyles.koreanSubtitle.copyWith(
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // 번역
          if (translation.isNotEmpty)
            Text(
              translation,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          const Spacer(flex: 3),
          // 액션 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isCompleted) ...[
                FilledButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(UiStrings.complete),
                ),
                const SizedBox(width: 12),
              ],
              OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined),
                label: const Text(UiStrings.share),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: card.phrase.ko));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(UiStrings.copied)),
                  );
                },
                icon: const Icon(Icons.copy_outlined),
                tooltip: UiStrings.copyTooltip,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
