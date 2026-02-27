import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/entities/phrase_pack.dart';
import 'package:fangeul/presentation/providers/phrase_providers.dart';
import 'package:fangeul/presentation/widgets/phrase_card.dart';
import 'package:fangeul/presentation/widgets/tag_filter_chips.dart';

/// 선택된 태그 필터 상태 Provider.
///
/// null이면 '전체' 선택. Riverpod으로 관리하여 setState 사용을 회피한다.
final selectedTagProvider = StateProvider<String?>((ref) => null);

/// 문구 화면 -- 팬 문구 라이브러리.
///
/// 태그 필터 칩으로 카테고리를 선택하고, 해당 문구 목록을 표시한다.
class PhrasesScreen extends ConsumerWidget {
  /// Creates the [PhrasesScreen] widget.
  const PhrasesScreen({super.key});

  static const _availableTags = [
    'love',
    'cheer',
    'daily',
    'greeting',
    'emotional',
    'praise',
    'fandom',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTag = ref.watch(selectedTagProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('문구')),
      body: Column(
        children: [
          // 태그 필터
          TagFilterChips(
            tags: _availableTags,
            selectedTag: selectedTag,
            onTagSelected: (tag) =>
                ref.read(selectedTagProvider.notifier).state = tag,
          ),
          const SizedBox(height: 8),
          // 문구 리스트
          Expanded(
            child: selectedTag == null
                ? _buildAllPhrases(ref)
                : _buildFilteredPhrases(ref, selectedTag),
          ),
        ],
      ),
    );
  }

  /// 전체 문구 (팩 기반) 표시.
  Widget _buildAllPhrases(WidgetRef ref) {
    final packsAsync = ref.watch(allPhrasesProvider);

    return packsAsync.when(
      data: (packs) {
        final phrases = _flattenPacks(packs);
        if (phrases.isEmpty) {
          return const Center(child: Text('문구가 없습니다'));
        }
        return ListView.builder(
          itemCount: phrases.length,
          itemBuilder: (context, index) => PhraseCard(
            phrase: phrases[index],
            translationLang: 'en',
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류: $e')),
    );
  }

  /// 태그 필터링된 문구 표시.
  Widget _buildFilteredPhrases(WidgetRef ref, String tag) {
    final phrasesAsync = ref.watch(phrasesByTagProvider(tag));

    return phrasesAsync.when(
      data: (phrases) {
        if (phrases.isEmpty) {
          return const Center(child: Text('문구가 없습니다'));
        }
        return ListView.builder(
          itemCount: phrases.length,
          itemBuilder: (context, index) => PhraseCard(
            phrase: phrases[index],
            translationLang: 'en',
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류: $e')),
    );
  }

  /// 무료 팩의 문구를 평탄화하여 단일 리스트로 변환.
  List<Phrase> _flattenPacks(List<PhrasePack> packs) {
    return packs
        .where((pack) => pack.isFree)
        .expand((pack) => pack.phrases)
        .toList();
  }
}
