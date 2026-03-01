import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/copy_history_provider.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/theme/fangeul_colors.dart';

/// 간편모드 문구 타일 — ko + roman + ★토글 + 복사.
///
/// 팩 탐색 탭에서 각 문구를 표시한다.
/// ★ 토글로 즐겨찾기 추가/제거, 📋 버튼으로 클립보드 복사.
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
    final favorites = ref.watch(favoritePhrasesNotifierProvider).valueOrNull ?? {};
    final isFavorite = favorites.contains(phrase.ko);

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
          ? Text(
              phrase.roman,
              style: theme.textTheme.bodySmall?.copyWith(
                color: FangeulColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              size: 20,
              color: isFavorite ? FangeulColors.primary : null,
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

  void _copy(BuildContext context, WidgetRef ref) {
    Clipboard.setData(ClipboardData(text: phrase.ko));
    ref.read(copyHistoryNotifierProvider.notifier).addEntry(phrase.ko);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      onCopied?.call();
    });
  }
}
