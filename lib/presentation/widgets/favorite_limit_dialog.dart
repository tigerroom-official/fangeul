import 'package:flutter/material.dart';

import 'package:fangeul/l10n/app_localizations.dart';

/// 즐겨찾기 슬롯 포화 다이얼로그 — 테마 IAP 구매를 유도한다.
///
/// 아무 테마 IAP(피커/슬롯/번들)든 하나 구매하면 즐겨찾기 무제한 해금.
/// 첫 도달 시에만 표시하고, 이후는 SnackBar+Action으로 대체한다.
Future<void> showFavoriteLimitDialog(
  BuildContext context, {
  required VoidCallback onViewThemeOptions,
  required String startingPrice,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => FavoriteLimitDialog(
      onViewThemeOptions: onViewThemeOptions,
      startingPrice: startingPrice,
    ),
  );
}

/// 즐겨찾기 제한 다이얼로그 위젯.
class FavoriteLimitDialog extends StatelessWidget {
  /// Creates a [FavoriteLimitDialog].
  const FavoriteLimitDialog({
    required this.onViewThemeOptions,
    required this.startingPrice,
    super.key,
  });

  /// 테마 커스터마이징 시트를 여는 콜백.
  final VoidCallback onViewThemeOptions;

  /// 최저 IAP 가격 (로컬라이즈된 문자열, 예: "₩990", "¥150").
  final String startingPrice;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l.favLimitTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            startingPrice.isNotEmpty
                ? l.favLimitMessage(startingPrice)
                : l.favoriteLimitReached,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.favLimitDismiss),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onViewThemeOptions();
          },
          child: Text(l.favLimitButton),
        ),
      ],
    );
  }
}
