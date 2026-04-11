import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/ad_service_provider.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/providers/phrase_providers.dart';
import 'package:fangeul/presentation/providers/progress_providers.dart';
import 'package:fangeul/presentation/widgets/celebration_overlay.dart';
import 'package:fangeul/presentation/widgets/daily_card_widget.dart';
import 'package:fangeul/presentation/widgets/share_card_painter.dart';
import 'package:fangeul/presentation/widgets/streak_banner.dart';

/// 축하 애니메이션 표시 여부 Provider.
///
/// 스트릭 완료 시 true, 애니메이션 종료 시 false.
final showCelebrationProvider = StateProvider.autoDispose<bool>((ref) => false);

/// 오늘 날짜를 'yyyy-MM-dd' 형식으로 반환한다.
String _todayString() {
  final now = DateTime.now();
  final y = now.year.toString();
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// 홈 화면 — 데일리 카드 + 스트릭.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the [HomeScreen] widget.
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 보상형 광고 프리로드 (1회, initState에서 실행)
    ref.read(adServiceProvider).preloadRewarded();
  }

  @override
  Widget build(BuildContext context) {


    final today = _todayString();
    final dailyCard = ref.watch(dailyCardProvider(today));
    final progress = ref.watch(userProgressProvider);
    final showCelebration = ref.watch(showCelebrationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, _) {
            final l = L.of(context);
            final idolName = ref.watch(myIdolDisplayNameProvider);
            return idolName.when(
              data: (name) =>
                  name != null ? Text(l.homeGreeting(name)) : Text(l.appName),
              loading: () => Text(l.appName),
              error: (_, __) => Text(l.appName),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 스트릭 배너
              progress.when(
                data: (p) => StreakBanner(
                  streak: p.streak,
                  isCompletedToday: p.lastCompletedDate == today,
                ),
                loading: () => const SizedBox(height: 72),
                error: (_, __) => const SizedBox.shrink(),
              ),
              // 데일리 카드
              Expanded(
                child: dailyCard.when(
                  data: (card) {
                    final l = L.of(context);
                    if (card == null) {
                      return Center(
                        child: Text(l.dailyCardLoadError),
                      );
                    }
                    final isCompleted =
                        progress.valueOrNull?.lastCompletedDate == today;
                    return DailyCardWidget(
                      card: card,
                      translationLang: l.defaultTranslationLang,
                      isCompleted: isCompleted,
                      onComplete: isCompleted
                          ? null
                          : () async {
                              try {
                                final useCase =
                                    ref.read(updateStreakUseCaseProvider);
                                await useCase.execute(now: DateTime.now());
                                ref.invalidate(userProgressProvider);
                                ref.read(showCelebrationProvider.notifier)
                                    .state = true;
                              } catch (e) {
                                debugPrint('onComplete failed: $e');
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '${L.of(context).errorPrefix} $e')),
                                );
                              }
                            },
                      onShare: () => shareCard(
                        card: card,
                        colorScheme: theme.colorScheme,
                        translationLang: l.defaultTranslationLang,
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('${L.of(context).errorPrefix} $e')),
                ),
              ),
            ],
          ),
          // Lottie 축하 오버레이
          if (showCelebration)
            CelebrationOverlay(
              assetPath: 'assets/lottie/confetti.json',
              onComplete: () =>
                  ref.read(showCelebrationProvider.notifier).state = false,
            ),
        ],
      ),
    );
  }
}
