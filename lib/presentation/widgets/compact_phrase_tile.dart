import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/analytics_providers.dart';
import 'package:fangeul/presentation/providers/copy_history_provider.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/widgets/copy_feedback_overlay.dart';
import 'package:fangeul/services/analytics_events.dart';

/// 간편모드 문구 타일 — ko + roman + ★토글 + 복사.
///
/// 팩 탐색 탭에서 각 문구를 표시한다.
/// ★ 토글로 즐겨찾기 추가/제거, 📋 버튼으로 클립보드 복사.
///
/// roman 텍스트 내 그룹/멤버명은 로마자 발음이 아니므로
/// muted 색상([ColorScheme.onSurfaceVariant])으로 구분하여 표시한다.
class CompactPhraseTile extends ConsumerWidget {
  /// Creates a [CompactPhraseTile].
  const CompactPhraseTile({
    super.key,
    required this.phrase,
    this.onCopied,
  });

  /// 표시할 문구.
  final Phrase phrase;

  /// 복사 완료 콜백 (dismiss 트리거용).
  final VoidCallback? onCopied;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favorites =
        ref.watch(favoritePhrasesNotifierProvider).valueOrNull ?? {};
    final isFavorite = favorites.contains(phrase.ko);

    final idolName =
        ref.watch(myIdolDisplayNameProvider).valueOrNull;
    final memberName =
        ref.watch(myIdolMemberNameProvider).valueOrNull;

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text(
        phrase.ko,
        style: theme.textTheme.bodyLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: phrase.roman.isNotEmpty
          ? _buildRomanSubtitle(theme, idolName, memberName)
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              size: 20,
              color: isFavorite ? theme.colorScheme.primary : null,
            ),
            tooltip: UiStrings.favoriteTooltip,
            constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
            padding: EdgeInsets.zero,
            onPressed: () {
              ref
                  .read(favoritePhrasesNotifierProvider.notifier)
                  .toggle(phrase.ko);
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18),
            tooltip: UiStrings.copyTooltip,
            constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
            padding: EdgeInsets.zero,
            onPressed: () => _copy(context, ref),
          ),
        ],
      ),
      onTap: () => _copy(context, ref),
    );
  }

  /// roman 텍스트에서 그룹/멤버명을 다른 색상으로 구분한 위젯.
  ///
  /// 아이돌 미설정이거나 roman에 이름이 없으면 단일 Text를 반환한다.
  Widget _buildRomanSubtitle(
    ThemeData theme,
    String? idolName,
    String? memberName,
  ) {
    final romanStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.primary,
    );

    // 이름이 없으면 단일 텍스트
    final names = <String>[
      if (idolName != null) idolName,
      if (memberName != null) memberName,
    ];
    if (names.isEmpty || !names.any((n) => phrase.roman.contains(n))) {
      return Text(
        phrase.roman,
        style: romanStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final nameStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    final spans = _splitRomanByNames(phrase.roman, names, romanStyle, nameStyle);
    return Text.rich(
      TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// roman 텍스트를 이름 부분과 로마자 부분으로 분리하여 TextSpan 목록을 반환한다.
  List<TextSpan> _splitRomanByNames(
    String text,
    List<String> names,
    TextStyle? romanStyle,
    TextStyle? nameStyle,
  ) {
    final spans = <TextSpan>[];
    var remaining = text;

    while (remaining.isNotEmpty) {
      // 가장 가까운 이름 매치 찾기
      int nearestIndex = remaining.length;
      String? matchedName;
      for (final name in names) {
        final idx = remaining.indexOf(name);
        if (idx >= 0 && idx < nearestIndex) {
          nearestIndex = idx;
          matchedName = name;
        }
      }

      if (matchedName == null) {
        // 더 이상 이름 없음
        spans.add(TextSpan(text: remaining, style: romanStyle));
        break;
      }

      // 이름 앞 로마자 부분
      if (nearestIndex > 0) {
        spans.add(TextSpan(
          text: remaining.substring(0, nearestIndex),
          style: romanStyle,
        ));
      }

      // 이름 부분 (muted 색상)
      spans.add(TextSpan(text: matchedName, style: nameStyle));
      remaining = remaining.substring(nearestIndex + matchedName.length);
    }

    return spans;
  }

  void _copy(BuildContext context, WidgetRef ref) {
    Clipboard.setData(ClipboardData(text: phrase.ko));
    ref.read(copyHistoryNotifierProvider.notifier).addEntry(phrase.ko);
    ref.read(analyticsServiceProvider).logEvent(
      AnalyticsEvents.phraseCopy,
      {
        AnalyticsParams.source: 'bubble',
        if (phrase.situation != null)
          AnalyticsParams.situation: phrase.situation!,
      },
    );
    CopyFeedback.trigger(context);
    // 피드백이 잠시 보인 후 닫기
    Future.delayed(const Duration(milliseconds: 400), () {
      onCopied?.call();
    });
  }
}
