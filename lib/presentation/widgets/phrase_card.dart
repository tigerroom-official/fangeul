import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/theme/fangeul_colors.dart';

/// 문구 카드 -- 한글 원문 + 발음 + 번역.
///
/// 복사 버튼으로 한글 원문을 클립보드에 복사할 수 있다.
class PhraseCard extends StatelessWidget {
  /// Creates the [PhraseCard] widget.
  const PhraseCard({
    super.key,
    required this.phrase,
    required this.translationLang,
  });

  /// 표시할 문구.
  final Phrase phrase;

  /// 번역 언어 코드.
  final String translationLang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translation = phrase.translations[translationLang] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 한글 원문
          Text(
            phrase.ko,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // 로마자 발음
          Text(
            phrase.roman,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: FangeulColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          // 번역
          if (translation.isNotEmpty)
            Text(
              translation,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 8),
          // 액션 버튼
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: phrase.ko));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(UiStrings.copied)),
                  );
                },
                tooltip: UiStrings.copyTooltip,
              ),
              // TODO(fangeul): TTS 버튼 (Phase 5 서비스 연동)
            ],
          ),
        ],
      ),
    );
  }
}
