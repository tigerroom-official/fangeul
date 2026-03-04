import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/analytics_providers.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/services/analytics_events.dart';

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
    final idolName = ref.watch(myIdolDisplayNameProvider).valueOrNull;
    final memberName = ref.watch(myIdolMemberNameProvider).valueOrNull;

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
          // 로마자 발음 — 치환된 그룹/멤버명은 muted 색상으로 구분
          _buildRomanText(theme, idolName, memberName),
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
                  ref.read(analyticsServiceProvider).logEvent(
                    AnalyticsEvents.phraseCopy,
                    {
                      AnalyticsParams.source: 'main',
                      if (phrase.situation != null)
                        AnalyticsParams.situation: phrase.situation!,
                    },
                  );
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

  /// roman 텍스트에서 치환된 그룹/멤버명을 muted 색상으로 구분한다.
  ///
  /// 아이돌 미설정이거나 roman에 이름이 없으면 단일 Text를 반환한다.
  Widget _buildRomanText(
    ThemeData theme,
    String? idolName,
    String? memberName,
  ) {
    final romanStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.primary,
    );

    final names = <String>[
      if (idolName != null) idolName,
      if (memberName != null) memberName,
    ];
    if (names.isEmpty || !names.any((n) => phrase.roman.contains(n))) {
      return Text(phrase.roman, style: romanStyle);
    }

    final nameStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Text.rich(
      TextSpan(children: _splitByNames(phrase.roman, names, romanStyle, nameStyle)),
    );
  }

  /// 텍스트를 이름 부분(muted)과 발음 부분(primary)으로 분리.
  List<TextSpan> _splitByNames(
    String text,
    List<String> names,
    TextStyle? romanStyle,
    TextStyle? nameStyle,
  ) {
    final spans = <TextSpan>[];
    var remaining = text;

    while (remaining.isNotEmpty) {
      int nearestIndex = remaining.length;
      String? matched;
      for (final name in names) {
        final idx = remaining.indexOf(name);
        if (idx >= 0 && idx < nearestIndex) {
          nearestIndex = idx;
          matched = name;
        }
      }

      if (matched == null) {
        spans.add(TextSpan(text: remaining, style: romanStyle));
        break;
      }

      if (nearestIndex > 0) {
        spans.add(TextSpan(
          text: remaining.substring(0, nearestIndex),
          style: romanStyle,
        ));
      }
      spans.add(TextSpan(text: matched, style: nameStyle));
      remaining = remaining.substring(nearestIndex + matched.length);
    }

    return spans;
  }
}
