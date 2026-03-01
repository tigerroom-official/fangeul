import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';

/// 문구 카드 -- 한글 원문 + 발음 + 번역.
///
/// 복사 버튼과 즐겨찾기 토글 버튼을 제공한다.
class PhraseCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final translation = phrase.translations[translationLang] ?? '';
    final favorites =
        ref.watch(favoritePhrasesNotifierProvider).valueOrNull ?? {};
    final isFavorite = favorites.contains(phrase.ko);

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
              color: theme.colorScheme.primary,
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
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 20,
                  color: isFavorite ? theme.colorScheme.primary : null,
                ),
                onPressed: () {
                  ref
                      .read(favoritePhrasesNotifierProvider.notifier)
                      .toggle(phrase.ko);
                },
                tooltip: UiStrings.favoriteTooltip,
              ),
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
