import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/analytics_providers.dart';
import 'package:fangeul/presentation/widgets/favorite_limit_dialog.dart';
import 'package:fangeul/presentation/widgets/theme_picker_sheet.dart';
import 'package:fangeul/services/analytics_events.dart';

/// SharedPreferences 키 — 즐겨찾기 제한 다이얼로그를 이미 본 적 있는지.
const _hasSeenFavLimitDialogKey = 'has_seen_fav_limit_dialog';

/// 중복 다이얼로그 방지 인메모리 가드.
bool _dialogInFlight = false;

/// 즐겨찾기 제한 도달 시 피드백을 표시한다.
///
/// - **메인앱 첫 도달**: 설명 다이얼로그 ([showFavoriteLimitDialog]) 표시.
/// - **메인앱 이후**: SnackBar + Action 버튼("테마 옵션 보기")으로 간결하게 안내.
/// - **버블(미니 컨버터)**: SnackBar만 표시 (소형 윈도우 UX 제약).
///
/// 버블 간편모드([CompactPhraseTile], [CompactPhraseList])와
/// 메인앱 문구 카드([PhraseCard]) 모두에서 호출한다.
Future<void> showFavoriteLimitFeedback(
  BuildContext context, {
  required String startingPrice,
  required WidgetRef ref,
}) async {
  ref.read(analyticsServiceProvider).logEvent(
    AnalyticsEvents.favLimitReached,
  );
  ref.read(analyticsServiceProvider).logEvent(
    AnalyticsEvents.conversionTriggerShown,
    {AnalyticsParams.source: 'favorite_limit'},
  );
  final prefs = await SharedPreferences.getInstance();
  // 듀얼 엔진 환경: 다른 엔진에서 기록한 값을 읽기 위해 reload
  await prefs.reload();
  final hasSeen = prefs.getBool(_hasSeenFavLimitDialogKey) ?? false;

  if (!context.mounted) return;

  // 버블 환경 감지: /mini-converter 경로면 축소 UI만 표시.
  final isBubble = GoRouterState.of(context).uri.path.startsWith('/mini');

  if (isBubble) {
    final l = L.of(context);
    // 가격 미로딩 시 가격 없는 일반 메시지로 대체
    final snackText = startingPrice.isNotEmpty
        ? l.favLimitMessage(startingPrice)
        : l.favoriteLimitReached;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(snackText),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: l.favLimitOpenApp,
            onPressed: () async {
              try {
                await const MethodChannel(
                  'com.tigerroom.fangeul/mini_converter',
                ).invokeMethod<bool>('openMainApp');
              } on PlatformException {
                // MiniConverterActivity가 아닌 환경에서 호출 시 무시.
              }
            },
          ),
        ),
      );
    return;
  }

  if (!hasSeen && !_dialogInFlight) {
    // 첫 도달 — 설명 다이얼로그
    _dialogInFlight = true;
    try {
      await showFavoriteLimitDialog(
        context,
        startingPrice: startingPrice,
        onViewThemeOptions: () {
          ref.read(analyticsServiceProvider).logEvent(
            AnalyticsEvents.conversionTriggerClicked,
            {AnalyticsParams.source: 'favorite_limit'},
          );
          if (context.mounted) {
            ThemePickerSheet.show(context);
          }
        },
      );
      // 가격 포함 메시지를 보여줬을 때만 seen 플래그 저장.
      // 가격 미로딩 상태에서는 다음에 다시 표시하여 가격 포함 메시지 노출 보장.
      if (startingPrice.isNotEmpty) {
        await prefs.setBool(_hasSeenFavLimitDialogKey, true);
      }
    } finally {
      _dialogInFlight = false;
    }
  } else {
    // 이후 — SnackBar + Action
    final l = L.of(context);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l.favoriteLimitReached),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: l.favLimitButton,
            onPressed: () {
              ref.read(analyticsServiceProvider).logEvent(
                AnalyticsEvents.conversionTriggerClicked,
                {AnalyticsParams.source: 'favorite_limit'},
              );
              if (context.mounted) {
                ThemePickerSheet.show(context);
              }
            },
          ),
        ),
      );
  }
}
