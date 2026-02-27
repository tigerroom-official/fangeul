import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fangeul/presentation/providers/phrase_providers.dart';
import 'package:fangeul/presentation/providers/progress_providers.dart';
import 'package:fangeul/presentation/widgets/daily_card_widget.dart';
import 'package:fangeul/presentation/widgets/streak_banner.dart';

/// 홈 화면 -- 데일리 카드 + 스트릭.
///
/// 매일 하나의 한국어 문구를 제공하고, 연속 학습일수를 표시한다.
class HomeScreen extends ConsumerWidget {
  /// Creates the [HomeScreen] widget.
  const HomeScreen({super.key});

  String _todayString() {
    final now = DateTime.now();
    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = _todayString();
    final dailyCard = ref.watch(dailyCardProvider(today));
    final progress = ref.watch(userProgressProvider);

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
      body: Column(
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
                  onComplete:
                      isCompleted ? null : () => _completeDailyCard(ref),
                  onShare: () {
                    // TODO(fangeul): Task 11에서 공유 카드 구현
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeDailyCard(WidgetRef ref) async {
    final useCase = ref.read(updateStreakUseCaseProvider);
    await useCase.execute(now: DateTime.now());
    ref.invalidate(userProgressProvider);
  }
}
