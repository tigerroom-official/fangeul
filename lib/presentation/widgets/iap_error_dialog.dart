import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

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
          onPressed: () async {
            try {
              final launched = await launchUrl(
                AppConstants.supportEmailUri,
                mode: LaunchMode.externalApplication,
              );
              if (!launched && ctx.mounted) {
                // 이메일 앱 실행 실패 → 이메일 주소 복사 fallback
                await Clipboard.setData(
                  const ClipboardData(text: AppConstants.supportEmail),
                );
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${AppConstants.supportEmail} ${l.copied}'),
                    ),
                  );
                }
              }
            } catch (_) {
              // 예외 발생 시에도 클립보드 복사 fallback
              await Clipboard.setData(
                const ClipboardData(text: AppConstants.supportEmail),
              );
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${AppConstants.supportEmail} copied'),
                  ),
                );
              }
            }
          },
          child: Text(l.iapErrorContact),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.pop(ctx),
          child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
        ),
      ],
    ),
  );

  return result ?? false;
}
