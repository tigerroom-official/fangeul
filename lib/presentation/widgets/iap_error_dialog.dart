import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fangeul/l10n/app_localizations.dart';

/// IAP 결제 실패 시 유저 안내 다이얼로그.
///
/// Play Store 업데이트 안내 + 재시도 + 문의하기 CTA.
/// 반환값: true = 재시도, false/null = 닫힘/문의.
Future<bool> showIapErrorDialog(BuildContext context) async {
  final l = L.of(context);
  final theme = Theme.of(context);

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.error_outline_rounded,
          size: 32,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      title: Text(
        l.iapErrorTitle,
        textAlign: TextAlign.center,
      ),
      content: Text(
        l.iapErrorBody,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l.iapErrorRetry),
        ),
        FilledButton.tonal(
          onPressed: () {
            Navigator.pop(ctx, false);
            try {
              launchUrl(
                Uri.parse('mailto:tigerroom.official@gmail.com'),
                mode: LaunchMode.externalApplication,
              );
            } catch (_) {}
          },
          child: Text(l.iapErrorContact),
        ),
      ],
    ),
  );

  return result ?? false;
}
