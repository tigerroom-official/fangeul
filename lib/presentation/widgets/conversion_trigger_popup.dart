import 'package:flutter/material.dart';

import 'package:fangeul/l10n/app_localizations.dart';

/// 전환 트리거 팝업 — IAP 구매를 유도하는 소프트 CTA 다이얼로그.
///
/// Day 14+, 보상형 3회 소진, 즐겨찾기 슬롯 포화 조건 충족 시
/// 세션당 1회 표시한다.
/// [onViewShop] 콜백으로 ShopScreen 이동을, 닫기로 거절을 처리한다.
Future<void> showConversionTriggerPopup(
  BuildContext context, {
  required VoidCallback onViewShop,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => ConversionTriggerPopup(
      onViewShop: onViewShop,
    ),
  );
}

/// 전환 트리거 다이얼로그 위젯.
class ConversionTriggerPopup extends StatelessWidget {
  /// Creates a [ConversionTriggerPopup].
  const ConversionTriggerPopup({
    required this.onViewShop,
    super.key,
  });

  /// ShopScreen으로 이동하는 콜백.
  final VoidCallback onViewShop;

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
            Icons.auto_awesome,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l.conversionTriggerTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l.conversionTriggerMessage,
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
          child: Text(l.conversionTriggerDismiss),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onViewShop();
          },
          child: Text(l.conversionTriggerButton),
        ),
      ],
    );
  }
}
