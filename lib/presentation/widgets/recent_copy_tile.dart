import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';

/// 간편모드 최근 복사 타일.
///
/// 최근 복사한 텍스트를 표시. 탭하면 클립보드에 다시 복사.
class RecentCopyTile extends StatelessWidget {
  /// Creates a [RecentCopyTile].
  const RecentCopyTile({
    super.key,
    required this.text,
    this.onCopied,
  });

  /// 복사된 텍스트.
  final String text;

  /// 복사 완료 콜백.
  final VoidCallback? onCopied;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      leading: Icon(
        Icons.history_rounded,
        size: 18,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        text,
        style: theme.textTheme.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.copy_rounded, size: 18),
        tooltip: UiStrings.copyTooltip,
        onPressed: () => _copy(context),
      ),
      onTap: () => _copy(context),
    );
  }

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(UiStrings.copied),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    onCopied?.call();
  }
}
