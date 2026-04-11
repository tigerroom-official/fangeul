import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/ad_service_provider.dart';
import 'package:fangeul/presentation/providers/analytics_providers.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/remote_config_providers.dart';
import 'package:fangeul/presentation/widgets/theme_picker_sheet.dart';
import 'package:fangeul/services/analytics_events.dart';

/// TTS 일일 제한 도달 팝업.
///
/// 보상형 광고(+N회) 또는 IAP(무제한) 두 가지 CTA를 제공한다.
Future<void> showTtsLimitPopup(BuildContext context, WidgetRef ref) {
  ref.read(analyticsServiceProvider).logEvent(
    AnalyticsEvents.ttsLimitReached,
  );
  ref.read(analyticsServiceProvider).logEvent(
    AnalyticsEvents.conversionTriggerShown,
    {AnalyticsParams.source: 'tts_limit'},
  );
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
            ref.read(analyticsServiceProvider).logEvent(
              AnalyticsEvents.conversionTriggerClicked,
              {AnalyticsParams.source: 'tts_limit'},
            );
            Navigator.pop(dialogContext);
            ThemePickerSheet.show(context);
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
    if (context.mounted) {
      final l = L.of(context);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(l.fanPassAdLoading),
            duration: const Duration(seconds: 2),
          ),
        );
    }
    return;
  }
  try {
    await adService.showRewarded(
      onRewarded: () {
        ref
            .read(monetizationNotifierProvider.notifier)
            .addTtsRewardedBonus(bonus);
        ref.read(analyticsServiceProvider).logEvent(
          AnalyticsEvents.ttsRewardedWatch,
        );
        // ttsPlayedIdsProvider는 유지 — 이미 들은 문구는 재재생 시 카운트 안 함
      },
    );
  } catch (e) {
    debugPrint('[TtsLimitPopup] showRewarded failed: $e');
  }
}
