import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/copy_history_provider.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/widgets/favorite_phrase_tile.dart';
import 'package:fangeul/presentation/widgets/recent_copy_tile.dart';

/// 간편모드 문구 리스트 (즐겨찾기 + 최근 탭).
///
/// [TabController]는 부모에서 관리하며,
/// 마지막 선택 탭은 shared_preferences에 저장.
class CompactPhraseList extends ConsumerWidget {
  /// Creates a [CompactPhraseList].
  const CompactPhraseList({
    super.key,
    required this.tabController,
    this.onCopied,
  });

  /// 탭 컨트롤러 (즐겨찾기 / 최근).
  final TabController tabController;

  /// 복사 완료 콜백 (dismiss 트리거용).
  final VoidCallback? onCopied;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritePhrasesNotifierProvider);
    final history = ref.watch(copyHistoryNotifierProvider);

    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: UiStrings.miniTabFavorites),
            Tab(text: UiStrings.miniTabRecent),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _buildFavoritesTab(favorites, ref),
              _buildRecentTab(history),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab(Set<String> favorites, WidgetRef ref) {
    if (favorites.isEmpty) {
      return const Center(
        child: Text(
          UiStrings.miniFavoritesEmpty,
          textAlign: TextAlign.center,
        ),
      );
    }

    final favoritesList = favorites.toList();
    return ListView.builder(
      itemCount: favoritesList.length,
      itemBuilder: (context, index) {
        final ko = favoritesList[index];
        return FavoritePhraseTile(
          text: ko,
          onCopied: () {
            ref.read(copyHistoryNotifierProvider.notifier).addEntry(ko);
            // addEntry가 rebuild을 트리거하므로 프레임 완료 후 close
            SchedulerBinding.instance.addPostFrameCallback((_) {
              onCopied?.call();
            });
          },
        );
      },
    );
  }

  Widget _buildRecentTab(List<String> history) {
    if (history.isEmpty) {
      return const Center(
        child: Text(UiStrings.miniRecentEmpty),
      );
    }

    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        return RecentCopyTile(
          text: history[index],
          onCopied: onCopied,
        );
      },
    );
  }
}
