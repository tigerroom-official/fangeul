import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/ad_service_provider.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/remote_config_providers.dart';

/// TTS 일일 제한 도달 팝업.
///
/// 보상형 광고(+N회) 또는 IAP(무제한) 두 가지 CTA를 제공한다.
Future<void> showTtsLimitPopup(BuildContext context, WidgetRef ref) {
  final l = L.of(context);
  final bonus = ref.read(remoteConfigValuesProvider).ttsRewardedBonus;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l.ttsLimitTitle),
      content: Text(l.ttsLimitBody),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            _showRewardedForTts(context, ref, bonus);
          },
          child: Text(l.ttsLimitRewarded(bonus)),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            // Open theme picker sheet for IAP purchase
            // This navigates to the existing theme picker
          },
          child: Text(l.ttsLimitIap),
        ),
      ],
    ),
  );
}

Future<void> _showRewardedForTts(
  BuildContext context,
  WidgetRef ref,
  int bonus,
) async {
  final adService = ref.read(adServiceProvider);
  if (!adService.isRewardedReady) {
    adService.preloadRewarded();
    return;
  }
  try {
    await adService.showRewarded(
      onRewarded: () {
        ref
            .read(monetizationNotifierProvider.notifier)
            .addTtsRewardedBonus(bonus);
      },
    );
  } catch (e) {
    debugPrint('[TtsLimitPopup] showRewarded failed: $e');
  }
}
