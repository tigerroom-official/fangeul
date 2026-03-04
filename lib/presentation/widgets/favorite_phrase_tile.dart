import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fangeul/l10n/app_localizations.dart';

/// 간편모드 즐겨찾기 문구 타일.
///
/// 한글 문구 + 복사 버튼. 탭하면 클립보드에 복사.
class FavoritePhraseTile extends StatelessWidget {
  /// Creates a [FavoritePhraseTile].
  const FavoritePhraseTile({
    super.key,
    required this.text,
    this.subtitle,
    this.onCopied,
  });

  /// 한글 문구 텍스트.
  final String text;

  /// 부제(로마자 발음 등). null이면 미표시.
  final String? subtitle;

  /// 복사 완료 콜백.
  final VoidCallback? onCopied;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      title: Text(
        text,
        style: theme.textTheme.bodyLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.copy_rounded, size: 18),
        tooltip: l.copyTooltip,
        onPressed: () => _copy(context),
      ),
      onTap: () => _copy(context),
    );
  }

  void _copy(BuildContext context) {
    final l = L.of(context);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.copied),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    onCopied?.call();
  }
}
