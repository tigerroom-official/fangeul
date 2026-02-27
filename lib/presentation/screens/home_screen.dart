import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fangeul/presentation/providers/phrase_providers.dart';
import 'package:fangeul/presentation/providers/progress_providers.dart';
import 'package:fangeul/presentation/widgets/celebration_overlay.dart';
import 'package:fangeul/presentation/widgets/daily_card_widget.dart';
import 'package:fangeul/presentation/widgets/share_card_painter.dart';
import 'package:fangeul/presentation/widgets/streak_banner.dart';

/// 홈 화면 — 데일리 카드 + 스트릭.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the [HomeScreen] widget.
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showCelebration = false;

  String _todayString() {
    final now = DateTime.now();
    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _completeDailyCard() async {
    final useCase = ref.read(updateStreakUseCaseProvider);
    await useCase.execute(now: DateTime.now());
    ref.invalidate(userProgressProvider);
    setState(() => _showCelebration = true);
  }

  @override
  Widget build(BuildContext context) {
    final today = _todayString();
    final dailyCard = ref.watch(dailyCardProvider(today));
    final progress = ref.watch(userProgressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fangeul'),
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
                    if (card == null) {
                      return const Center(
                        child: Text('오늘의 카드를 불러올 수 없습니다'),
                      );
                    }
                    final isCompleted =
                        progress.valueOrNull?.lastCompletedDate == today;
                    return DailyCardWidget(
                      card: card,
                      translationLang: 'en',
                      isCompleted: isCompleted,
                      onComplete: isCompleted ? null : _completeDailyCard,
                      onShare: () => shareCard(
                        card: card,
                        isDark: theme.brightness == Brightness.dark,
                        translationLang: 'en',
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('오류: $e')),
                ),
              ),
            ],
          ),
          // Lottie 축하 오버레이
          if (_showCelebration)
            CelebrationOverlay(
              assetPath: 'assets/lottie/confetti.json',
              onComplete: () => setState(() => _showCelebration = false),
            ),
        ],
      ),
    );
  }
}
