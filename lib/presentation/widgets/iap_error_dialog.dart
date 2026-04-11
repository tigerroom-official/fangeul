import 'package:flutter/material.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

/// IAP 결제 실패 시 유저 안내 다이얼로그.
///
/// Play Store 업데이트 안내 + 문의하기 + 확인 버튼.
Future<void> showIapErrorDialog(BuildContext context) async {
  final l = L.of(context);
  final theme = Theme.of(context);

  await showDialog<void>(
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
          onPressed: () {
            // async 없이 fire-and-forget — 첫 탭 이벤트 차단 방지
            launchUrl(
              AppConstants.supportEmailUri,
              mode: LaunchMode.externalApplication,
            ).catchError((_) => false);
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
}
