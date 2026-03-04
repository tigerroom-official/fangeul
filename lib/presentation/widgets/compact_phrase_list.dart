import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/compact_phrase_filter_provider.dart';
import 'package:fangeul/presentation/providers/calendar_providers.dart';
import 'package:fangeul/presentation/providers/copy_history_provider.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/providers/my_idol_provider.dart';
import 'package:fangeul/presentation/providers/phrase_providers.dart';

import 'package:fangeul/presentation/widgets/compact_phrase_tile.dart';
import 'package:fangeul/presentation/widgets/copy_feedback_overlay.dart';
import 'package:fangeul/presentation/widgets/pack_filter_chips.dart';
import 'package:fangeul/presentation/widgets/recent_copy_tile.dart';

/// 간편모드 문구 리스트 (문구 탐색 + 최근 탭).
///
/// 탭1 "문구": 팩 필터 칩 + 좌우 스와이프 카드(팩) / 세로 리스트(즐겨찾기).
/// 탭2 "최근": 최근 복사 이력 세로 리스트.
class CompactPhraseList extends ConsumerWidget {
  /// Creates a [CompactPhraseList].
  const CompactPhraseList({
    super.key,
    required this.tabController,
    this.onCopied,
  });

  /// 탭 컨트롤러 (문구 / 최근).
  final TabController tabController;

  /// 복사 완료 콜백 (dismiss 트리거용).
  final VoidCallback? onCopied;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(copyHistoryNotifierProvider);

    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: UiStrings.miniTabPhrases),
            Tab(text: UiStrings.miniTabRecent),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _PhrasesTab(onCopied: onCopied),
              _buildRecentTab(history),
            ],
          ),
        ),
      ],
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

/// 탭1 "문구" — 팩 필터 칩 + 문구 콘텐츠.
///
/// [AutomaticKeepAliveClientMixin]으로 탭 전환 시에도 위젯을 유지하여
/// provider auto-dispose 방지 (최근 탭 갔다 돌아올 때 로딩 스피너 방지).
class _PhrasesTab extends ConsumerStatefulWidget {
  const _PhrasesTab({this.onCopied});

  final VoidCallback? onCopied;

  @override
  ConsumerState<_PhrasesTab> createState() => _PhrasesTabState();
}

class _PhrasesTabState extends ConsumerState<_PhrasesTab>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 필터 변경 시 PageView 0페이지로 리셋 — build() 내 사이드 이펙트 방지.
    ref.listenManual(compactPhraseFilterNotifierProvider, (_, __) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      _currentPage.value = 0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 필수

    final filterAsync = ref.watch(compactPhraseFilterNotifierProvider);
    final packsAsync = ref.watch(allPhrasesProvider);
    final phrasesAsync = ref.watch(filteredCompactPhrasesProvider);
    final lockedAsync = ref.watch(isSelectedPackLockedProvider);

    final filter =
        filterAsync.valueOrNull ?? const CompactPhraseFilter.favorites();
    final isFavoritesSelected = filter == const CompactPhraseFilter.favorites();
    final isMyIdolSelected = filter == const CompactPhraseFilter.myIdol();
    final isTodaySelected = filter == const CompactPhraseFilter.today();
    final selectedPackId = filter.whenOrNull(pack: (id) => id);

    // 마이 아이돌 설정 여부 — 칩 표시 조건
    final idolNameAsync = ref.watch(myIdolDisplayNameProvider);
    final idolName = idolNameAsync.valueOrNull;
    final hasIdol = idolName != null;
    final memberName = ref.watch(myIdolMemberNameProvider).valueOrNull;

    // 마이 아이돌 칩 레이블: ♡ {멤버명 or 그룹명}
    final myIdolLabel = hasIdol
        ? UiStrings.phrasesMyIdolChip(memberName ?? idolName)
        : null;

    // "오늘" 칩 표시 조건 — 오늘 이벤트가 있는지
    final todayAsync = ref.watch(todaySuggestedPhrasesProvider);
    final hasToday = (todayAsync.valueOrNull ?? []).isNotEmpty;

    return Column(
      children: [
        // 팩 필터 칩 바
        packsAsync.when(
          data: (packs) => PackFilterChips(
            // 템플릿 전용 팩 제외 — 마이 아이돌 칩에서만 사용
            packs: packs
                .where((p) => p.phrases.any((phrase) => !phrase.isTemplate))
                .toList(),
            isFavoritesSelected: isFavoritesSelected,
            selectedPackId: selectedPackId,
            onFavoritesSelected: () {
              ref
                  .read(compactPhraseFilterNotifierProvider.notifier)
                  .selectFavorites();
            },
            onPackSelected: (packId) {
              ref
                  .read(compactPhraseFilterNotifierProvider.notifier)
                  .selectPack(packId);
            },
            showMyIdolChip: hasIdol,
            myIdolLabel: myIdolLabel,
            isMyIdolSelected: isMyIdolSelected,
            onMyIdolSelected: () {
              ref
                  .read(compactPhraseFilterNotifierProvider.notifier)
                  .selectMyIdol();
            },
            showTodayChip: hasToday,
            isTodaySelected: isTodaySelected,
            onTodaySelected: () {
              ref
                  .read(compactPhraseFilterNotifierProvider.notifier)
                  .selectToday();
            },
          ),
          loading: () => const SizedBox(height: 36),
          error: (_, __) => const SizedBox(height: 36),
        ),
        // 문구 콘텐츠
        Expanded(
          child: _buildPhraseContent(
            context,
            phrasesAsync,
            lockedAsync,
            useList: isFavoritesSelected || isMyIdolSelected || isTodaySelected,
            emptyMessage: isMyIdolSelected
                ? UiStrings.miniMyIdolEmpty
                : isTodaySelected
                    ? UiStrings.miniTodayEmpty
                    : isFavoritesSelected
                        ? UiStrings.miniFavoritesEmpty
                        : UiStrings.miniPackEmpty,
          ),
        ),
      ],
    );
  }

  Widget _buildPhraseContent(
    BuildContext context,
    AsyncValue<List<Phrase>> phrasesAsync,
    AsyncValue<bool> lockedAsync, {
    required bool useList,
    required String emptyMessage,
  }) {
    // 잠금 팩
    final isLocked = lockedAsync.valueOrNull ?? false;
    if (isLocked) {
      return const Center(
        child: Text(
          UiStrings.miniPackLocked,
          textAlign: TextAlign.center,
        ),
      );
    }

    return phrasesAsync.when(
      // 이전 데이터가 있으면 로딩 중에도 이전 데이터 표시 (스피너 방지)
      skipLoadingOnRefresh: true,
      data: (phrases) {
        if (phrases.isEmpty) {
          return Center(
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
            ),
          );
        }

        // 즐겨찾기/마이아이돌/오늘: 세로 리스트, 팩 문구: 좌우 스와이프 카드
        if (useList) {
          return _buildVerticalList(phrases);
        }
        return _buildPackSwiper(context, phrases);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text(UiStrings.miniPackEmpty)),
    );
  }

  /// 즐겨찾기 / 마이아이돌 / 오늘 — 세로 리스트.
  Widget _buildVerticalList(List<Phrase> phrases) {
    return ListView.builder(
      itemCount: phrases.length,
      itemBuilder: (context, index) {
        return CompactPhraseTile(
          phrase: phrases[index],
          onCopied: widget.onCopied,
        );
      },
    );
  }

  /// 팩 문구 — 좌우 스와이프 카드 + 페이지 인디케이터.
  Widget _buildPackSwiper(BuildContext context, List<Phrase> phrases) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: phrases.length,
            onPageChanged: (page) => _currentPage.value = page,
            itemBuilder: (context, index) {
              return _PhraseCard(
                phrase: phrases[index],
                onCopied: widget.onCopied,
              );
            },
          ),
        ),
        // 페이지 인디케이터
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: ValueListenableBuilder<int>(
            valueListenable: _currentPage,
            builder: (context, page, _) {
              return Text(
                '${page + 1} / ${phrases.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 팩 문구 카드 — 좌우 스와이프 PageView 내 개별 카드.
///
/// 중앙 정렬된 ko + roman + 하단 ★/복사 버튼.
class _PhraseCard extends ConsumerWidget {
  const _PhraseCard({
    required this.phrase,
    this.onCopied,
  });

  final Phrase phrase;
  final VoidCallback? onCopied;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favorites =
        ref.watch(favoritePhrasesNotifierProvider).valueOrNull ?? {};
    final isFavorite = favorites.contains(phrase.ko);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 한글 문구
          Text(
            phrase.ko,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (phrase.roman.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              phrase.roman,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          // 액션 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isFavorite ? theme.colorScheme.primary : null,
                ),
                tooltip: UiStrings.favoriteTooltip,
                onPressed: () {
                  ref
                      .read(favoritePhrasesNotifierProvider.notifier)
                      .toggle(phrase.ko);
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                tooltip: UiStrings.copyTooltip,
                onPressed: () => _copy(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copy(BuildContext context, WidgetRef ref) {
    Clipboard.setData(ClipboardData(text: phrase.ko));
    ref.read(copyHistoryNotifierProvider.notifier).addEntry(phrase.ko);
    CopyFeedback.trigger(context);
    // 피드백이 잠시 보인 후 닫기
    Future.delayed(const Duration(milliseconds: 400), () {
      onCopied?.call();
    });
  }
}
